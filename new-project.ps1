<#
.SYNOPSIS
    Creates a new project from the baseline template with automated setup.

.DESCRIPTION
    This script automates the creation of new projects from the baseline template.
    It copies documentation, replaces template variables, sets up directory structure,
    and optionally initializes a Git repository.

.PARAMETER ProjectName
    The name of the new project (required).
    This will replace {{PROJECT_NAME}} throughout the documentation.

.PARAMETER DestinationPath
    The full path where the new project will be created (required).
    Example: "E:\projects\my-new-project"

.PARAMETER ConfigFile
    Optional JSON file containing template variable values.
    If not provided, the script will prompt interactively.

.PARAMETER ServiceName
    The service name for the project.
    If not provided, defaults to ProjectName.

.PARAMETER ContactEmail
    Contact email for the project.
    If not provided, will prompt interactively.

.PARAMETER Domain
    Project domain (e.g., "myapp.com").
    If not provided, will prompt interactively.

.PARAMETER InitGit
    Whether to initialize a Git repository.
    Default: $true

.PARAMETER SkipGitIgnore
    Skip creating .gitignore file.
    Default: $false

.PARAMETER BaselinePath
    Path to the baseline template directory.
    Default: Current script directory

.EXAMPLE
    .\new-project.ps1 -ProjectName "MyApp" -DestinationPath "E:\projects\myapp"

    Creates a new project with interactive prompts for additional details.

.EXAMPLE
    .\new-project.ps1 -ProjectName "MyApp" -DestinationPath "E:\projects\myapp" -ConfigFile "config.json"

    Creates a new project using configuration from JSON file.

.EXAMPLE
    .\new-project.ps1 -ProjectName "MyApp" -DestinationPath "E:\projects\myapp" -ContactEmail "dev@myapp.com" -Domain "myapp.com"

    Creates a new project with specified values (no prompts).

.NOTES
    Author: ComplianceScorecard Dev Team
    Version: 1.0
    Last Updated: January 2025
    Requires: PowerShell 5.1 or higher
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(
        Mandatory = $true,
        Position = 0,
        HelpMessage = "Name of the new project"
    )]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectName,

    [Parameter(
        Mandatory = $true,
        Position = 1,
        HelpMessage = "Destination path for the new project"
    )]
    [ValidateNotNullOrEmpty()]
    [string]$DestinationPath,

    [Parameter(HelpMessage = "JSON configuration file with template variables")]
    [string]$ConfigFile,

    [Parameter(HelpMessage = "Service name (defaults to ProjectName)")]
    [string]$ServiceName,

    [Parameter(HelpMessage = "Contact email address")]
    [ValidatePattern('^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')]
    [string]$ContactEmail,

    [Parameter(HelpMessage = "Project domain")]
    [string]$Domain,

    [Parameter(HelpMessage = "Initialize Git repository")]
    [bool]$InitGit = $true,

    [Parameter(HelpMessage = "Skip .gitignore creation")]
    [bool]$SkipGitIgnore = $false,

    [Parameter(HelpMessage = "Path to baseline template directory")]
    [string]$BaselinePath = (Split-Path -Parent $PSCommandPath)
)

#region Configuration

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Default service name to project name if not provided
if ([string]::IsNullOrWhiteSpace($ServiceName)) {
    $ServiceName = $ProjectName
}

#endregion Configuration

#region Functions

function Write-Header {
    param([string]$Text)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "  ✓ $Text" -ForegroundColor Green
}

function Write-Info {
    param([string]$Text)
    Write-Host "  → $Text" -ForegroundColor Yellow
}

function Write-Detail {
    param([string]$Text)
    Write-Host "    $Text" -ForegroundColor DarkGray
}

