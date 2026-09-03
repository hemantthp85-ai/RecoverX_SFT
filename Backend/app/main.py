from fastapi import FastAPI

from app.core.config import settings

from app.api.auth import router as auth_router
from app.api.progress import router as progress_router
from app.api.recovery import router as recovery_router
from app.api.report import router as report_router
from app.api.sensor import router as sensor_router


from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="RecoverX Backend",
    description="Backend API for the RecoverX smart recovery system",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    # Read allowed origins from the ALLOWED_ORIGINS env variable (comma-separated).
    # Example: ALLOWED_ORIGINS=http://localhost:3000,https://recoverx.app
    allow_origins=[o.strip() for o in settings.ALLOWED_ORIGINS.split(",")],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)

app.include_router(auth_router)
app.include_router(progress_router)
app.include_router(recovery_router)
app.include_router(report_router)
app.include_router(sensor_router)


@app.get("/")
async def root():
    return {
        "project": "RecoverX",
        "version": "1.0.0",
        "environment": getattr(settings, "ENVIRONMENT", "development"),
        "status": "running",
        "message": "RecoverX Backend is running successfully",
    }


@app.get("/health")
async def health_check():
    return {
        "status": "healthy"
    }