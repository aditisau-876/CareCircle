from datetime import datetime, timedelta
from math import asin, cos, radians, sin, sqrt
import re

from sqlalchemy.orm import Session

from .. import models


ACTIVE_STATUSES = {
    "assigned",
    "on_the_way",
    "arrived",
    "in_progress",
}


def normalize_text(value: str | None) -> str:
    if not value:
        return ""

    value = value.lower().strip()
    value = value.replace("&", " and ")
    value = value.replace("/", " ")
    value = re.sub(r"[^a-z0-9]+", " ", value)

    return " ".join(value.split())


def service_matches(requested_service: str, helper_skills: str) -> bool:
    requested = normalize_text(requested_service)
    skills = [
        normalize_text(item)
        for item in helper_skills.split(",")
        if item.strip()
    ]

    aliases = {
        "accompaniment to hospital": {
            "accompaniment to hospital",
            "hospital accompaniment",
        },
        "document bill assistance": {
            "document bill assistance",
            "document assistance",
            "bill assistance",
        },
    }

    accepted = aliases.get(requested, {requested})

    return any(skill in accepted for skill in skills)


def language_matches(
    requested_language: str | None,
    helper_languages: str,
) -> bool:
    if not requested_language:
        return True

    requested = normalize_text(requested_language)

    languages = {
        normalize_text(item)
        for item in helper_languages.split(",")
        if item.strip()
    }

    return requested in languages or "other" in languages


def distance_km(
    latitude_a: float,
    longitude_a: float,
    latitude_b: float,
    longitude_b: float,
) -> float:
    earth_radius_km = 6371.0088

    lat_a = radians(latitude_a)
    lat_b = radians(latitude_b)
    delta_lat = radians(latitude_b - latitude_a)
    delta_lon = radians(longitude_b - longitude_a)

    a = (
        sin(delta_lat / 2) ** 2
        + cos(lat_a)
        * cos(lat_b)
        * sin(delta_lon / 2) ** 2
    )

    a = min(1.0, max(0.0, a))

    return 2 * earth_radius_km * asin(sqrt(a))


def duration_minutes(value: str | None) -> int:
    if not value:
        return 60

    text = value.strip().lower()

    clock = re.fullmatch(r"(\d{1,2}):(\d{2})", text)

    if clock:
        hours = int(clock.group(1))
        minutes = int(clock.group(2))
        total = hours * 60 + minutes

        return total if 0 < total <= 1440 else 60

    number = re.search(r"\d+(?:\.\d+)?", text)

    if not number:
        return 60

    amount = float(number.group())

    if amount <= 0:
        return 60

    if "hour" in text or re.search(r"\bhr\b|\bhrs\b", text):
        total = round(amount * 60)
    else:
        total = round(amount)

    return total if 0 < total <= 1440 else 60


def request_interval(request) -> tuple[datetime, datetime]:
    start = datetime.combine(
        request.scheduled_date,
        request.scheduled_time,
    )

    end = start + timedelta(
        minutes=duration_minutes(request.duration)
    )

    return start, end


def intervals_overlap(
    first_start: datetime,
    first_end: datetime,
    second_start: datetime,
    second_end: datetime,
) -> bool:
    return first_start < second_end and second_start < first_end


def helper_has_schedule_conflict(
    db: Session,
    helper_profile_id: int,
    new_request,
) -> bool:
    new_start, new_end = request_interval(new_request)

    existing_requests = (
        db.query(models.CareRequest)
        .filter(
            models.CareRequest.helper_id == helper_profile_id,
            models.CareRequest.status.in_(ACTIVE_STATUSES),
        )
        .all()
    )

    for existing in existing_requests:
        existing_start, existing_end = request_interval(existing)

        if intervals_overlap(
            new_start,
            new_end,
            existing_start,
            existing_end,
        ):
            return True

    return False


def find_eligible_helpers(
    db: Session,
    care_request,
) -> list[tuple[models.HelperProfile, float]]:
    if (
        care_request.latitude is None
        or care_request.longitude is None
    ):
        return []

    profiles = (
        db.query(models.HelperProfile)
        .join(
            models.User,
            models.User.id == models.HelperProfile.user_id,
        )
        .filter(
            models.User.is_active.is_(True),
            models.User.role == "helper",
            models.HelperProfile.verification_status == "verified",
            models.HelperProfile.is_available.is_(True),
        )
        .all()
    )

    matches = []

    for helper in profiles:
        if helper.latitude is None or helper.longitude is None:
            continue

        if not service_matches(
            care_request.service,
            helper.skills,
        ):
            continue

        if not language_matches(
            care_request.language,
            helper.languages,
        ):
            continue

        distance = distance_km(
            care_request.latitude,
            care_request.longitude,
            helper.latitude,
            helper.longitude,
        )

        if distance > helper.service_radius_km:
            continue

        if helper_has_schedule_conflict(
            db,
            helper.id,
            care_request,
        ):
            continue

        matches.append((helper, distance))

    matches.sort(key=lambda item: item[1])

    return matches