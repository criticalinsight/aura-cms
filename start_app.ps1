Write-Host "=== ZigchDB System Launcher ===" -ForegroundColor Cyan

# 1. Start the Python Agent Server (Background/New Window)
Write-Host "Starting Python ADK Agent Server..." -ForegroundColor Yellow
$agentPath = Join-Path $PSScriptRoot "adk_agent"
$pythonPath = Join-Path $agentPath ".venv\Scripts\python.exe"
$serverScript = "agent_server.py"

if (-not (Test-Path $pythonPath)) {
    Write-Error "Python venv not found at $pythonPath"
    exit 1
}

# Start server in a new window so logs are visible but don't clutter main output
Start-Process -FilePath $pythonPath -ArgumentList $serverScript -WorkingDirectory $agentPath

Write-Host "Waiting 5 seconds for Agent Server to initialize..." -ForegroundColor DarkGray
Start-Sleep -Seconds 5

# 2. Start the Zig Application
Write-Host "Starting Aura-Turbo Zig App..." -ForegroundColor Green
$zigPath = Join-Path $PSScriptRoot "aura-turbo"
Set-Location $zigPath

# Run interactive
zig build run
