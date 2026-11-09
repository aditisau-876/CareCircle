from datetime import date, datetime, time
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, EmailStr


CareService = Literal[
    "Grocery pickup",
    "Medicine pickup",
    "Appointment assistance",
    "Accompaniment to hospital",
    "Household assistance",
    "Document/bill assistance",
    "Companionship",
    "Short walk assistance",
]


class CareRequestCreate(BaseModel):
    elderly_name: str = Field(min_length=1, max_length=120)
    service: CareService
    address: str = Field(min_length=5, max_length=500)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    scheduled_date: date
    scheduled_time: time
    duration: str | None = Field(default=None, max_length=50)
    mobility: str | None = Field(default=None, max_length=150)
    language: str | None = Field(default=None, max_length=60)
    instructions: str = Field(default="", max_length=1000)
    family_sharing: bool = True


class CareRequestRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    elderly_name: str
    service: str
    address: str
    latitude: float | None
    longitude: float | None
    scheduled_date: date
    scheduled_time: time
    duration: str | None
    mobility: str | None
    language: str | None
    instructions: str
    family_sharing: bool
    status: str
    created_at: datetime


class HealthResponse(BaseModel):
    status: str
    app: str


class UserRegister(BaseModel):
    full_name: str = Field(min_length=2, max_length=120)
    email: EmailStr
    phone: str | None = Field(default=None, max_length=25)
    password: str = Field(min_length=8, max_length=128)
    role: Literal["family", "elderly", "helper"]


class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class UserRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    full_name: str
    email: str | None
    phone: str | None
    role: str
    is_active: bool
    created_at: datetime


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserRead


class CareRecipientCreate(BaseModel):
    full_name: str = Field(min_length=2, max_length=120)
    age: int | None = Field(default=None, ge=18, le=120)
    relationship_to_family: str | None = Field(
        default=None, max_length=60
    )
    address: str = Field(min_length=5, max_length=500)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    preferred_language: str | None = Field(
        default=None, max_length=60
    )
    mobility_needs: str | None = Field(
        default=None, max_length=150
    )
    emergency_contact_name: str | None = Field(
        default=None, max_length=120
    )
    emergency_contact_phone: str | None = Field(
        default=None, max_length=25
    )


class CareRecipientRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    full_name: str
    age: int | None
    relationship_to_family: str | None
    address: str
    preferred_language: str | None
    mobility_needs: str | None
    emergency_contact_name: str | None
    emergency_contact_phone: str | None
    created_at: datetime


class HelperProfileCreate(BaseModel):
    address: str = Field(min_length=5, max_length=500)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    skills: str = Field(min_length=2, max_length=1000)
    languages: str = Field(min_length=2, max_length=500)
    service_radius_km: int = Field(default=5, ge=1, le=100)


class HelperProfileRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    address: str
    latitude: float | None
    longitude: float | None
    skills: str
    languages: str
    service_radius_km: int
    is_available: bool
    verification_status: str
    created_at: datetime


class HelperAssignmentRequest(BaseModel):
    helper_profile_id: int = Field(gt=0)


class FindHelpersResponse(BaseModel):
    request_id: int
    request_status: str
    offers_created: int
    message: str


class HelperOfferRead(CareRequestRead):
    offer_id: int
    offer_status: str
    distance_km: float
    expires_at: datetime


class HelperOfferActionRead(BaseModel):
    offer_id: int
    offer_status: str
    message: str


class CareStatusEventRead(BaseModel):
    id: int
    care_request_id: int
    status: str
    note: str | None = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class TrackingHelperRead(BaseModel):
    full_name: str


class CareTrackingRead(BaseModel):
    request: CareRequestRead
    helper: TrackingHelperRead | None = None
    history: list[CareStatusEventRead]


class CareNotificationRead(BaseModel):
    request_id: int
    elderly_name: str
    service: str
    status: str
    message: str
    created_at: datetime