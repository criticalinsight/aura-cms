# ZigchDB: Aura-Roc AI Content Factory

**ZigchDB** is a high-performance, local-first AI Content Factory. It combines a **Roc** functional programming language application with **Gemini-powered** AI research capabilities to automate deep research and content synthesis.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Aura-Roc Stack                         │
├─────────────────────────────────────────────────────────────┤
│  main.roc     │  Interactive CLI & One-Shot Mode           │
│  server.roc   │  HTTP Server with Gemini API Integration   │
│  cron.roc     │  Scheduled Task Runner                     │
│  Db.roc       │  Database/Persistence Layer                │
└─────────────────────────────────────────────────────────────┘
```

- **`aura-roc/`**: The main Roc engine. A pure functional CLI and server that handles user interaction and AI-powered research via Gemini.
- **`adk_agent/`**: Optional Python agent layer for extended tooling (Google ADK).

## Quick Start (WSL/Linux)

> **Note**: Roc does not yet support native Windows. Use WSL (Ubuntu) for development.

### 1. Install Roc Compiler
```bash
# Download latest nightly to home directory
cd ~
curl -L https://github.com/roc-lang/roc/releases/download/nightly/roc_nightly-linux_x86_64-latest.tar.gz -o roc.tar.gz
tar -xzf roc.tar.gz
```

### 2. Run the CLI
```bash
cd aura-roc
./run_client.sh

# Or one-shot mode:
./run_client.sh --prompt "Research quantum computing"
```

### 3. Run the Server (with Gemini)
```bash
# Set your API key in the script or environment
export GOOGLE_API_KEY="your-key-here"
./run_server.sh
```

## Key Features

- **Interactive Research**: Query the Gemini AI directly from your terminal.
- **Pure Functional**: Built with Roc - statically typed, no runtime exceptions.
- **Server Mode**: HTTP server with `/chat` endpoint for programmatic access.
- **Cron Service**: Scheduled task execution with `cron.roc`.

## Development Status

- [x] Zig to Roc Migration
- [x] CLI Interactive Mode
- [x] One-Shot Command Mode
- [x] Gemini 2.5-Flash Integration
- [x] HTTP Server Implementation
- [x] Cron/Scheduler Module

## Shell Scripts

| Script | Purpose |
|--------|---------|
| `run_client.sh` | Run the interactive CLI |
| `run_server.sh` | Start the HTTP server |
| `run_cron.sh` | Start the cron service |
| `start.sh` | Master launcher script |

---
*Powered by Roc Lang & Gemini AI | 2026*
