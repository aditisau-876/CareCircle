from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from ..services.matching import helper_has_schedule_conflict
from .auth import get_current_user


router = APIRouter(prefix="/api/helper", tags=["Helper"])


class AvailabilityUpdate(schemas.BaseModel):
    is_available: bool


def require_helper(current_user: models.User) -> None:
    if current_user.role != "helper":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This endpoint is only for helper accounts.",
        )


def get_own_profile(db: Session, user_id: int):
    return (
        db.query(models.HelperProfile)
        .filter(models.HelperProfile.user_id == user_id)
        .first()
    )


def require_own_profile(db: Session, user_id: int):
    profile = get_own_profile(db, user_id)

    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Helper profile not found. Create your profile first.",
        )

    return profile


def get_owned_offer(
    db: Session,
    offer_id: int,
    helper_profile_id: int,
):
    offer = (
        db.query(models.HelperOffer)
        .filter(
            models.HelperOffer.id == offer_id,
            models.HelperOffer.helper_profile_id == helper_profile_id,
        )
        .with_for_update()
        .first()
    )

    if offer is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Offer not found.",
        )

    return offer


def offer_to_response(offer, care_request):
    data = schemas.CareRequestRead.model_validate(
        care_request
    ).model_dump()

    data.update({
        "offer_id": offer.id,
        "offer_status": offer.status,
        "distance_km": offer.distance_km,
        "expires_at": offer.expires_at,
    })

    return data


@router.get("/profile", response_model=schemas.HelperProfileRead)
def get_helper_profile(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)
    profile = require_own_profile(db, current_user.id)

    if profile.verification_status != "verified" and profile.is_available:
        profile.is_available = False
        db.commit()
        db.refresh(profile)

    return profile


@router.put("/profile", response_model=schemas.HelperProfileRead)
def save_helper_profile(
    data: schemas.HelperProfileCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)

    if (data.latitude is None) != (data.longitude is None):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Both latitude and longitude must be supplied together.",
        )

    try:
        profile = get_own_profile(db, current_user.id)

        if profile is None:
            profile = models.HelperProfile(
                user_id=current_user.id,
                address=data.address,
                skills=data.skills,
                languages=data.languages,
                service_radius_km=data.service_radius_km,
                latitude=data.latitude,
                longitude=data.longitude,
                is_available=False,
                verification_status="pending",
            )
            db.add(profile)
        else:
            profile.address = data.address
            profile.skills = data.skills
            profile.languages = data.languages
            profile.service_radius_km = data.service_radius_km
            profile.latitude = data.latitude
            profile.longitude = data.longitude

            if profile.verification_status != "verified":
                profile.is_available = False

        db.commit()
        db.refresh(profile)

        return profile

    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not save the helper profile.",
        ) from exc


@router.patch("/availability")
def update_availability(
    data: AvailabilityUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)

    try:
        profile = require_own_profile(db, current_user.id)

        if data.is_available and profile.verification_status != "verified":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "Your helper account must be verified before "
                    "you can become available."
                ),
            )

        profile.is_available = data.is_available
        db.commit()
        db.refresh(profile)

        return {
            "message": (
                "You are now available for requests."
                if profile.is_available
                else "You are now unavailable for new requests."
            ),
            "is_available": profile.is_available,
        }

    except HTTPException:
        db.rollback()
        raise
    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not update availability.",
        ) from exc


@router.get(
    "/offers",
    response_model=list[schemas.HelperOfferRead],
)
def get_my_offers(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)
    profile = require_own_profile(db, current_user.id)

    now = datetime.now(timezone.utc)

    offers = (
        db.query(models.HelperOffer)
        .filter(
            models.HelperOffer.helper_profile_id == profile.id,
            models.HelperOffer.status == "pending",
            models.HelperOffer.expires_at > now,
        )
        .order_by(models.HelperOffer.created_at.desc())
        .all()
    )

    results = []

    for offer in offers:
        care_request = db.get(
            models.CareRequest,
            offer.care_request_id,
        )

        if care_request is not None and care_request.status == "offered":
            results.append(offer_to_response(offer, care_request))

    return results