function Get-TemplateVariables {
    <#
    .SYNOPSIS
        Gets template variable values from config file or interactive prompts
    #>
    param(
        [string]$ConfigPath,
        [hashtable]$ProvidedValues
    )

    $variables = @{}

    # Load from config file if provided
    if ($ConfigPath -and (Test-Path $ConfigPath)) {
        Write-Info "Loading configuration from: $ConfigPath"
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        $config.PSObject.Properties | ForEach-Object {
            $variables[$_.Name] = $_.Value
        }
        Write-Success "Configuration loaded"
    }

    # Add provided parameter values
    $ProvidedValues.GetEnumerator() | ForEach-Object {
        if (![string]::IsNullOrWhiteSpace($_.Value)) {
            $variables[$_.Key] = $_.Value
        }
    }

    # Set required defaults
    $variables['PROJECT_NAME'] = $ProjectName
    $variables['SERVICE_NAME'] = $ServiceName
    $variables['REPO_PATH'] = $DestinationPath
    $variables['CLAUDE_WIP_PATH'] = Join-Path $DestinationPath "claude_wip"
    $variables['DATE'] = Get-Date -Format "yyyy-MM-dd"

    # Prompt for missing required variables
    $requiredVars = @{
        'CONTACT_EMAIL' = 'Contact email address'
        'DOMAIN' = 'Project domain (e.g., myapp.com)'
    }

    foreach ($var in $requiredVars.GetEnumerator()) {
        if ([string]::IsNullOrWhiteSpace($variables[$var.Key])) {
            Write-Host "`n$($var.Value):" -ForegroundColor Yellow -NoNewline
            Write-Host " " -NoNewline
            $value = Read-Host
            if (![string]::IsNullOrWhiteSpace($value)) {
                $variables[$var.Key] = $value
            }
        }
    }

    # Prompt for optional variables
    Write-Host "`nOptional variables (press Enter to skip):" -ForegroundColor Cyan

    $optionalVars = @{
        'DOCUMENT_PURPOSE' = 'Document purpose/description'
        'AUTH0_DOMAIN' = 'Auth0 domain (e.g., tenant.auth0.com)'
        'DB_HOST' = 'Database host'
        'DB_USER' = 'Database user'
        'REDIS_HOST' = 'Redis host'
    }

    foreach ($var in $optionalVars.GetEnumerator()) {
        if ([string]::IsNullOrWhiteSpace($variables[$var.Key])) {
            Write-Host "  $($var.Value): " -ForegroundColor DarkGray -NoNewline
            $value = Read-Host
            if (![string]::IsNullOrWhiteSpace($value)) {
                $variables[$var.Key] = $value
            }
        }
    }

    return $variables
}

function Copy-BaselineFiles {
    <#
    .SYNOPSIS
        Copies baseline files to the new project
    #>
    param(
        [string]$Source,
        [string]$Destination
    )

    Write-Info "Copying baseline files..."

    # Create destination if it doesn't exist
    if (!(Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        Write-Detail "Created project directory"
    }

    # Create directory structure
    $directories = @(
        "docs\baseline",
        "docs\coding-standards",
        "claude_wip\drafts",
        "claude_wip\analysis",
        "claude_wip\scratch",
        "claude_wip\backups",
        "scripts"
    )

    foreach ($dir in $directories) {
        $fullPath = Join-Path $Destination $dir
        if (!(Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        }
    }
    Write-Detail "Created directory structure"

    # Copy CLAUDE.md
    $claudeMd = Join-Path $Source "CLAUDE.md"
    if (Test-Path $claudeMd) {
        Copy-Item $claudeMd -Destination $Destination -Force
        Write-Detail "Copied CLAUDE.md"
    }

    # Copy baseline_docs
    $baselineDocs = Join-Path $Source "baseline_docs"
    if (Test-Path $baselineDocs) {
        $destDocs = Join-Path $Destination "docs\baseline"
        Copy-Item "$baselineDocs\*" -Destination $destDocs -Recurse -Force
        Write-Detail "Copied baseline documentation"
    }

    # Copy coding standards
    $codingStandards = Join-Path $Source "coding-standards"
    if (Test-Path $codingStandards) {
        $destStandards = Join-Path $Destination "docs\coding-standards"
        Copy-Item "$codingStandards\*" -Destination $destStandards -Recurse -Force
        Write-Detail "Copied coding standards"
    }

    # Copy claude_wip README
    $claudeWipReadme = Join-Path $Source "claude_wip\README.md"
    if (Test-Path $claudeWipReadme) {
        $destReadme = Join-Path $Destination "claude_wip\README.md"
        Copy-Item $claudeWipReadme -Destination $destReadme -Force
        Write-Detail "Copied claude_wip README"
    }

    # Copy backup script
    $backupScript = Join-Path $Source "baseline_docs\backup-project.ps1"
    if (Test-Path $backupScript) {
        $destScript = Join-Path $Destination "scripts\backup-project.ps1"
        Copy-Item $backupScript -Destination $destScript -Force
        Write-Detail "Copied backup script"
    }

    # Create .gitkeep files
    $directories | Where-Object { $_ -like "*claude_wip*" } | ForEach-Object {
        $gitkeep = Join-Path $Destination "$_\.gitkeep"
        if (!(Test-Path $gitkeep)) {
            New-Item -ItemType File -Path $gitkeep -Force | Out-Null
        }
    }
    Write-Detail "Created .gitkeep files"

    Write-Success "Files copied successfully"
}

function Update-TemplateVariables {
    <#
    .SYNOPSIS
        Replaces template variables in all copied files
    #>
    param(
        [string]$ProjectPath,
        [hashtable]$Variables
    )

    Write-Info "Replacing template variables..."

    $fileCount = 0
    $replacementCount = 0

    # Get all markdown and PowerShell files
    $files = Get-ChildItem -Path $ProjectPath -Recurse -Include *.md,*.ps1 -File

    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if (!$content) { continue }

        $modified = $false
        $fileReplacements = 0

        foreach ($var in $Variables.GetEnumerator()) {
            $pattern = "{{$($var.Key)}}"
            if ($content -match [regex]::Escape($pattern)) {
                $content = $content -replace [regex]::Escape($pattern), $var.Value
                $modified = $true
                $matchCount = ([regex]::Matches($content, [regex]::Escape($pattern))).Count
                $fileReplacements += $matchCount
            }
        }

        if ($modified) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $fileCount++
            $replacementCount += $fileReplacements
        }
    }

    Write-Detail "Updated $fileCount files"
    Write-Detail "Made $replacementCount replacements"
    Write-Success "Template variables replaced"
}

