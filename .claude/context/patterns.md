# Coding Patterns - claude_code_baseline

**Last Updated:** 2025-11-05

This file documents coding patterns, best practices, and conventions established for this project.

---

## 🎨 Established Patterns

### Pattern 1: PowerShell Character Analysis for Encoding Issues

**When to use:** Debugging encoding or character-related issues in text files, especially when Unicode corruption is suspected.

**Example:**
```powershell
# Read file and analyze characters
$lines = Get-Content 'script.ps1'
$line = $lines[165]  # 0-indexed

# Convert to character array and analyze
$chars = $line.ToCharArray()
for ($i = 0; $i -lt $chars.Length; $i++) {
    $unicode = [int]$chars[$i]
    $hexValue = $unicode.ToString('X4')

    # Display character with Unicode value
    Write-Host "[$i] '$($chars[$i])' U+$hexValue"

    # Flag non-ASCII characters
    if ($unicode -ge 128) {
        Write-Host "  ^ NON-ASCII CHARACTER" -ForegroundColor Red
    }
}
```

**Why this pattern:**
- Reveals hidden encoding issues that aren't visible in editors
- Shows exact Unicode values for each character
- Identifies problematic characters (curly quotes, emojis, etc.)
- Enables byte-level debugging of text corruption

**Files using this pattern:**
- `claude_wip/analyze-line-166.ps1`
- `claude_wip/find-all-unicode.ps1`

**Discovered:** 2025-11-05 during Unicode corruption debugging

---

### Pattern 2: PowerShell Script Parser Testing

**When to use:** Validating PowerShell script syntax programmatically before execution, especially in CI/CD or pre-commit hooks.