@router.post(
    "/offers/{offer_id}/accept",
    response_model=schemas.CareRequestRead,
)
def accept_offer(
    offer_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)

    try:
        profile = require_own_profile(db, current_user.id)

        offer = get_owned_offer(db, offer_id, profile.id)

        now = datetime.now(timezone.utc)

        if offer.status != "pending":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This offer has already been answered.",
            )

        if offer.expires_at <= now:
            offer.status = "expired"
            offer.responded_at = now
            db.commit()

            raise HTTPException(
                status_code=status.HTTP_410_GONE,
                detail="This offer has expired.",
            )

        if profile.verification_status != "verified":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Your helper profile is not verified.",
            )

        if not profile.is_available:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="You are currently unavailable.",
            )

        care_request = (
            db.query(models.CareRequest)
            .filter(models.CareRequest.id == offer.care_request_id)
            .with_for_update()
            .first()
        )

        if care_request is None or care_request.status != "offered":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This request is no longer available.",
            )

        if helper_has_schedule_conflict(
            db,
            profile.id,
            care_request,
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    "You already have another request scheduled "
                    "during this time."
                ),
            )

        care_request.helper_id = profile.id
        care_request.status = "assigned"

        offer.status = "accepted"
        offer.responded_at = now

        other_offers = (
            db.query(models.HelperOffer)
            .filter(
                models.HelperOffer.care_request_id == care_request.id,
                models.HelperOffer.id != offer.id,
                models.HelperOffer.status == "pending",
            )
            .all()
        )

        for other in other_offers:
            other.status = "expired"
            other.responded_at = now

        db.add(
            models.CareStatusEvent(
                care_request_id=care_request.id,
                status="assigned",
                note="A verified helper accepted the care request.",
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
            detail="Could not accept this offer.",
        ) from exc


@router.post(
    "/offers/{offer_id}/reject",
    response_model=schemas.HelperOfferActionRead,
)
def reject_offer(
    offer_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)

    try:
        profile = require_own_profile(db, current_user.id)
        offer = get_owned_offer(db, offer_id, profile.id)

        if offer.status != "pending":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This offer has already been answered.",
            )

        now = datetime.now(timezone.utc)

        offer.status = "rejected"
        offer.responded_at = now

        db.add(
            models.CareStatusEvent(
                care_request_id=offer.care_request_id,
                status="offer_rejected",
                note=f"Helper profile {profile.id} declined the offer.",
            )
        )

        db.commit()

        return schemas.HelperOfferActionRead(
            offer_id=offer.id,
            offer_status=offer.status,
            message="You have declined this care request.",
        )

    except HTTPException:
        db.rollback()
        raise
    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not reject this offer.",
        ) from exc


@router.get(
    "/my-requests",
    response_model=list[schemas.CareRequestRead],
)
def get_my_requests(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)
    profile = require_own_profile(db, current_user.id)

    active_statuses = [
        "assigned",
        "on_the_way",
        "arrived",
        "in_progress",
    ]

    return (
        db.query(models.CareRequest)
        .filter(
            models.CareRequest.helper_id == profile.id,
            models.CareRequest.status.in_(active_statuses),
        )
        .order_by(
            models.CareRequest.scheduled_date.asc(),
            models.CareRequest.scheduled_time.asc(),
        )
        .all()
    )


@router.get(
    "/completed-requests",
    response_model=list[schemas.CareRequestRead],
)
def get_completed_requests(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)
    profile = require_own_profile(db, current_user.id)

    return (
        db.query(models.CareRequest)
        .filter(
            models.CareRequest.helper_id == profile.id,
            models.CareRequest.status == "completed",
        )
        .order_by(models.CareRequest.id.desc())
        .all()
    )