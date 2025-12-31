# Social Media Repurposer - Backend API

FastAPI backend for transforming long-form content into platform-optimized social media posts.

## Features

- 🚀 Fast async API built with FastAPI
- 🤖 OpenAI-powered content adaptation using Agent framework
- 📱 Support for 5 platforms: Twitter/X, LinkedIn, Instagram, Facebook, Bluesky
- ✅ Full request/response validation with Pydantic
- 🔒 CORS configured for frontend security
- 📊 Health check endpoint for monitoring
- 🐳 Docker-ready for AWS App Runner deployment

## Local Development

### Prerequisites

- Python 3.11+
- OpenAI API key

### Setup

1. **Install dependencies:**
   ```bash
   cd backend
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

1. **Set environment variables:**
   ```bash
   export OPENAI_API_KEY="sk-your-openai-api-key"
   export ENVIRONMENT="development"
   ```

2. **Run the development server:**
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

3. **Access the API:**
   - API: http://localhost:8000
   - Interactive docs: http://localhost:8000/docs
   - Alternative docs: http://localhost:8000/redoc
   - Health check: http://localhost:8000/health

### Testing the API

**Using curl:**
```bash
curl -X POST http://localhost:8000/api/repurpose \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Your blog post content here...",
    "platforms": ["twitter", "linkedin"],
    "link": "https://example.com/article"
  }'
```

**Using the interactive docs:**
1. Go to http://localhost:8000/docs
2. Click on `/api/repurpose` endpoint
3. Click "Try it out"
4. Fill in the request body
5. Click "Execute"

## Docker Deployment

### Build locally

```bash
cd backend
docker build -t social-media-repurposer-api .
```

### Run locally

```bash
docker run -p 8000:8000 \
  -e OPENAI_API_KEY="sk-your-key" \
  social-media-repurposer-api
```

## AWS App Runner Deployment

### Prerequisites

1. AWS CLI configured
2. ECR repository created
3. OpenAI API key stored in AWS Secrets Manager

### Deploy to App Runner

1. **Build for AMD64 (App Runner compatible):**
   ```bash
   docker build --platform linux/amd64 -t social-media-repurposer-api .
   ```

2. **Tag for ECR:**
   ```bash
   docker tag social-media-repurposer-api:latest \
     <account-id>.dkr.ecr.eu-central-1.amazonaws.com/social-media-repurposer-api:latest
   ```

3. **Login to ECR:**
   ```bash
   aws ecr get-login-password --region eu-central-1 | \
     docker login --username AWS --password-stdin \
     <account-id>.dkr.ecr.eu-central-1.amazonaws.com
   ```

4. **Push to ECR:**
   ```bash
   docker push <account-id>.dkr.ecr.eu-central-1.amazonaws.com/social-media-repurposer-api:latest
   ```

5. **Update Terraform and apply:**
   ```bash
   cd ../terraform
   terraform apply -var-file=config/production.tfvars
   ```

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app entry point
│   ├── api/
│   │   ├── __init__.py
│   │   └── repurpose.py     # Repurpose endpoint
│   ├── models/
│   │   ├── __init__.py
│   │   └── schemas.py       # Pydantic models
│   └── core/
│       ├── __init__.py
│       ├── config.py        # Settings and config
│       ├── prompt.py        # LLM prompt
│       └── agents.py        # Agent logic
├── Dockerfile
├── requirements.txt
├── .dockerignore
└── README.md
```

## API Endpoints

### POST /api/repurpose

Repurpose content into social media posts.

**Request:**
```json
{
  "text": "Long-form content here...",
  "platforms": ["twitter", "linkedin", "instagram"],
  "link": "https://optional-link.com"
}
```

**Response:**
```json
{
  "posts": {
    "twitter": "Generated Twitter post...",
    "linkedin": "Generated LinkedIn post...",
    "instagram": "Generated Instagram post...",
    "meta description": "Generated meta description..."
  }
}
```

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy"
}
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes | OpenAI API key for agent execution |
| `ENVIRONMENT` | No | Environment name (development/production) |

## Error Handling

The API returns appropriate HTTP status codes:

- `200` - Success
- `400` - Invalid request (validation errors)
- `500` - Internal server error (agent processing failed)
- `502` - Bad gateway (OpenAI API error)

## CORS Configuration

Allowed origins:
- `http://localhost:5173` (Vite dev server)
- `https://mycreatorkit.com` (Production)
- `https://www.mycreatorkit.com` (Production with www)

## Logging

Application logs include:
- Request processing information
- Agent execution details
- Error traces for debugging

View logs in development:
```bash
# Logs appear in console when running with --reload
```

View logs in App Runner:
- CloudWatch Logs: `/aws/apprunner/<service-name>/<service-id>`

## Troubleshooting

### "OPENAI_API_KEY environment variable is required"

Make sure the environment variable is set:
```bash
export OPENAI_API_KEY="sk-your-key"
```

### "Failed to communicate with OpenAI API"

Check:
1. API key is valid
2. Internet connectivity
3. OpenAI API status (https://status.openai.com)

### Docker healthcheck failing

The healthcheck requires `requests` library. If needed, add to requirements.txt:
```
requests==2.32.5
```

## Contributing

When making changes:
1. Update the agent logic in `app/core/agents.py`
2. Update models in `app/models/schemas.py`
3. Test locally before deploying
4. Update documentation

## License

Internal use only.
