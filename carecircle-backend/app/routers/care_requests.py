
import math

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from .auth import get_current_user

router = APIRouter(
    prefix="/api/care-requests",
    tags=["Care Requests"],
)


def require_family_user(current_user: models.User) -> models.User:
    if current_user.role != "family":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only family accounts can perform this operation",
        )
    return current_user


def distance_km(
    latitude_a: float,
    longitude_a: float,
    latitude_b: float,
    longitude_b: float,
) -> float:
    """Calculate the approximate great-circle distance between two points."""
    earth_radius_km = 6371.0088

    lat_a = math.radians(latitude_a)
    lat_b = math.radians(latitude_b)
    delta_lat = math.radians(latitude_b - latitude_a)
    delta_lon = math.radians(longitude_b - longitude_a)

    a = (
        math.sin(delta_lat / 2) ** 2
        + math.cos(lat_a)
        * math.cos(lat_b)
        * math.sin(delta_lon / 2) ** 2
    )

    a = min(1.0, max(0.0, a))
    return 2 * earth_radius_km * math.asin(math.sqrt(a))


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

    saved_request = models.CareRequest(
        family_user_id=current_user.id,
        **request.model_dump(),
    )

    try:
        db.add(saved_request)
        db.flush()

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
        .filter(models.CareRequest.family_user_id == current_user.id)
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

        if care_request.status not in {"pending", "assigned"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    f"Cannot cancel a request with status "
                    f"'{care_request.status}'"
                ),
            )

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

    except HTTPException:
        db.rollback()
        raise
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

        # Require coordinates for location-based assignment.
        if (
            care_request.latitude is None
            or care_request.longitude is None
            or helper.latitude is None
            or helper.longitude is None
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    "Location coordinates are required for both the care "
                    "request and helper profile before assignment"
                ),
            )

        distance = distance_km(
            care_request.latitude,
            care_request.longitude,
            helper.latitude,
            helper.longitude,
        )

        if distance > helper.service_radius_km:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    "This helper is outside their service radius "
                    f"({distance:.1f} km away)"
                ),
            )

        care_request.helper_id = helper.id
        care_request.status = "assigned"

        db.add(
            models.CareStatusEvent(
                care_request_id=care_request.id,
                status="assigned",
                note=(
                    "Helper assigned after verification, availability, "
                    "and service-radius checks"
                ),
            )
        )

        db.commit()
        db.refresh(care_request)
        return care_request

    except HTTPException:
        db.rollback()
        raise
    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not assign the helper",
        ) from exc
