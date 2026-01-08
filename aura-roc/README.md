# Aura-Roc

The Roc implementation of the Aura AI Content Factory - a pure functional CLI and server for AI-powered research.

## Prerequisites

- **Roc Compiler**: Download from [roc-lang.org](https://roc-lang.org)
  - Linux/Mac: Direct install supported
  - Windows: Use WSL (Ubuntu recommended)
- **Google API Key**: Required for Gemini integration

## Components

| File | Description |
|------|-------------|
| `main.roc` | Interactive CLI + one-shot mode |
| `server.roc` | HTTP server with `/chat` endpoint |
| `cron.roc` | Scheduled task runner |
| `Db.roc` | Persistence layer |

## Usage

### Interactive CLI
```bash
./run_client.sh
# Type queries, 'exit' to quit
```

### One-Shot Mode
```bash
./run_client.sh --prompt "Research topic here"
```

### HTTP Server
```bash
export GOOGLE_API_KEY="your-key"
./run_server.sh

# Then POST to localhost:8000/chat
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Explain quantum computing"}'
```

### Cron Service
```bash
./run_cron.sh
```

## Architecture

```
┌────────────────┐     ┌────────────────┐
│   main.roc     │     │  server.roc    │
│   (CLI Mode)   │     │  (HTTP Mode)   │
└───────┬────────┘     └───────┬────────┘
        │                      │
        └──────────┬───────────┘
                   │
           ┌───────▼───────┐
           │  Gemini API   │
           │ (2.5-flash)   │
           └───────────────┘
```

## Scripts

All scripts auto-detect the Roc compiler in `~/roc_nightly*/`:

- `run_client.sh` - CLI launcher
- `run_server.sh` - Server launcher (sets `GOOGLE_API_KEY`)
- `run_cron.sh` - Cron service launcher
- `start.sh` - Master orchestrator

## Development

Build and run directly with Roc:
```bash
roc run main.roc -- --prompt "Test"
roc run server.roc
roc run cron.roc
```

---
*Roc Lang • Gemini AI • 2026*
