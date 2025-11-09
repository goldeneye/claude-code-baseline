# Gotchas & Known Issues - claude_code_baseline

**Last Updated:** 2025-11-05

This file documents tricky issues, gotchas, and their solutions to prevent future debugging.

---

## ⚠️ Known Gotchas

### Gotcha 1: PowerShell Script Encoding Corruption

**Problem:**
Unicode emoji characters (✓, →, ⚠, ⊘) in PowerShell scripts can corrupt when copied across systems or edited in different editors, causing parser errors with misleading error messages.

**Why it happens:**
- Different editors handle Unicode differently (VS Code, Notepad++, PowerShell ISE)
- Copy-paste from rich text sources includes hidden formatting
- Windows encoding varies (UTF-8, UTF-16, ANSI)
- Emoji characters may contain multi-byte sequences with problematic characters (curly quotes U+2018, U+2019)

**Symptoms:**
- PowerShell parsing fails with "missing string terminator" error
- Error message points to wrong line number
- Script appears correct in most text editors
- Only revealed with character-by-character analysis

**Solution:**
1. Use only ASCII characters (U+0000 to U+007F) in PowerShell scripts
2. Replace Unicode emojis with ASCII-safe alternatives:
   - ✓ → `[OK]`
   - → → `>`
   - ⚠ → `[!]`
   - ⊘ → `[SKIP]`
3. Test scripts with PowerShell parser before committing:
```powershell
$parseErrors = $null
$tokens = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    "script.ps1", [ref]$tokens, [ref]$parseErrors
)
if ($parseErrors.Count -gt 0) { "ERRORS FOUND" }
```

**How to detect:**
```powershell
# Scan for non-ASCII characters
$lines = Get-Content 'script.ps1'
for ($i = 0; $i -lt $lines.Count; $i++) {
    $chars = $lines[$i].ToCharArray()
    foreach ($char in $chars) {
        if ([int]$char -ge 128) {
            Write-Host "Line $($i+1): Non-ASCII U+$([int]$char.ToString('X4'))"
        }
    }
}
```

**Affected files:**
- `add-baseline-to-existing-project.ps1` (fixed 2025-11-05)

**Discovered:** 2025-11-05 during debugging session

**Prevention:**
- Add pre-commit hook to detect non-ASCII in .ps1 files
- Use .editorconfig to enforce UTF-8 without BOM
- Scan all PowerShell scripts periodically
- Never copy-paste from Word, rich text editors, or websites

---

### Gotcha 2: PowerShell Parser Errors Point to Wrong Line

**Problem:**
When PowerShell encounters encoding issues or malformed characters, the parser error message may point to a completely different line than where the actual problem is.

**Why it's tricky:**
- Parser tries to recover from errors
- Continues parsing until it hits a breaking point
- Reports error at breaking point, not at corruption point
- Example: Corruption on line 166, error reported at line 852

**Solution:**
1. Don't trust the line number in the error message
2. Use PowerShell parser programmatically to get all errors
3. Scan entire file for encoding issues
4. Check lines near the reported error, but also scan globally

**Example:**
```
Error says: "Line 852: missing string terminator"
Actual problem: Line 166 has corrupted emoji with curly quote
```

**How to debug:**
1. Run PowerShell parser to get ALL errors
2. Create diagnostic script to scan for non-ASCII
3. Check character-by-character around all non-ASCII characters
4. Fix the actual corruption, not the line in error message

**Discovered:** 2025-11-05 (wasted 30 minutes checking line 852 when problem was line 166)

---

### Gotcha 3: Project Standards Are Strictly Enforced

**Problem:**
User has strict project standards documented in CLAUDE.md and agent files. Violations will be immediately called out and must be corrected.

**Why it matters:**
- Standards exist for good reason (organization, consistency)
- Future Claude instances rely on standards being followed
- User expects adherence without needing to remind
- Violations break workflows and organization

**Standard:** ALL WIP/diagnostic/temporary files go in `claude_wip/` directory

**Violation Example:**
Creating diagnostic scripts in root instead of claude_wip/:
```
claude_code_baseline/
├── check-quotes.ps1         # WRONG - in root
├── test-parse.ps1           # WRONG - in root
└── ...
```

