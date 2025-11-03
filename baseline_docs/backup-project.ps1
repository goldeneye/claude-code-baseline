<#
.SYNOPSIS
    Creates a timestamped backup of a project directory with configurable exclusions.

.DESCRIPTION
    This script backs up a source directory to a timestamped folder, excluding specified patterns.
    Automatically detects the project name from the source path.
    Reports file counts and validates backup integrity.

.PARAMETER SourcePath
    The path to the project directory to backup.
    Default: Current directory

.PARAMETER BackupBase
    The base directory where backups will be stored.
    Default: E:\backups

.PARAMETER ExcludePatterns
    Array of wildcard patterns for files/folders to exclude.
    Default: Common development artifacts (node_modules, vendor, logs, etc.)

.PARAMETER ProjectName
    Override the auto-detected project name for the backup folder.
    Default: Auto-detected from SourcePath

.EXAMPLE
    .\backup-project.ps1
    Backs up current directory to E:\backups\{project-name}-{timestamp}

.EXAMPLE
    .\backup-project.ps1 -SourcePath "C:\projects\my-app" -BackupBase "D:\backups"
    Backs up specified project to custom backup location

.EXAMPLE
    .\backup-project.ps1 -ExcludePatterns @("*.log","*.tmp","node_modules")
    Backs up with custom exclusion patterns

.NOTES
    Author: ComplianceScorecard Dev Team
    Version: 2.0
    Last Updated: January 2025
#>

[CmdletBinding()]
param(
    [Parameter(
        Position = 0,
        ValueFromPipeline = $true,
        HelpMessage = "Path to the project directory to backup"
    )]
    [ValidateScript({
        if (-not (Test-Path $_ -PathType Container)) {
            throw "Source path '$_' does not exist or is not a directory"
        }
        $true
    })]
    [string]$SourcePath = (Get-Location).Path,

    [Parameter(
        Position = 1,
        HelpMessage = "Base directory for backups"
    )]
    [string]$BackupBase = "E:\backups",

    [Parameter(
        HelpMessage = "Array of exclusion patterns (wildcards supported)"
    )]
    [string[]]$ExcludePatterns = @(
        # Build artifacts
        "*node_modules*",
        "*vendor*",
        "*bower_components*",
        "*packages*",

        # Version control
        "*.git*",
        "*.svn*",

        # IDE and editor files
        "*.vs*",
        "*.vscode*",
        "*.idea*",
        "*.DS_Store*",

        # Temporary files
        "*.tmp",
        "*.temp",
        "*.cache",
        "*.bak",
        "*.bac",
        "*.old",

        # Logs
        "*log*",
        "*.log",

        # Build outputs
        "*build*",
        "*dist*",
        "*bin*",
        "*obj*",

        # Storage and uploads
        "*storage*",
        "*uploads*",

        # Framework specific
        "*frameworks*",

        # Testing
        "*test*",
        "*tests*",
        "*coverage*",

        # Documentation (optional - remove if you want to backup docs)
        "*doc*",
        "*docs*",

        # WIP and backup folders
        "*WIP*",
        "*backup*",

        # Reserved names
        "nul"
    ),

    [Parameter(
        HelpMessage = "Override project name for backup folder"
    )]
    [string]$ProjectName = $null
)

# Clear screen for clean output
Clear-Host

#region Functions

<#
.SYNOPSIS
    Tests if a path matches any exclusion patterns
#>
function Test-ShouldExclude {
    param(
        [string]$Path,
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($Path -like $pattern) {
            return $true
        }
    }
    return $false
}

<#
.SYNOPSIS
    Gets the project name from the source path
#>
function Get-ProjectName {
    param([string]$Path)

    $dirInfo = Get-Item -Path $Path
    return $dirInfo.Name
}

<#
.SYNOPSIS
    Formats file size for display
#>
function Format-FileSize {
    param([long]$Size)

    if ($Size -gt 1GB) {
        return "{0:N2} GB" -f ($Size / 1GB)
    }
    elseif ($Size -gt 1MB) {
        return "{0:N2} MB" -f ($Size / 1MB)
    }
    elseif ($Size -gt 1KB) {
        return "{0:N2} KB" -f ($Size / 1KB)
    }
    else {
        return "{0:N0} bytes" -f $Size
    }
}

#endregion Functions

#region Validation

# Ensure backup base directory exists
if (-not (Test-Path $BackupBase)) {
    Write-Host "`nCreating backup base directory: $BackupBase" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $BackupBase -Force | Out-Null
}

# Resolve full paths
$SourcePath = (Resolve-Path $SourcePath).Path

# Detect project name
if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = Get-ProjectName -Path $SourcePath
}

#endregion Validation

