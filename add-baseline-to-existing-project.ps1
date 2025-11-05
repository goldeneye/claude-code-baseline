<#
.SYNOPSIS
    Safely adds baseline documentation to an existing project without overwriting files.

.DESCRIPTION
    This script adds the baseline documentation pack to existing projects with complete
    safety measures. It never overwrites existing files, creates backups, handles conflicts
    intelligently, and can rollback if anything goes wrong.

.PARAMETER ProjectPath
    The path to the existing project where baseline will be added (required).

.PARAMETER BaselinePath
    Path to the baseline template directory.
    Default: Current script directory

.PARAMETER ConfigFile
    Optional JSON file containing template variable values.

.PARAMETER Components
    Components to add (comma-separated).
    Options: baseline-docs, coding-standards, claude-wip, claude-config, agents, scripts, gitignore, all
    Default: all

.PARAMETER ConflictStrategy
    How to handle file conflicts.
    Options: skip, suffix, interactive, alternate-directory
    Default: suffix

.PARAMETER CreateBackup
    Whether to create backup before changes.
    Default: $true (strongly recommended)

.PARAMETER BackupStrategy
    Backup strategy to use.
    Options: full, selective, git-stash
    Default: selective

.PARAMETER DryRun
    Preview changes without making any modifications.

.PARAMETER Force
    Skip confirmation prompts.

.PARAMETER SkipVariables
    Skip template variable replacement.

.PARAMETER LogFile
    Path to log file for detailed logging.
    Default: baseline-addition.log in project directory

.EXAMPLE
    .\add-baseline-to-existing-project.ps1 -ProjectPath "E:\myproject"

    Adds baseline to existing project with interactive prompts.

.EXAMPLE
    .\add-baseline-to-existing-project.ps1 -ProjectPath "E:\myproject" -DryRun

    Preview what would be added without making changes.

.EXAMPLE
    .\add-baseline-to-existing-project.ps1 -ProjectPath "E:\myproject" -Components baseline-docs,claude-wip

    Add only specific components.

.EXAMPLE
    .\add-baseline-to-existing-project.ps1 -ProjectPath "E:\myproject" -ConfigFile "config.json" -Force

    Fully automated addition with configuration file.

.NOTES
    Author: ComplianceScorecard Dev Team
    Version: 1.0
    Last Updated: January 2025

    SAFETY FIRST: This script will NEVER overwrite existing files without explicit consent.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(
        Mandatory = $true,
        Position = 0,
        HelpMessage = "Path to the existing project"
    )]
    [ValidateScript({
        if (-not (Test-Path $_ -PathType Container)) {
            throw "Project path '$_' does not exist or is not a directory"
        }
        $true
    })]
    [string]$ProjectPath,

    [Parameter(HelpMessage = "Path to baseline template directory")]
    [string]$BaselinePath = (Split-Path -Parent $PSCommandPath),

    [Parameter(HelpMessage = "JSON configuration file with template variables")]
    [string]$ConfigFile,

    [Parameter(HelpMessage = "Components to add")]
    [ValidateSet("baseline-docs", "coding-standards", "claude-wip", "claude-config", "agents", "scripts", "gitignore", "all")]
    [string[]]$Components = @("all"),

    [Parameter(HelpMessage = "Conflict resolution strategy")]
    [ValidateSet("skip", "suffix", "interactive", "alternate-directory")]
    [string]$ConflictStrategy = "suffix",

    [Parameter(HelpMessage = "Create backup before changes")]
    [bool]$CreateBackup = $true,

    [Parameter(HelpMessage = "Backup strategy")]
    [ValidateSet("full", "selective", "git-stash")]
    [string]$BackupStrategy = "selective",

    [Parameter(HelpMessage = "Preview mode - no changes made")]
    [switch]$DryRun,

    [Parameter(HelpMessage = "Skip confirmation prompts")]
    [switch]$Force,

    [Parameter(HelpMessage = "Skip template variable replacement")]
    [switch]$SkipVariables,

    [Parameter(HelpMessage = "Log file path")]
    [string]$LogFile
)

#region Configuration

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Statistics
$script:Stats = @{
    FilesAdded = 0
    FilesSkipped = 0
    ConflictsDetected = 0
    BackupCreated = $false
    StartTime = Get-Date
}

