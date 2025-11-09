# Architecture Decision Records - claude_code_baseline

**Last Updated:** 2025-11-05

This file documents significant architectural decisions made for this project.

---

## ADR-001: Template-Based Documentation System

**Date:** 2025-11-02
**Status:** Accepted
**Decision ID:** ADR-001

### Context

The project needed a documentation system that could be:
- Reused across multiple projects
- Easily customized per project
- Version controlled (text-based, not binary)
- Framework-agnostic (not tied to specific language/framework)
- Self-documenting (with metadata)

Forces:
- Different projects have different documentation needs
- Copy-paste documentation leads to inconsistency
- Binary formats (Word, PDF) don't version control well
- Projects need both structure and flexibility
- Documentation should work with or without build tools

### Decision

Use **Markdown templates with YAML frontmatter** and **template variables** for all baseline documentation.

Format:
```markdown
---
title: "Document Title"
category: "Category"
priority: "high"
template_variables:
  - PROJECT_NAME
  - COMPANY_NAME
---

# Document Title

Content with {{PROJECT_NAME}} variables...
```

### Rationale

**Reasons for this decision:**
1. **Markdown is universal** - Readable as plain text, renders in GitHub, supports rich formatting
2. **YAML frontmatter is standard** - Used by Jekyll, Hugo, many static site generators
3. **Template variables enable customization** - Simple `{{VAR}}` syntax, easy to find/replace
4. **Version control friendly** - Text files diff cleanly, easy to review changes
5. **Framework-agnostic** - Works with any language, any project structure
6. **Tooling support** - Every editor supports Markdown, many tools parse YAML

### Alternatives Considered

**Option A: Word/PDF Templates**
- Pros: Familiar, WYSIWYG, professional formatting
- Cons: Binary format, poor version control, requires Microsoft Office, hard to customize
- **Why rejected:** Version control is critical, must be text-based

**Option B: AsciiDoc**
- Pros: More features than Markdown, better for complex docs
- Cons: Less widely supported, steeper learning curve, fewer tools
- **Why rejected:** Markdown support is more universal

**Option C: ReStructuredText**
- Pros: Used in Python ecosystem, powerful
- Cons: Complex syntax, primarily Python-focused
- **Why rejected:** Too complex for general use, not framework-agnostic

### Consequences

**Positive:**
- Easy to customize documentation per project
- Clean version control and diff history
- Works with any text editor
- Can automate variable replacement
- Templates can be improved over time
- Framework-agnostic design

**Negative:**
- Requires manual or scripted variable replacement
- YAML frontmatter not rendered by all Markdown viewers
- More work upfront to create templates
- Users must understand template variables

**Neutral:**
- Templates need periodic updates as best practices evolve
- Different projects may need different subsets of templates

### Implementation

- Created 10 baseline documentation templates in `baseline_docs/`
- Created 12 coding standard templates in `coding-standards/`
- Added YAML frontmatter to all templates
- Documented template variables in each file
- Created `add-baseline-to-existing-project.ps1` with optional variable replacement

### Related Decisions

- Related to ADR-002 (PowerShell automation)
- Related to ADR-004 (ASCII-safe scripts)

---

## ADR-002: PowerShell for Automation

**Date:** 2025-11-02
**Status:** Accepted
**Decision ID:** ADR-002

### Context

The project needed automation for:
- Backup operations (MySQL databases, Git repositories, baseline files)
- Service monitoring (XAMPP Apache and MySQL)
- Documentation generation (README index)
- Validation (baseline quality checks)
- Baseline deployment to existing projects

Forces:
- Target environment: Windows with XAMPP
- Need file system, Git, and MySQL access
- Scripts should be maintainable by team
- Cross-platform support would be nice but not required
- Must integrate with existing Windows workflows

### Decision

Use **PowerShell 5.1+** for all automation scripts.

### Rationale

**Reasons for this decision:**
1. **Native Windows integration** - Built into Windows, no installation needed
2. **Powerful scripting** - Object-oriented, not text-based like Bash
3. **Access to .NET** - Can use full .NET Framework capabilities
4. **Good Git integration** - Can call Git commands easily
5. **MySQL compatibility** - Can execute MySQL commands, parse output
6. **File system operations** - Excellent support for complex file operations
7. **Team familiarity** - Team knows PowerShell better than Python/Node.js

### Alternatives Considered

**Option A: Bash/Shell Scripts**
- Pros: Cross-platform, familiar to Linux users, simple syntax
- Cons: Text-based parsing (brittle), Windows support requires WSL/Cygwin, limited .NET access
- **Why rejected:** Team is Windows-focused, PowerShell is superior on Windows

