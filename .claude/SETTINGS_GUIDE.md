# Claude Settings Configuration Guide

## Overview

This document explains the enhanced `.claude/settings.local.json` configuration for the Engineering Baseline Documentation repository, including environment paths, backup automation, and development tool integration.

---

## 📁 Directory Structure

```
.claude/
├── settings.local.json      # Main configuration file
├── SETTINGS_GUIDE.md        # This guide
└── scripts/                 # Automation scripts
    ├── validate-baseline.ps1
    ├── generate-readme-index.ps1
    ├── backup-baseline.ps1
    ├── backup-mysql.ps1
    ├── backup-repos.ps1
    └── check-services.ps1
```

---

## 🔧 Environment Configuration

### Development Tool Paths

The configuration maps all your Windows development tools:

```json
"environment": {
  "paths": {
    "xampp": "E:\\xampp",
    "xampp_mysql": "E:\\xampp\\mysql\\bin",
    "python": "E:\\python",
    "composer": "E:\\composer",
    "nmap": "E:\\Nmap",
    "putty": "E:\\PuTTY",
    "xmeta": "E:\\XMeta"
  }
}
```

### Backup Locations

Three designated backup destinations:

| Location | Purpose | Path |
|----------|---------|------|
| **General** | General backups | `E:\backup` |
| **MySQL** | Database backups | `E:\mysql_backups` |
| **Repositories** | GitHub repo backups | `E:\github` |

### Repository Management

```json
"repositories": {
  "baseDir": "E:\\github",
  "current": "E:\\github\\claude_code_baseline"
}
```

---

## 🤖 Automation Scripts

### 1. MySQL Database Backup

**Script**: `backup-mysql.ps1`

**Purpose**: Backs up all MySQL databases with automatic compression and retention management.

**Usage**:
```powershell
# Basic usage
powershell -NoProfile -File .claude/scripts/backup-mysql.ps1

# With custom parameters
powershell -NoProfile -File .claude/scripts/backup-mysql.ps1 `
  -BackupDir "E:\mysql_backups" `
  -Username "root" `
  -RetentionDays 30 `
  -Compress
```

**Features**:
- ✅ Automatic database discovery
- ✅ Individual database backups
- ✅ Optional compression (.zip)
- ✅ Automatic cleanup of old backups (30 days default)
- ✅ Backup manifest (JSON)
- ✅ Detailed logging and error reporting

**Output Location**: `E:\mysql_backups\<timestamp>\`

**Files Created**:
```
E:\mysql_backups\
└── 20251102_081530\
    ├── database1.sql.zip
    ├── database2.sql.zip
    ├── database3.sql.zip
    └── manifest.json
```

---

### 2. GitHub Repositories Backup

**Script**: `backup-repos.ps1`

**Purpose**: Backs up all Git repositories from `E:\github` with smart exclusions.

**Usage**:
```powershell
# Basic usage
powershell -NoProfile -File .claude/scripts/backup-repos.ps1

# Include node_modules and vendor
powershell -NoProfile -File .claude/scripts/backup-repos.ps1 `
  -IncludeNodeModules `
  -IncludeVendor
```

**Features**:
- ✅ Automatic Git repository detection
- ✅ Excludes `node_modules` and `vendor` by default
- ✅ Captures current branch and commit hash
- ✅ Compresses entire backup to single .zip
- ✅ 90-day retention policy
- ✅ Backup manifest with repository metadata

**Output Location**: `E:\backup\repos_<timestamp>.zip`

**Smart Exclusions**:
- `node_modules/` - Excluded by default (use `-IncludeNodeModules` to keep)
- `vendor/` - Excluded by default (use `-IncludeVendor` to keep)

---

### 3. Baseline Documentation Backup

**Script**: `backup-baseline.ps1`

**Purpose**: Creates timestamped backup of baseline documentation files.

**Usage**:
```powershell
powershell -NoProfile -File .claude/scripts/backup-baseline.ps1
```

**Features**:
- ✅ Backs up all `.md` files from `baseline_docs/`
- ✅ Compressed archive
- ✅ 60-day retention
- ✅ Backup manifest

**Output**: `E:\backup\baseline_docs\baseline_docs_<timestamp>.zip`

---

### 4. XAMPP Services Health Check

**Script**: `check-services.ps1`

**Purpose**: Monitors health of XAMPP MySQL, Apache, PHP, and development tools.

**Usage**:
```powershell
# Basic check
powershell -NoProfile -File .claude/scripts/check-services.ps1

# Detailed check (includes ports and resource usage)
powershell -NoProfile -File .claude/scripts/check-services.ps1 -Detailed
```

**Checks**:
- ✅ MySQL server status and version
- ✅ Apache server status and HTTP connectivity
- ✅ PHP version
- ✅ Composer version
- ✅ Python version
- ✅ Port availability (80, 443, 3306, 8080) - with `-Detailed`
- ✅ CPU and memory usage - with `-Detailed`

**Example Output**:
```
=== XAMPP Services Health Check ===

