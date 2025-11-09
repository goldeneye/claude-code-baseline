# Project Overview - claude_code_baseline

**Last Updated:** 2025-11-05
**Company:** ComplianceScorecard / GoldenEye Engineering
**Project Type:** Documentation Repository / Automation Toolkit
**Maintainer:** {{USERNAME}} (GoldenEye Engineering)

---

## 🎯 What We're Building

### Project Purpose
The **claude_code_baseline** repository provides comprehensive engineering documentation templates, automation scripts, and Claude Code agent definitions to accelerate project setup and maintain consistency across development teams. It serves as a foundation that can be applied to existing or new projects, providing instant access to best practices, security standards, coding guidelines, and AI-assisted workflows.

### Target Users
- **Development Teams:** Need standardized documentation and coding standards across projects
- **Project Managers:** Require consistent project structure and tracking mechanisms
- **Security Teams:** Need compliance-ready documentation and audit templates
- **AI/ML Teams:** Want Claude Code agent definitions for automated workflows

### Core Functionality
1. **Baseline Documentation Templates** - 10 comprehensive markdown templates covering architecture, security, coding standards, deployment, testing, and more
2. **Automation Scripts** - PowerShell scripts for backups, validation, README generation, and service monitoring
3. **Claude Code Integration** - Agent definitions, settings, and workflow automation
4. **Baseline Deployment** - Script to apply baseline to existing projects with conflict handling
5. **Professional Reporting** - HTML report generation with Bootstrap 5 styling

---

## 🏗️ Technical Stack

### Documentation System
- **Format:** Markdown with YAML frontmatter
- **Templates:** 10 baseline docs + 12 coding standards
- **Template Variables:** {{PROJECT_NAME}}, {{COMPANY_NAME}}, etc.
- **Cross-references:** Internal links between documentation files

### Automation
- **Language:** PowerShell 5.1+
- **Scripts:** 6 automation scripts (~980 lines total)
- **Target Platform:** Windows (XAMPP environment)
- **Key Scripts:**
  - generate-readme-index.ps1 - Auto-generate README
  - check-services.ps1 - XAMPP monitoring
  - backup-*.ps1 - MySQL, repos, baseline backups
  - add-baseline-to-existing-project.ps1 - Deploy to projects

### Claude Code Integration
- **Configuration:** .claude/settings.local.json with enhanced settings
- **Agents:** 15 agent definitions for various workflows
- **Memory System:** .claude/memory/ with session notes and snapshots
- **Context:** .claude/context/ with persistent project knowledge

### Frontend (Reports)
- **Framework:** Bootstrap 5
- **Styling:** Custom CSS (agent-reports.css)
- **Templates:** HTML report templates with ComplianceScorecard branding
- **Logo:** cs-logo.png for professional appearance

---

## 📁 Project Structure

### Key Directories
- `/baseline_docs` - 10 baseline documentation templates
- `/coding-standards` - 12 detailed coding standard files
- `/agents` - 15 Claude Code agent definition files
- `/.claude` - Claude Code configuration and memory
  - `.claude/memory` - Session notes and snapshots
  - `.claude/context` - Persistent project knowledge
  - `.claude/scripts` - Utility PowerShell scripts
- `/project_docs` - Generated reports and documentation
  - `project_docs/session-reports` - HTML session reports
  - `project_docs/agent-results` - Agent-generated reports
- `/claude_wip` - Work-in-progress and diagnostic files
- `/docs` - GitHub Pages documentation (if enabled)

### Important Files
- `README.md` (root) - Main repository documentation
- `CLAUDE.md` - Guide for Claude Code AI assistant
- `TODO.md` - Project status tracking with completed tasks
- `CHANGELOG.md` - Version history and changes
- `add-baseline-to-existing-project.ps1` - **KEY SCRIPT** - Deploy baseline to projects
- `.claude/settings.local.json` - Claude Code configuration
- `.gitignore` - Excludes claude_wip/, backups, etc.

---

## 🔑 Key Architectural Decisions

### Decision 1: Template-Based Documentation System

**Date:** 2025-11-02
**Context:** Needed reusable documentation that works across multiple projects
**Decision:** Use markdown templates with YAML frontmatter and template variables
**Consequences:**
- **Positive:** Easy to customize, version control friendly, framework-agnostic
- **Positive:** YAML frontmatter enables metadata without disrupting content
- **Negative:** Requires manual variable replacement (or script automation)

### Decision 2: PowerShell for Automation

**Date:** 2025-11-02
**Context:** XAMPP environment on Windows, need backup and monitoring automation
**Decision:** Use PowerShell 5.1+ for all automation scripts
**Consequences:**
- **Positive:** Native Windows integration, powerful scripting capabilities
- **Positive:** Can interact with Git, MySQL, file systems easily
- **Negative:** Windows-only (though WSL can run some scripts)