**Correct:**
```
claude_code_baseline/
└── claude_wip/
    ├── check-quotes.ps1     # CORRECT - in claude_wip
    ├── test-parse.ps1       # CORRECT - in claude_wip
    └── ...
```

**User Response:**
> "you didnt adhere to our standards you WIP folder is claude_wip but yet you made the PS scrip in the root directory why didnt you obey our standars we outline in all the agens, and MD files!!"

**How to avoid:**
1. Read CLAUDE.md at session start
2. Check agent standards before creating files
3. Default to claude_wip/ for any temporary work
4. Ask if unsure about file location
5. When corrected, fix immediately and acknowledge

**Discovered:** 2025-11-05 (user corrected immediately)

---

### Gotcha 4: Baseline Script Component Selection

**Problem:**
The `add-baseline-to-existing-project.ps1` script has multiple components that can be selected independently. Not understanding this leads to incomplete deployments.

**Why it's important:**
- Not all projects want all baseline components
- `-Components` parameter allows selective copying
- "all" is default but can be overridden
- New components added over time (claude-config, agents added 2025-11-05)

**Components Available:**
- `baseline-docs` - Documentation templates
- `coding-standards` - Coding guidelines
- `claude-wip` - Working directory setup
- `claude-config` - Claude Code settings (NEW 2025-11-05)
- `agents` - Agent definitions (NEW 2025-11-05)
- `scripts` - Utility scripts
- `gitignore` - Git ignore patterns
- `all` - Everything (default)

**How to handle:**
1. Use `-DryRun` first to preview what will be copied
2. Check file count matches expectations
3. Specify components explicitly if selective deployment needed:
```powershell
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\project" `
    -Components baseline-docs,agents `
    -DryRun
```

**File count expectations:**
- **Before 2025-11-05:** 29 files
- **After 2025-11-05:** 45 files (added .claude and agents/)

**Discovered:** 2025-11-05 when user noticed missing .claude files

---

### Gotcha 5: Template Variables Not Replaced Automatically

**Problem:**
Template variables like `{{PROJECT_NAME}}`, `{{COMPANY_NAME}}` remain in copied files unless explicitly replaced.

**Why it happens:**
- add-baseline-to-existing-project.ps1 has `-SkipVariables` option
- Without config file, variables aren't replaced
- User must manually update or provide config

**Example:**
After copying baseline, files still contain:
```markdown
# {{PROJECT_NAME}} Security Standards

This document defines security standards for {{COMPANY_NAME}}.
```

**Solution:**
1. **Option A:** Provide config file:
```powershell
.\add-baseline-to-existing-project.ps1 `
    -ProjectPath "E:\project" `
    -ConfigFile "config.json"
```

Where config.json:
```json
{
  "PROJECT_NAME": "My Project",
  "COMPANY_NAME": "My Company",
  "DOMAIN": "myproject.com"
}
```

2. **Option B:** Manually update after deployment
3. **Option C:** Use `-SkipVariables` and replace later with script

**How to avoid confusion:**
- Document template variables at top of each file
- Use dry-run to see what will be copied
- Consider providing template config file

**Discovered:** Throughout project development

---

## 🐛 Known Bugs (Not Yet Fixed)

*No known bugs at this time. Last checked: 2025-11-05*

---

## 🔧 Environment-Specific Issues

### Windows PowerShell Execution Policy

**Issue:** PowerShell scripts may not run due to execution policy

**Symptoms:**
```
File script.ps1 cannot be loaded because running scripts is disabled on this system.
```

**Workaround:**
```powershell
# Option 1: Bypass for single script
powershell.exe -ExecutionPolicy Bypass -File "script.ps1"

# Option 2: Set policy for current user (permanent)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Alternative:** Sign scripts with code-signing certificate

---

### WSL Line Ending Issues

**Issue:** Git may show files as modified when switching between Windows and WSL

**Symptoms:**
```bash
$ git status
modified:   script.ps1  # but no actual changes
```

**Workaround:**
```bash
# Configure Git to handle line endings
git config --global core.autocrlf input

