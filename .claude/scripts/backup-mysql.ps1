# MySQL Database Backup Script
# Backs up all MySQL databases to E:\mysql_backups

param(
    [string]$BackupDir = "E:\mysql_backups",
    [string]$MysqlPath = "E:\xampp\mysql\bin",
    [string]$Username = "root",
    [string]$Password = "",
    [switch]$Compress = $true,
    [int]$RetentionDays = 30
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$mysqldump = Join-Path $MysqlPath "mysqldump.exe"
$mysql = Join-Path $MysqlPath "mysql.exe"

Write-Host "=== MySQL Database Backup ===" -ForegroundColor Cyan
Write-Host ""

# Check if MySQL is running
try {
    $mysqlProcess = Get-Process mysqld -ErrorAction SilentlyContinue
    if (-not $mysqlProcess) {
        Write-Host "WARNING: MySQL process not detected. Attempting backup anyway..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "WARNING: Could not check MySQL process status" -ForegroundColor Yellow
}

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupDir)) {
    Write-Host "Creating backup directory: $BackupDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

# Create timestamped subdirectory
$backupPath = Join-Path $BackupDir $timestamp
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

Write-Host "Backup location: $backupPath" -ForegroundColor Cyan
Write-Host ""

# Get list of databases
Write-Host "Retrieving database list..." -ForegroundColor Yellow
try {
    $passwordArg = if ($Password) { "-p$Password" } else { "" }
    $databases = & $mysql -u $Username $passwordArg -e "SHOW DATABASES;" 2>&1 |
                 Where-Object { $_ -notmatch "Database|information_schema|performance_schema|mysql|phpmyadmin" }

    if (-not $databases) {
        Write-Host "ERROR: No databases found or unable to connect to MySQL" -ForegroundColor Red
        exit 1
    }

    $dbCount = ($databases | Measure-Object).Count
    Write-Host "Found $dbCount database(s) to backup" -ForegroundColor Green
    Write-Host ""

    # Backup each database
    $successCount = 0
    $failCount = 0

    foreach ($db in $databases) {
        $db = $db.Trim()
        if ([string]::IsNullOrWhiteSpace($db)) { continue }

        Write-Host "Backing up: $db..." -ForegroundColor Yellow

        $outputFile = Join-Path $backupPath "$db.sql"

        try {
            # Execute mysqldump
            $dumpArgs = @(
                "-u", $Username,
                "--single-transaction",
                "--quick",
                "--lock-tables=false",
                $db
            )
            if ($Password) {
                $dumpArgs = @("-p$Password") + $dumpArgs
            }

            & $mysqldump $dumpArgs > $outputFile 2>&1

            if ($LASTEXITCODE -eq 0 -and (Test-Path $outputFile)) {
                $fileSize = (Get-Item $outputFile).Length / 1MB
                Write-Host "  SUCCESS: $db backed up ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green

                # Compress if enabled
                if ($Compress) {
                    Write-Host "  Compressing..." -ForegroundColor Cyan
                    Compress-Archive -Path $outputFile -DestinationPath "$outputFile.zip" -Force
                    Remove-Item $outputFile -Force
                    Write-Host "  Compressed to $db.sql.zip" -ForegroundColor Green
                }

                $successCount++
            } else {
                Write-Host "  ERROR: Backup failed for $db" -ForegroundColor Red
                $failCount++
            }
        } catch {
            Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
            $failCount++
        }

        Write-Host ""
    }

    # Create backup manifest
    $manifest = @{
        timestamp = $timestamp
        backupPath = $backupPath
        totalDatabases = $dbCount
        successful = $successCount
        failed = $failCount
        compressed = $Compress
    }
    $manifest | ConvertTo-Json | Out-File (Join-Path $backupPath "manifest.json") -Encoding UTF8

    # Cleanup old backups
    Write-Host "Cleaning up old backups (retention: $RetentionDays days)..." -ForegroundColor Yellow
    $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
    $oldBackups = Get-ChildItem $BackupDir -Directory |
                  Where-Object { $_.CreationTime -lt $cutoffDate }

    foreach ($oldBackup in $oldBackups) {
        Write-Host "  Removing: $($oldBackup.Name)" -ForegroundColor Gray
        Remove-Item $oldBackup.FullName -Recurse -Force
    }

    # Summary
    Write-Host ""
    Write-Host "=== Backup Summary ===" -ForegroundColor Cyan
    Write-Host "Total databases: $dbCount" -ForegroundColor White
    Write-Host "Successful: $successCount" -ForegroundColor Green
    Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
    Write-Host "Location: $backupPath" -ForegroundColor Cyan
    Write-Host ""

    if ($failCount -eq 0) {
        Write-Host "All backups completed successfully! ✓" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Some backups failed. Check logs above." -ForegroundColor Yellow
        exit 1
    }

} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
