# Adding Baseline to Existing Projects

**Safe integration of baseline documentation into your current projects**

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Safety Guarantees](#safety-guarantees)
3. [What Gets Added](#what-gets-added)
4. [Usage Examples](#usage-examples)
5. [Conflict Resolution](#conflict-resolution)
6. [Component Selection](#component-selection)
7. [Dry Run Mode](#dry-run-mode)
8. [Backup and Rollback](#backup-and-rollback)
9. [Template Variables](#template-variables)
10. [Troubleshooting](#troubleshooting)

---

## Quick Start

**Add baseline to your existing project in 3 steps:**

```powershell
# 1. Navigate to baseline directory
cd E:\github\claude_code_baseline

# 2. Run the script (it will prompt for details)
.\add-baseline-to-existing-project.ps1 -ProjectPath "E:\your-project"

# 3. Review and merge CLAUDE-baseline.md into your existing CLAUDE.md
```

**That's it!** The script will safely add baseline documentation without overwriting any existing files.

---

## Safety Guarantees

### 🛡️ The #1 Rule: NEVER OVERWRITE

**This script will NEVER overwrite your existing files.** Here's how we guarantee safety:

#### Automatic Backup
- ✅ Creates timestamped backup before ANY changes
- ✅ Backup location: `.baseline-backup-YYYYMMDD-HHMMSS/`
- ✅ Can restore automatically if anything fails

#### Conflict Detection
- ✅ Scans for existing files before copying
- ✅ Reports all conflicts before making changes
- ✅ Requires confirmation (unless `-Force`)

#### Smart Handling
- ✅ Existing files are NEVER replaced
- ✅ New files get `.baseline` suffix if conflict
- ✅ You choose what to merge manually

#### Automatic Rollback
- ✅ If anything fails, automatic restore
- ✅ Project returns to exact previous state
- ✅ No partial updates or broken states

#### Git Integration
- ✅ Detects Git repositories
- ✅ Warns if uncommitted changes
- ✅ Can use Git stash for backup

---

## What Gets Added

The script can add these components to your project:

### 1. Baseline Documentation (`docs/baseline/`)

Complete documentation templates:
- 00-overview.md
- 01-architecture.md
- 02-security.md
- 03-coding-standards.md (redirect file)
- 04-ai-agent-protocol.md
- 05-deployment-guide.md
- 06-database-schema.md
- 07-testing-and-QA.md
- 08-api-documentation.md
- 09-project-roadmap-template.md
- 10-disaster-recovery-and-audit.md

**Conflict Handling:** If `docs/baseline/` exists, creates `docs/baseline-from-template/` instead

### 2. Coding Standards (`docs/coding-standards/`)

13 comprehensive coding standard files:
- README.md (central navigation)
- 01-pseudo-code-standards.md
- 02-project-structure.md
- 03-php-standards.md
- 04-javascript-standards.md
- 05-database-standards.md
- 06-logging-standards.md
- 07-safety-rules.md (⚠️ CRITICAL)
- 08-quality-standards.md
- 09-github-jira-workflow.md
- 10-testing-standards.md
- 11-security-standards.md
- 12-performance-standards.md

**Conflict Handling:** If `docs/coding-standards/` exists, creates `docs/coding-standards-baseline/` instead

### 3. Claude WIP Directory (`claude_wip/`)

Working directory for Claude Code:
- README.md (usage guidelines)
- drafts/ (draft implementations)
- analysis/ (code analysis & research)
- scratch/ (temporary experiments)
- backups/ (quick backups)

**Conflict Handling:** If `claude_wip/` exists, only creates missing subdirectories

### 4. Scripts (`scripts/`)

Utility scripts:
- backup-project.ps1 (universal project backup utility)

**Conflict Handling:** If script exists, creates with `.baseline` suffix

### 5. CLAUDE.md Reference

**ALWAYS creates as:** `CLAUDE-baseline.md`

This is a reference file for you to manually merge into your existing `CLAUDE.md`. It will NEVER overwrite your existing CLAUDE.md.

### 6. .gitignore Updates

Adds baseline-specific entries:
```gitignore
# Claude Code working directory
claude_wip/
!claude_wip/README.md
!claude_wip/**/.gitkeep

# Baseline backup directories
.baseline-backup-*/

# Baseline addition log
baseline-addition.log
```

**Conflict Handling:** Smart merge - appends only if entries don't exist

---

## Usage Examples

### Example 1: Standard Addition (Recommended)

```powershell
# Interactive mode with all default settings
.\add-baseline-to-existing-project.ps1 -ProjectPath "E:\myproject"
```

**What happens:**
- Runs pre-flight checks
- Scans for conflicts
- Prompts for template variables
- Asks for confirmation
- Creates selective backup
- Adds all components
- Shows summary

### Example 2: Dry Run (Preview First)

```powershell
# See what would be added without making changes
.\add-baseline-to-existing-project.ps1 -ProjectPath "E:\myproject" -DryRun
```

**Output shows:**
- Files that would be added
- Files that would be skipped (conflicts)
- Backup strategy
- Template variables needed

### Example 3: Selective Components

```powershell
# Add only specific components
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -Components baseline-docs,claude-wip
```

**Available components:**
- `baseline-docs` - Documentation templates only
- `coding-standards` - Coding standards only
- `claude-wip` - Working directory only
- `scripts` - Utility scripts only
- `gitignore` - .gitignore updates only
- `all` - Everything (default)

### Example 4: Fully Automated

```powershell
# Use config file, skip prompts
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -ConfigFile "config.json" `
    -Force
```

**Config file example:**
```json
{
  "PROJECT_NAME": "MyProject",
  "CONTACT_EMAIL": "dev@myproject.com",
  "DOMAIN": "myproject.com"
}
```

### Example 5: Interactive Conflict Resolution

```powershell
# Prompt for each conflict
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -ConflictStrategy interactive
```

**For each conflict, you choose:**
- [S] Skip - Keep existing file
- [B] Backup and replace - Move existing, add baseline
- [R] Rename new file - Add with .baseline suffix

### Example 6: Skip Backups (Not Recommended)

```powershell
# Add without creating backup (use with caution!)
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -CreateBackup $false
```

**⚠️ Warning:** Only use if you have your own backup or version control

### Example 7: Git Stash Backup

```powershell
# Use Git stash for backup (fastest for Git repos)
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -BackupStrategy git-stash
```

**Requires:** Git repository with no uncommitted critical changes

---

## Conflict Resolution

### How Conflicts Are Handled

When a file already exists, the script uses the configured strategy:

#### Strategy 1: Skip (Safest)

```powershell
-ConflictStrategy skip
```

**Behavior:**
- Existing files are left untouched
- Baseline version is not added
- You must manually add if needed

**Use when:** You want maximum safety and will merge manually

#### Strategy 2: Suffix (Default - Recommended)

```powershell
-ConflictStrategy suffix
```

**Behavior:**
- Existing files are left untouched
- Baseline version is added with `.baseline` suffix
- Example: `backup-project.ps1.baseline`

**Use when:** You want to compare files side-by-side

#### Strategy 3: Interactive (Most Control)

```powershell
-ConflictStrategy interactive
```

**Behavior:**
- Prompts for each conflict
- You choose: Skip, Backup & Replace, or Rename
- Full control over each decision

**Use when:** You have few conflicts and want to decide case-by-case

#### Strategy 4: Alternate Directory

```powershell
-ConflictStrategy alternate-directory
```

**Behavior:**
- If `docs/coding-standards/` exists, creates `docs/coding-standards-baseline/`
- Keeps both versions in separate directories
- No files overwritten

**Use when:** You want parallel structures for comparison

---

## Component Selection

### Add Everything (Default)

```powershell
-Components all
```

Adds: baseline-docs, coding-standards, claude-wip, scripts, gitignore, CLAUDE-baseline.md

### Add Only Documentation

```powershell
-Components baseline-docs
```

Adds: Only the docs/baseline/ directory with 11 template files

### Add Only Coding Standards

```powershell
-Components coding-standards
```

Adds: Only the docs/coding-standards/ directory with 13 standard files

### Add Multiple Components

```powershell
-Components baseline-docs,coding-standards,claude-wip
```

Adds: Documentation, standards, and working directory

---

## Dry Run Mode

### What Is Dry Run?

Dry run mode shows what **would** happen without making any changes.

```powershell
.\add-baseline-to-existing-project.ps1 -ProjectPath "E:\myproject" -DryRun
```

### Dry Run Output

```
========================================
  ADD BASELINE - DRY RUN MODE
========================================
  No changes will be made to your project

Scanning baseline files...
  Found 45 files to process

Checking for conflicts...
  ⚠ 3 file(s) already exist
    CLAUDE.md
    scripts/backup.ps1
    .gitignore

========================================
  DRY RUN SUMMARY
========================================

Would add 42 files
Would skip 3 files (conflicts)

Run without -DryRun to apply changes
```

**Use dry run to:**
- Preview what will be added
- Check for conflicts
- Verify backup size
- Test without risk

---

## Backup and Rollback

### Backup Strategies

#### Selective Backup (Default - Recommended)

```powershell
-BackupStrategy selective
```

**Backs up only:**
- CLAUDE.md
- docs/
- claude_wip/
- scripts/
- .gitignore

**Pros:** Fast, small backup size
**Cons:** Doesn't backup entire project

#### Full Backup

```powershell
-BackupStrategy full
```

**Backs up:** Entire project (except node_modules, vendor, .git, dist, build)

**Pros:** Complete safety
**Cons:** Slow for large projects, large backup size

#### Git Stash

```powershell
-BackupStrategy git-stash
```

**Backs up:** Uses Git stash with timestamp

**Pros:** Fastest, uses Git
**Cons:** Requires Git repository

### Backup Location

**Default:** `.baseline-backup-YYYYMMDD-HHMMSS/` in project root

**Example:** `.baseline-backup-20250115-143022/`

### Manual Rollback

If automatic rollback fails:

```powershell
# 1. Find backup
Get-ChildItem .baseline-backup-* | Sort-Object Name -Descending | Select-Object -First 1

# 2. Restore specific file
Copy-Item .baseline-backup-20250115-143022\CLAUDE.md .\CLAUDE.md -Force

# 3. Or restore everything
Remove-Item docs\baseline -Recurse -Force
Copy-Item .baseline-backup-20250115-143022\* .\ -Recurse -Force

# 4. Clean up backup
Remove-Item .baseline-backup-20250115-143022 -Recurse -Force
```

### Automatic Rollback

If the script fails, it automatically:
1. Detects the failure
2. Shows error message
3. Restores from backup
4. Returns project to original state

**You don't need to do anything!**

---

## Template Variables

### What Are Template Variables?

Template variables are placeholders like `{{PROJECT_NAME}}` that get replaced with your project's actual values.

### Variables Used

**Required:**
- `{{PROJECT_NAME}}` - Your project name
- `{{CONTACT_EMAIL}}` - Primary contact email
- `{{DOMAIN}}` - Project domain

**Auto-Set:**
- `{{DATE}}` - Current date
- `{{REPO_PATH}}` - Your project path
- `{{CLAUDE_WIP_PATH}}` - claude_wip directory path

### Interactive Mode

Script prompts for missing variables:

```
Template Variables:
  Project name: MyProject
  Contact email address: dev@myproject.com
  Project domain: myproject.com
```

### Config File Mode

Create `config.json`:

```json
{
  "PROJECT_NAME": "MyProject",
  "CONTACT_EMAIL": "dev@myproject.com",
  "DOMAIN": "myproject.com",
  "SERVICE_NAME": "API Service"
}
```

Use with script:

```powershell
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -ConfigFile "config.json"
```

### Skip Variables

```powershell
-SkipVariables
```

**Use when:** You want to replace variables manually later

---

## Troubleshooting

### Issue 1: "Insufficient disk space"

**Cause:** Less than 100 MB free disk space

**Solution:**
1. Free up disk space
2. Use `-BackupStrategy git-stash` (smaller backup)
3. Use `-CreateBackup $false` (not recommended)

### Issue 2: "No write permissions"

**Cause:** Project directory is read-only

**Solution:**
1. Run PowerShell as Administrator
2. Check folder permissions
3. Remove read-only attribute

### Issue 3: "Git uncommitted changes"

**Cause:** Git repository has uncommitted changes

**Solution:**
1. Commit your changes: `git commit -am "Work in progress"`
2. Or stash them: `git stash`
3. Or use `-Force` to proceed anyway

### Issue 4: "Baseline path not found"

**Cause:** Script can't find baseline template directory

**Solution:**
```powershell
# Specify baseline path explicitly
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -BaselinePath "E:\github\claude_code_baseline"
```

### Issue 5: Script Fails Mid-Execution

**Automatic Fix:** Script automatically rolls back from backup

**Manual Check:**
```powershell
# Verify project state
Get-ChildItem .baseline-backup-*

# If needed, restore manually
Copy-Item .baseline-backup-20250115-143022\* .\ -Recurse -Force
```

### Issue 6: Too Many Conflicts

**Solution:**
```powershell
# Use interactive mode to handle individually
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -ConflictStrategy interactive
```

Or:

```powershell
# Add only specific components without conflicts
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -Components baseline-docs
```

---

## After Addition

### Step 1: Review CLAUDE-baseline.md

```powershell
# Compare with existing CLAUDE.md
git diff --no-index CLAUDE.md CLAUDE-baseline.md

# Or open both files
code CLAUDE.md CLAUDE-baseline.md
```

**Merge relevant sections:**
- Template variable system
- Claude_wip convention
- Coding standards references
- Integration guidelines

### Step 2: Review Baseline Files

```powershell
# Browse added documentation
code docs/baseline/README.md

# Review coding standards
code docs/coding-standards/README.md
```

### Step 3: Customize for Your Project

- Remove standards that don't apply
- Add project-specific conventions
- Update examples with your domain
- Replace remaining template variables

### Step 4: Test Backup Script

```powershell
# Test the new backup script
.\scripts\backup-project.ps1
```

### Step 5: Clean Up

```powershell
# After verifying everything works, remove:

# 1. Backup directory
Remove-Item .baseline-backup-20250115-143022 -Recurse -Force

# 2. .baseline files (after merging)
Remove-Item CLAUDE-baseline.md
Remove-Item scripts\*.baseline

# 3. Addition log (optional)
Remove-Item baseline-addition.log
```

---

## Advanced Usage

### Custom Log File

```powershell
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\myproject" `
    -LogFile "E:\logs\baseline-addition.log"
```

### Multiple Projects

```powershell
# Batch add to multiple projects
$projects = @("E:\project1", "E:\project2", "E:\project3")

foreach ($project in $projects) {
    .\add-baseline-to-existing-project.ps1 `
        -ProjectPath $project `
        -ConfigFile "config.json" `
        -Force
}
```

### Integration with CI/CD

```yaml
# Example: GitHub Actions
- name: Add baseline documentation
  run: |
    pwsh -File add-baseline-to-existing-project.ps1 `
      -ProjectPath ${{ github.workspace }} `
      -ConfigFile .github/baseline-config.json `
      -Force `
      -CreateBackup $false
```

---

## FAQ

**Q: Will this overwrite my existing files?**
A: No. Never. The script will NEVER overwrite existing files.

**Q: What if I already have a CLAUDE.md?**
A: The script creates `CLAUDE-baseline.md` as a reference. You merge it manually.

**Q: Can I undo the changes?**
A: Yes. The script creates a backup and can automatically rollback if anything fails.

**Q: Do I have to add everything?**
A: No. Use `-Components` to select only what you need.

**Q: What if I have many conflicts?**
A: Use `-ConflictStrategy interactive` to handle each one, or `-ConflictStrategy skip` to skip all conflicts.

**Q: Is it safe to run on production?**
A: Yes, with proper precautions:
- Run `-DryRun` first
- Ensure backups are working
- Test on staging first
- Use version control

**Q: How long does it take?**
A: Usually < 1 minute for most projects

**Q: Will it work with Git?**
A: Yes. It detects Git and can use Git stash for backup.

---

## Related Documentation

- [NEW-PROJECT-SETUP.md](./NEW-PROJECT-SETUP.md) - Creating new projects
- [CLAUDE.md](./CLAUDE.md) - AI assistant guidance
- [README.md](./README.md) - Repository overview
- [baseline_docs/README.md](./baseline_docs/README.md) - Baseline templates
- [coding-standards/README.md](./coding-standards/README.md) - Coding standards

---

## Getting Help

**If you encounter issues:**

1. Check this guide's [Troubleshooting](#troubleshooting) section
2. Review the log file: `baseline-addition.log`
3. Run with `-DryRun` to preview
4. Check backup: `.baseline-backup-*/`

**Common commands:**

```powershell
# Get help
Get-Help .\add-baseline-to-existing-project.ps1 -Full

# View examples
Get-Help .\add-baseline-to-existing-project.ps1 -Examples

# View parameters
Get-Help .\add-baseline-to-existing-project.ps1 -Parameter *
```

---

**Last Updated:** January 2025
**Version:** 1.0