#region Backup Process

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  PROJECT BACKUP UTILITY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Project Name : " -NoNewline
Write-Host $ProjectName -ForegroundColor Green

Write-Host "Source Path  : " -NoNewline
Write-Host $SourcePath -ForegroundColor Green

Write-Host "Backup Base  : " -NoNewline
Write-Host $BackupBase -ForegroundColor Green

Write-Host "`nExclusion Patterns:" -ForegroundColor Yellow
$ExcludePatterns | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkGray }

# Check for reserved names (optional reporting)
if ($ExcludePatterns -contains 'nul') {
    $reservedFiles = Get-ChildItem -Path $SourcePath -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq 'nul' }

    if ($reservedFiles) {
        Write-Host "`nReserved names found (will be skipped):" -ForegroundColor Yellow
        $reservedFiles | ForEach-Object {
            Write-Host "  - $($_.FullName)" -ForegroundColor DarkYellow
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STARTING BACKUP..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Generate timestamp and create destination folder
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$destinationPath = Join-Path $BackupBase "$ProjectName-$timestamp"

Write-Host "Creating backup directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null

Write-Host "Backup Location: " -NoNewline
Write-Host $destinationPath -ForegroundColor Green
Write-Host ""

# Track statistics
$copiedCount = 0
$totalSize = 0
$startTime = Get-Date

# Gather files, apply exclusions, then copy
Write-Host "Copying files..." -ForegroundColor Yellow

Get-ChildItem -Path $SourcePath -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
    -not (Test-ShouldExclude -Path $_.FullName -Patterns $ExcludePatterns)
} | ForEach-Object {
    try {
        # Compute relative path under $SourcePath
        $relativePath = $_.FullName.Substring($SourcePath.Length).TrimStart('\', '/')
        $destFull = Join-Path $destinationPath $relativePath

        # Ensure target directory exists
        $destDir = Split-Path $destFull -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force -ErrorAction Stop | Out-Null
        }

        # Copy file
        Copy-Item -Path $_.FullName -Destination $destFull -Force -ErrorAction Stop

        # Update statistics
        $copiedCount++
        $totalSize += $_.Length

        # Show progress every 10 files
        if ($copiedCount % 10 -eq 0) {
            Write-Host "." -NoNewline -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "`nError copying $($_.FullName): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n"

$endTime = Get-Date
$duration = $endTime - $startTime

#endregion Backup Process

#region Validation & Reporting

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VALIDATING BACKUP..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Count files in source (after exclusions)
$sourceCount = (Get-ChildItem -Path $SourcePath -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
    -not (Test-ShouldExclude -Path $_.FullName -Patterns $ExcludePatterns)
}).Count

# Count files in destination
$destCount = (Get-ChildItem -Path $destinationPath -Recurse -File -ErrorAction SilentlyContinue).Count

# Calculate destination size
$destSize = (Get-ChildItem -Path $destinationPath -Recurse -File -ErrorAction SilentlyContinue |
    Measure-Object -Property Length -Sum).Sum

# Display results
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BACKUP COMPLETE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Project       : " -NoNewline
Write-Host $ProjectName -ForegroundColor Green

Write-Host "Source        : " -NoNewline
Write-Host $SourcePath -ForegroundColor Green

Write-Host "Destination   : " -NoNewline
Write-Host $destinationPath -ForegroundColor Green

Write-Host "`nStatistics:" -ForegroundColor Cyan
Write-Host "  Files in source (after exclusions): " -NoNewline
Write-Host $sourceCount -ForegroundColor Yellow

Write-Host "  Files in backup                   : " -NoNewline
Write-Host $destCount -ForegroundColor Yellow

Write-Host "  Total backup size                 : " -NoNewline
Write-Host (Format-FileSize -Size $destSize) -ForegroundColor Yellow

Write-Host "  Duration                          : " -NoNewline
Write-Host ("{0:N2} seconds" -f $duration.TotalSeconds) -ForegroundColor Yellow

# Validation
Write-Host "`nValidation:" -ForegroundColor Cyan

if ($sourceCount -eq $destCount) {
    Write-Host "  ✓ File count matches" -ForegroundColor Green
    Write-Host "  ✓ Backup completed successfully!" -ForegroundColor Green
    $exitCode = 0
}
else {
    Write-Host "  ✗ File count mismatch!" -ForegroundColor Red
    Write-Host "    Expected: $sourceCount files" -ForegroundColor Yellow
    Write-Host "    Found   : $destCount files" -ForegroundColor Yellow
    Write-Host "  ⚠ Please review backup integrity" -ForegroundColor Yellow
    $exitCode = 1
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

#endregion Validation & Reporting

# Return exit code
exit $exitCode
