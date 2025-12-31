"""Pydantic schemas for API request and response validation."""
from typing import Optional

from pydantic import BaseModel, Field, field_validator


class RepurposeRequest(BaseModel):
    """Request model for content repurposing."""

    text: str = Field(
        ...,
        min_length=1,
        description="Long-form content to repurpose (blog post, article, etc.)"
    )
    link: Optional[str] = Field(
        default=None,
        description="Optional URL to append to social media posts"
    )
    platforms: list[str] = Field(
        ...,
        min_length=1,
        description="List of platforms to generate posts for"
    )

    @field_validator("platforms")
    @classmethod
    def validate_platforms(cls, v: list[str]) -> list[str]:
        """Validate that all platforms are supported."""
        valid_platforms = {
            "twitter",
            "linkedin",
            "instagram",
            "facebook",
            "bluesky"
        }
        for platform in v:
            if platform.lower() not in valid_platforms:
                raise ValueError(
                    f"Invalid platform '{platform}'. "
                    f"Supported platforms: {', '.join(valid_platforms)}"
                )
        return [p.lower() for p in v]

    @field_validator("text")
    @classmethod
    def validate_text_not_empty(cls, v: str) -> str:
        """Validate that text is not just whitespace."""
        if not v.strip():
            raise ValueError("Text content cannot be empty")
        return v

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "text": "Your blog post or article content here...",
                    "link": "https://example.com/article",
                    "platforms": ["twitter", "linkedin", "instagram"]
                }
            ]
        }
    }


class RepurposeResponse(BaseModel):
    """Response model for repurposed content."""

    posts: dict[str, str] = Field(
        ...,
        description="Dictionary mapping platform names to generated posts"
    )

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "posts": {
                        "twitter": "Fascinating insights on AI...",
                        "linkedin": "A deep dive into artificial intelligence...",
                        "meta-description": "Explore how AI is transforming..."
                    }
                }
            ]
        }
    }


class HealthResponse(BaseModel):
    """Health check response."""

    status: str = Field(default="healthy", description="Service health status")
