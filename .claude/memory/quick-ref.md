# Quick Reference - Load This First Every Session

**Purpose**: 30-second context loading for Claude Code sessions

**Usage**: At session start, say: "Load quick-ref" or "Read .claude/memory/quick-ref.md"

---

## 🚨 CRITICAL STANDARDS (Always Follow)

### 1. File Location Rules
```
✅ CORRECT:
- Temporary files → claude_wip/scripts/
- Draft docs → claude_wip/drafts/
- Analysis → claude_wip/analysis/
- Backups → claude_wip/backups/

❌ WRONG:
- NO temporary files in root directory
- NO test scripts outside claude_wip/
- NO draft/WIP files in tracked directories
```

**Pre-Commit Hook**: Automatically blocks violations

### 2. Logging Standard (PHP)
```php
// ✅ CORRECT
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Message", ['context' => 'value']);

// ❌ WRONG
Log::info("Message");
error_log("Message");
```

### 3. Safety Rules (NEVER ALLOW)
- ❌ NO `Schema::drop()` or `Schema::dropIfExists()`
- ❌ NO `TRUNCATE` or `DROP TABLE` statements
- ❌ NO `DELETE FROM` without `WHERE msp_id`
- ❌ NO `unlink()` without backup
- ❌ NO `rm -rf` operations
- ✅ ALWAYS require multi-tenant filtering: `WHERE msp_id = ?`
- ✅ ALWAYS use soft deletes over hard deletes

### 4. Security Rules
- ❌ NO hardcoded credentials
- ✅ ALL API keys → `config('services.name.key')`
- ✅ Use `.env` for sensitive data
- ✅ All secrets in `.gitignore`

### 5. Documentation Standards
- ✅ ComplianceScorecard branding required
- ✅ Use logo: `![ComplianceScorecard Logo](../images/cs-logo.png)`
- ✅ Use template: `project_docs/includes/report-template.html`
- ✅ Bootstrap 5 for HTML reports

---

## 📋 Pre-Task Checklist

Before creating ANY file, ask yourself:

1. **Is this temporary?** → Goes in `claude_wip/`
2. **Is this a script?** → Goes in `claude_wip/scripts/`
3. **Is this a draft?** → Goes in `claude_wip/drafts/`
4. **Is this documentation?** → Use proper template with placeholders
5. **Does it contain logs?** → Use `__FILE__:__LINE__` format
6. **Does it have credentials?** → Use config/env, never hardcode

**Git Hook**: Pre-commit hook validates these rules automatically

---

## 🏗️ Project Structure

```
{{BASELINE_ROOT}}\
├── .claude/
│   ├── agents/              # Project-specific agent customizations
│   ├── memory/              # Session memory (quick-ref, notes)
│   ├── hooks/               # Git hook templates and docs
│   ├── scripts/             # PowerShell automation scripts
│   ├── settings.example.json
│   └── settings.local.json  # Gitignored - user-specific
│
├── agents/                  # Baseline agents (synced to global)
├── baseline_docs/           # Project setup templates
├── coding-standards/        # All coding standards documents
├── docs/                    # GitHub Pages site
├── project_docs/            # HTML documentation
├── markdown/                # General markdown docs
│
├── claude_wip/              # Gitignored - AI temporary work
│   ├── scripts/
│   ├── drafts/
│   ├── analysis/
│   └── backups/
│
└── tim_wip/                 # Gitignored - User temporary work
```

---

## 🔍 Standards Location

**Full standards documentation:**
- `coding-standards/01-pseudo-code-standards.md`
- `coding-standards/02-project-structure.md`
- `coding-standards/03-php-standards.md`
- `coding-standards/04-javascript-standards.md`
- `coding-standards/05-database-standards.md`
- `coding-standards/06-logging-standards.md`
- `coding-standards/07-safety-rules.md` ← **CRITICAL**
- `coding-standards/08-quality-standards.md`
- `coding-standards/10-testing-standards.md`
- `coding-standards/11-security-standards.md`
- `coding-standards/12-performance-standards.md`

---

## 🤖 Available Agents

**Core Development:**
- `/code-documenter` - Generate PHPDoc, JSDoc, inline comments
- `/code-reviewer` - Review code for bugs, security, standards
- `/refactorer` - Refactor code following DRY, SOLID principles
- `/test-runner` - Run tests, generate coverage reports

**Standards & Security:**
- `/standards-enforcer` - Check for standards violations
- `/security-auditor` - OWASP Top 10, security scan

**Documentation:**
- `/gen-docs` - Generate HTML/Markdown documentation
- `/end-of-day` - Comprehensive session summary

**Git Operations:**
- `/git-helper` - Commits, branches, PRs, conflict resolution

**Session Management:**
- `/session-start` - Load context at session start
- `/end-of-day-integrated` - Orchestrated quality checks

**Invoke when needed:**
```bash
/standards-enforcer    # Before committing
/security-auditor      # Before production
/code-reviewer         # After major changes
```

---

## 🎯 Current Project Context

**Project**: ComplianceScorecard Engineering Baseline
**Purpose**: Standards, templates, and agent infrastructure for all projects
**Repository**: `{{BASELINE_ROOT}}`
**GitHub**: `https://github.com/goldeneye/claude-code-baseline.git`

**Key Features:**
- 15 AI agents (baseline + specialized)
- Comprehensive coding standards
- Project setup templates
- Pre-commit hooks for enforcement
- GitHub Pages documentation site
- Settings template system

**Git Workflow:**
- Branch: `main`
- Remote: `origin` (GitHub)
- Pre-commit hook: ✅ Active
- WIP directories: ✅ Gitignored

---

## 🔧 Quick Commands

**Standards Enforcement:**
```bash
# Manual standards check
/standards-enforcer

# Git will auto-check on commit
git commit -m "message"  # Hook validates automatically
```

**Agent Sync:**
```bash
# Sync agents from baseline to global
powershell -NoProfile -File sync-agents.ps1

# Force sync all agents
powershell -NoProfile -File sync-agents.ps1 -Force
```

**Project Setup:**
```bash
# Add baseline to existing project
powershell -NoProfile -File add-baseline-to-existing-project.ps1
```

---

## 💡 Remember Every Session

1. **ALWAYS use `claude_wip/` for temporary files**
2. **NEVER hardcode credentials or paths**
3. **ALWAYS use `__FILE__:__LINE__` in logs**
4. **NEVER allow destructive operations without safeguards**
5. **ALWAYS preserve {{TEMPLATE_VARIABLES}} in baseline docs**
6. **Pre-commit hook will block violations** - trust it!

---

## 📚 Additional Memory Files

Create these as needed in `.claude/memory/`:

- `session-notes-YYYY-MM-DD.md` - Daily session notes
- `project-context.json` - Machine-readable context
- `snapshots/snapshot-YYYY-MM-DD.json` - State snapshots
- `decisions.md` - Architecture decisions made
- `issues.md` - Known issues and workarounds

---

## 🚀 Session Start Checklist

1. ✅ Read this quick-ref
2. ✅ Check git status (`git status`)
3. ✅ Review any uncommitted changes
4. ✅ Load any session-specific notes
5. ✅ Verify pre-commit hook is active
6. ✅ Ready to code!

---

**Last Updated**: 2025-11-05
**Version**: 1.0
**Maintained By**: Claude Code + Tim Golden
