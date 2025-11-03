# Baseline Documentation Backup Script
# Creates timestamped backup of baseline_docs directory

param(
    [string]$SourceDir = "E:\github\claude_code_baseline\baseline_docs",
    [string]$BackupDir = "E:\backup\baseline_docs",
    [int]$RetentionDays = 60
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "=== Baseline Documentation Backup ===" -ForegroundColor Cyan
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

Write-Host "Source: $SourceDir" -ForegroundColor Cyan
Write-Host "Destination: $BackupDir" -ForegroundColor Cyan
Write-Host ""

# Count files to backup
$files = Get-ChildItem $SourceDir -Filter "*.md" -File
$fileCount = ($files | Measure-Object).Count

Write-Host "Found $fileCount markdown file(s) to backup" -ForegroundColor Green
Write-Host ""

# Create compressed backup
$backupFile = Join-Path $BackupDir "baseline_docs_$timestamp.zip"

try {
    Write-Host "Creating compressed backup..." -ForegroundColor Yellow
    Compress-Archive -Path "$SourceDir\*.md" -DestinationPath $backupFile -Force

    $backupSize = (Get-Item $backupFile).Length / 1KB
    Write-Host "SUCCESS: Backup created" -ForegroundColor Green
    Write-Host "  File: $backupFile" -ForegroundColor Cyan
    Write-Host "  Size: $([math]::Round($backupSize, 2)) KB" -ForegroundColor Gray
    Write-Host "  Files: $fileCount" -ForegroundColor Gray
    Write-Host ""

    # Create manifest
    $manifest = @{
        timestamp = $timestamp
        sourceDir = $SourceDir
        backupFile = $backupFile
        fileCount = $fileCount
        backupSize = [math]::Round($backupSize, 2)
    }
    $manifestFile = "$backupFile.manifest.json"
    $manifest | ConvertTo-Json | Out-File $manifestFile -Encoding UTF8

    # Cleanup old backups
    Write-Host "Cleaning up old backups (retention: $RetentionDays days)..." -ForegroundColor Yellow
    $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
    $oldBackups = Get-ChildItem $BackupDir -Filter "baseline_docs_*.zip" |
                  Where-Object { $_.CreationTime -lt $cutoffDate }

    $removedCount = 0
    foreach ($oldBackup in $oldBackups) {
        Write-Host "  Removing: $($oldBackup.Name)" -ForegroundColor Gray
        Remove-Item $oldBackup.FullName -Force
        # Remove manifest too
        $oldManifest = "$($oldBackup.FullName).manifest.json"
        if (Test-Path $oldManifest) {
            Remove-Item $oldManifest -Force
        }
        $removedCount++
    }

    if ($removedCount -gt 0) {
        Write-Host "  Removed $removedCount old backup(s)" -ForegroundColor Gray
    } else {
        Write-Host "  No old backups to remove" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Backup completed successfully! ✓" -ForegroundColor Green
    exit 0

} catch {
    Write-Host "ERROR: Backup failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