**Option B: Python**
- Pros: Cross-platform, huge ecosystem, readable syntax
- Cons: Requires Python installation, dependency management (pip), not built into Windows
- **Why rejected:** Requires external dependencies, PowerShell is native

**Option C: Node.js**
- Pros: Cross-platform, modern, good package ecosystem
- Cons: Requires Node.js installation, npm dependencies, async complexity for simple tasks
- **Why rejected:** Too heavy for simple automation tasks

### Consequences

**Positive:**
- No installation required (PowerShell 5.1+ on Windows 10+)
- Native Windows integration (services, registry, etc.)
- Strong typing and object-oriented
- Excellent error handling
- Can call external commands (Git, MySQL)
- Maintainable by current team

**Negative:**
- Windows-only (though PowerShell 7+ works on macOS/Linux)
- Execution policy restrictions (can be bypassed)
- Different syntax than Bash (learning curve for Linux users)
- Verbose compared to Bash

**Neutral:**
- Scripts are longer than Bash equivalents
- Requires learning PowerShell cmdlet names
- WSL users need to use `powershell.exe` to run scripts

### Implementation

Created 6 PowerShell automation scripts (~980 lines):
- `generate-readme-index.ps1` - Auto-generate README
- `check-services.ps1` - XAMPP health monitoring
- `validate-baseline.ps1` - Documentation quality validation
- `backup-baseline.ps1` - Backup baseline files (60-day retention)
- `backup-mysql.ps1` - Backup MySQL databases (30-day retention)
- `backup-repos.ps1` - Backup Git repositories (90-day retention)
- `add-baseline-to-existing-project.ps1` - Deploy baseline to projects

### Related Decisions

- Related to ADR-001 (template system requires scripted deployment)
- Related to ADR-004 (ASCII-safe output for cross-platform compatibility)

---

## ADR-003: Claude Code Agent Ecosystem

**Date:** 2025-11-03
**Status:** Accepted
**Decision ID:** ADR-003

### Context

Development sessions with Claude Code suffered from:
- No continuity between sessions (fresh start each time)
- Repetitive explanations of project structure
- Lost context from previous work
- No automation for common workflows (session wrap-up, security audits)
- Manual documentation updates

Forces:
- Each new Claude session starts with zero context
- Manually explaining project state is time-consuming
- Common workflows (security audits, code reviews) are repetitive
- Session knowledge is lost unless manually documented
- Need persistent memory across sessions

### Decision

Create comprehensive **Claude Code agent ecosystem** with:
1. **Agent definitions** for common workflows (15 agents)
2. **Memory system** with session notes and context
3. **Automated session wrap-up** (end-of-day agent)
4. **Security auditing** (security-auditor agent)
5. **Code review** (code-reviewer agent)
6. **Documentation generation** (gen-docs agent)

### Rationale

**Reasons for this decision:**
1. **Session continuity** - Future sessions read memory files for complete context
2. **Workflow automation** - Agents handle repetitive tasks (audits, reviews)
3. **Knowledge preservation** - Session notes capture decisions, patterns, gotchas
4. **Consistency** - Agents use templates, ensure consistent output
5. **Time savings** - No re-explaining project, no manual documentation
6. **Quality** - Agents follow checklists, nothing is forgotten

### Alternatives Considered

**Option A: Manual documentation only**
- Pros: Simple, no dependencies, complete control
- Cons: Time-consuming, easily forgotten, inconsistent, no automation
- **Why rejected:** Too manual, doesn't scale, knowledge gets lost

**Option B: External tools (Notion, Confluence)**
- Pros: Rich UI, collaboration features, search
- Cons: External dependency, not in version control, requires manual updates
- **Why rejected:** Want documentation in Git, not external systems

**Option C: GitHub Actions for automation**
- Pros: CI/CD integration, runs automatically
- Cons: Can't run interactively, no session context, limited to Git events
- **Why rejected:** Need interactive workflows, not just CI/CD

### Consequences

**Positive:**
- Future Claude sessions have complete context
- Common workflows are automated (security audits, session wrap-ups)
- Session knowledge is preserved (decisions, patterns, gotchas)
- Consistent output across sessions (templates, formats)
- Time savings (no re-explaining, no manual docs)
- Quality improvements (checklists, nothing forgotten)

**Negative:**
- Requires Claude Code to be useful (not standalone)
- Agents need maintenance as workflows evolve
- Initial time investment to create agent definitions
- Memory system grows over time (cleanup needed)

**Neutral:**
- Agents are markdown files (easy to edit, version control)
- Memory files must be read by future sessions (documented in agent definitions)
- Some agents are optional (can skip quality checks)

### Implementation

