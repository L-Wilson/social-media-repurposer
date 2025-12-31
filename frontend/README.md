# Social Media Repurposer - Frontend

Modern React TypeScript frontend for the Social Media Repurposer application.

## Features

- Clean, responsive UI with Tailwind CSS
- Real-time form validation
- Platform selection with visual feedback
- Loading states and error handling
- Copy to clipboard functionality
- Mobile-optimized design

## Tech Stack

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **Axios** - HTTP client for API calls

## Prerequisites

- Node.js 18+ and npm

## Local Development Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

The `.env` file is already configured for local development:

```bash
VITE_API_URL=http://localhost:8000
```

### 3. Start Backend API

Make sure the FastAPI backend is running on port 8000:

```bash
cd ../backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Start Development Server

```bash
npm run dev
```

The app will be available at: http://localhost:5173

## Building for Production

### Build

```bash
npm run build
```

This creates optimized static files in the `dist/` directory.

### Preview Production Build

```bash
npm run preview
```

## Project Structure

```
frontend/
├── src/
│   ├── types/
│   │   └── index.ts          # TypeScript interfaces and platform definitions
│   ├── services/
│   │   └── api.ts             # API client with axios
│   ├── App.tsx                # Main application component
│   ├── index.css              # Global styles with Tailwind directives
│   └── main.tsx               # Application entry point
├── public/                    # Static assets
├── .env                       # Local development config
├── .env.production           # Production config
├── tailwind.config.js        # Tailwind CSS configuration
├── tsconfig.json             # TypeScript configuration
└── vite.config.ts            # Vite configuration
```

## Environment Variables

| Variable | Description | Development | Production |
|----------|-------------|-------------|------------|
| `VITE_API_URL` | Backend API URL | `http://localhost:8000` | `https://api.mycreatorkit.com` |

## Deployment

### Option 1: AWS S3 + CloudFlare

```bash
# Build for production
npm run build

# Upload to S3
aws s3 sync dist/ s3://mycreatorkit-frontend --delete

# Configure CloudFlare DNS to point to S3 bucket
```

### Option 2: CloudFlare Pages (Recommended)

1. Connect your Git repository to CloudFlare Pages
2. Configure build settings:
   - **Build command:** `npm run build`
   - **Build output directory:** `dist`
   - **Root directory:** `frontend`
3. Set environment variables:
   - `VITE_API_URL`: `https://api.mycreatorkit.com`
4. Deploy

CloudFlare Pages provides:
- Automatic deployments on git push
- Free SSL/HTTPS
- Global CDN
- Preview deployments for branches

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally
- `npm run lint` - Run ESLint (if configured)

## API Integration

The frontend communicates with the FastAPI backend via REST API:

**Endpoint:** `POST /api/repurpose`

**Request:**
```json
{
  "text": "Your long-form content here...",
  "platforms": ["twitter", "linkedin", "instagram"],
  "link": "https://example.com/article"
}
```

**Response:**
```json
{
  "posts": {
    "twitter": "Generated tweet content...",
    "linkedin": "Generated LinkedIn post...",
    "instagram": "Generated Instagram caption..."
  }
}
```

## Supported Platforms

- Twitter/X
- LinkedIn
- Instagram
- Facebook
- Bluesky

## Error Handling

The application handles three types of errors:

1. **Validation errors** - Client-side form validation
2. **API errors** - Server returned an error response
3. **Network errors** - Cannot reach the backend server

All errors are displayed to the user with clear messaging and suggested actions.

## Troubleshooting

### Cannot connect to API

**Error:** "Cannot connect to the API server"

**Solution:**
1. Ensure backend is running on `http://localhost:8000`
2. Check backend health: `curl http://localhost:8000/health`
3. Verify CORS is configured in backend `app/core/config.py`

### Build fails

**Error:** TypeScript compilation errors

**Solution:**
1. Ensure all dependencies are installed: `npm install`
2. Check Node.js version: `node --version` (should be 18+)
3. Clear cache: `rm -rf node_modules package-lock.json && npm install`

### Styles not loading

**Error:** Tailwind classes not working

**Solution:**
1. Ensure Tailwind directives are in `src/index.css`
2. Verify `tailwind.config.js` and `postcss.config.js` exist
3. Restart dev server: `npm run dev`

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Android)

## Performance

- Initial load: ~0.5-1s
- Bundle size: ~150-200KB (gzipped)
- Lighthouse score: 95+

## License

Same as parent project
