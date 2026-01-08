# Aura CMS - Roc Engine

The Roc implementation of Aura CMS - a pure functional CLI and server for AI-powered content management.

## Components

| File | Description |
|------|-------------|
| `main.roc` | Interactive CLI + research mode |
| `server.roc` | HTTP server with CORS & caching |
| `cron.roc` | Scheduled task runner |
| `Db.roc` | Caching layer with TTL |

## Usage

### Interactive CLI
```bash
./run_client.sh
```

### Research Mode
```bash
./run_client.sh --research "AI trends 2026"
# Runs 4-phase deep research: Overview → Concepts → Trends → Outlook
```

### HTTP Server
```bash
./run_server.sh

curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Explain machine learning"}'
```

## Build

```bash
./build.sh
# Creates optimized binaries in ./bin/
```

## Architecture

```
┌─────────────┐     ┌─────────────┐
│  main.roc   │     │ server.roc  │
│  (CLI)      │     │ (HTTP+CORS) │
└──────┬──────┘     └──────┬──────┘
       └────────┬──────────┘
                │
        ┌───────▼───────┐
        │  Gemini API   │
        │  (2.5-flash)  │
        └───────────────┘
```

---
*Roc Lang • Gemini AI • 2026*
