# GitHub Repositories Backup Script
# Backs up all repositories from E:\github to E:\backup

param(
    [string]$SourceDir = "E:\github",
    [string]$BackupDir = "E:\backup",
    [switch]$IncludeNodeModules = $false,
    [switch]$IncludeVendor = $false,
    [int]$RetentionDays = 90
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "=== GitHub Repositories Backup ===" -ForegroundColor Cyan
Write-Host ""

# Check source directory
if (-not (Test-Path $SourceDir)) {
    Write-Host "ERROR: Source directory not found: $SourceDir" -ForegroundColor Red
    exit 1
}

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupDir)) {
    Write-Host "Creating backup directory: $BackupDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

# Create timestamped subdirectory
$backupPath = Join-Path $BackupDir "repos_$timestamp"
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

Write-Host "Source: $SourceDir" -ForegroundColor Cyan
Write-Host "Destination: $backupPath" -ForegroundColor Cyan
Write-Host ""

# Get all repositories
$repos = Get-ChildItem $SourceDir -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName ".git")
}

$repoCount = ($repos | Measure-Object).Count
Write-Host "Found $repoCount repository(ies)" -ForegroundColor Green
Write-Host ""

if ($repoCount -eq 0) {
    Write-Host "WARNING: No Git repositories found in $SourceDir" -ForegroundColor Yellow
    exit 0
}

$successCount = 0
$failCount = 0

foreach ($repo in $repos) {
    Write-Host "Backing up: $($repo.Name)..." -ForegroundColor Yellow

    $repoBackupPath = Join-Path $backupPath $repo.Name

    try {
        # Copy repository
        Copy-Item -Path $repo.FullName -Destination $repoBackupPath -Recurse -Force -ErrorAction Stop

        # Exclude node_modules unless explicitly included
        if (-not $IncludeNodeModules) {
            $nodeModules = Join-Path $repoBackupPath "node_modules"
            if (Test-Path $nodeModules) {
                Write-Host "  Excluding node_modules..." -ForegroundColor Gray
                Remove-Item $nodeModules -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        # Exclude vendor unless explicitly included
        if (-not $IncludeVendor) {
            $vendor = Join-Path $repoBackupPath "vendor"
            if (Test-Path $vendor) {
                Write-Host "  Excluding vendor..." -ForegroundColor Gray
                Remove-Item $vendor -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        # Get repository size
        $size = (Get-ChildItem $repoBackupPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB

        # Get git status
        Push-Location $repo.FullName
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        $commit = git rev-parse --short HEAD 2>$null
        Pop-Location

        Write-Host "  SUCCESS: Backed up $([math]::Round($size, 2)) MB (branch: $branch, commit: $commit)" -ForegroundColor Green

        $successCount++
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }

    Write-Host ""
}

# Compress entire backup
Write-Host "Compressing backup..." -ForegroundColor Yellow
$zipFile = "$backupPath.zip"
try {
    Compress-Archive -Path $backupPath -DestinationPath $zipFile -Force
    $zipSize = (Get-Item $zipFile).Length / 1MB
    Write-Host "Compressed to: $zipFile ($([math]::Round($zipSize, 2)) MB)" -ForegroundColor Green

    # Remove uncompressed directory
    Remove-Item $backupPath -Recurse -Force
} catch {
    Write-Host "WARNING: Compression failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Create backup manifest
$manifest = @{
    timestamp = $timestamp
    sourceDir = $SourceDir
    backupFile = $zipFile
    totalRepos = $repoCount
    successful = $successCount
    failed = $failCount
    excludedNodeModules = -not $IncludeNodeModules
    excludedVendor = -not $IncludeVendor
}
$manifestFile = "$backupPath.manifest.json"
$manifest | ConvertTo-Json | Out-File $manifestFile -Encoding UTF8

# Cleanup old backups
Write-Host ""
Write-Host "Cleaning up old backups (retention: $RetentionDays days)..." -ForegroundColor Yellow
$cutoffDate = (Get-Date).AddDays(-$RetentionDays)
$oldBackups = Get-ChildItem $BackupDir -Filter "repos_*.zip" |
              Where-Object { $_.CreationTime -lt $cutoffDate }

foreach ($oldBackup in $oldBackups) {
    Write-Host "  Removing: $($oldBackup.Name)" -ForegroundColor Gray
    Remove-Item $oldBackup.FullName -Force
    # Remove manifest too
    $manifestPath = "$($oldBackup.FullName).manifest.json"
    if (Test-Path $manifestPath) {
        Remove-Item $manifestPath -Force
    }
}

# Summary
Write-Host ""
Write-Host "=== Backup Summary ===" -ForegroundColor Cyan
Write-Host "Total repositories: $repoCount" -ForegroundColor White
Write-Host "Successful: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host "Backup file: $zipFile" -ForegroundColor Cyan
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "All repositories backed up successfully! ✓" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some backups failed. Check logs above." -ForegroundColor Yellow
    exit 1
}