function Initialize-GitRepository {
    <#
    .SYNOPSIS
        Initializes Git repository and creates .gitignore
    #>
    param(
        [string]$ProjectPath,
        [bool]$SkipIgnore
    )

    Write-Info "Initializing Git repository..."

    Push-Location $ProjectPath
    try {
        # Initialize Git
        git init 2>&1 | Out-Null
        Write-Detail "Repository initialized"

        # Create .gitignore if not skipped
        if (!$SkipIgnore) {
            $gitignoreContent = @"
# Claude Code working directory
claude_wip/
!claude_wip/README.md
!claude_wip/**/.gitkeep

# Environment files
.env
.env.local
.env.*.local

# Dependencies
node_modules/
vendor/
bower_components/

# Build outputs
dist/
build/
public/build/
public/hot

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Testing
coverage/
.phpunit.result.cache

# Temporary files
*.tmp
*.bak
*.backup
"@
            $gitignorePath = Join-Path $ProjectPath ".gitignore"
            Set-Content -Path $gitignorePath -Value $gitignoreContent
            Write-Detail "Created .gitignore"
        }

        # Initial commit
        git add . 2>&1 | Out-Null
        git commit -m "Initial project setup from baseline template" 2>&1 | Out-Null
        Write-Detail "Created initial commit"

        Write-Success "Git repository initialized"
    }
    catch {
        Write-Warning "Git initialization failed: $($_.Exception.Message)"
    }
    finally {
        Pop-Location
    }
}

function Test-ProjectSetup {
    <#
    .SYNOPSIS
        Verifies the project setup is complete and correct
    #>
    param([string]$ProjectPath)

    Write-Info "Verifying project setup..."

    $checks = @{
        "CLAUDE.md exists" = Test-Path (Join-Path $ProjectPath "CLAUDE.md")
        "Coding standards exist" = Test-Path (Join-Path $ProjectPath "docs\coding-standards\README.md")
        "Claude_wip structure exists" = Test-Path (Join-Path $ProjectPath "claude_wip\README.md")
        "Backup script exists" = Test-Path (Join-Path $ProjectPath "scripts\backup-project.ps1")
        "Git repository initialized" = Test-Path (Join-Path $ProjectPath ".git")
    }

    $allPassed = $true
    foreach ($check in $checks.GetEnumerator()) {
        if ($check.Value) {
            Write-Success $check.Key
        } else {
            Write-Host "  ✗ $($check.Key)" -ForegroundColor Red
            $allPassed = $false
        }
    }

    # Check for unreplaced variables
    $unreplaced = Get-ChildItem -Path $ProjectPath -Recurse -Include *.md,*.ps1 |
        Select-String -Pattern '{{.*?}}' |
        Where-Object { $_.Line -notmatch '\.EXAMPLE' -and $_.Line -notmatch 'Example:' }

    if ($unreplaced) {
        Write-Warning "Found unreplaced template variables:"
        $unreplaced | Select-Object -First 5 | ForEach-Object {
            Write-Detail "$($_.Filename):$($_.LineNumber) - $($_.Line.Trim())"
        }
        $allPassed = $false
    } else {
        Write-Success "All template variables replaced"
    }

    return $allPassed
}