**Created 15 agent definitions:**
- `session-start.md` - Session initialization with context loading
- `end-of-day.md` - Comprehensive session wrap-up (used Nov 5, 2025)
- `security-auditor.md` - Security vulnerability scanning
- `code-reviewer.md` - Code quality review
- `gen-docs.md` - Documentation generation
- `refactorer.md` - Code refactoring assistance
- `test-runner.md` - Test execution and analysis
- `git-helper.md` - Git workflow assistance
- `standards-enforcer.md` - Coding standards validation
- `code-documenter.md` - Code documentation generation
- Plus 5 more supporting agents

**Memory system structure:**
```
.claude/
├── memory/                  # Session-specific
│   ├── session-notes-{{DATE}}.md
│   ├── next-session.md
│   └── snapshots/
│       └── snapshot-{{DATE}}.json
└── context/                 # Persistent
    ├── project-overview.md
    ├── patterns.md
    ├── gotchas.md
    └── architecture-decisions.md
```

### Related Decisions

- Related to ADR-001 (documentation templates used in reports)
- Related to ADR-005 (agent deployment in baseline script)

---

## ADR-004: ASCII-Safe PowerShell Output

**Date:** 2025-11-05
**Status:** Accepted
**Decision ID:** ADR-004

### Context

The `add-baseline-to-existing-project.ps1` script used Unicode emoji characters (✓, →, ⚠, ⊘) for visual output formatting. These characters corrupted when:
- Copied across different systems
- Edited in different text editors
- Committed and pulled from Git

This caused critical parser errors:
- Script failed to parse with "missing string terminator" error
- Error messages pointed to wrong line numbers
- Corruption was invisible in most editors

Forces:
- Need visual hierarchy in console output
- Unicode emojis look professional
- But Unicode corruption breaks scripts entirely
- PowerShell encoding varies across systems
- Cross-platform compatibility important

### Decision

**Use ASCII-safe characters only** (U+0000 to U+007F) in all PowerShell scripts, replacing Unicode emojis with ASCII alternatives.

Replacements:
- ✓ (checkmark) → `[OK]`
- → (arrow) → `>`
- ⚠ (warning) → `[!]`
- ⊘ (prohibited) → `[SKIP]`

### Rationale

**Reasons for this decision:**
1. **Eliminates corruption risk** - ASCII never corrupts across systems
2. **Cross-platform compatibility** - Works on all Windows versions, WSL, PowerShell 7+
3. **Reliable parsing** - No hidden multi-byte sequences
4. **Maintainable** - Clear what characters are in source
5. **Debuggable** - Easy to see in any editor
6. **Still readable** - ASCII alternatives maintain visual hierarchy

### Alternatives Considered

**Option A: Keep Unicode emojis, fix encoding**
- Pros: Looks professional, modern
- Cons: Unreliable, varies by system, hard to guarantee correct encoding
- **Why rejected:** Too risky, corruption breaks scripts entirely

**Option B: Remove symbols entirely**
- Pros: Guaranteed compatible, simplest
- Cons: Loses visual hierarchy, harder to scan output
- **Why rejected:** Visual hierarchy is valuable for user experience

**Option C: Use Unicode only in comments**
- Pros: Safe in comments, doesn't affect parsing
- Cons: Inconsistent (emojis in some places, not others)
- **Why rejected:** Want consistency, and even comments can cause editor issues

### Consequences

**Positive:**
- **Reliability** - Scripts parse correctly on all systems
- **Debugging** - No more "mystery characters" causing errors
- **Compatibility** - Works in PowerShell ISE, VS Code, terminal, WSL
- **Maintainability** - Easy to see what characters are in source
- **Prevention** - Can use pre-commit hooks to block non-ASCII

**Negative:**
- **Aesthetics** - ASCII characters less visually appealing than emojis
- **Modern look** - Emojis feel more modern/professional
- **Typing** - Brackets slightly more verbose than single emoji

**Neutral:**
- **Learning curve** - Team must remember to use ASCII in scripts
- **Consistency** - Must apply to all scripts (not just one)

### Implementation

**Fixed on 2025-11-05:**
- Updated `add-baseline-to-existing-project.ps1` (lines 161, 166, 171, 176)
- Replaced all Unicode emojis with ASCII alternatives
- Created diagnostic scripts to detect non-ASCII:
  - `claude_wip/find-all-unicode.ps1`
  - `claude_wip/check-quotes.ps1`
- Tested script parsing successfully

**Output format:**
```
[OK] Pre-flight checks passed
> Scanning baseline files...
  Found 45 files to process
[!] 10 files already exist
[SKIP] README.md (already exists)
```

**Prevention measures:**
- Documented in gotchas.md
- Diagnostic scripts available for future use
- Can create pre-commit hook to block non-ASCII in .ps1 files

### Related Decisions

