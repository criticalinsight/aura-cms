# Aura CMS

**Aura CMS** is a high-performance, local-first AI Content Management System. Built with **Roc** functional programming and powered by **Gemini AI** for intelligent research and content synthesis.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Aura CMS Stack                         │
├─────────────────────────────────────────────────────────────┤
│  main.roc     │  Interactive CLI & Research Mode           │
│  server.roc   │  HTTP Server with Gemini API + CORS        │
│  cron.roc     │  Scheduled Task Runner                     │
│  Db.roc       │  Caching & Persistence Layer               │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start (WSL/Linux)

> **Note**: Roc does not support native Windows. Use WSL (Ubuntu) for development.

### 1. Install Roc Compiler
```bash
./install_roc.sh
```

### 2. Configure API Key
```bash
cd aura-roc
cp .env.example .env
# Edit .env with your GOOGLE_API_KEY
```

### 3. Run the CLI
```bash
./run_client.sh

# Or with research mode:
./run_client.sh --research "Quantum computing trends"
```

### 4. Run the Server
```bash
./run_server.sh
# Server runs at http://localhost:8000
```

## Key Features

- **Deep Research Mode**: Multi-phase AI research with `--research` flag
- **Pure Functional**: Built with Roc - statically typed, no runtime exceptions
- **HTTP API**: RESTful server with CORS, rate limiting, and health checks
- **Response Caching**: DuckDB-backed caching with configurable TTL
- **CI/CD Ready**: GitHub Actions workflow included

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/chat` | POST | Send prompt, receive AI response |
| `/health` | GET | Server health and version |
| `/metrics` | GET | Server metrics |

## Development

```bash
# Build optimized binaries
./build.sh

# Run tests via GitHub Actions
git push origin main
```

## Production Deployment

```bash
# Copy systemd service
sudo cp aura-server.service /etc/systemd/system/
sudo systemctl enable aura-server
sudo systemctl start aura-server
```

---
*Powered by Roc Lang & Gemini AI | 2026*