**Example:**
```powershell
# Test if script parses correctly
$scriptPath = 'E:\path\to\script.ps1'
$parseErrors = $null
$tokens = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    $scriptPath,
    [ref]$tokens,
    [ref]$parseErrors
)

if ($parseErrors.Count -eq 0) {
    Write-Host "SUCCESS: Script parses without errors!" -ForegroundColor Green
} else {
    Write-Host "ERRORS FOUND: $($parseErrors.Count)" -ForegroundColor Red
    foreach ($err in $parseErrors) {
        Write-Host "`nLine $($err.Extent.StartLineNumber), Column $($err.Extent.StartColumnNumber):"
        Write-Host "  Message: $($err.Message)"
        Write-Host "  Extent: $($err.Extent.Text)"
    }
}
```

**Why this pattern:**
- Catches syntax errors before running potentially dangerous scripts
- Provides accurate line numbers and error messages
- Can be integrated into CI/CD pipelines
- Safer than running scripts with `-WhatIf` for syntax validation
- More reliable than Get-Command parsing

**Files using this pattern:**
- `claude_wip/test-parse.ps1`

**Discovered:** 2025-11-05 during script debugging

---

### Pattern 3: Progressive File Mapping with Component Selection

**When to use:** Building complex file copy/transform operations where users need granular control over which components to deploy.

**Example:**
```powershell
function Get-FileMapping {
    param([string[]]$Components)

    $mapping = @()

    # Component 1: Documentation
    if ($Components -contains "all" -or $Components -contains "docs") {
        $docFiles = Get-ChildItem (Join-Path $BasePath "docs") -Recurse -File
        foreach ($file in $docFiles) {
            $relativePath = $file.FullName.Substring(
                (Join-Path $BasePath "docs").Length
            ).TrimStart('\', '/')

            $mapping += @{
                Source = $file.FullName
                Destination = Join-Path $TargetPath "docs\$relativePath"
                Component = "docs"
                ConflictAction = "Suffix"
            }
        }
    }

    # Component 2: Configuration
    if ($Components -contains "all" -or $Components -contains "config") {
        # Add more mappings...
    }

    return $mapping
}
```

**Why this pattern:**
- Flexible component selection (users pick what they need)
- Consistent conflict handling across all components
- Easy to extend with new components
- Clear source-to-destination mapping
- Supports "all" for convenience

**Files using this pattern:**
- `add-baseline-to-existing-project.ps1` (Get-FileMapping function)

**Discovered:** Used throughout project, enhanced 2025-11-05

---

### Pattern 4: YAML Frontmatter in Markdown Templates

**When to use:** Creating reusable documentation templates that need metadata without disrupting content readability.

**Example:**
```markdown
---
title: "Security Standards and Compliance"
category: "Security"
priority: "high"
last_updated: "2025-11-05"
tags: ["security", "compliance", "OWASP", "SOC2"]
template_variables:
  - PROJECT_NAME
  - COMPANY_NAME
  - DOMAIN
---

# Security Standards

Content here can use {{PROJECT_NAME}} variables...
```

**Why this pattern:**
- Clean separation of metadata and content
- YAML is human-readable and parseable
- Doesn't disrupt markdown rendering
- Enables scripted processing of templates
- Standard in Jekyll, Hugo, and other static site generators

**Files using this pattern:**
- All 10 files in `baseline_docs/`
- All 12 files in `coding-standards/`

**Established:** 2025-11-02 (project creation)

---

### Pattern 5: Conflict Handling with Multiple Strategies

**When to use:** Copying files to locations where conflicts may occur, giving users control over resolution.

**Example:**
```powershell
# Handle conflict based on strategy
if (Test-Path $destination) {
    switch ($ConflictStrategy) {
        "skip" {
            Write-Host "Skipping $file (already exists)"
            continue
        }
        "suffix" {
            $destination = "$destination.baseline"
            Write-Host "Creating $destination (conflict resolved with suffix)"
        }
        "interactive" {
            $choice = Read-Host "File exists. [S]kip, [B]ackup, [R]ename?"
            # Handle user choice...
        }
        "alternate-directory" {
            $destination = Join-Path $alternatePath $file
            Write-Host "Using alternate directory"
        }
    }
}

Copy-Item $source $destination
```

**Why this pattern:**
- Never overwrites files without user consent
- Multiple strategies for different use cases
- "Skip" is safest (preserves existing)
- "Suffix" allows comparison (.baseline extension)
- "Interactive" gives complete control
- "Alternate-directory" for complete separation

**Files using this pattern:**
- `add-baseline-to-existing-project.ps1` (Add-BaselineFiles function)

**Established:** 2025-11-02, enhanced 2025-11-05

---

## 🔧 Helper Functions / Utilities

### Helper 1: Write-Header, Write-Success, Write-Info, Write-Conflict

**Location:** `add-baseline-to-existing-project.ps1` (lines 152-177)

**Purpose:** Consistent, formatted console output with visual hierarchy

**Usage:**
```powershell
Write-Header "ADD BASELINE TO PROJECT"
Write-Success "Pre-flight checks passed"
Write-Info "Scanning baseline files..."
Write-Conflict "10 files already exist"
Write-Skip "README.md (already exists)"
Write-Detail "Found 45 files to process"
```

**Output Format:**
```
========================================
  ADD BASELINE TO PROJECT
========================================

  [OK] Pre-flight checks passed
  > Scanning baseline files...
    Found 45 files to process
  [!] 10 files already exist
  [SKIP] README.md (already exists)
```

**Common use cases:**
- Script output formatting
- Progress indication
- Status messages
- Conflict warnings
- Success confirmation

**Note:** Changed from Unicode emojis to ASCII-safe on 2025-11-05 for cross-platform compatibility

---

### Helper 2: Template Variable Replacement

**Location:** `add-baseline-to-existing-project.ps1` (lines 567-576)

**Purpose:** Replace template variables in copied files

**Usage:**
```powershell
$variables = @{
    'PROJECT_NAME' = 'My Project'
    'COMPANY_NAME' = 'My Company'
    'DATE' = Get-Date -Format 'yyyy-MM-dd'
}

$content = Get-Content $file -Raw
foreach ($var in $variables.GetEnumerator()) {
    $pattern = "{{$($var.Key)}}"
    $content = $content -replace [regex]::Escape($pattern), $var.Value
}
Set-Content -Path $file -Value $content -NoNewline
```

**Why this approach:**
- Uses `[regex]::Escape()` to handle special characters
- `-NoNewline` preserves file formatting
- Supports nested variables
- Fast string replacement

---

## 🏗️ Architecture Patterns

### Service Layer Pattern (Documentation Structure)

**Pattern:** Organized documentation by functional area
- **Location:** `baseline_docs/` and `coding-standards/`
- **Naming:** `00-overview.md` (numeric prefix for ordering)
- **Purpose:** Logical organization, easy navigation
- **Cross-references:** Links between related documents

**Structure:**
```
baseline_docs/
├── 00-overview.md           # Project overview
├── 01-architecture.md       # Technical architecture
├── 02-security.md           # Security standards
├── 03-coding-standards.md   # Redirect to coding-standards/
├── 04-ai-agent-protocol.md  # AI workflows
└── ...
```

---

### Memory System Pattern (Claude Code Integration)

**Pattern:** Layered memory with session-specific and persistent context

**Structure:**
```
.claude/
├── memory/                  # Session-specific (changes each session)
│   ├── session-notes-{{DATE}}.md
│   ├── next-session.md
│   └── snapshots/
│       └── snapshot-{{DATE}}.json
└── context/                 # Persistent (updated but not replaced)
    ├── project-overview.md
    ├── patterns.md
    ├── gotchas.md
    └── architecture-decisions.md
```

**Purpose:**
- Session notes: Detailed record of specific session
- Next session: Clear starting point for future
- Snapshots: Machine-readable project state
- Context: Accumulated knowledge over time

**Why this works:**
- Future Claude sessions read all memory files
- Complete context available without re-explanation
- Patterns and gotchas accumulate
- Project overview evolves but isn't replaced

---

## ✅ Testing Patterns

### Dry-Run Pattern

**When to use:** Any destructive operation (file copy, deletion, modification)

**Example:**
```powershell
param([switch]$DryRun)

if ($DryRun) {
    Write-Host "DRY RUN: Would copy $source to $destination"
} else {
    Copy-Item $source $destination
    Write-Host "Copied $source to $destination"
}
```

**Why this pattern:**
- Preview changes before committing
- Safe testing of complex operations
- User confidence before deployment
- Easy to implement with `-WhatIf` parameter support

**Files using this pattern:**
- `add-baseline-to-existing-project.ps1`

---

### Backup Before Modify Pattern

**When to use:** Any operation that modifies existing files

**Example:**
```powershell
# Create backup before making changes
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = Join-Path $ProjectPath ".baseline-backup-$timestamp"

# Backup specific files/directories
Copy-Item $filesToBackup $backupPath -Recurse

# Make changes...

# If error occurs, restore from backup
if ($error) {
    Copy-Item "$backupPath\*" $ProjectPath -Recurse -Force
}
```

**Why this pattern:**
- Safety net for mistakes
- Easy rollback if issues occur
- User confidence in destructive operations
- Automatic recovery from failures

**Files using this pattern:**
- `add-baseline-to-existing-project.ps1` (New-BackupDirectory function)

---

## 🚫 Anti-Patterns (What to Avoid)

### Anti-Pattern 1: Unicode Emojis in PowerShell Scripts

**Problem:** Unicode characters corrupt when copied across systems, causing parsing errors

**What NOT to do:**
```powershell
# BAD - Unicode emojis
Write-Host "  ✓ Success" -ForegroundColor Green
Write-Host "  → Processing" -ForegroundColor Yellow
Write-Host "  ⚠ Warning" -ForegroundColor Yellow
```

**Instead use:**
```powershell
# GOOD - ASCII-safe alternatives
Write-Host "  [OK] Success" -ForegroundColor Green
Write-Host "  > Processing" -ForegroundColor Yellow
Write-Host "  [!] Warning" -ForegroundColor Yellow
```

**Why it's bad:**
- Emojis can contain curly quotes (U+2018, U+2019)
- Corruption is invisible in most editors
- Causes "missing string terminator" errors
- PowerShell encoding varies across systems

**Discovered:** 2025-11-05 (learned the hard way!)

---

### Anti-Pattern 2: WIP Files in Root Directory

**Problem:** Creates clutter and violates project organization standards

**What NOT to do:**
```
claude_code_baseline/
├── diagnostic-script.ps1    # BAD - in root
├── test-encoding.ps1        # BAD - in root
├── temp-analysis.md         # BAD - in root
└── ...
```

**Instead use:**
```
claude_code_baseline/
├── claude_wip/
│   ├── diagnostic-script.ps1    # GOOD - in claude_wip
│   ├── test-encoding.ps1        # GOOD - in claude_wip
│   └── temp-analysis.md         # GOOD - in claude_wip
└── ...
```

**Why it's bad:**
- Root directory gets cluttered
- Violates documented project standards
- User will immediately correct violations
- Makes it hard to distinguish permanent vs temporary files

**Lesson learned:** 2025-11-05 (user corrected this immediately)

---

### Anti-Pattern 3: Overwriting Existing Files Without Consent

**Problem:** Destroys user customizations and causes data loss

**What NOT to do:**
```powershell
# BAD - overwrites without asking
Copy-Item $source $destination -Force
```

**Instead use:**
```powershell
# GOOD - check for conflicts first
if (Test-Path $destination) {
    # Handle conflict based on strategy
    # Options: skip, suffix, interactive, backup
} else {
    Copy-Item $source $destination
}
```

**Why it's bad:**
- Destroys user work
- No rollback possible
- Violates principle of least surprise
- Breaks trust

---

## 📝 Documentation Patterns

### Pattern: Comprehensive Session Notes

**Format:** Markdown with multiple sections capturing complete session context

**Structure:**
```markdown
# Session Notes - {{DATE}}

## What We Accomplished
## What We Learned
## Important Decisions Made
## Issues Encountered & Resolved
## Gotchas & Warnings
## Next Session Planning
## Code Patterns Used
```

**Why this works:**
- Future sessions have complete context
- Decisions are documented with rationale
- Patterns are captured for reuse
- Gotchas prevent repeated mistakes

**Files using this pattern:**
- `.claude/memory/session-notes-{{DATE}}.md`

**Established:** 2025-11-04, refined 2025-11-05

---

**Note:** This file is updated when new patterns are discovered or established. Last update: 2025-11-05.
