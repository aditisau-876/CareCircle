import os
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jwt.exceptions import InvalidTokenError
from pwdlib import PasswordHash
from sqlalchemy import or_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/api/auth", tags=["Authentication"])

password_hash = PasswordHash.recommended()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")

SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
TOKEN_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))

if not SECRET_KEY:
    raise RuntimeError("JWT_SECRET_KEY is missing from .env")


def create_access_token(user_id: int) -> str:
    expires = datetime.now(timezone.utc) + timedelta(
        minutes=TOKEN_MINUTES
    )
    payload = {
        "sub": str(user_id),
        "exp": expires,
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


@router.post(
    "/register",
    response_model=schemas.AuthResponse,
    status_code=status.HTTP_201_CREATED,
)
def register_user(
    data: schemas.UserRegister,
    db: Session = Depends(get_db),
):
    email = str(data.email).lower()

    existing_user = db.query(models.User).filter(
        or_(
            models.User.email == email,
            models.User.phone == data.phone
            if data.phone
            else False,
        )
    ).first()

    if existing_user:
        raise HTTPException(
            status_code=409,
            detail="An account with this email or phone already exists",
        )

    user = models.User(
        full_name=data.full_name.strip(),
        email=email,
        phone=data.phone,
        role=data.role,
        password_hash=password_hash.hash(data.password),
    )

    try:
        db.add(user)
        db.commit()
        db.refresh(user)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="An account with these details already exists",
        ) from exc

    return schemas.AuthResponse(
        access_token=create_access_token(user.id),
        user=user,
    )


@router.post("/login", response_model=schemas.AuthResponse)
def login_user(
    data: schemas.UserLogin,
    db: Session = Depends(get_db),
):
    email = str(data.email).lower()

    user = db.query(models.User).filter(
        models.User.email == email
    ).first()

    if (
        user is None
        or not password_hash.verify(data.password, user.password_hash)
    ):
        raise HTTPException(
            status_code=401,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(
            status_code=403,
            detail="This account is inactive",
        )

    return schemas.AuthResponse(
        access_token=create_access_token(user.id),
        user=user,
    )


@router.post("/token")
def login_for_swagger(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    # OAuth2 calls the email field "username".
    email = form_data.username.strip().lower()

    user = db.query(models.User).filter(
        models.User.email == email
    ).first()

    if (
        user is None
        or not password_hash.verify(
            form_data.password,
            user.password_hash,
        )
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This account is inactive",
        )

    return {
        "access_token": create_access_token(user.id),
        "token_type": "bearer",
    }


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> models.User:
    credentials_error = HTTPException(
        status_code=401,
        detail="Invalid or expired access token",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM],
        )
        subject = payload.get("sub")

        if not subject:
            raise credentials_error

        user_id = int(subject)
    except (InvalidTokenError, ValueError, TypeError) as exc:
        raise credentials_error from exc

    user = db.get(models.User, user_id)

    if user is None or not user.is_active:
        raise credentials_error

    return user


@router.get("/me", response_model=schemas.UserRead)
def get_my_account(
    current_user: models.User = Depends(get_current_user),
):
    return current_user