### Decision 3: Claude Code Agent Ecosystem

**Date:** 2025-11-03
**Context:** Repetitive workflows need automation, sessions need continuity
**Decision:** Create comprehensive agent definitions for common workflows
**Consequences:**
- **Positive:** Automated session wrap-ups, security audits, documentation generation
- **Positive:** Memory system enables session continuity
- **Negative:** Agents require Claude Code to be useful (not standalone)

### Decision 4: ASCII-Safe PowerShell Output (2025-11-05)

**Date:** 2025-11-05
**Context:** Unicode emoji characters corrupted when copied across systems
**Decision:** Use only ASCII characters in PowerShell scripts for output formatting
**Consequences:**
- **Positive:** Cross-platform compatibility, no encoding corruption
- **Positive:** Scripts work reliably regardless of encoding settings
- **Negative:** Less visually appealing than Unicode emojis
- **Trade-off:** Reliability over aesthetics

### Decision 5: Include .claude and agents/ in Baseline Deployment (2025-11-05)

**Date:** 2025-11-05
**Context:** Baseline deployments were missing Claude Code configuration and agent definitions
**Decision:** Add .claude and agents/ directories to baseline deployment script
**Consequences:**
- **Positive:** Complete Claude Code setup out of the box
- **Positive:** Projects get full agent ecosystem (15 definitions)
- **Positive:** File count increased from 29 to 45 (+55%)
- **Neutral:** Adds 1 MB to baseline deployment size

---

## 🌊 Data Flow

**Baseline Deployment Flow:**
1. User runs add-baseline-to-existing-project.ps1 with project path
2. Script validates prerequisites (permissions, disk space, Git status)
3. Script scans baseline directory for files to copy
4. Script checks for conflicts in target project
5. Script creates backup of existing files (selective or full)
6. Script copies files with conflict handling (skip, suffix, interactive)
7. Script updates .gitignore with baseline entries
8. Script creates claude_wip/ structure
9. Script generates summary report with file counts and locations
10. User reviews and can rollback if needed

**Session Continuity Flow:**
1. End-of-day agent runs at session end
2. Creates session-notes-{{DATE}}.md with full details
3. Updates persistent context files (project-overview, patterns, gotchas)
4. Creates next-session.md with starting point
5. Generates HTML session report
6. Creates machine-readable snapshot JSON
7. Future Claude session reads memory files on start
8. Claude has complete context from previous sessions

---

## 🔐 Security Considerations

- **Authentication:** Not applicable (documentation repository)
- **Authorization:** Git-based (GitHub repository permissions)
- **Data encryption:** Not stored (templates only)
- **Sensitive data handling:** Template variables for API keys/credentials (never committed)
- **Backup security:** Scripts use local filesystem (not cloud)
- **Script execution:** PowerShell scripts require Execution Policy bypass or signed scripts

---

## 📊 Current State

- **Version:** 2.1.2 (as of 2025-11-05)
- **Status:** Production Ready
- **Completeness:** 100% complete (all core features)
- **Next milestone:** Optional enhancements (testing, cloud backups, CI/CD)

### Feature Status
- ✅ Baseline documentation templates (10 files)
- ✅ Coding standards (12 files)
- ✅ Automation scripts (6 scripts)
- ✅ Claude Code agents (15 definitions)
- ✅ Baseline deployment script (fully functional)
- ✅ HTML reporting system
- ✅ Memory and context system
- ⏸️ Cloud backup integration (optional)
- ⏸️ CI/CD integration (optional)

### Recent Enhancements (2025-11-05)
- Fixed critical PowerShell parsing errors (Unicode corruption)
- Enhanced baseline script to copy .claude and agents/ directories
- Increased deployment from 29 to 45 files (+55%)
- Successfully tested on E:\xampp\domainscanner project
- Created 5 diagnostic scripts for encoding troubleshooting

---

## 🎯 Project Goals

**Short-term (Completed)**
- ✅ Create comprehensive baseline documentation
- ✅ Build automation scripts for common tasks
- ✅ Integrate with Claude Code for AI workflows
- ✅ Test and validate all components

**Medium-term (In Progress)**
- Update documentation for enhanced baseline script
- Review all PowerShell scripts for encoding issues
- Create pre-commit hooks for validation
- Test baseline on multiple projects

**Long-term (Future)**
- Cloud backup integration (Azure/AWS)
- Multi-project template management system
- Community contribution guidelines
- Video tutorials for baseline usage

---

**Last major update:** 2025-11-05 (baseline script enhancements, encoding fixes)
**Next update:** Documentation updates for new features
