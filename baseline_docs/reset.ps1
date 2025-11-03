# File: reset.ps1
# Purpose: Full Laravel scanner system reset with safer queue management
#          Keep ANSI colors in console; strip ANSI + compress spaces for logs

$logFile    = "{{REPO_PATH}}/storage/logs/laravel_reset.log"  
$cliLogFile = "{{REPO_PATH}}/storage/logs/cli-debug-log.txt"
$timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$divider    = "=" * 50

# Robust ANSI escape matcher (CSI + OSC + common variants)
$AnsiRegex = '\x1B\[[0-9;?]*[ -/]*[@-~]|\x1B\][^\a]*\a|\x1B[@-Z\\-_]'

function Log {
    param([string]$message)
    $ts = Get-Date -Format "HH:mm:ss"
    "$ts  $message" | Add-Content -Path $logFile
}

# Tee-Clean: mirrors to console (with color), writes cleaned to file.
function Tee-Clean {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [switch]$CompressSpaces
    )
    process {
        # Normalize to string per pipeline record
        $line = [string]$InputObject

        # 1) Show raw (keeps ANSI) in console
        $line | Out-Host

        # 2) Clean and write to file
        $clean = $line -replace $AnsiRegex, ''
        if ($CompressSpaces) { $clean = $clean -replace '\s{2,}', ' ' }
        Add-Content -Path $Path -Value $clean
    }
}

# Start fresh log
"" | Set-Content -Path $logFile
cls

Write-Host "`n$divider" -ForegroundColor Cyan
Write-Host " Laravel Full Reset Utility" -ForegroundColor Cyan
Write-Host "$divider`n" -ForegroundColor Cyan
Log "[START] Laravel Reset @ $timestamp"

# Step 1: Clear Laravel cache/state
Write-Host "Clearing config, cache, views, routes..." -ForegroundColor Yellow
Log "Clearing config, cache, views, routes"

php artisan config:clear 2>&1 | Tee-Clean -Path $logFile -CompressSpaces
php artisan view:clear   2>&1 | Tee-Clean -Path $logFile -CompressSpaces
php artisan cache:clear  2>&1 | Tee-Clean -Path $logFile -CompressSpaces
php artisan route:clear  2>&1 | Tee-Clean -Path $logFile -CompressSpaces

# Step 2: Clear database scan data
#Write-Host "Removing scan/check/WHOIS data..." -ForegroundColor Red
#Log "Removing scan/check/WHOIS data"
#php artisan database:remove_scan_data 2>&1 | Tee-Clean -Path $logFile -CompressSpaces

# Step 3: Dump autoload
Write-Host "Running composer dump-autoload..." -ForegroundColor Green
Log "Running composer dump-autoload"
composer dump-autoload 2>&1 | Tee-Clean -Path $logFile -CompressSpaces

# Step 4: Clear Laravel error log
Write-Host "Clearing laravel.log..." -ForegroundColor Gray
Log "Clearing laravel.log"
"" | Set-Content -Path "storage/logs/laravel.log"
Log "laravel.log cleared"

# Step 5: Clear scanner logs
#Write-Host "Clearing WHOIS and DNS logs..." -ForegroundColor Gray
#Log "Clearing scanners/whois.log"
#"" | Set-Content -Path "scanners/whois.log"
#Log "whois.log cleared"
#Log "Clearing scanners/dns.log"
#"" | Set-Content -Path "scanners/dns.log"
#Log "dns.log cleared"

Log "Clearing SQL/dns.log"
#"" | Set-Content -Path "E:\xampp\domainscanner\storage\logs\sql-data\*.sql"
Remove-Item "{{REPO_PATH}}\storage\logs\sql-data\*.sql" -Force -ErrorAction SilentlyContinue
Log "sql files  cleared"



#E:\xampp\domainscanner\storage\logs\sql-data

# Step 6: Delete all JSON files
Write-Host "Flushing JSON..." -ForegroundColor Blue
Log "Clearing JSON results"
Get-ChildItem -Path "scanners/output" -Filter *.json -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Log "JSON files deleted"

# Step 7: Clear CLI debug log for fresh start
Write-Host "Clearing CLI debug log..." -ForegroundColor Gray
Log "Clearing $cliLogFile"
"" | Set-Content -Path $cliLogFile
Log "cli-debug-log.txt cleared"

# Step 8: Reset queues
Write-Host "Resetting queue system..." -ForegroundColor Blue
Log "Clearing config/cache before queue start"
php artisan config:clear 2>&1 | Tee-Clean -Path $logFile -CompressSpaces
php artisan cache:clear  2>&1 | Tee-Clean -Path $logFile -CompressSpaces

Log "Flushing queue"
php artisan queue:flush  2>&1 | Tee-Clean -Path $logFile -CompressSpaces

# Done
$endTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "`n? Laravel Full Reset Complete @ $endTime" -ForegroundColor Green
Log "[COMPLETE] Laravel Reset @ $endTime"
Write-Host "$divider`n" -ForegroundColor Cyan

Log "Starting queue worker (console keeps color; file is cleaned)"
Write-Host "NOTE: All output is being logged (cleaned) to $cliLogFile" -ForegroundColor Yellow

# Queue worker: keep ANSI for console; strip ANSI + compress for file
#php artisan queue:work --queue=default,checks --sleep=1 --tries=1 --timeout=60 2>&1 |
php artisan queue:work --tries=1 --timeout=30 2>&1 |

    Tee-Clean -Path $cliLogFile -CompressSpaces
