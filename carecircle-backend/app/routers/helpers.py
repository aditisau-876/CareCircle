
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from .auth import get_current_user


router = APIRouter(prefix="/api/helper", tags=["Helper"])


class AvailabilityUpdate(BaseModel):
    is_available: bool


def require_helper(current_user: models.User):
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

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Helper profile not found. Create your profile first.",
        )

    return profile


# ---------------------------------------------------------
# Get the signed-in helper's profile
# ---------------------------------------------------------

@router.get("/profile", response_model=schemas.HelperProfileRead)
def get_helper_profile(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)

    return require_own_profile(db, current_user.id)


# ---------------------------------------------------------
# Create or update the signed-in helper's profile
# ---------------------------------------------------------

@router.put("/profile", response_model=schemas.HelperProfileRead)
def save_helper_profile(
    data: schemas.HelperProfileCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)

    if data.service_radius_km <= 0:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Service radius must be greater than zero.",
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
                is_available=True,
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

        db.commit()
        db.refresh(profile)
        return profile

    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not save the helper profile.",
        )


# ---------------------------------------------------------
# Change helper availability
# ---------------------------------------------------------

@router.patch("/availability")
def update_availability(
    data: AvailabilityUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)

    try:
        profile = require_own_profile(db, current_user.id)

        if profile.verification_status != "verified" and data.is_available:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "Your helper account must be verified before "
                    "you can become available for requests."
                ),
            )

        profile.is_available = data.is_available
        db.commit()

        return {
            "message": (
                "You are now available for requests."
                if profile.is_available
                else "You are now unavailable for new requests."
            ),
            "is_available": profile.is_available,
        }

    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not update availability.",
        )


# ---------------------------------------------------------
# View incoming offers for this helper
# ---------------------------------------------------------

@router.get("/offers", response_model=list[schemas.CareRequestRead])
def get_my_offers(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_helper(current_user)

    profile = require_own_profile(db, current_user.id)

    return (
        db.query(models.CareRequest)
        .filter(
            models.CareRequest.helper_id == profile.id,
            models.CareRequest.status == "offered",
        )
        .order_by(
            models.CareRequest.scheduled_date.asc(),
            models.CareRequest.scheduled_time.asc(),
        )
        .all()
    )


# ---------------------------------------------------------
# View accepted and active care requests
# ---------------------------------------------------------

@router.get("/my-requests", response_model=list[schemas.CareRequestRead])
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


# ---------------------------------------------------------
# View completed requests for this helper
# ---------------------------------------------------------

@router.get("/completed-requests", response_model=list[schemas.CareRequestRead])
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
