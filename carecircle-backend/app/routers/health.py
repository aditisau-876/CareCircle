
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from ..database import get_db

router = APIRouter(tags=["Health"])


@router.get("/")
def root():
    return {
        "message": "CareCircle API is running",
        "docs": "/docs",
        "health": "/health",
    }


@router.get("/health")
def health_check():
    return {
        "status": "healthy",
        "app": "CareCircle",
    }


@router.get("/health/database")
def database_health(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
        return {
            "status": "connected",
            "database": "available",
        }
    except SQLAlchemyError as exc:
        raise HTTPException(
            status_code=503,
            detail="Database connection failed",
        ) from exc
