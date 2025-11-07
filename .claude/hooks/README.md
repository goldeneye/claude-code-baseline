# Git Hooks Documentation

**Purpose**: Automated enforcement of project coding standards

Git hooks are scripts that run automatically at specific points in the Git workflow. This directory contains hook templates and installation instructions.

---

## Available Hooks

### `pre-commit`

**Runs**: Before every `git commit`

**Enforces**:
1. ✅ No temporary files in root directory
2. ✅ Scripts must be in approved locations
3. ✅ No Windows reserved filenames (nul, con, prn, etc.)
4. ✅ PHP logging format compliance
5. ⚠️ Warns about hardcoded credentials
6. ✅ Ensures `claude_wip/` directory structure exists

**Example Output**:
```bash
$ git commit -m "Add feature"
🛡️  Enforcing Project Standards...
Checking for temporary files in root...
✅ All standards checks passed
[main abc1234] Add feature
```

**If Violations Detected**:
```bash
$ git commit -m "Add temp script"
🛡️  Enforcing Project Standards...
Checking for temporary files in root...
❌ VIOLATION: Temporary files must go in claude_wip/
test-temp.ps1
   Move these to: claude_wip/scripts/ or claude_wip/drafts/

❌ COMMIT BLOCKED: 1 standard violation(s) detected

Fix violations and try again, or use: git commit --no-verify (NOT recommended)
Review standards: coding-standards/
```

---

## Installation

### Option 1: Automatic Installation (Recommended)

**Windows (PowerShell)**:
```powershell
# From repository root
Copy-Item .claude/hooks/pre-commit .git/hooks/pre-commit -Force

# Make executable (if using Git Bash)
git update-index --chmod=+x .git/hooks/pre-commit
```

**Linux/Mac (Bash)**:
```bash
# From repository root
cp .claude/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Option 2: Installation Script

Create and run this script:

**`install-hooks.ps1` (Windows)**:
```powershell
# Install Git hooks for this repository
Write-Host "Installing Git hooks..." -ForegroundColor Cyan

$hooksSource = ".claude/hooks"
$hooksTarget = ".git/hooks"

if (-not (Test-Path $hooksTarget)) {
    Write-Host "Error: .git/hooks directory not found" -ForegroundColor Red
    Write-Host "Are you in a Git repository?" -ForegroundColor Yellow
    exit 1
}

# Install pre-commit hook
if (Test-Path "$hooksSource/pre-commit") {
    Copy-Item "$hooksSource/pre-commit" "$hooksTarget/pre-commit" -Force
    Write-Host "✓ Installed pre-commit hook" -ForegroundColor Green
} else {
    Write-Host "✗ pre-commit hook not found in $hooksSource" -ForegroundColor Red
}

Write-Host "`nGit hooks installed successfully!" -ForegroundColor Green
Write-Host "Hooks will run automatically on git commit" -ForegroundColor Gray
```

**`install-hooks.sh` (Linux/Mac)**:
```bash
#!/bin/bash
# Install Git hooks for this repository

echo "Installing Git hooks..."

HOOKS_SOURCE=".claude/hooks"
HOOKS_TARGET=".git/hooks"

if [ ! -d "$HOOKS_TARGET" ]; then
    echo "Error: .git/hooks directory not found"
    echo "Are you in a Git repository?"
    exit 1
fi

# Install pre-commit hook
if [ -f "$HOOKS_SOURCE/pre-commit" ]; then
    cp "$HOOKS_SOURCE/pre-commit" "$HOOKS_TARGET/pre-commit"
    chmod +x "$HOOKS_TARGET/pre-commit"
    echo "✓ Installed pre-commit hook"
else
    echo "✗ pre-commit hook not found in $HOOKS_SOURCE"
    exit 1
fi

echo ""
echo "Git hooks installed successfully!"
echo "Hooks will run automatically on git commit"
```

---

## Verification

### Test Hook Installation

```bash
# Check if hook exists
ls -la .git/hooks/pre-commit

# Check if hook is executable (Linux/Mac)
test -x .git/hooks/pre-commit && echo "Executable" || echo "Not executable"

# Test the hook manually
.git/hooks/pre-commit
```

### Test Hook Functionality

Create a test violation:

```bash
# Create a temp file in root (violation)
echo "test" > temp-test.txt
git add temp-test.txt
git commit -m "Test commit"

# Should see:
# ❌ VIOLATION: Temporary files must go in claude_wip/
# ❌ COMMIT BLOCKED

