# Verify Claude Code Agents Installation
#
# This script verifies that all agents are properly installed and accessible.
#
# Usage: .\verify-agents.ps1

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Claude Code Agents - Installation Verification" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Define agent locations
$globalAgentsPath = Join-Path $HOME ".claude\agents"
$templateAgentsPath = Join-Path $PSScriptRoot "..\..\agents"

# Expected agents
$expectedAgents = @(
    "security-auditor.md",
    "standards-enforcer.md",
    "gen-docs.md",
    "code-documenter.md",
    "code-reviewer.md",
    "test-runner.md",
    "git-helper.md",
    "refactorer.md",
    "README.md"
)

# Check global agents
Write-Host "1. Checking Global Agents Location" -ForegroundColor Yellow
Write-Host "   Path: $globalAgentsPath" -ForegroundColor Gray

if (Test-Path $globalAgentsPath) {
    Write-Host "   ✓ Directory exists" -ForegroundColor Green

    $foundAgents = 0
    $missingAgents = @()

    foreach ($agent in $expectedAgents) {
        $agentPath = Join-Path $globalAgentsPath $agent
        if (Test-Path $agentPath) {
            $foundAgents++
            if ($Verbose) {
                Write-Host "   ✓ $agent" -ForegroundColor Green
            }
        } else {
            $missingAgents += $agent
            Write-Host "   ✗ $agent (MISSING)" -ForegroundColor Red
        }
    }

    Write-Host "   Found: $foundAgents / $($expectedAgents.Count) agents" -ForegroundColor $(if ($foundAgents -eq $expectedAgents.Count) { "Green" } else { "Yellow" })

    if ($missingAgents.Count -gt 0) {
        Write-Host ""
        Write-Host "   Missing agents:" -ForegroundColor Red
        foreach ($missing in $missingAgents) {
            Write-Host "   - $missing" -ForegroundColor Red
        }
    }
} else {
    Write-Host "   ✗ Directory does NOT exist" -ForegroundColor Red
    Write-Host ""
    Write-Host "   To install agents globally, run:" -ForegroundColor Yellow
    Write-Host "   Copy-Item $templateAgentsPath\*.md $globalAgentsPath" -ForegroundColor Cyan
}

Write-Host ""

# Check template agents
Write-Host "2. Checking Template Agents Location" -ForegroundColor Yellow
Write-Host "   Path: $templateAgentsPath" -ForegroundColor Gray

if (Test-Path $templateAgentsPath) {
    Write-Host "   ✓ Directory exists" -ForegroundColor Green

    $templateCount = (Get-ChildItem -Path $templateAgentsPath -Filter "*.md" | Measure-Object).Count
    Write-Host "   Found: $templateCount template files" -ForegroundColor Green
} else {
    Write-Host "   ✗ Directory does NOT exist" -ForegroundColor Red
}

Write-Host ""

# Check if agents have valid YAML frontmatter
Write-Host "3. Validating Agent Configuration" -ForegroundColor Yellow

if (Test-Path $globalAgentsPath) {
    $validAgents = 0
    $invalidAgents = @()

    foreach ($agent in $expectedAgents) {
        if ($agent -eq "README.md") { continue }

        $agentPath = Join-Path $globalAgentsPath $agent
        if (Test-Path $agentPath) {
            $content = Get-Content $agentPath -Raw

            # Check for YAML frontmatter
            if ($content -match "^---\s*\n.*name:\s*\w+.*\n.*description:.*\n.*---") {
                $validAgents++
                if ($Verbose) {
                    Write-Host "   ✓ $agent has valid frontmatter" -ForegroundColor Green
                }
            } else {
                $invalidAgents += $agent
                Write-Host "   ✗ $agent missing or invalid frontmatter" -ForegroundColor Red
            }
        }
    }

    Write-Host "   Valid: $validAgents / $($expectedAgents.Count - 1) agents" -ForegroundColor $(if ($validAgents -eq ($expectedAgents.Count - 1)) { "Green" } else { "Yellow" })

    if ($invalidAgents.Count -gt 0) {
        Write-Host ""
        Write-Host "   Invalid agents:" -ForegroundColor Red
        foreach ($invalid in $invalidAgents) {
            Write-Host "   - $invalid" -ForegroundColor Red
        }
    }
} else {
    Write-Host "   ⚠ Skipped (global agents not installed)" -ForegroundColor Yellow
}

Write-Host ""

# Final summary
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$globalInstalled = Test-Path $globalAgentsPath
$templateExists = Test-Path $templateAgentsPath

if ($globalInstalled -and $templateExists) {
    Write-Host "✓ Installation Status: COMPLETE" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your agents are ready to use!" -ForegroundColor Green
    Write-Host "Try these commands in any project:" -ForegroundColor Cyan
    Write-Host '  - "Scan for security vulnerabilities"' -ForegroundColor Gray
    Write-Host '  - "Generate documentation for this project"' -ForegroundColor Gray
    Write-Host '  - "Check if code follows our standards"' -ForegroundColor Gray
    Write-Host ""
    Write-Host "See AGENTS-GUIDE.md for full documentation." -ForegroundColor Cyan
} elseif ($templateExists -and -not $globalInstalled) {
    Write-Host "⚠ Installation Status: INCOMPLETE" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Templates exist but agents not installed globally." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install globally, run:" -ForegroundColor Cyan
    Write-Host "  Copy-Item $templateAgentsPath\*.md $globalAgentsPath" -ForegroundColor White
} else {
    Write-Host "✗ Installation Status: NOT FOUND" -ForegroundColor Red
    Write-Host ""
    Write-Host "Agent templates are missing. Check your repository." -ForegroundColor Red
}

Write-Host ""
