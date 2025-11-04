# Sync Baseline Agents to Global Claude Code Directory
# This script copies updated agent files from the baseline repository to the global agents directory

param(
    [switch]$WhatIf,
    [switch]$Force
)

$baselineAgentsPath = "E:\github\claude_code_baseline\agents"
$globalAgentsPath = "C:\Users\TimGolden\.claude\agents"
$projectAgentsPath = "E:\github\claude_code_baseline\.claude\agents"

Write-Host "`n================================================================" -ForegroundColor Blue
Write-Host " Sync Baseline Agents to Claude Code" -ForegroundColor Blue
Write-Host "================================================================`n" -ForegroundColor Blue

# Verify paths exist
if (-not (Test-Path $baselineAgentsPath)) {
    Write-Host "[ERROR] Baseline agents directory not found: $baselineAgentsPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $globalAgentsPath)) {
    Write-Host "[WARN] Global agents directory not found: $globalAgentsPath" -ForegroundColor Yellow
    Write-Host "       Creating directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $globalAgentsPath -Force | Out-Null
}

if (-not (Test-Path $projectAgentsPath)) {
    Write-Host "[WARN] Project agents directory not found: $projectAgentsPath" -ForegroundColor Yellow
    Write-Host "       Creating directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $projectAgentsPath -Force | Out-Null
}

# Get all agent files (exclude README.md)
$agentFiles = Get-ChildItem -Path $baselineAgentsPath -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

Write-Host "Found $($agentFiles.Count) agent files to sync:`n" -ForegroundColor Cyan

foreach ($file in $agentFiles) {
    Write-Host "  - $($file.Name)" -ForegroundColor Gray
}

Write-Host ""

# Sync to Global Directory
Write-Host "Syncing to GLOBAL agents directory:" -ForegroundColor Green
Write-Host "Target: $globalAgentsPath`n" -ForegroundColor Gray

$globalUpdated = 0
$globalSkipped = 0

foreach ($file in $agentFiles) {
    $source = $file.FullName
    $destination = Join-Path $globalAgentsPath $file.Name

    $needsUpdate = $false
    $reason = ""

    if (-not (Test-Path $destination)) {
        $needsUpdate = $true
        $reason = "NEW"
    }
    elseif ($Force) {
        $needsUpdate = $true
        $reason = "FORCED"
    }
    else {
        $sourceHash = (Get-FileHash -Path $source -Algorithm MD5).Hash
        $destHash = (Get-FileHash -Path $destination -Algorithm MD5).Hash

        if ($sourceHash -ne $destHash) {
            $needsUpdate = $true
            $reason = "UPDATED"
        }
        else {
            $reason = "UNCHANGED"
        }
    }

    if ($needsUpdate) {
        if ($WhatIf) {
            Write-Host "  [WHATIF] Would copy: $($file.Name) [$reason]" -ForegroundColor Yellow
        }
        else {
            Copy-Item -Path $source -Destination $destination -Force
            Write-Host "  [OK] Copied: $($file.Name) [$reason]" -ForegroundColor Green
            $globalUpdated++
        }
    }
    else {
        Write-Host "  [SKIP] $($file.Name) [$reason]" -ForegroundColor Gray
        $globalSkipped++
    }
}

# Sync to Project Directory
Write-Host "`nSyncing to PROJECT agents directory:" -ForegroundColor Cyan
Write-Host "Target: $projectAgentsPath`n" -ForegroundColor Gray

$projectUpdated = 0
$projectSkipped = 0

foreach ($file in $agentFiles) {
    $source = $file.FullName
    $destination = Join-Path $projectAgentsPath $file.Name

    $needsUpdate = $false
    $reason = ""

    if (-not (Test-Path $destination)) {
        $needsUpdate = $true
        $reason = "NEW"
    }
    elseif ($Force) {
        $needsUpdate = $true
        $reason = "FORCED"
    }
    else {
        $sourceHash = (Get-FileHash -Path $source -Algorithm MD5).Hash
        $destHash = (Get-FileHash -Path $destination -Algorithm MD5).Hash

        if ($sourceHash -ne $destHash) {
            $needsUpdate = $true
            $reason = "UPDATED"
        }
        else {
            $reason = "UNCHANGED"
        }
    }

    if ($needsUpdate) {
        if ($WhatIf) {
            Write-Host "  [WHATIF] Would copy: $($file.Name) [$reason]" -ForegroundColor Yellow
        }
        else {
            Copy-Item -Path $source -Destination $destination -Force
            Write-Host "  [OK] Copied: $($file.Name) [$reason]" -ForegroundColor Green
            $projectUpdated++
        }
    }
    else {
        Write-Host "  [SKIP] $($file.Name) [$reason]" -ForegroundColor Gray
        $projectSkipped++
    }
}

# Summary
Write-Host "`n================================================================" -ForegroundColor Blue
Write-Host " Sync Complete" -ForegroundColor Blue
Write-Host "================================================================`n" -ForegroundColor Blue

if ($WhatIf) {
    Write-Host "WHAT-IF MODE: No files were actually modified`n" -ForegroundColor Yellow
}

Write-Host "Global Agents:" -ForegroundColor Cyan
Write-Host "  Updated: $globalUpdated" -ForegroundColor Green
Write-Host "  Skipped: $globalSkipped" -ForegroundColor Gray

Write-Host "`nProject Agents:" -ForegroundColor Cyan
Write-Host "  Updated: $projectUpdated" -ForegroundColor Green
Write-Host "  Skipped: $projectSkipped" -ForegroundColor Gray

Write-Host "`nAvailable Agents:" -ForegroundColor Cyan
foreach ($file in $agentFiles) {
    $agentName = $file.BaseName
    Write-Host "  - $agentName" -ForegroundColor Gray
}

Write-Host "`nUsage:" -ForegroundColor Yellow
Write-Host "  - Type: /agents in Claude Code to see all available agents" -ForegroundColor Gray
Write-Host "  - Or just ask Claude naturally: Scan for security issues" -ForegroundColor Gray
Write-Host "  - Agents activate automatically based on your request" -ForegroundColor Gray

Write-Host "`nTo Update Agents:" -ForegroundColor Yellow
Write-Host "  powershell -NoProfile -File sync-agents.ps1         # Sync changed files" -ForegroundColor Gray
Write-Host "  powershell -NoProfile -File sync-agents.ps1 -Force  # Force sync all" -ForegroundColor Gray
Write-Host "  powershell -NoProfile -File sync-agents.ps1 -WhatIf # Preview changes" -ForegroundColor Gray

Write-Host ""