- Related to ADR-002 (PowerShell automation)
- Supersedes previous decision to use Unicode for aesthetics

---

## ADR-005: Include .claude and agents/ in Baseline Deployment

**Date:** 2025-11-05
**Status:** Accepted
**Decision ID:** ADR-005

### Context

The `add-baseline-to-existing-project.ps1` script deployed baseline documentation and coding standards but was **missing**:
- `.claude` directory (Claude Code configuration)
- `agents/` directory (15 agent definition files)

This meant projects didn't get:
- Claude Code settings (`.claude/settings.local.json`)
- Agent definitions for workflows
- Complete Claude Code integration

Forces:
- Baseline should be complete (include all necessary files)
- Claude Code integration is core to project
- Agents are valuable for workflows
- But `.claude` might conflict with existing project settings
- File count increased significantly (29 → 45 files)

### Decision

**Add both `.claude` and `agents/` directories** to baseline deployment with:
- New component: `claude-config` (includes .claude directory)
- New component: `agents` (includes agents/ directory)
- Conflict strategy: "Skip" for .claude files (preserve existing)
- Total file count: 45 files (up from 29)

### Rationale

**Reasons for this decision:**
1. **Complete setup** - Projects get full Claude Code integration
2. **Agent ecosystem** - 15 agent definitions enable workflows
3. **Baseline purpose** - Should include everything needed to start
4. **User expectation** - User expected these files to be included
5. **Workflow value** - Agents significantly improve productivity

### Alternatives Considered

**Option A: Keep script as-is (only docs and standards)**
- Pros: Simpler, fewer files, less conflicts
- Cons: Incomplete baseline, missing key functionality
- **Why rejected:** Baseline should be complete

**Option B: Add .claude but not agents**
- Pros: Smaller deployment, settings included
- Cons: Agents are valuable, missing half the benefit
- **Why rejected:** Agents are core to Claude Code workflow

**Option C: Make it optional with components**
- Pros: Users choose what they want
- Cons: More complex, most users want everything
- **Chosen:** BUT made it optional via component selection

### Consequences

**Positive:**
- **Complete baseline** - Projects get full Claude Code setup
- **Agent ecosystem** - 15 definitions ready to use
- **Workflow automation** - Sessions, audits, reviews automated
- **File count increase** - 29 → 45 files (+55%)
- **User satisfaction** - Matches user expectations

**Negative:**
- **Larger deployment** - More files to copy
- **Potential conflicts** - .claude directory might exist
- **Complexity** - More components to manage

**Neutral:**
- **Conflict handling** - "Skip" strategy preserves existing .claude
- **Component selection** - Users can exclude if not wanted
- **Documentation needed** - Must document new components

### Implementation

**Added on 2025-11-05:**

1. **New .claude directory mapping:**
```powershell
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
```

2. **New agents/ directory mapping:**
```powershell
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
```

3. **Updated ValidateSet:**
```powershell
[ValidateSet("baseline-docs", "coding-standards", "claude-wip", "claude-config", "agents", "scripts", "gitignore", "all")]
[string[]]$Components = @("all")
```

**Test deployment (E:\xampp\domainscanner):**
- Files: 45 (previously 29)
- Duration: 1.22 seconds
- Backup: 0.73 MB
- Status: ✅ Success

### Related Decisions

- Related to ADR-003 (Claude Code agent ecosystem)
- Enhances ADR-001 (complete baseline deployment)

---

## Template for New ADRs

**Date:** YYYY-MM-DD
**Status:** Proposed / Accepted / Deprecated / Superseded by ADR-XXX
**Decision ID:** ADR-XXX

### Context

What is the issue we're trying to solve? What forces are at play?

- Force 1
- Force 2
- Force 3

### Decision

What did we decide to do?

[Clear statement of the architectural decision]

### Rationale

Why did we make this decision?

- Reason 1: Explanation
- Reason 2: Explanation
- Reason 3: Explanation

### Alternatives Considered

What other options did we consider?

**Option A:** Description
- Pros: ...
- Cons: ...
- **Why rejected:** ...

**Option B:** Description
- Pros: ...
- Cons: ...
- **Why rejected:** ...

### Consequences

What are the consequences of this decision?

**Positive:**
- Benefit 1
- Benefit 2

**Negative:**
- Trade-off 1
- Trade-off 2

**Neutral:**
- Impact 1
- Impact 2

### Implementation

How is this decision being implemented?

- Implementation detail 1
- Implementation detail 2
- Files affected: `file1.ext`, `file2.ext`

### Related Decisions

- Related to ADR-XXX
- Depends on ADR-YYY

---

**Note:** Add new ADRs to the top of this file (after template). Last updated: 2025-11-05.
