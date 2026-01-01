"""Agent logic for content repurposing - ported from original Streamlit app."""
import json
from typing import Optional

from agents import Agent, Runner

from .prompt import SOCIAL_MEDIA_REPURPOSER_PROMPT


# Initialize the repurposer agent with the system prompt
repurposer = Agent(
    name="Social Media Repurposer",
    instructions=SOCIAL_MEDIA_REPURPOSER_PROMPT,
)


async def repurpose_content(
    text: str,
    platforms: list[str],
    link: Optional[str] = None
) -> dict[str, str]:
    """
    Repurpose long-form content into platform-specific social media posts.

    Args:
        text: The long-form content to repurpose (blog post, article, etc.)
        platforms: List of platform names to generate posts for
              (e.g., ["twitter", "linkedin", "instagram"])
        link: Optional link to append to posts

    Returns:
        Dictionary mapping platform names to their generated posts.
        Example: {"twitter": "...", "linkedin": "...", "meta-description": "..."}

    Raises:
        json.JSONDecodeError: If the agent returns invalid JSON
        Exception: If agent execution fails
    """
    # Add platform filtering to the input
    # Always include meta-description in addition to user-selected platforms
    all_platforms = list(set(platforms + ["meta-description"]))
    platform_instruction = (
        "\n\nGenerate posts ONLY for these platforms: " + ", ".join(all_platforms)
    )

    # Run the agent with the combined input
    result = await Runner.run(repurposer, text + platform_instruction)

    # Parse the JSON response
    posts = json.loads(result.final_output)

    # Add link to posts if provided
    if link and link.strip():
        posts = _append_link_to_posts(posts, link.strip(), platforms)

    return posts


def _append_link_to_posts(
    posts: dict[str, str],
    link: str,
    platforms: list[str]
) -> dict[str, str]:
    """
    Append link to platform posts following platform-specific formatting.

    Args:
        posts: Dictionary of platform posts
        link: URL to append
        platforms: List of selected platforms

    Returns:
        Updated posts dictionary with links appended
    """
    for platform in platforms:
        if platform not in posts or not posts[platform].strip():
            continue

        content = posts[platform]

        # Platform-specific link formatting
        if platform in ["twitter", "bluesky"]:
            # Twitter and Bluesky: just the URL
            posts[platform] = f"{content}\n\n{link}"
        else:
            # LinkedIn, Instagram, Facebook: URL with emoji
            posts[platform] = f"{content}\n\n🔗 {link}"

    return posts
