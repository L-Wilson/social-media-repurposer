import os
import asyncio
import json

import streamlit as st
from agents import Agent, Runner
from app.social_media_prompt import SOCIAL_MEDIA_REPURPOSER_PROMPT

# --- Config / prompt ---------------------------------------------------------

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if not OPENAI_API_KEY:
    st.error("OPENAI_API_KEY is not set in your environment.")
    st.stop()


# --- Agent -------------------------------------------------------------------

repurposer = Agent(
    name="Social Media Repurposer",
     instructions=SOCIAL_MEDIA_REPURPOSER_PROMPT,
)

async def repurpose_content(text: str, platforms: list[str]) -> str:
    platform_instruction = (
        "\n\nGenerate posts ONLY for these platforms: " + ", ".join(platforms)
    )
    result = await Runner.run(repurposer, text + platform_instruction)
    return result.final_output

# --- Streamlit UI ------------------------------------------------------------

st.set_page_config(
    page_title="Social Media Repurposer",
    page_icon="💥",
    layout="centered",
)

# Font Awesome (optional)
st.markdown(
    """
<link rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
""",
    unsafe_allow_html=True,
)

st.title("✂️ Social Media Repurposer")
st.write("Let's tailor that long-form content for social media")

user_text = st.text_area("Enter your full blog post, article, or text", height=200)
user_link = st.text_input("Enter the link to the article (optional)")

# Platform selection
st.subheader("Select Platforms")
col1, col2, col3 = st.columns(3)
with col1:
    twitter = st.checkbox("Twitter/X", value=True)
    linkedin = st.checkbox("LinkedIn", value=True)
with col2:
    instagram = st.checkbox("Instagram", value=True)
    facebook = st.checkbox("Facebook", value=True)
with col3:
    bluesky = st.checkbox("Bluesky", value=True)

if st.button("Repurpose!", type="primary"):
    # Collect selected platforms
    selected_platforms = []
    if twitter:
        selected_platforms.append("twitter")
    if linkedin:
        selected_platforms.append("linkedin")
    if instagram:
        selected_platforms.append("instagram")
    if facebook:
        selected_platforms.append("facebook")
    if bluesky:
        selected_platforms.append("bluesky")

    if user_text.strip() == "":
        st.warning("Please enter your text")
    elif not selected_platforms:
        st.warning("Please select at least one platform")
    else:
        with st.spinner("Generating your content..."):
            result = asyncio.run(repurpose_content(user_text, selected_platforms))

            # Parse JSON response
            try:
                posts = json.loads(result)
                st.success("✨ Content generated!")

                platform_config = {
                    "twitter": {
                        "name": "Twitter/X",
                        "logo": "https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/x.svg",
                        "color": "#000000",
                    },
                    "linkedin": {
                        "name": "LinkedIn",
                        "logo": "https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/linkedin.svg",
                        "color": "#0A66C2",
                    },
                    "instagram": {
                        "name": "Instagram",
                        "logo": "https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/instagram.svg",
                        "color": "#E4405F",
                    },
                    "facebook": {
                        "name": "Facebook",
                        "logo": "https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/facebook.svg",
                        "color": "#1877F2",
                    },
                    "bluesky": {
                        "name": "Bluesky",
                        "logo": "https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/bluesky.svg",
                        "color": "#00A8FC",
                    },
                }

                # Display Excerpt first (if it exists)
                if "excerpt" in posts and posts["excerpt"].strip():
                    st.markdown(
                        """
<div style="display:flex;align-items:center;margin-bottom:10px;">
  <h3 style="margin:0;">✍️ Excerpt</h3>
</div>
<div style="background-color:#f0f2f6;padding:20px;border-radius:10px;
            border-left:5px solid #21759b;margin-bottom:30px;">
  {0}
</div>
""".format(posts["excerpt"].strip()),
                        unsafe_allow_html=True,
                    )

                 # Display each selected platform
                for platform in selected_platforms:
                    config = platform_config[platform]
                    content = (posts.get(platform) or "").strip()
                    if not content:
                        continue
                    
                    # Add link to the end if provided
                    if user_link.strip():
                        # Add appropriate spacing based on platform
                        if platform in ["twitter", "bluesky"]:
                            content = f"{content}\n\n{user_link.strip()}"
                        else:
                            content = f"{content}\n\n🔗 {user_link.strip()}"
                    
                    # Replace newlines with <br> for HTML rendering
                    content_html = content.replace('\n', '<br>')
                    
                    st.markdown(
                        f"""
<div style="display:flex;align-items:center;margin-bottom:10px;">
  <img src="{config['logo']}" width="24" height="24"
       style="margin-right:10px;filter:brightness(0) saturate(100%);">
  <h3 style="margin:0;">{config['name']}</h3>
</div>
<div style="background-color:#f0f2f6;padding:20px;border-radius:10px;
            border-left:5px solid {config['color']};margin-bottom:20px;">
  {content_html}
</div>
""",
                        unsafe_allow_html=True,
                    )

            except json.JSONDecodeError:
                st.error("Could not parse response as JSON. Here's the raw output:")
                st.text(result)