# Create .gitattributes
echo "*.sh text eol=lf" >> .gitattributes
echo "*.ps1 text eol=crlf" >> .gitattributes
```

**Solution:** Use `setup-wsl.sh` script which configures this automatically

---

### XAMPP Service Detection on Non-Standard Ports

**Issue:** check-services.ps1 assumes default ports (Apache:80, MySQL:3306)

**Symptoms:**
- Services shown as "not running" when they are running on different ports
- False negatives in monitoring

**Workaround:**
Modify ports in script or check `netstat` output manually:
```powershell
netstat -ano | findstr ":8080"  # Check custom Apache port
```

**Future fix:** Make ports configurable via parameters or config file

---

## 📦 Dependency Issues

### Bootstrap 5 CDN Dependency

**Issue:** HTML reports use Bootstrap CDN. Reports fail to render properly offline.

**Description:** All HTML reports rely on:
```html
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
```

**Workaround:**
1. **Online:** Reports work fine when internet connected
2. **Offline:** Download Bootstrap locally and update HTML templates

**Tracking:** Low priority (most environments have internet)

---

### PowerShell Version Compatibility

**Issue:** Scripts assume PowerShell 5.1+. May not work on PowerShell 2.0.

**Affected versions:** PowerShell 2.0 (Windows 7)

**Workaround:**
Upgrade to PowerShell 5.1 or later:
```powershell
$PSVersionTable.PSVersion  # Check current version
```

**Note:** PowerShell 7+ (cross-platform) is recommended but not required

---

## 💾 Git Quirks

### Large Files in Git History

**Issue:** Security audit reports (HTML, images) are large (50-300 KB each)

**Impact:**
- Repository size grows over time
- Clone times increase
- Some reports may belong in .gitignore

**Mitigation:**
- Consider using Git LFS for large reports
- Archive old reports to separate repository
- Add WIP reports to .gitignore

**Status:** Monitoring, no action needed yet

---

### Untracked Files in claude_wip/

**Issue:** claude_wip/ is in .gitignore, but README.md should be tracked

**Current .gitignore:**
```
claude_wip/
!claude_wip/README.md
!claude_wip/**/.gitkeep
```

**This works correctly:** README.md and .gitkeep files are tracked, everything else ignored

**No action needed**

---

## 🌐 Platform-Specific Issues

### Windows-Only Scripts

**Issue:** All PowerShell scripts are Windows-only

**Affected scripts:**
- All .ps1 files (PowerShell)
- Bash scripts exist but are for WSL only

**Workaround:**
- Use WSL for cross-platform compatibility
- Use PowerShell 7+ on macOS/Linux (experimental)

**Status:** Documented limitation, not a bug

---

### File Path Separators

**Issue:** PowerShell scripts use backslashes (`\`) which don't work on Unix

**Example:**
```powershell
$path = "{{BASELINE_ROOT}}"  # Windows-specific
```

**Solution:** Use `Join-Path` for cross-platform compatibility:
```powershell
$path = Join-Path "E:" "github" "claude_code_baseline"
```

**Status:** Most scripts use Join-Path correctly

---

## 🔍 Diagnostic Tips

### How to Find Non-ASCII Characters

Use diagnostic script:
```powershell
# Run find-all-unicode.ps1
.\claude_wip\find-all-unicode.ps1
```

Or manually:
```powershell
$lines = Get-Content 'file.ps1'
for ($i = 0; $i -lt $lines.Count; $i++) {
    $chars = $lines[$i].ToCharArray()
    foreach ($char in $chars) {
        if ([int]$char -ge 128) {
            Write-Host "Line $($i+1): '$char' = U+$([int]$char.ToString('X4'))"
        }
    }
}
```

### How to Test PowerShell Script Syntax

Use test-parse.ps1:
```powershell
.\claude_wip\test-parse.ps1
```

Or manually:
```powershell
$errors = $null
$tokens = $null
[System.Management.Automation.Language.Parser]::ParseFile(
    "script.ps1", [ref]$tokens, [ref]$errors
)
$errors  # Show any errors found
```

### How to Check Git Line Endings

```bash
git config --global core.autocrlf  # Should be "input" or "true"
cat .gitattributes  # Check line ending rules
```

---

**Note:** Remove items from this file once they're permanently fixed. Last updated: 2025-11-05.
