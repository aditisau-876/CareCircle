
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from sqlalchemy import select
from .. import models, schemas
from ..database import get_db
from .auth import get_current_user

router = APIRouter(
    prefix="/api/care-requests",
    tags=["Care Requests"],
)


def require_family_user(
    current_user: models.User,
) -> models.User:
    """Allow care-request operations only for family accounts."""
    if current_user.role != "family":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only family accounts can perform this operation",
        )

    return current_user


@router.post(
    "",
    response_model=schemas.CareRequestRead,
    status_code=status.HTTP_201_CREATED,
)
def create_care_request(
    request: schemas.CareRequestCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_family_user(current_user)

    # The family owner comes from the verified access token,
    # never from the request body.
    saved_request = models.CareRequest(
        family_user_id=current_user.id,
        **request.model_dump(),
    )

    try:
        db.add(saved_request)
        db.flush()

        # Record the initial status in the same transaction.
        db.add(
            models.CareStatusEvent(
                care_request_id=saved_request.id,
                status="pending",
                note="Care request created",
            )
        )

        db.commit()
        db.refresh(saved_request)

        return saved_request

    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not save the care request",
        ) from exc


@router.get(
    "",
    response_model=list[schemas.CareRequestRead],
)
def list_care_requests(
    limit: int = 50,
    offset: int = 0,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_family_user(current_user)

    if limit < 1 or limit > 100 or offset < 0:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Use limit 1–100 and a non-negative offset",
        )

    return (
        db.query(models.CareRequest)
        .filter(
            models.CareRequest.family_user_id == current_user.id
        )
        .order_by(models.CareRequest.id.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )


@router.get(
    "/{request_id}",
    response_model=schemas.CareRequestRead,
)
def get_care_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_family_user(current_user)

    care_request = (
        db.query(models.CareRequest)
        .filter(
            models.CareRequest.id == request_id,
            models.CareRequest.family_user_id == current_user.id,
        )
        .first()
    )

    if care_request is None:
        # Do not reveal whether another family's request exists.
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Care request not found",
        )

    return care_request


@router.post(
    "/{request_id}/cancel",
    response_model=schemas.CareRequestRead,
)
def cancel_care_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_family_user(current_user)

    care_request = (
        db.query(models.CareRequest)
        .filter(
            models.CareRequest.id == request_id,
            models.CareRequest.family_user_id == current_user.id,
        )
        .with_for_update()
        .first()
    )

    if care_request is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Care request not found",
        )

    cancellable_statuses = {"pending", "assigned"}

    if care_request.status not in cancellable_statuses:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                f"Cannot cancel a request with status "
                f"'{care_request.status}'"
            ),
        )

    try:
        care_request.status = "cancelled"

        db.add(
            models.CareStatusEvent(
                care_request_id=care_request.id,
                status="cancelled",
                note="Care request cancelled by family",
            )
        )

        db.commit()
        db.refresh(care_request)

        return care_request

    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not cancel the care request",
        ) from exc


@router.post(
    "/{request_id}/assign-helper",
    response_model=schemas.CareRequestRead,
)
def assign_helper(
    request_id: int,
    assignment: schemas.HelperAssignmentRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_family_user(current_user)

    try:
        care_request = (
            db.query(models.CareRequest)
            .filter(
                models.CareRequest.id == request_id,
                models.CareRequest.family_user_id == current_user.id,
            )
            .with_for_update()
            .first()
        )

        if care_request is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Care request not found",
            )

        if care_request.status != "pending":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Only pending requests can be assigned",
            )

        helper = db.get(
            models.HelperProfile,
            assignment.helper_profile_id,
        )

        if helper is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Helper profile not found",
            )

        helper_user = db.get(models.User, helper.user_id)

        if (
            helper_user is None
            or not helper_user.is_active
            or helper_user.role != "helper"
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This profile is not linked to an active helper",
            )

        if helper.verification_status != "verified":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This helper has not been verified",
            )

        if not helper.is_available:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This helper is not currently available",
            )

        care_request.helper_id = helper.id
        care_request.status = "assigned"

        db.add(
            models.CareStatusEvent(
                care_request_id=care_request.id,
                status="assigned",
                note="Helper assigned to care request",
            )
        )

        db.commit()
        db.refresh(care_request)

        return care_request

    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not assign the helper",
        ) from exc

