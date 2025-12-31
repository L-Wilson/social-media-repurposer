# Social Media Repurposer

Transform long-form content (blog posts, articles, essays) into platform-optimized social media posts for Twitter/X, LinkedIn, Instagram, Facebook, and Bluesky.

## Architecture

Modern full-stack application with separated frontend and backend:
- **Backend**: FastAPI REST API with OpenAI integration
- **Frontend**: React TypeScript with Tailwind CSS
- **Deployment**: AWS App Runner (backend) + CloudFlare Pages (frontend)

## Features

- AI-powered content adaptation for each platform
- Platform-specific character limits, tone, and formatting
- Optional link attachment to posts
- Clean, responsive UI with platform logos
- Real-time form validation and error handling
- Copy-to-clipboard functionality

## Prerequisites

- **Backend**: Python 3.11+, OpenAI API key
- **Frontend**: Node.js 18+, npm
- **Deployment**: Docker, AWS CLI (optional)

## Quick Start - Local Development

### 1. Backend Setup

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Set environment variable
export OPENAI_API_KEY="your-openai-api-key"

# Run development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Backend available at: http://localhost:8000
API docs at: http://localhost:8000/docs

### 2. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Run development server
npm run dev
```

Frontend available at: http://localhost:5173

## Usage

1. Enter your long-form content in the textarea
2. (Optional) Add a link to the original article
3. Select platforms using the visual selector
4. Click "Repurpose Content"
5. Copy generated posts using the copy button

## Project Structure

```
social-media-repurposer/
├── backend/                      # FastAPI backend
│   ├── app/
│   │   ├── main.py              # FastAPI entry point
│   │   ├── core/                # Business logic
│   │   ├── api/                 # API routes
│   │   └── models/              # Pydantic schemas
│   ├── Dockerfile               # Backend container
│   └── requirements.txt         # Python dependencies
├── frontend/                     # React TypeScript frontend
│   ├── src/
│   │   ├── App.tsx              # Main component
│   │   ├── components/          # React components
│   │   ├── services/            # API client
│   │   └── types/               # TypeScript types
│   ├── package.json             # Node dependencies
│   └── .env                     # Environment config
├── terraform/                    # App Runner infrastructure
├── MIGRATION.md                 # Migration guide from Streamlit
└── README.md                    # This file
```

## Documentation

- [Frontend README](frontend/README.md) - Frontend setup and deployment
- [Backend README](backend/README.md) - Backend setup and deployment
- [Migration Guide](MIGRATION.md) - Streamlit to FastAPI+React migration

## Deployment

See [MIGRATION.md](MIGRATION.md) for complete deployment instructions:
- Backend: AWS App Runner with Docker
- Frontend: CloudFlare Pages or S3 + CloudFlare CDN

## Development

**Backend:**
```bash
cd backend
source venv/bin/activate
uvicorn app.main:app --reload
```

**Frontend:**
```bash
cd frontend
npm run dev
```

**Build for Production:**
```bash
# Backend
cd backend
docker build --platform linux/amd64 -t social-media-repurposer-api .

# Frontend
cd frontend
npm run build
```
