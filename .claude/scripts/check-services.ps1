# XAMPP Services Health Check Script
param([switch]$Detailed = $false)

Write-Host "=== XAMPP Services Health Check ===" -ForegroundColor Cyan
Write-Host ""

function Check-Service {
    param([string]$ProcessName, [string]$DisplayName, [string]$ExePath = $null)
    
    Write-Host "$DisplayName Status: " -NoNewline -ForegroundColor Yellow
    $process = Get-Process $ProcessName -ErrorAction SilentlyContinue
    
    if ($process) {
        Write-Host "RUNNING" -ForegroundColor Green
        if ($Detailed) {
            Write-Host "  PID: $($process.Id)" -ForegroundColor Gray
        }
    } else {
        Write-Host "STOPPED" -ForegroundColor Red
    }
    Write-Host ""
}

# Check services
Check-Service -ProcessName "mysqld" -DisplayName "MySQL Server"
Check-Service -ProcessName "httpd" -DisplayName "Apache Server"

# Check MySQL connectivity
Write-Host "MySQL Connection: " -NoNewline -ForegroundColor Yellow
try {
    $mysqlPath = "E:\xampp\mysql\bin\mysql.exe"
    if (Test-Path $mysqlPath) {
        $result = & $mysqlPath -u root -e 'SELECT VERSION();' 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS" -ForegroundColor Green
        } else {
            Write-Host "FAILED" -ForegroundColor Red
        }
    } else {
        Write-Host "NOT FOUND" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR" -ForegroundColor Red
}
Write-Host ""

# Check tool versions
$tools = @(
    @{Name="PHP"; Path="E:\xampp\php\php.exe"; Args="-v"},
    @{Name="Python"; Path="E:\python\python.exe"; Args="--version"},
    @{Name="Composer"; Path="E:\composer\composer.bat"; Args="--version"}
)

foreach ($tool in $tools) {
    Write-Host "$($tool.Name): " -NoNewline -ForegroundColor Yellow
    if (Test-Path $tool.Path) {
        try {
            $version = & $tool.Path $tool.Args 2>&1 | Select-Object -First 1
            Write-Host "OK" -ForegroundColor Green
        } catch {
            Write-Host "ERROR" -ForegroundColor Red
        }
    } else {
        Write-Host "NOT FOUND" -ForegroundColor Red
    }
}
Write-Host ""

# Summary
Write-Host "=== Summary ===" -ForegroundColor Cyan
$mysqlRunning = Get-Process mysqld -ErrorAction SilentlyContinue
$apacheRunning = Get-Process httpd -ErrorAction SilentlyContinue

if ($mysqlRunning -and $apacheRunning) {
    Write-Host "All services running" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some services not running" -ForegroundColor Yellow
    exit 1
}
