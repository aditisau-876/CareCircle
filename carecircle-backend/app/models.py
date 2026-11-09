from datetime import date, datetime, time

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    Time,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from .database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    full_name: Mapped[str] = mapped_column(String(120), nullable=False)
    email: Mapped[str | None] = mapped_column(
        String(255), unique=True, index=True, nullable=True
    )
    phone: Mapped[str | None] = mapped_column(
        String(25), unique=True, index=True, nullable=True
    )
    role: Mapped[str] = mapped_column(String(30), nullable=False)
    password_hash: Mapped[str] = mapped_column(
        String(255), nullable=False
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )


class CareRecipient(Base):
    __tablename__ = "care_recipients"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    family_user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id"), nullable=True, index=True
    )
    full_name: Mapped[str] = mapped_column(
        String(120), nullable=False
    )
    age: Mapped[int | None] = mapped_column(
        Integer, nullable=True
    )
    relationship_to_family: Mapped[str | None] = mapped_column(
        String(60), nullable=True
    )
    address: Mapped[str] = mapped_column(
        String(500), nullable=False
    )
    latitude: Mapped[float | None] = mapped_column(
        Float, nullable=True
    )
    longitude: Mapped[float | None] = mapped_column(
        Float, nullable=True
    )
    preferred_language: Mapped[str | None] = mapped_column(
        String(60), nullable=True
    )
    mobility_needs: Mapped[str | None] = mapped_column(
        String(150), nullable=True
    )
    emergency_contact_name: Mapped[str | None] = mapped_column(
        String(120), nullable=True
    )
    emergency_contact_phone: Mapped[str | None] = mapped_column(
        String(25), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )


class HelperProfile(Base):
    __tablename__ = "helper_profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"), unique=True, index=True
    )
    address: Mapped[str] = mapped_column(
        String(500), nullable=False
    )
    latitude: Mapped[float | None] = mapped_column(
        Float, nullable=True
    )
    longitude: Mapped[float | None] = mapped_column(
        Float, nullable=True
    )
    skills: Mapped[str] = mapped_column(
        Text, nullable=False, default=""
    )
    languages: Mapped[str] = mapped_column(
        Text, nullable=False, default=""
    )
    service_radius_km: Mapped[int] = mapped_column(
        Integer, nullable=False, default=5
    )
    is_available: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False
    )
    verification_status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="pending"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )


class CareRequest(Base):
    __tablename__ = "care_requests"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)

    family_user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id"), nullable=True, index=True
    )
    recipient_id: Mapped[int | None] = mapped_column(
        ForeignKey("care_recipients.id"), nullable=True, index=True
    )
    helper_id: Mapped[int | None] = mapped_column(
        ForeignKey("helper_profiles.id"), nullable=True, index=True
    )

    elderly_name: Mapped[str] = mapped_column(
        String(120), nullable=False
    )
    service: Mapped[str] = mapped_column(
        String(100), nullable=False
    )
    address: Mapped[str] = mapped_column(
        String(500), nullable=False
    )
    latitude: Mapped[float | None] = mapped_column(
        Float, nullable=True
    )
    longitude: Mapped[float | None] = mapped_column(
        Float, nullable=True
    )
    scheduled_date: Mapped[date] = mapped_column(
        Date, nullable=False
    )
    scheduled_time: Mapped[time] = mapped_column(
        Time, nullable=False
    )
    duration: Mapped[str | None] = mapped_column(
        String(50), nullable=True
    )
    mobility: Mapped[str | None] = mapped_column(
        String(150), nullable=True
    )
    language: Mapped[str | None] = mapped_column(
        String(60), nullable=True
    )
    instructions: Mapped[str] = mapped_column(
        Text, nullable=False, default=""
    )
    family_sharing: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=True
    )
    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="pending", index=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )


class HelperOffer(Base):
    __tablename__ = "helper_offers"

    __table_args__ = (
        UniqueConstraint(
            "care_request_id",
            "helper_profile_id",
            name="uq_helper_offer_request_helper",
        ),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)

    care_request_id: Mapped[int] = mapped_column(
        ForeignKey("care_requests.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    helper_profile_id: Mapped[int] = mapped_column(
        ForeignKey("helper_profiles.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="pending", index=True
    )

    distance_km: Mapped[float] = mapped_column(
        Float, nullable=False
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )

    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
    )

    responded_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )


class CareStatusEvent(Base):
    __tablename__ = "care_status_events"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)

    care_request_id: Mapped[int] = mapped_column(
        ForeignKey("care_requests.id"), index=True
    )

    status: Mapped[str] = mapped_column(
        String(30), nullable=False
    )

    note: Mapped[str | None] = mapped_column(
        String(500), nullable=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )