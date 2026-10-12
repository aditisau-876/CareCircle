
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from .auth import get_current_user


router = APIRouter(prefix="/api/tracking", tags=["Care Tracking"])


def require_family(current_user: models.User):
    if current_user.role != "family":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only family accounts can access this tracking view.",
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
        .first()
    )

    if not care_request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Care request not found.",
        )

    return care_request


@router.get(
    "/{request_id}",
    response_model=schemas.CareTrackingRead,
)
def get_care_tracking(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_family(current_user)

    care_request = get_owned_request(
        db,
        request_id,
        current_user.id,
    )

    helper_details = None

    if care_request.helper_id is not None:
        helper_profile = (
            db.query(models.HelperProfile)
            .filter(
                models.HelperProfile.id == care_request.helper_id
            )
            .first()
        )

        if helper_profile:
            helper_user = (
                db.query(models.User)
                .filter(
                    models.User.id == helper_profile.user_id,
                    models.User.is_active.is_(True),
                )
                .first()
            )

            if helper_user:
                helper_details = schemas.TrackingHelperRead(
                    full_name=helper_user.full_name
                )

    history = (
        db.query(models.CareStatusEvent)
        .filter(
            models.CareStatusEvent.care_request_id == care_request.id
        )
        .order_by(models.CareStatusEvent.created_at.asc())
        .all()
    )

    return schemas.CareTrackingRead(
        request=care_request,
        helper=helper_details,
        history=history,
    )


@router.get(
    "/{request_id}/history",
    response_model=list[schemas.CareStatusEventRead],
)
def get_care_request_history(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    require_family(current_user)

    care_request = get_owned_request(
        db,
        request_id,
        current_user.id,
    )

    return (
        db.query(models.CareStatusEvent)
        .filter(
            models.CareStatusEvent.care_request_id == care_request.id
        )
        .order_by(models.CareStatusEvent.created_at.asc())
        .all()
    )


@router.get(
    "/notifications/recent",
    response_model=list[schemas.CareNotificationRead],
)
def get_recent_notifications(
    limit: int = 30,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    if current_user.role == "family":
        query = (
            db.query(
                models.CareStatusEvent,
                models.CareRequest,
            )
            .join(
                models.CareRequest,
                models.CareRequest.id
                == models.CareStatusEvent.care_request_id,
            )
            .filter(
                models.CareRequest.family_user_id == current_user.id
            )
        )

    elif current_user.role == "helper":
        helper = (
            db.query(models.HelperProfile)
            .filter(
                models.HelperProfile.user_id == current_user.id
            )
            .first()
        )

        if not helper:
            return []

        query = (
            db.query(
                models.CareStatusEvent,
                models.CareRequest,
            )
            .join(
                models.CareRequest,
                models.CareRequest.id
                == models.CareStatusEvent.care_request_id,
            )
            .filter(
                models.CareRequest.helper_id == helper.id
            )
        )

    else:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Notifications are not available for this account role.",
        )

    records = (
        query
        .order_by(models.CareStatusEvent.created_at.desc())
        .limit(max(1, min(limit, 100)))
        .all()
    )

    notifications = []

    for event, care_request in records:
        notifications.append(
            schemas.CareNotificationRead(
                request_id=care_request.id,
                elderly_name=care_request.elderly_name,
                service=care_request.service,
                status=event.status,
                message=(
                    event.note
                    or f"Request status updated to {event.status}."
                ),
                created_at=event.created_at,
            )
        )

    return notifications
