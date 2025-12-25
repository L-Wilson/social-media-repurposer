# Social Media Repurposer

Transform long-form content (blog posts, articles, essays) into platform-optimized social media posts for Twitter/X, LinkedIn, Instagram, Facebook, and Bluesky.

## Features

- AI-powered content adaptation for each platform
- Platform-specific character limits, tone, and formatting
- Optional link attachment to posts
- General excerpt generation

## Prerequisites

- Docker and Docker Compose (recommended)
- OR Python 3.13+ with pip (for local development)
- OpenAI API key

## Quick Start with Docker (Recommended)

### 1. Set up your environment

Create a `.env` file in the project root:

```bash
OPENAI_API_KEY=your_openai_api_key_here
```

### 2. Run with Docker Compose

```bash
docker-compose up --build
```

### 3. Open the app

Navigate to [http://localhost:8501](http://localhost:8501) in your browser.

## Running Locally (Without Docker)

### 1. Create a virtual environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Set up environment variables

Create a `.env` file with your OpenAI API key:

```bash
OPENAI_API_KEY=your_openai_api_key_here
```

### 4. Run the app

```bash
streamlit run app/app.py
```

### 5. Open the app

View app at [http://localhost:8501](http://localhost:8501)

## Usage

1. Paste your long-form content into the text area
2. (Optional) Add a link to the original article
3. Select which platforms you want to generate posts for
4. Click "Repurpose!"
5. Copy the generated posts for each platform

## Project Structure

```
social-media-repurposer/
├── app/
│   ├── app.py                    # Main Streamlit application
│   └── social_media_prompt.py    # AI prompt configuration
├── .streamlit/                   # Streamlit configuration
├── requirements.txt              # Python dependencies
├── Dockerfile                    # Docker container configuration
├── docker-compose.yml            # Docker Compose setup
└── .env                          # Environment variables (create this)
```

## Stopping the App

**Docker:**
```bash
docker-compose down
```

**Local:**
Press `Ctrl+C` in the terminal where Streamlit is running
