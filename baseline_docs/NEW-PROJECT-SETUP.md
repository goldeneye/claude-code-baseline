# New Project Setup Guide

**Quick Start Guide for Creating Projects from the Baseline**

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Adding to Existing Project?](#adding-to-existing-project)
3. [Manual Setup](#manual-setup)
4. [Automated Setup (Recommended)](#automated-setup-recommended)
5. [Template Variables](#template-variables)
6. [What Gets Copied](#what-gets-copied)
7. [Post-Setup Tasks](#post-setup-tasks)
8. [Verification Checklist](#verification-checklist)

---

## Quick Start

**The fastest way to create a new project:**

```powershell
# Navigate to the baseline directory
cd E:\github\claude_code_baseline

# Run the setup script
.\new-project.ps1 -ProjectName "MyNewProject" -DestinationPath "E:\projects\my-new-project"
```

The script will:
- Create the project directory structure
- Copy all baseline documentation
- Prompt you for template variable values
- Replace all `{{VARIABLES}}` with your values
- Set up `.gitignore` and Git repository
- Create the `claude_wip/` working directory

---

## Adding to Existing Project?

**If you have an existing project** and want to add the baseline documentation:

```powershell
# Use the existing project script instead
.\add-baseline-to-existing-project.ps1 -ProjectPath "E:\your-existing-project"
```

**See:** [EXISTING-PROJECT-GUIDE.md](./EXISTING-PROJECT-GUIDE.md) for complete instructions

**Key Difference:**
- `new-project.ps1` - Creates a **new** project from scratch
- `add-baseline-to-existing-project.ps1` - Adds baseline to **existing** project safely

---

## Manual Setup

If you prefer to set up manually:

### Step 1: Create Project Directory

```powershell
# Create your new project directory
New-Item -ItemType Directory -Path "E:\projects\my-new-project" -Force

# Navigate to it
cd E:\projects\my-new-project
```

### Step 2: Copy Baseline Files

Copy these directories from `E:\github\claude_code_baseline`:

```powershell
$baseline = "E:\github\claude_code_baseline"
$project = "E:\projects\my-new-project"

# Copy documentation
Copy-Item "$baseline\baseline_docs" "$project\docs\baseline" -Recurse
Copy-Item "$baseline\coding-standards" "$project\docs\coding-standards" -Recurse

# Copy CLAUDE.md (this becomes your project's AI guidance)
Copy-Item "$baseline\CLAUDE.md" "$project\CLAUDE.md"

# Copy utilities
Copy-Item "$baseline\baseline_docs\backup-project.ps1" "$project\scripts\backup-project.ps1"
```

### Step 3: Create claude_wip Directory

```powershell
# Create working directory for Claude Code
mkdir "$project\claude_wip\drafts"
mkdir "$project\claude_wip\analysis"
mkdir "$project\claude_wip\scratch"
mkdir "$project\claude_wip\backups"

# Copy README
Copy-Item "$baseline\claude_wip\README.md" "$project\claude_wip\README.md"
```

### Step 4: Replace Template Variables

**Find and replace these in ALL copied files:**

```
{{PROJECT_NAME}}        → Your Project Name (e.g., "ComplianceScorecard")
{{SERVICE_NAME}}        → Service Name (e.g., "API Service")
{{REPO_PATH}}           → Full path (e.g., "E:\projects\my-new-project")
{{CLAUDE_WIP_PATH}}     → claude_wip path (e.g., "E:\projects\my-new-project\claude_wip")
{{CONTACT_EMAIL}}       → Your email (e.g., "dev@company.com")
{{DOMAIN}}              → Domain (e.g., "myapp.com")
{{DATE}}                → Current date (e.g., "2025-01-15")
{{DOCUMENT_PURPOSE}}    → Brief description
```

**PowerShell command to replace:**

```powershell
# Example: Replace PROJECT_NAME
Get-ChildItem -Path $project -Recurse -Include *.md,*.ps1 | ForEach-Object {
    (Get-Content $_.FullName) -replace '{{PROJECT_NAME}}', 'MyNewProject' | Set-Content $_.FullName
}
```

### Step 5: Set Up Git

```powershell
# Initialize repository
git init

# Create .gitignore
@"
# Claude Code working directory
claude_wip/
!claude_wip/README.md
!claude_wip/**/.gitkeep

# Environment files
.env
.env.local

# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
"@ | Out-File -FilePath "$project\.gitignore" -Encoding UTF8

# Initial commit
git add .
git commit -m "Initial project setup from baseline"
```

---

## Automated Setup (Recommended)

The automated script handles all of the above plus:
- Interactive prompts for template variables
- Validation of inputs
- Automatic Git initialization
- Project structure verification
- Summary report

### Script Parameters

```powershell
.\new-project.ps1 `
    -ProjectName "MyNewProject" `
    -DestinationPath "E:\projects\my-new-project" `
    -ConfigFile "project-config.json" `
    -InitGit $true `
    -Verbose
```

**Parameters:**

| Parameter | Required | Description | Default |
|-----------|----------|-------------|---------|
| `ProjectName` | Yes | Name of the new project | - |
| `DestinationPath` | Yes | Where to create the project | - |
| `ConfigFile` | No | JSON file with template variables | Interactive prompt |
| `ServiceName` | No | Service name | Same as ProjectName |
| `ContactEmail` | No | Contact email | Prompts if not provided |
| `Domain` | No | Project domain | Prompts if not provided |
| `InitGit` | No | Initialize Git repository | `$true` |
| `SkipGitIgnore` | No | Skip .gitignore creation | `$false` |

### Using a Config File

Create `project-config.json`:

```json
{
  "PROJECT_NAME": "ComplianceScorecard",
  "SERVICE_NAME": "Assessment API",
  "REPO_PATH": "E:\\projects\\compliance-scorecard",
  "CONTACT_EMAIL": "dev@compliancescorecard.com",
  "DOMAIN": "compliancescorecard.com",
  "AUTH0_DOMAIN": "your-tenant.auth0.com",
  "AUTH0_CLIENT_ID": "your-client-id",
  "DB_HOST": "localhost",
  "DB_USER": "app_user",
  "REDIS_HOST": "localhost"
}
```

Then run:

```powershell
.\new-project.ps1 -ProjectName "ComplianceScorecard" `
                  -DestinationPath "E:\projects\compliance-scorecard" `
                  -ConfigFile "project-config.json"
```

---

## Template Variables

### Core Variables (Required)

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Official project name | "ComplianceScorecard" |
| `{{SERVICE_NAME}}` | Service/component name | "Assessment API" |
| `{{REPO_PATH}}` | Full repository path | "E:\projects\myapp" |
| `{{CLAUDE_WIP_PATH}}` | Claude working directory | "E:\projects\myapp\claude_wip" |
| `{{CONTACT_EMAIL}}` | Primary contact email | "dev@company.com" |
| `{{DOMAIN}}` | Application domain | "myapp.com" |
| `{{DATE}}` | Current date | "2025-01-15" |

### Optional Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{DOCUMENT_PURPOSE}}` | Document description | "API documentation" |
| `{{AUTH0_DOMAIN}}` | Auth0 tenant | "myapp.auth0.com" |
| `{{AUTH0_CLIENT_ID}}` | Auth0 client ID | "abc123..." |
| `{{DB_HOST}}` | Database host | "localhost" |
| `{{DB_USER}}` | Database user | "app_user" |
| `{{REDIS_HOST}}` | Redis host | "localhost" |

### Where Variables Are Used

Variables appear in:
- `CLAUDE.md` - Main AI guidance file
- `docs/baseline_docs/*.md` - All baseline documentation
- `docs/coding-standards/*.md` - All coding standards
- `claude_wip/README.md` - Working directory guide
- `scripts/*.ps1` - Utility scripts

---

## What Gets Copied

### Always Copied

```
new-project/
├── CLAUDE.md                    # Main AI guidance (customized)
├── docs/
│   ├── baseline/                # All baseline documentation
│   └── coding-standards/     # All coding standards
├── claude_wip/                  # Claude working directory
│   ├── README.md
│   ├── drafts/
│   ├── analysis/
│   ├── scratch/
│   └── backups/
└── scripts/
    └── backup-project.ps1       # Backup utility
```

### Optional (Based on Project Type)

```
├── .gitignore                   # Git configuration
├── README.md                    # Project README (template)
└── project-config.json          # Variable configuration
```

### NOT Copied

These stay in the baseline only:
- `tim_wip/` - Baseline working files
- `claude_wip/analysis/` - Baseline development notes
- `.git/` - Baseline Git history
- `new-project.ps1` - Setup script (unless requested)
- `NEW-PROJECT-SETUP.md` - This guide (unless requested)

---

## Post-Setup Tasks

After creating your new project:

### 1. Verify Template Variables

```powershell
# Check for any remaining unreplaced variables
Get-ChildItem -Path . -Recurse -Include *.md,*.ps1 |
    Select-String -Pattern '{{.*?}}' |
    Select-Object Path, LineNumber, Line
```

### 2. Customize CLAUDE.md

Edit `CLAUDE.md` to add:
- Project-specific context
- Custom conventions
- Domain-specific terminology
- Team preferences

### 3. Review Coding Standards

Navigate to `docs/coding-standards/README.md` and:
- Remove standards that don't apply
- Add project-specific rules
- Update examples with your domain

### 4. Set Up Development Environment

```powershell
# Install dependencies (example for Laravel)
composer install
npm install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

### 5. Configure Git Remote

```powershell
# Add remote repository
git remote add origin https://github.com/yourorg/yourproject.git

# Push initial commit
git push -u origin main
```

### 6. Update Documentation

- [ ] Update README.md with project details
- [ ] Document installation steps
- [ ] Add project-specific architecture notes
- [ ] Document environment setup

---

## Verification Checklist

After setup, verify everything is correct:

### Directory Structure

```powershell
# Should exist
Test-Path ".\CLAUDE.md"
Test-Path ".\docs\coding-standards\README.md"
Test-Path ".\claude_wip\README.md"
Test-Path ".\scripts\backup-project.ps1"
```

### Template Variables

```powershell
# Should return NO results
Get-ChildItem -Recurse -Include *.md,*.ps1 |
    Select-String '{{PROJECT_NAME}}'
# If this returns results, you missed some replacements!
```

### Git Setup

```powershell
# Should be initialized
git status
# Should show .gitignore
Test-Path ".\.gitignore"
```

### Claude_WIP Structure

```powershell
# All subdirectories should exist
Test-Path ".\claude_wip\drafts"
Test-Path ".\claude_wip\analysis"
Test-Path ".\claude_wip\scratch"
Test-Path ".\claude_wip\backups"
```

---

## Troubleshooting

### Issue: Template Variables Not Replaced

**Problem:** Still seeing `{{VARIABLE}}` in files

**Solution:**
```powershell
# Re-run replacement for specific variable
Get-ChildItem -Recurse -Include *.md | ForEach-Object {
    (Get-Content $_.FullName) -replace '{{PROJECT_NAME}}', 'ActualValue' |
        Set-Content $_.FullName
}
```

### Issue: Script Fails to Copy Files

**Problem:** "Access denied" or "File not found" errors

**Solution:**
- Run PowerShell as Administrator
- Verify baseline path exists: `E:\github\claude_code_baseline`
- Check destination path is writable

### Issue: Git Not Initialized

**Problem:** `git status` shows "not a git repository"

**Solution:**
```powershell
git init
git add .
git commit -m "Initial commit"
```

---

## Examples

### Example 1: Laravel API Project

```powershell
.\new-project.ps1 `
    -ProjectName "ComplianceAPI" `
    -DestinationPath "E:\projects\compliance-api" `
    -ServiceName "RESTful API Service" `
    -ContactEmail "api@compliance.com" `
    -Domain "api.compliance.com"
```

### Example 2: React Frontend Project

```powershell
.\new-project.ps1 `
    -ProjectName "ComplianceDashboard" `
    -DestinationPath "E:\projects\compliance-dashboard" `
    -ServiceName "Admin Dashboard" `
    -ContactEmail "frontend@compliance.com" `
    -Domain "app.compliance.com"
```

### Example 3: Full-Stack Project with Config

**Create `my-config.json`:**
```json
{
  "PROJECT_NAME": "ComplianceScorecard",
  "SERVICE_NAME": "Full-Stack Application",
  "REPO_PATH": "E:\\projects\\compliance-full",
  "CONTACT_EMAIL": "dev@compliance.com",
  "DOMAIN": "compliance.com",
  "DB_HOST": "db.compliance.com",
  "REDIS_HOST": "cache.compliance.com"
}
```

**Run:**
```powershell
.\new-project.ps1 `
    -ProjectName "ComplianceScorecard" `
    -DestinationPath "E:\projects\compliance-full" `
    -ConfigFile "my-config.json"
```

---

## Next Steps

After setup:

1. **Read CLAUDE.md** - Understand the AI guidance for your project
2. **Review Coding Standards** - Familiarize yourself with conventions
3. **Set Up Development Environment** - Install dependencies, configure tools
4. **Create First Feature** - Use `claude_wip/drafts/` for initial development
5. **Commit Your Work** - Follow the Git workflow in coding standards

---

## Additional Resources

- [CLAUDE.md](./CLAUDE.md) - Main AI guidance file
- [Coding Standards](./docs/coding-standards/README.md) - Complete standards
- [Backup Script](./scripts/backup-project.ps1) - Project backup utility
- [Claude_WIP Convention](./claude_wip/README.md) - Working directory usage

---

**Questions or Issues?**

If you encounter problems:
1. Check the [Troubleshooting](#troubleshooting) section
2. Verify all paths in the script parameters
3. Ensure PowerShell execution policy allows scripts: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

---

**Last Updated:** January 2025
**Version:** 1.0