# Set log file path
if ([string]::IsNullOrWhiteSpace($LogFile)) {
    $LogFile = Join-Path $ProjectPath "baseline-addition.log"
}

#endregion Configuration

#region Helper Functions

function Write-Header {
    param([string]$Text)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "  [OK] $Text" -ForegroundColor Green
}

function Write-Info {
    param([string]$Text)
    Write-Host "  > $Text" -ForegroundColor Yellow
}

function Write-Conflict {
    param([string]$Text)
    Write-Host "  [!] $Text" -ForegroundColor Yellow
}

function Write-Skip {
    param([string]$Text)
    Write-Host "  [SKIP] $Text" -ForegroundColor DarkGray
}

function Write-Detail {
    param([string]$Text)
    Write-Host "    $Text" -ForegroundColor DarkGray
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Test-Prerequisites {
    <#
    .SYNOPSIS
        Performs pre-flight checks before adding baseline
    #>
    Write-Info "Running pre-flight checks..."
    Write-Log "Starting pre-flight checks"

    # Check if project path exists
    if (!(Test-Path $ProjectPath)) {
        throw "Project path does not exist: $ProjectPath"
    }
    Write-Detail "Project directory exists"

    # Check write permissions
    try {
        $testFile = Join-Path $ProjectPath ".baseline-write-test"
        "test" | Out-File $testFile -ErrorAction Stop
        Remove-Item $testFile -ErrorAction SilentlyContinue
        Write-Detail "Write permissions verified"
    } catch {
        throw "No write permissions in project directory: $ProjectPath"
    }

    # Check disk space
    $drive = (Get-Item $ProjectPath).PSDrive
    $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
    if ($drive.Free -lt 100MB) {
        throw "Insufficient disk space. Only $freeSpaceGB GB free."
    }
    Write-Detail "Disk space sufficient ($freeSpaceGB GB free)"

    # Check if baseline path exists
    if (!(Test-Path $BaselinePath)) {
        throw "Baseline path not found: $BaselinePath"
    }
    Write-Detail "Baseline template found"

    # Check Git status if Git repo
    if (Test-Path (Join-Path $ProjectPath ".git")) {
        Push-Location $ProjectPath
        try {
            $gitStatus = git status --porcelain 2>$null
            if ($gitStatus -and !$Force) {
                Write-Conflict "Git repository has uncommitted changes"
                Write-Detail "Run with -Force to proceed anyway"
                $response = Read-Host "Continue? (y/N)"
                if ($response -ne 'y' -and $response -ne 'Y') {
                    throw "Operation cancelled by user"
                }
            } elseif ($gitStatus) {
                Write-Conflict "Git repository has uncommitted changes (proceeding with -Force)"
            }
        } finally {
            Pop-Location
        }
    }

    Write-Success "Pre-flight checks passed"
    Write-Log "Pre-flight checks completed successfully"
}

function Get-FileMapping {
    <#
    .SYNOPSIS
        Returns mapping of source files to destination with conflict strategies
    #>
    $mapping = @()

    # Baseline documentation files
    if ($Components -contains "all" -or $Components -contains "baseline-docs") {
        $baselineDocs = Get-ChildItem (Join-Path $BaselinePath "baseline_docs") -Recurse -File
        foreach ($file in $baselineDocs) {
            $relativePath = $file.FullName.Substring((Join-Path $BaselinePath "baseline_docs").Length).TrimStart('\', '/')
            $mapping += @{
                Source = $file.FullName
                Destination = Join-Path $ProjectPath "docs\baseline\$relativePath"
                Component = "baseline-docs"
                ConflictAction = "Suffix"
            }
        }
    }

    # Coding standards
    if ($Components -contains "all" -or $Components -contains "coding-standards") {
        $codingStandards = Get-ChildItem (Join-Path $BaselinePath "coding-standards") -Recurse -File
        foreach ($file in $codingStandards) {
            $relativePath = $file.FullName.Substring((Join-Path $BaselinePath "coding-standards").Length).TrimStart('\', '/')

            # Check if coding-standards directory already exists
            $destDir = Join-Path $ProjectPath "docs\coding-standards"
            if (Test-Path $destDir) {
                # Use alternate directory
                $destDir = Join-Path $ProjectPath "docs\coding-standards-baseline"
            }

            $mapping += @{
                Source = $file.FullName
                Destination = Join-Path $destDir $relativePath
                Component = "coding-standards"
                ConflictAction = "AlternateDirectory"
            }
        }
    }

    # Claude WIP directory
    if ($Components -contains "all" -or $Components -contains "claude-wip") {
        $claudeWipReadme = Join-Path $BaselinePath "claude_wip\README.md"
        if (Test-Path $claudeWipReadme) {
            $mapping += @{
                Source = $claudeWipReadme
                Destination = Join-Path $ProjectPath "claude_wip\README.md"
                Component = "claude-wip"
                ConflictAction = "Skip"
            }
        }
    }

    # .claude directory (agents, settings, memory)
    if ($Components -contains "all" -or $Components -contains "claude-config") {
        $claudeConfigPath = Join-Path $BaselinePath ".claude"
        if (Test-Path $claudeConfigPath) {
            $claudeFiles = Get-ChildItem $claudeConfigPath -Recurse -File
            foreach ($file in $claudeFiles) {
                $relativePath = $file.FullName.Substring($claudeConfigPath.Length).TrimStart('\', '/')
                $mapping += @{
                    Source = $file.FullName
                    Destination = Join-Path $ProjectPath ".claude\$relativePath"
                    Component = "claude-config"
                    ConflictAction = "Skip"
                }
            }
        }
    }

    # agents directory (agent definitions and documentation)
    if ($Components -contains "all" -or $Components -contains "agents") {
        $agentsPath = Join-Path $BaselinePath "agents"
        if (Test-Path $agentsPath) {
            $agentFiles = Get-ChildItem $agentsPath -Recurse -File
            foreach ($file in $agentFiles) {
                $relativePath = $file.FullName.Substring($agentsPath.Length).TrimStart('\', '/')
                $mapping += @{
                    Source = $file.FullName
                    Destination = Join-Path $ProjectPath "agents\$relativePath"
                    Component = "agents"
                    ConflictAction = "Skip"
                }
            }
        }
    }

    # Scripts
    if ($Components -contains "all" -or $Components -contains "scripts") {
        $backupScript = Join-Path $BaselinePath "baseline_docs\backup-project.ps1"
        if (Test-Path $backupScript) {
            $mapping += @{
                Source = $backupScript
                Destination = Join-Path $ProjectPath "scripts\backup-project.ps1"
                Component = "scripts"
                ConflictAction = "Suffix"
            }
        }
    }

    # CLAUDE.md reference file (always create with alternate name)
    $claudeMd = Join-Path $BaselinePath "CLAUDE.md"
    if (Test-Path $claudeMd) {
        $mapping += @{
            Source = $claudeMd
            Destination = Join-Path $ProjectPath "CLAUDE-baseline.md"
            Component = "reference"
            ConflictAction = "AlwaysSuffix"
            Note = "Reference file - merge manually into existing CLAUDE.md"
        }
    }

    return $mapping
}

function Get-ConflictingFiles {
    <#
    .SYNOPSIS
        Scans for files that would conflict with baseline addition
    #>
    param([array]$FileMapping)

    $conflicts = @()

    foreach ($item in $FileMapping) {
        if (Test-Path $item.Destination) {
            $conflicts += $item
        }
    }

    return $conflicts
}

function New-BackupDirectory {
    <#
    .SYNOPSIS
        Creates backup of project before making changes
    #>
    param([string]$Strategy)

    if (!$CreateBackup) {
        Write-Info "Backup skipped (CreateBackup = false)"
        return $null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = Join-Path $ProjectPath ".baseline-backup-$timestamp"

    Write-Info "Creating backup..."
    Write-Log "Creating backup with strategy: $Strategy"

    try {
        switch ($Strategy) {
            "full" {
                # Full backup excluding common large directories
                $excludeDirs = @("node_modules", "vendor", ".git", "dist", "build")
                New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

                Get-ChildItem $ProjectPath -Recurse | Where-Object {
                    $item = $_
                    $exclude = $false
                    foreach ($dir in $excludeDirs) {
                        if ($item.FullName -like "*\$dir\*") {
                            $exclude = $true
                            break
                        }
                    }
                    !$exclude
                } | ForEach-Object {
                    $dest = $_.FullName.Replace($ProjectPath, $backupPath)
                    $destDir = Split-Path $dest -Parent
                    if (!(Test-Path $destDir)) {
                        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                    }
                    if (!$_.PSIsContainer) {
                        Copy-Item $_.FullName $dest -Force
                    }
                }
            }

            "selective" {
                # Backup only potentially affected files
                New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

                $pathsToBackup = @(
                    "CLAUDE.md",
                    "docs",
                    "claude_wip",
                    "scripts",
                    ".gitignore"
                )

                foreach ($path in $pathsToBackup) {
                    $fullPath = Join-Path $ProjectPath $path
                    if (Test-Path $fullPath) {
                        $destPath = Join-Path $backupPath $path
                        $destDir = Split-Path $destPath -Parent

                        if (!(Test-Path $destDir)) {
                            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                        }

                        if (Test-Path $fullPath -PathType Container) {
                            Copy-Item $fullPath $destPath -Recurse -Force
                        } else {
                            Copy-Item $fullPath $destPath -Force
                        }
                    }
                }
            }

            "git-stash" {
                if (Test-Path (Join-Path $ProjectPath ".git")) {
                    Push-Location $ProjectPath
                    try {
                        git stash push -m "Pre-baseline-addition backup $timestamp" 2>&1 | Out-Null
                        Write-Detail "Changes stashed in Git"
                        return "git-stash:$timestamp"
                    } finally {
                        Pop-Location
                    }
                } else {
                    Write-Conflict "Git not available, falling back to selective backup"
                    return New-BackupDirectory -Strategy "selective"
                }
            }
        }

        # Calculate backup size
        if ($Strategy -ne "git-stash") {
            $backupSize = (Get-ChildItem $backupPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
            $backupSizeMB = [math]::Round($backupSize / 1MB, 2)
            Write-Detail "Backup size: $backupSizeMB MB"
        }

        Write-Success "Backup created: $backupPath"
        Write-Log "Backup created successfully at: $backupPath"

        $script:Stats.BackupCreated = $true
        return $backupPath

    } catch {
        Write-Error "Backup creation failed: $($_.Exception.Message)"
        Write-Log "Backup creation failed: $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function Add-BaselineFiles {
    <#
    .SYNOPSIS
        Adds baseline files to project with conflict handling
    #>
    param(
        [array]$FileMapping,
        [hashtable]$Variables
    )

    Write-Info "Adding baseline components..."
    Write-Log "Starting file addition"

    $added = @()
    $skipped = @()

    # Group by component
    $byComponent = $FileMapping | Group-Object -Property Component

    $componentNum = 1
    $totalComponents = $byComponent.Count

    foreach ($group in $byComponent) {
        Write-Host "`n  [$componentNum/$totalComponents] $($group.Name)" -ForegroundColor Cyan

        foreach ($item in $group.Group) {
            $dest = $item.Destination

            # Check for conflict
            if (Test-Path $dest) {
                $script:Stats.ConflictsDetected++

                # Handle based on strategy
                switch ($ConflictStrategy) {
                    "skip" {
                        Write-Skip "$(Split-Path $dest -Leaf) (already exists)"
                        $skipped += $dest
                        $script:Stats.FilesSkipped++
                        continue
                    }

                    "suffix" {
                        # Add .baseline suffix
                        $dest = "$dest.baseline"
                        Write-Conflict "$(Split-Path $item.Destination -Leaf) exists, creating $(Split-Path $dest -Leaf)"
                    }

                    "interactive" {
                        Write-Conflict "$(Split-Path $dest -Leaf) already exists"
                        Write-Host "    [S] Skip  [B] Backup and replace  [R] Rename new file" -ForegroundColor DarkGray
                        $choice = Read-Host "    Choose"

                        switch ($choice.ToUpper()) {
                            "S" {
                                $skipped += $dest
                                $script:Stats.FilesSkipped++
                                continue
                            }
                            "B" {
                                $backupFile = "$dest.backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
                                Move-Item $dest $backupFile -Force
                                Write-Detail "Backed up to $(Split-Path $backupFile -Leaf)"
                            }
                            "R" {
                                $dest = "$dest.baseline"
                            }
                            default {
                                $skipped += $dest
                                $script:Stats.FilesSkipped++
                                continue
                            }
                        }
                    }

                    "alternate-directory" {
                        # Already handled in GetFileMapping
                        Write-Info "$(Split-Path $dest -Leaf)"
                    }
                }
            }

            # Create parent directories
            $destDir = Split-Path $dest -Parent
            if (!(Test-Path $destDir)) {
                if (!$DryRun) {
                    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                }
            }

            # Copy file
            if (!$DryRun) {
                try {
                    Copy-Item $item.Source $dest -Force -ErrorAction Stop

                    # Replace variables if not skipped
                    if (!$SkipVariables -and $Variables) {
                        $content = Get-Content $dest -Raw -ErrorAction SilentlyContinue
                        if ($content) {
                            foreach ($var in $Variables.GetEnumerator()) {
                                $pattern = "{{$($var.Key)}}"
                                $content = $content -replace [regex]::Escape($pattern), $var.Value
                            }
                            Set-Content -Path $dest -Value $content -NoNewline
                        }
                    }

                    $added += $dest
                    $script:Stats.FilesAdded++

                } catch {
                    Write-Error "Failed to copy $($item.Source): $($_.Exception.Message)"
                    Write-Log "Failed to copy file: $($_.Exception.Message)" -Level "ERROR"
                }
            }

            Write-Success "$(Split-Path $dest -Leaf)"
        }

        $componentNum++
    }

    Write-Log "File addition completed. Added: $($added.Count), Skipped: $($skipped.Count)"

    return @{
        Added = $added
        Skipped = $skipped
    }
}

function Update-GitIgnore {
    <#
    .SYNOPSIS
        Adds baseline entries to .gitignore
    #>
    param([string]$ProjectPath)

    $gitignorePath = Join-Path $ProjectPath ".gitignore"
    $entries = @(
        "",
        "# Claude Code working directory",
        "claude_wip/",
        "!claude_wip/README.md",
        "!claude_wip/**/.gitkeep",
        "",
        "# Baseline backup directories",
        ".baseline-backup-*/",
        "",
        "# Baseline addition log",
        "baseline-addition.log"
    )

    if (Test-Path $gitignorePath) {
        # Read existing content
        $existingContent = Get-Content $gitignorePath -Raw

        # Check if claude_wip already ignored
        if ($existingContent -match "claude_wip") {
            Write-Info ".gitignore already contains claude_wip entry"
            return
        }

        # Append entries
        if (!$DryRun) {
            Add-Content -Path $gitignorePath -Value ($entries -join "`n")
        }
        Write-Success "Updated .gitignore"
        Write-Log "Updated .gitignore with baseline entries"
    } else {
        # Create new .gitignore
        if (!$DryRun) {
            Set-Content -Path $gitignorePath -Value ($entries -join "`n")
        }
        Write-Success "Created .gitignore"
        Write-Log "Created new .gitignore"
    }
}

function Get-TemplateVariables {
    <#
    .SYNOPSIS
        Collects template variable values
    #>
    param([string]$ConfigPath)

    $variables = @{}

    # Load from config if provided
    if ($ConfigPath -and (Test-Path $ConfigPath)) {
        Write-Info "Loading configuration from: $ConfigPath"
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        $config.PSObject.Properties | ForEach-Object {
            $variables[$_.Name] = $_.Value
        }
    }

    # Set defaults
    $variables['DATE'] = Get-Date -Format "yyyy-MM-dd"
    $variables['REPO_PATH'] = $ProjectPath
    $variables['CLAUDE_WIP_PATH'] = Join-Path $ProjectPath "claude_wip"

    # Prompt for missing required variables
    if (!$Force -and !$SkipVariables) {
        $requiredVars = @{
            'PROJECT_NAME' = 'Project name'
            'CONTACT_EMAIL' = 'Contact email address'
            'DOMAIN' = 'Project domain'
        }

        Write-Host "`nTemplate Variables:" -ForegroundColor Cyan
        foreach ($var in $requiredVars.GetEnumerator()) {
            if ([string]::IsNullOrWhiteSpace($variables[$var.Key])) {
                Write-Host "  $($var.Value): " -ForegroundColor Yellow -NoNewline
                $value = Read-Host
                if (![string]::IsNullOrWhiteSpace($value)) {
                    $variables[$var.Key] = $value
                }
            }
        }
    }

    return $variables
}

function Restore-FromBackup {
    <#
    .SYNOPSIS
        Restores project from backup
    #>
    param([string]$BackupPath)

    if (!$BackupPath) {
        Write-Warning "No backup path provided for restore"
        return
    }

    Write-Info "Restoring from backup..."
    Write-Log "Starting restore from: $BackupPath"

    try {
        if ($BackupPath -like "git-stash:*") {
            # Restore from Git stash
            $timestamp = $BackupPath.Split(':')[1]
            Push-Location $ProjectPath
            try {
                git stash list | Select-String $timestamp | ForEach-Object {
                    $stashRef = $_.ToString().Split(':')[0]
                    git stash pop $stashRef 2>&1 | Out-Null
                }
            } finally {
                Pop-Location
            }
        } else {
            # Restore from directory backup
            if (Test-Path $BackupPath) {
                Copy-Item "$BackupPath\*" $ProjectPath -Recurse -Force
            }
        }

        Write-Success "Project restored from backup"
        Write-Log "Restore completed successfully"
    } catch {
        Write-Error "Restore failed: $($_.Exception.Message)"
        Write-Log "Restore failed: $($_.Exception.Message)" -Level "ERROR"
    }
}

function Show-Summary {
    <#
    .SYNOPSIS
        Displays operation summary
    #>
    param(
        [string]$BackupPath,
        [array]$AddedFiles,
        [array]$SkippedFiles
    )

    $duration = (Get-Date) - $script:Stats.StartTime
    $durationSeconds = [math]::Round($duration.TotalSeconds, 2)

    Write-Header "BASELINE ADDITION COMPLETE"

    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "  Files Added    : " -NoNewline
    Write-Host $script:Stats.FilesAdded -ForegroundColor Yellow
    Write-Host "  Files Skipped  : " -NoNewline
    Write-Host $script:Stats.FilesSkipped -ForegroundColor Yellow
    Write-Host "  Conflicts      : " -NoNewline
    Write-Host $script:Stats.ConflictsDetected -ForegroundColor Yellow
    Write-Host "  Duration       : " -NoNewline
    Write-Host "$durationSeconds seconds" -ForegroundColor Yellow

    if ($BackupPath) {
        Write-Host "  Backup Location: " -NoNewline
        Write-Host $BackupPath -ForegroundColor Yellow
    }

    Write-Host "  Log File       : " -NoNewline
    Write-Host $LogFile -ForegroundColor Yellow

    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  1. Review CLAUDE-baseline.md and merge into your CLAUDE.md"
    Write-Host "  2. Customize docs/coding-standards/ for your project"
    Write-Host "  3. Replace template variables if needed"
    Write-Host "  4. Remove backup after verification:"
    Write-Host "     Remove-Item '$BackupPath' -Recurse -Force" -ForegroundColor DarkGray

    if ($SkippedFiles.Count -gt 0) {
        Write-Host "`nFiles Skipped (conflicts):" -ForegroundColor Yellow
        $SkippedFiles | Select-Object -First 10 | ForEach-Object {
            Write-Host "  - $(Split-Path $_ -Leaf)" -ForegroundColor DarkGray
        }
        if ($SkippedFiles.Count -gt 10) {
            Write-Host "  ... and $($SkippedFiles.Count - 10) more" -ForegroundColor DarkGray
        }
    }

    Write-Host "`nUseful Commands:" -ForegroundColor Cyan
    Write-Host "  # Compare CLAUDE.md files"
    Write-Host "  git diff --no-index CLAUDE.md CLAUDE-baseline.md" -ForegroundColor DarkGray
    Write-Host "`n  # Review backup contents"
    Write-Host "  Get-ChildItem '$BackupPath' -Recurse" -ForegroundColor DarkGray

    Write-Host "`n========================================`n" -ForegroundColor Cyan
}

#endregion Helper Functions

#region Main Execution

try {
    Clear-Host

    # Header
    if ($DryRun) {
        Write-Header "ADD BASELINE - DRY RUN MODE"
        Write-Host "  No changes will be made to your project" -ForegroundColor Yellow
    } else {
        Write-Header "ADD BASELINE TO EXISTING PROJECT"
    }

    Write-Host "Project: $ProjectPath" -ForegroundColor Green
    Write-Host "Baseline: $BaselinePath`n" -ForegroundColor Green

    # Step 1: Pre-flight checks
    Test-Prerequisites

    # Step 2: Get file mapping
    Write-Info "Scanning baseline files..."
    $fileMapping = Get-FileMapping
    Write-Detail "Found $($fileMapping.Count) files to process"
    Write-Log "File mapping created: $($fileMapping.Count) files"

    # Step 3: Detect conflicts
    Write-Info "Checking for conflicts..."
    $conflicts = Get-ConflictingFiles -FileMapping $fileMapping

    if ($conflicts.Count -gt 0) {
        Write-Conflict "$($conflicts.Count) file(s) already exist"
        $conflicts | Select-Object -First 5 | ForEach-Object {
            Write-Detail "$(Split-Path $_.Destination -Leaf)"
        }
        if ($conflicts.Count -gt 5) {
            Write-Detail "... and $($conflicts.Count - 5) more"
        }
    } else {
        Write-Success "No conflicts detected"
    }

    # Step 4: Get template variables
    if (!$SkipVariables) {
        $variables = Get-TemplateVariables -ConfigPath $ConfigFile
        Write-Log "Template variables collected: $($variables.Keys -join ', ')"
    }

    # Confirmation
    if (!$Force -and !$DryRun) {
        Write-Host "`nProceed with baseline addition? [Y/n]: " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
        if ($response -eq 'n' -or $response -eq 'N') {
            Write-Host "Operation cancelled by user" -ForegroundColor Yellow
            exit 0
        }
    }

    if ($DryRun) {
        Write-Header "DRY RUN SUMMARY"
        Write-Host "Would add $($fileMapping.Count - $conflicts.Count) files" -ForegroundColor Yellow
        Write-Host "Would skip $($conflicts.Count) files (conflicts)" -ForegroundColor Yellow
        Write-Host "`nRun without -DryRun to apply changes" -ForegroundColor Cyan
        exit 0
    }

    # Step 5: Create backup
    $backupPath = $null
    if ($CreateBackup) {
        $backupPath = New-BackupDirectory -Strategy $BackupStrategy
    }

    # Step 6: Add files
    $results = Add-BaselineFiles -FileMapping $fileMapping -Variables $variables

    # Step 7: Update .gitignore
    if ($Components -contains "all" -or $Components -contains "gitignore") {
        Write-Host "`nUpdating .gitignore..." -ForegroundColor Cyan
        Update-GitIgnore -ProjectPath $ProjectPath
    }

    # Step 8: Create claude_wip structure
    if ($Components -contains "all" -or $Components -contains "claude-wip") {
        Write-Host "`nCreating claude_wip structure..." -ForegroundColor Cyan
        $subdirs = @("drafts", "analysis", "scratch", "backups")
        foreach ($subdir in $subdirs) {
            $path = Join-Path $ProjectPath "claude_wip\$subdir"
            if (!(Test-Path $path)) {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
                New-Item -ItemType File -Path (Join-Path $path ".gitkeep") -Force | Out-Null
                Write-Success "$subdir/"
            }
        }
    }

    # Step 9: Summary
    Show-Summary -BackupPath $backupPath -AddedFiles $results.Added -SkippedFiles $results.Skipped

    Write-Log "Baseline addition completed successfully"
    exit 0

} catch {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "  ERROR: Baseline Addition Failed" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Log "Baseline addition failed: $($_.Exception.Message)" -Level "ERROR"

    # Attempt rollback
    if ($backupPath -and $script:Stats.BackupCreated) {
        Write-Host "`nAttempting automatic rollback..." -ForegroundColor Yellow
        Restore-FromBackup -BackupPath $backupPath
    }

    exit 1
}

#endregion Main Execution
