from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from ..services.matching import find_eligible_helpers
from .auth import get_current_user


router = APIRouter(
    prefix="/api/care-requests",
    tags=["Care Requests"],
)


def require_family_user(current_user: models.User) -> None:
    if current_user.role != "family":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only family accounts can perform this operation.",
        )


def get_owned_request(
    db: Session,
    request_id: int,
    family_user_id: int,
):
    care_request = (
        db.query(models.CareRequest)
        .filter(
            models.CareRequest.id == request_id,
            models.CareRequest.family_user_id == family_user_id,
        )
        .with_for_update()
        .first()
    )

    if care_request is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Care request not found.",
        )

    return care_request


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

    if (request.latitude is None) != (request.longitude is None):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Both latitude and longitude must be supplied together.",
        )

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
                note="Care request created.",
            )
        )

        db.commit()
        db.refresh(saved_request)

        return saved_request

    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not save the care request.",
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
            detail="Use limit 1–100 and a non-negative offset.",
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

    return (
        db.query(models.CareRequest)
        .filter(
            models.CareRequest.id == request_id,
            models.CareRequest.family_user_id == current_user.id,
        )
        .first()
    ) or _not_found()


def _not_found():
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Care request not found.",
    )


@router.post(
    "/{request_id}/find-helpers",
    response_model=schemas.FindHelpersResponse,
)
def find_helpers_for_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_family_user(current_user)

    try:
        care_request = get_owned_request(
            db,
            request_id,
            current_user.id,
        )

        if care_request.status not in {"pending", "offered"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    "Matching can only be started for pending requests "
                    "that have not been assigned or cancelled."
                ),
            )

        if (
            care_request.latitude is None
            or care_request.longitude is None
        ):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=(
                    "This request does not have location coordinates. "
                    "Please add the care location before matching helpers."
                ),
            )

        existing_pending = (
            db.query(models.HelperOffer)
            .filter(
                models.HelperOffer.care_request_id == care_request.id,
                models.HelperOffer.status == "pending",
                models.HelperOffer.expires_at > datetime.now(timezone.utc),
            )
            .count()
        )

        if existing_pending:
            return schemas.FindHelpersResponse(
                request_id=care_request.id,
                request_status=care_request.status,
                offers_created=existing_pending,
                message="This request already has active helper offers.",
            )

        eligible = find_eligible_helpers(db, care_request)

        if not eligible:
            db.add(
                models.CareStatusEvent(
                    care_request_id=care_request.id,
                    status="no_helpers_found",
                    note=(
                        "No verified, available helper matched the "
                        "service, language, location and schedule."
                    ),
                )
            )
            db.commit()

            return schemas.FindHelpersResponse(
                request_id=care_request.id,
                request_status="pending",
                offers_created=0,
                message=(
                    "No eligible helpers were found. You can try again "
                    "after more helpers become available."
                ),
            )

        created_count = 0
        expires_at = datetime.now(timezone.utc) + timedelta(hours=24)

        for helper, distance in eligible:
            previous_offer = (
                db.query(models.HelperOffer)
                .filter(
                    models.HelperOffer.care_request_id == care_request.id,
                    models.HelperOffer.helper_profile_id == helper.id,
                )
                .first()
            )

            # Do not resend an offer already accepted, rejected or expired.
            if previous_offer is not None:
                continue

            db.add(
                models.HelperOffer(
                    care_request_id=care_request.id,
                    helper_profile_id=helper.id,
                    status="pending",
                    distance_km=round(distance, 2),
                    expires_at=expires_at,
                )
            )
            created_count += 1

        if created_count:
            care_request.status = "offered"

            db.add(
                models.CareStatusEvent(
                    care_request_id=care_request.id,
                    status="offered",
                    note=(
                        f"{created_count} helper offer(s) created "
                        "after eligibility checks."
                    ),
                )
            )

        db.commit()

        return schemas.FindHelpersResponse(
            request_id=care_request.id,
            request_status=care_request.status,
            offers_created=created_count,
            message=(
                f"{created_count} helper offer(s) have been sent."
                if created_count
                else (
                    "No new offers could be created. Previously contacted "
                    "helpers have already responded or received an offer."
                )
            ),
        )

    except HTTPException:
        db.rollback()
        raise
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Matching was already started for this request.",
        ) from exc
    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not match helpers for this request.",
        ) from exc


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
        care_request = get_owned_request(
            db,
            request_id,
            current_user.id,
        )

        if care_request.status not in {"pending", "offered", "assigned"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    f"Cannot cancel a request with status "
                    f"'{care_request.status}'."
                ),
            )

        care_request.status = "cancelled"

        pending_offers = (
            db.query(models.HelperOffer)
            .filter(
                models.HelperOffer.care_request_id == care_request.id,
                models.HelperOffer.status == "pending",
            )
            .all()
        )

        for offer in pending_offers:
            offer.status = "expired"
            offer.responded_at = datetime.now(timezone.utc)

        db.add(
            models.CareStatusEvent(
                care_request_id=care_request.id,
                status="cancelled",
                note="Care request cancelled by family.",
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
            detail="Could not cancel the care request.",
        ) from exc