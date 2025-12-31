"""Application configuration and environment variables."""
import os
from functools import lru_cache


class Settings:
    """Application settings loaded from environment variables."""

    def __init__(self):
        self.openai_api_key: str = os.getenv("OPENAI_API_KEY", "")
        self.environment: str = os.getenv("ENVIRONMENT", "development")
        self.cors_origins: list[str] = [
            "http://localhost:5173",  # Vite dev server
            "http://localhost",  # Docker frontend
            "https://mycreatorkit.com",  # Production frontend
            "https://www.mycreatorkit.com",  # Production frontend with www
            "https://api.mycreatorkit.com",  # for API docs access
        ]

    def validate(self) -> None:
        """Validate required settings are present."""
        if not self.openai_api_key:
            raise ValueError(
                "OPENAI_API_KEY environment variable is required"
            )


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    settings = Settings()
    settings.validate()
    return settings
