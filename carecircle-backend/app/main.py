from contextlib import asynccontextmanager
from fastapi import FastAPI
from . import models
from .database import Base, engine
from .routers import auth, care_requests, health, helpers, profiles,tracking
@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="CareCircle API",
    description="Backend for the CareCircle mobile care coordination app.",
    version="0.1.0",
    lifespan=lifespan,
)

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(care_requests.router)
app.include_router(profiles.router)
app.include_router(helpers.router)
app.include_router(tracking.router)