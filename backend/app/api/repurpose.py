"""Repurpose endpoint for content transformation."""
import json
import logging

from fastapi import APIRouter, HTTPException, status

from app.core.agents import repurpose_content
from app.models.schemas import RepurposeRequest, RepurposeResponse


logger = logging.getLogger(__name__)
router = APIRouter()


@router.post(
    "/repurpose",
    response_model=RepurposeResponse,
    status_code=status.HTTP_200_OK,
    summary="Repurpose content for social media",
    description=(
        "Transform long-form content into platform-optimized social media posts. "
        "Supports Twitter/X, LinkedIn, Instagram, Facebook, and Bluesky."
    ),
)
async def repurpose_endpoint(request: RepurposeRequest) -> RepurposeResponse:
    """
    Repurpose long-form content into social media posts.

    This endpoint uses an AI agent to transform blog posts, articles, or other
    long-form content into platform-specific social media posts optimized for
    character limits, tone, and audience expectations.

    Args:
        request: RepurposeRequest containing text, platforms, and optional link

    Returns:
        RepurposeResponse with a dictionary of platform-specific posts

    Raises:
        HTTPException: 400 if input is invalid
        HTTPException: 500 if agent processing fails
        HTTPException: 502 if OpenAI API fails
    """
    try:
        logger.info(
            f"Processing repurpose request for platforms: {request.platforms}"
        )

        # Call the agent to repurpose content
        posts = await repurpose_content(
            text=request.text,
            platforms=request.platforms,
            link=request.link
        )

        logger.info("Successfully generated posts for all platforms")
        return RepurposeResponse(posts=posts)

    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse agent response as JSON: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=(
                "Agent returned invalid JSON response. "
                "This is an internal error, please try again."
            )
        ) from e

    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        ) from e

    except Exception as e:
        logger.error(f"Unexpected error during content repurposing: {e}")

        # Check if it's an OpenAI API error
        if "openai" in str(type(e)).lower() or "api" in str(e).lower():
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=(
                    "Failed to communicate with OpenAI API. "
                    "Please try again in a moment."
                )
            ) from e

        # Generic server error
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred while processing your request"
        ) from e