MySQL Server Status: RUNNING ✓
  PID: 1234
  Version: 8.0.30

Apache Server Status: RUNNING ✓

MySQL Connection Test: SUCCESS ✓
  Version: 8.0.30

Apache Connection Test: SUCCESS ✓
  Status Code: 200

PHP Version: 8.2.12 ✓
Composer: v2.6.5 ✓
Python: v3.11.5 ✓

=== Summary ===
All critical services are running ✓
```

---

### 5. Baseline Documentation Validation

**Script**: `validate-baseline.ps1`

**Purpose**: Validates all baseline documentation for consistency and quality.

**Usage**:
```powershell
# Run validation
powershell -NoProfile -File .claude/scripts/validate-baseline.ps1

# Verbose mode
powershell -NoProfile -File .claude/scripts/validate-baseline.ps1 -Verbose
```

**Validation Checks**:
- ✅ YAML frontmatter present and complete
- ✅ Template variables usage ({{PROJECT_NAME}}, etc.)
- ✅ File length under 600 lines
- ✅ Cross-references to other documents
- ✅ Code block formatting (balanced ```)
- ✅ Heading structure

**Example Output**:
```
=== Baseline Documentation Validation ===

Found 6 baseline files

Validating: 00-overview.md
  Found 12 template variables

Validating: 01-architecture.md
  Found 8 template variables

...

=== Validation Summary ===
Files checked: 6
Errors: 0
Warnings: 2

All baseline files are valid! ✓
```

---

### 6. README Index Generator

**Script**: `generate-readme-index.ps1`

**Purpose**: Auto-generates `README.md` index from baseline documentation files.

**Usage**:
```powershell
powershell -NoProfile -File .claude/scripts/generate-readme-index.ps1
```

**Features**:
- ✅ Reads frontmatter from each baseline file
- ✅ Extracts title and purpose
- ✅ Creates comprehensive index with usage instructions
- ✅ Includes template variable reference table
- ✅ Adds validation commands and compliance alignment

**Output**: `baseline_docs/README.md`

---

## ⚙️ Custom Commands

Access automation scripts via shortcuts defined in `settings.local.json`:

| Shortcut | Command | Description |
|----------|---------|-------------|
| `/validate` | `validate-baseline.ps1` | Run validation on all baseline files |
| `/regenerate` | N/A | Regenerate baseline pack from source files |
| `/backup` | `backup-baseline.ps1` | Create timestamped backup of baseline_docs |
| `/backup-mysql` | `backup-mysql.ps1` | Backup all MySQL databases |
| `/backup-repos` | `backup-repos.ps1` | Backup all GitHub repositories |
| `/index` | `generate-readme-index.ps1` | Generate README.md index |
| `/vars` | PowerShell command | Show all template variables in use |
| `/status` | `check-services.ps1` | Check XAMPP services status |
| `/repos` | PowerShell command | List all GitHub repositories |
| `/tools` | PowerShell command | Show installed tool versions |

---

## 📅 Backup Schedule & Retention

Configured in `settings.local.json`:

```json
"backup": {
  "schedule": {
    "mysql": "daily",
    "repositories": "weekly",
    "baseline_docs": "on-change"
  },
  "retention": {
    "mysql": 30,
    "repositories": 90,
    "baseline_docs": 60
  }
}
```

### Automated Cleanup

All backup scripts automatically remove old backups:

- **MySQL Backups**: 30 days
- **Repository Backups**: 90 days
- **Baseline Docs Backups**: 60 days

Old backups are identified by creation timestamp and removed automatically on each backup run.

---

## 🛠️ Tool Configuration

### XAMPP MySQL

```json
"xampp": {
  "mysql": {
    "path": "E:\\xampp\\mysql\\bin\\mysql.exe",
    "dump": "E:\\xampp\\mysql\\bin\\mysqldump.exe",
    "defaultUser": "root",
    "defaultHost": "localhost",
    "defaultPort": 3306
  }
}
```

**Quick Commands**:
```powershell
# Check MySQL status
powershell -NoProfile -Command "& 'E:\xampp\mysql\bin\mysql.exe' -u root -e 'SHOW DATABASES;'"

# Backup all databases
powershell -NoProfile -File .claude/scripts/backup-mysql.ps1
```

### Python

```json
"python": {
  "executable": "E:\\python\\python.exe",
  "pip": "E:\\python\\Scripts\\pip.exe",
  "scriptsPath": "E:\\python\\Scripts"
}
```

**Quick Commands**:
```powershell
# Check Python version
powershell -NoProfile -Command "& 'E:\python\python.exe' --version"

# Install package
powershell -NoProfile -Command "& 'E:\python\Scripts\pip.exe' install <package>"
```

### Composer

```json
"composer": {
  "executable": "E:\\composer\\composer.bat",
  "globalPath": "E:\\composer"
}
```

