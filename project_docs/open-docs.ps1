# Open HTML Documentation Site
# Quick launcher for the Claude Code Baseline documentation

$docsPath = Join-Path $PSScriptRoot "index.html"

if (Test-Path $docsPath) {
    Write-Host "Opening Claude Code Baseline Documentation..." -ForegroundColor Cyan
    Start-Process $docsPath
    Write-Host "Documentation opened in your default browser!" -ForegroundColor Green
} else {
    Write-Host "Error: index.html not found at $docsPath" -ForegroundColor Red
}
