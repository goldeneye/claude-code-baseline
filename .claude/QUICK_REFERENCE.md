# Quick Reference Card

## Essential Commands

### Daily Operations

```powershell
# Check XAMPP services status
powershell -NoProfile -File .claude/scripts/check-services.ps1

# Backup MySQL databases
powershell -NoProfile -File .claude/scripts/backup-mysql.ps1

# Validate baseline documentation
powershell -NoProfile -File .claude/scripts/validate-baseline.ps1
```

### Weekly Operations

```powershell
# Backup all GitHub repositories
powershell -NoProfile -File .claude/scripts/backup-repos.ps1

# List all repositories
Get-ChildItem E:\github -Directory | Select-Object Name,LastWriteTime
```

### Documentation Operations

```powershell
# Generate README.md index
powershell -NoProfile -File .claude/scripts/generate-readme-index.ps1

# Backup baseline documentation
powershell -NoProfile -File .claude/scripts/backup-baseline.ps1

# Find template variables
Select-String -Path 'baseline_docs\*.md' -Pattern '{{[A-Z_]+}}'
```

## Environment Paths

| Tool | Path |
|------|------|
| XAMPP | `E:\xampp` |
| MySQL | `E:\xampp\mysql\bin` |
| Python | `E:\python` |
| Composer | `E:\composer` |
| Nmap | `E:\Nmap` |
| PuTTY | `E:\PuTTY` |

## Backup Locations

| Type | Location | Retention |
|------|----------|-----------|
| MySQL | `E:\mysql_backups` | 30 days |
| Repos | `E:\backup` | 90 days |
| Baseline | `E:\backup\baseline_docs` | 60 days |

## Quick Tools Check

```powershell
# Python version
& 'E:\python\python.exe' --version

# Composer version
& 'E:\composer\composer.bat' --version

# MySQL databases
& 'E:\xampp\mysql\bin\mysql.exe' -u root -e 'SHOW DATABASES;'
```

## Shortcuts (When Available)

- `/validate` - Validate baseline files
- `/backup` - Backup baseline docs
- `/backup-mysql` - Backup MySQL
- `/backup-repos` - Backup repositories
- `/index` - Generate README
- `/status` - Check services
- `/repos` - List repositories

---

**Tip**: Add `.claude/scripts` to your PATH for easier access:
```powershell
$env:PATH += ";E:\github\claude_code_baseline\.claude\scripts"
```