function Show-Summary {
    <#
    .SYNOPSIS
        Displays setup summary and next steps
    #>
    param(
        [string]$ProjectPath,
        [hashtable]$Variables
    )

    Write-Header "SETUP COMPLETE"

    Write-Host "Project Details:" -ForegroundColor Cyan
    Write-Host "  Name        : " -NoNewline; Write-Host $Variables['PROJECT_NAME'] -ForegroundColor Green
    Write-Host "  Service     : " -NoNewline; Write-Host $Variables['SERVICE_NAME'] -ForegroundColor Green
    Write-Host "  Location    : " -NoNewline; Write-Host $ProjectPath -ForegroundColor Green
    Write-Host "  Contact     : " -NoNewline; Write-Host $Variables['CONTACT_EMAIL'] -ForegroundColor Green
    Write-Host "  Domain      : " -NoNewline; Write-Host $Variables['DOMAIN'] -ForegroundColor Green

    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  1. Review CLAUDE.md for AI guidance"
    Write-Host "  2. Read docs/coding-standards/README.md"
    Write-Host "  3. Customize coding standards for your project"
    Write-Host "  4. Set up your development environment"
    Write-Host "  5. Configure Git remote: git remote add origin <url>"

    Write-Host "`nUseful Commands:" -ForegroundColor Cyan
    Write-Host "  cd `"$ProjectPath`""
    Write-Host "  code .                              # Open in VS Code"
    Write-Host "  .\\scripts\\backup-project.ps1       # Backup project"
    Write-Host "  git remote add origin <url>        # Add Git remote"

    Write-Host "`n========================================`n" -ForegroundColor Cyan
}

#endregion Functions

#region Main Execution

try {
    Clear-Host
    Write-Header "NEW PROJECT SETUP"

    Write-Host "Creating project: $ProjectName" -ForegroundColor Green
    Write-Host "Destination: $DestinationPath`n" -ForegroundColor Green

    # Validate baseline path
    if (!(Test-Path $BaselinePath)) {
        throw "Baseline path not found: $BaselinePath"
    }
    Write-Success "Baseline template found"

    # Check if destination exists
    if (Test-Path $DestinationPath) {
        Write-Warning "Destination path already exists: $DestinationPath"
        $response = Read-Host "Continue anyway? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Setup cancelled by user" -ForegroundColor Yellow
            exit 0
        }
    }

    # Step 1: Get template variables
    Write-Header "STEP 1: CONFIGURE VARIABLES"
    $providedValues = @{
        'SERVICE_NAME' = $ServiceName
        'CONTACT_EMAIL' = $ContactEmail
        'DOMAIN' = $Domain
    }
    $variables = Get-TemplateVariables -ConfigPath $ConfigFile -ProvidedValues $providedValues

    # Step 2: Copy baseline files
    Write-Header "STEP 2: COPY BASELINE FILES"
    Copy-BaselineFiles -Source $BaselinePath -Destination $DestinationPath

    # Step 3: Replace template variables
    Write-Header "STEP 3: REPLACE TEMPLATE VARIABLES"
    Update-TemplateVariables -ProjectPath $DestinationPath -Variables $variables

    # Step 4: Initialize Git
    if ($InitGit) {
        Write-Header "STEP 4: INITIALIZE GIT"
        Initialize-GitRepository -ProjectPath $DestinationPath -SkipIgnore $SkipGitIgnore
    }

    # Step 5: Verify setup
    Write-Header "STEP 5: VERIFY SETUP"
    $verified = Test-ProjectSetup -ProjectPath $DestinationPath

    # Show summary
    Show-Summary -ProjectPath $DestinationPath -Variables $variables

    if ($verified) {
        exit 0
    } else {
        Write-Warning "Setup completed with warnings. Please review the output above."
        exit 1
    }
}
catch {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "  ERROR: Setup Failed" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor DarkGray
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    exit 1
}

#endregion Main Execution
