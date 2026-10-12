
from datetime import datetime, timedelta
from math import asin, cos, radians, sin, sqrt
import re


ACTIVE_STATUSES = {
    "offered",
    "assigned",
    "on_the_way",
    "arrived",
    "in_progress",
}


def distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate the approximate great-circle distance in kilometres."""
    earth_radius_km = 6371.0

    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)

    a = (
        sin(dlat / 2) ** 2
        + cos(radians(lat1))
        * cos(radians(lat2))
        * sin(dlon / 2) ** 2
    )

    return earth_radius_km * 2 * asin(sqrt(min(1.0, a)))


def duration_minutes(value: str | None) -> int:
    """
    Accept common values such as '1 hour', '90 minutes',
    '1.5 hours', or '01:30'. Unknown values default to 60 minutes.
    """
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
    """Adjacent appointments are allowed; overlapping ones are not."""
    return first_start < second_end and second_start < first_end