**Quick Commands**:
```powershell
# Check Composer version
powershell -NoProfile -Command "& 'E:\composer\composer.bat' --version"

# Global install
powershell -NoProfile -Command "& 'E:\composer\composer.bat' global require <package>"
```

---

## 🪝 Hooks

Automated quality checks that run automatically:

### Pre-Read Hook

**Trigger**: Reading any file in `baseline_docs/*.md`
**Action**: Reminds to preserve template variables

```json
"pre-read": {
  "pattern": "baseline_docs/*.md",
  "command": "echo 'Reading baseline template - remember to preserve {{TEMPLATE_VARIABLES}}'"
}
```

### Pre-Write Hook

**Trigger**: Before writing to `baseline_docs/*.md`
**Action**: Warns if template variables are missing

```json
"pre-write": {
  "pattern": "baseline_docs/*.md",
  "command": "powershell -Command \"if ((Get-Content '{{file}}' | Select-String -Pattern '{{[A-Z_]+}}' | Measure-Object).Count -eq 0) { Write-Warning 'No template variables found in {{file}}' }\""
}
```

### Post-Write Hook

**Trigger**: After writing to `baseline_docs/*.md`
**Action**: Checks if file exceeds 600 line limit

```json
"post-write": {
  "pattern": "baseline_docs/*.md",
  "command": "powershell -Command \"$lines = (Get-Content '{{file}}' | Measure-Object -Line).Lines; if ($lines -gt 600) { Write-Warning '{{file}} exceeds 600 line limit ($lines lines)' }\""
}
```

---

## 📊 File Watchers

Monitors file changes and triggers actions:

### Source Documentation Watcher

```json
"tim_wip/markdown/**/*.md": {
  "description": "Source documentation updated - consider regenerating baseline pack",
  "action": "notify"
}
```

### Baseline Templates Watcher

```json
"baseline_docs/**/*.md": {
  "description": "Baseline template modified",
  "action": "validate-frontmatter"
}
```

---

## 🎯 Common Use Cases

### Daily Workflow

```powershell
# Morning: Check services
powershell -NoProfile -File .claude/scripts/check-services.ps1

# Before work: Validate baseline docs
powershell -NoProfile -File .claude/scripts/validate-baseline.ps1

# After changes: Regenerate index
powershell -NoProfile -File .claude/scripts/generate-readme-index.ps1

# End of day: Backup MySQL databases
powershell -NoProfile -File .claude/scripts/backup-mysql.ps1
```

### Weekly Tasks

```powershell
# Backup all repositories
powershell -NoProfile -File .claude/scripts/backup-repos.ps1

# List all repos and check for updates
powershell -NoProfile -Command "Get-ChildItem E:\github -Directory | Select-Object Name,LastWriteTime"
```

### Before Major Changes

```powershell
# Create baseline backup
powershell -NoProfile -File .claude/scripts/backup-baseline.ps1

# Validate current state
powershell -NoProfile -File .claude/scripts/validate-baseline.ps1

# Make changes...

# Regenerate index
powershell -NoProfile -File .claude/scripts/generate-readme-index.ps1
```

---

## 🔍 Troubleshooting

### Script Execution Policy

If scripts won't run, you may need to adjust PowerShell execution policy:

```powershell
# Check current policy
Get-ExecutionPolicy

# Set to RemoteSigned (recommended for local scripts)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### MySQL Connection Issues

If MySQL backup fails:

1. Check MySQL is running:
   ```powershell
   powershell -NoProfile -File .claude/scripts/check-services.ps1
   ```

2. Verify MySQL path:
   ```powershell
   Test-Path "E:\xampp\mysql\bin\mysqldump.exe"
   ```

3. Test MySQL connection:
   ```powershell
   & "E:\xampp\mysql\bin\mysql.exe" -u root -e "SHOW DATABASES;"
   ```

### Backup Directory Permissions

If backup scripts fail with access denied:

1. Ensure backup directories exist and are writable
2. Run PowerShell as Administrator (if needed)
3. Check disk space: `Get-PSDrive`

---

## 📝 Best Practices

1. **Run validation before committing** baseline doc changes
2. **Backup MySQL daily** to prevent data loss
3. **Check services status** regularly to catch issues early
4. **Regenerate index** whenever baseline files change
5. **Review old backups** quarterly and archive if needed
6. **Test restore procedures** periodically

---

## 🚀 Future Enhancements

Potential improvements to consider:

- [ ] Automated scheduling via Windows Task Scheduler
- [ ] Email notifications for backup failures
- [ ] Cloud backup integration (Azure, AWS S3)
- [ ] Backup encryption for sensitive data
- [ ] Differential backups for large repositories
- [ ] Backup verification and integrity checks
- [ ] Dashboard for monitoring backup health

---

**Last Updated**: 2025-11-02
**Version**: 1.0
**Author**: TimGolden - aka GoldenEye Engineering
