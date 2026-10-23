
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from .auth import get_current_user

router = APIRouter(prefix="/api/profiles", tags=["Profiles"])


def require_role(user: models.User, expected_role: str):
    if user.role != expected_role:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"This action requires the {expected_role} role",
        )


@router.post(
    "/recipients",
    response_model=schemas.CareRecipientRead,
    status_code=status.HTTP_201_CREATED,
)
def create_recipient(
    data: schemas.CareRecipientCreate,
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    require_role(user, "family")

    recipient = models.CareRecipient(
        family_user_id=user.id,
        **data.model_dump(),
    )

    db.add(recipient)

    try:
        db.commit()
        db.refresh(recipient)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Could not save the elderly profile",
        ) from exc

    return recipient


@router.get(
    "/recipients",
    response_model=list[schemas.CareRecipientRead],
)
def list_recipients(
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    require_role(user, "family")

    return (
        db.query(models.CareRecipient)
        .filter(models.CareRecipient.family_user_id == user.id)
        .order_by(models.CareRecipient.id.desc())
        .all()
    )


@router.post(
    "/helper",
    response_model=schemas.HelperProfileRead,
    status_code=status.HTTP_201_CREATED,
)
def create_helper_profile(
    data: schemas.HelperProfileCreate,
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    require_role(user, "helper")

    existing = (
        db.query(models.HelperProfile)
        .filter(models.HelperProfile.user_id == user.id)
        .first()
    )

    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A helper profile already exists for this account",
        )

    profile = models.HelperProfile(
        user_id=user.id,
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

    try:
        db.commit()
        db.refresh(profile)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Could not create the helper profile",
        ) from exc

    return profile


@router.get(
    "/helper/me",
    response_model=schemas.HelperProfileRead,
)
def get_my_helper_profile(
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    require_role(user, "helper")

    profile = (
        db.query(models.HelperProfile)
        .filter(models.HelperProfile.user_id == user.id)
        .first()
    )

    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Helper profile not found",
        )

    return profile