# Clean up
git reset HEAD temp-test.txt
rm temp-test.txt
```

---

## Bypassing Hooks (Emergency Only)

**⚠️ WARNING**: Only use in emergencies. Bypassing hooks can lead to standards violations in the repository.

```bash
# Bypass hooks for single commit
git commit --no-verify -m "Emergency fix"

# Temporarily disable hook
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled

# Re-enable later
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
```

---

## Customizing Hooks

### Adding Approved Root Scripts

Edit line 20 in `pre-commit`:

```bash
# Before
APPROVED_ROOT_SCRIPTS="sync-agents.ps1|add-baseline-to-existing-project.ps1"

# After (add your script)
APPROVED_ROOT_SCRIPTS="sync-agents.ps1|add-baseline-to-existing-project.ps1|your-script.ps1"
```

### Adding New Checks

Add new check blocks before the "Summary" section:

```bash
# Check 7: Your custom check
echo "Checking for your rule..."
VIOLATIONS_FOUND=$(git diff --cached --name-only | grep "pattern" || true)
if [ -n "$VIOLATIONS_FOUND" ]; then
    echo "❌ VIOLATION: Your custom rule violated"
    VIOLATIONS=$((VIOLATIONS + 1))
fi
```

### Disabling Specific Checks

Comment out the check block:

```bash
# # Check 4: PHP files must use proper logging format (if PHP files exist)
# PHP_FILES=$(git diff --cached --name-only --diff-filter=AM | grep "\.php$" || true)
# if [ -n "$PHP_FILES" ]; then
#     ...
# fi
```

---

## Troubleshooting

### Hook Not Running

**Symptoms**: Commits succeed without any hook output

**Solutions**:
1. Verify hook file exists: `ls -la .git/hooks/pre-commit`
2. Check if hook is executable (Linux/Mac): `chmod +x .git/hooks/pre-commit`
3. Ensure hook has no extension (not `pre-commit.sh`)
4. Check for syntax errors: `bash -n .git/hooks/pre-commit`

### Hook Errors on Windows

**Issue**: "bash: bad interpreter"

**Solution**: Ensure Git Bash is installed and hook uses Unix line endings:
```bash
# Convert line endings
dos2unix .git/hooks/pre-commit
# Or in Git
git config core.autocrlf input
```

### Hook Blocking Valid Commits

**Issue**: Hook incorrectly identifies violations

**Solutions**:
1. Review the violation message
2. Check if file truly violates standards
3. If legitimate exception, add to approved list
4. Use `--no-verify` only if absolutely necessary

### Grep Pattern Issues

**Issue**: Pattern matching fails

**Solution**: Test patterns manually:
```bash
# Test pattern
echo "filename.ps1" | grep -E "^[^/]+\.(ps1|sh)$"

# Debug hook
bash -x .git/hooks/pre-commit
```

---

## Standards Enforced

Hooks enforce standards from:
- `coding-standards/06-logging-standards.md`
- `coding-standards/07-safety-rules.md`
- `coding-standards/11-security-standards.md`

**Full documentation**: See `/coding-standards` directory

---

## Updating Hooks

When hooks are updated in `.claude/hooks/`, reinstall them:

```bash
# Backup current hook (optional)
cp .git/hooks/pre-commit .git/hooks/pre-commit.backup

# Install updated hook
cp .claude/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Test
.git/hooks/pre-commit
```

---

## Multi-Repository Setup

To install hooks across multiple repositories:

**PowerShell Script**:
```powershell
$repos = @(
    "E:\github\project1",
    "E:\github\project2",
    "E:\github\project3"
)

$hookSource = "E:\github\claude_code_baseline\.claude\hooks\pre-commit"

foreach ($repo in $repos) {
    $hookTarget = "$repo\.git\hooks\pre-commit"
    if (Test-Path "$repo\.git") {
        Copy-Item $hookSource $hookTarget -Force
        Write-Host "✓ Installed hook in $repo" -ForegroundColor Green
    } else {
        Write-Host "✗ Skipped $repo (not a Git repo)" -ForegroundColor Yellow
    }
}
```

---

## Additional Resources

- **Git Hooks Documentation**: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
- **Project Standards**: `coding-standards/` directory
- **Quick Reference**: `.claude/memory/quick-ref.md`
- **Agent Helper**: Run `/git-helper` in Claude Code

---

## Notes

- ✅ Hooks are **local** to each repository (not in version control)
- ✅ Each developer must install hooks in their local repo
- ✅ Hooks run in **Git Bash** environment (even on Windows)
- ✅ Hooks can be bypassed with `--no-verify` (not recommended)
- ✅ Update `.claude/hooks/pre-commit` to update template

---

**Last Updated**: 2025-11-05
**Maintained By**: Claude Code + Tim Golden
