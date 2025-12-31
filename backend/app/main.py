"""FastAPI application entry point."""
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.repurpose import router as repurpose_router
from app.core.config import get_settings
from app.models.schemas import HealthResponse


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Get application settings
settings = get_settings()

# Initialize FastAPI app
app = FastAPI(
    title="Social Media Repurposer API",
    description=(
        "Transform long-form content into platform-optimized social media posts "
        "for Twitter/X, LinkedIn, Instagram, Facebook, and Bluesky."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers with /api prefix
app.include_router(repurpose_router, prefix="/api", tags=["repurpose"])


@app.get(
    "/health",
    response_model=HealthResponse,
    summary="Health check",
    description="Check if the service is running and healthy",
    tags=["health"],
)
async def health_check() -> HealthResponse:
    """
    Health check endpoint for monitoring and load balancers.

    Returns:
        HealthResponse indicating service is healthy
    """
    return HealthResponse(status="healthy")


@app.on_event("startup")
async def startup_event():
    """Log startup information."""
    logger.info("Starting Social Media Repurposer API")
    logger.info(f"Environment: {settings.environment}")
    logger.info(f"CORS origins: {settings.cors_origins}")


@app.on_event("shutdown")
async def shutdown_event():
    """Log shutdown information."""
    logger.info("Shutting down Social Media Repurposer API")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
