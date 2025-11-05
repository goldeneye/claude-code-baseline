# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is the **Engineering Baseline Documentation Repository**. It contains normalized, reusable documentation templates for building platforms. The baseline documentation pack is designed to bootstrap new microservices, AI agents, and internal tooling projects.

## Creating a New Project from This Baseline

**Quick Start:**

This baseline provides everything you need to start a new project with complete documentation and coding standards.

### Automated Setup (Recommended)

Use the automated setup script for fastest results:

```powershell
# From the baseline directory
.\new-project.ps1 -ProjectName "MyProject" -DestinationPath "E:\projects\my-project"
```

The script will:
- Create complete project directory structure
- Copy all baseline documentation
- Prompt for template variable values (or use a config file)
- Replace all `{{TEMPLATE_VARS}}` with your project values
- Set up `.gitignore` and initialize Git repository
- Create `claude_wip/` working directory

**See:** [NEW-PROJECT-SETUP.md](./baseline_docs/NEW-PROJECT-SETUP.md) for complete instructions

### Configuration Options

**Option 1: Interactive Setup** (prompts for values)
```powershell
.\new-project.ps1 -ProjectName "MyApp" -DestinationPath "E:\projects\myapp"
```

**Option 2: With Configuration File** (automated)
```powershell
# Copy and customize the config template
Copy-Item project-config.example.json project-config.json
# Edit project-config.json with your values

# Run with config
.\new-project.ps1 -ProjectName "MyApp" `
                  -DestinationPath "E:\projects\myapp" `
                  -ConfigFile "project-config.json"
```

**Option 3: Minimal Setup** (only required values)
```powershell
.\new-project.ps1 `
    -ProjectName "MyApp" `
    -DestinationPath "E:\projects\myapp" `
    -ContactEmail "dev@myapp.com" `
    -Domain "myapp.com"
```

### What Gets Created

After running the setup script, your new project will have:

```
my-project/
├── CLAUDE.md                      # Customized AI guidance for your project
├── docs/
│   ├── baseline/                  # All baseline documentation
│   │   ├── 00-overview.md
│   │   ├── 01-architecture.md
│   │   ├── 02-security.md
│   │   └── ... (10+ templates)
│   └── coding-standards/          # Complete coding standards (13 files)
│       ├── README.md
│       ├── 01-pseudo-code-standards.md
│       └── ... (through 12-performance-standards.md)
├── claude_wip/                    # Claude Code working directory
│   ├── README.md
│   ├── drafts/
│   ├── analysis/
│   ├── scratch/
│   └── backups/
├── scripts/
│   └── backup-project.ps1         # Project backup utility
├── .gitignore                     # Pre-configured
└── .git/                          # Initialized repository
```

### Manual Setup

If you prefer manual setup or need to customize the process, see [NEW-PROJECT-SETUP.md](./baseline_docs/NEW-PROJECT-SETUP.md) for step-by-step instructions.

### Files in This Baseline

**Setup & Configuration:**
- `new-project.ps1` - Automated project creation script
- `NEW-PROJECT-SETUP.md` - Complete setup guide
- `project-config.example.json` - Full configuration template
- `project-config.minimal.json` - Minimal configuration template

**Documentation Templates:**
- `baseline_docs/` - 10+ reusable documentation templates
- `coding-standards/` - 13 comprehensive coding standards
- `CLAUDE.md` - This file (template for new projects)

**Utilities:**
- `baseline_docs/backup-project.ps1` - Universal backup script

## Core Documentation Structure

The repository generates a **baseline documentation pack** in `baseline_docs/` with framework-agnostic templates:

- `00-overview.md` - System overview and quick reference
- `01-architecture.md` - System architecture and data flows
- `02-security.md` - Security model, encryption, and compliance
- `03-coding-standards.md` - **REDIRECTS TO:** `coding-standards/` directory (13 modular files)
- `04-ai-agent-protocol.md` - AI integration and Claude Code workflow
- `05-deployment-guide.md` - Deployment procedures and configuration
- `06-database-schema.md` - Database tables and relationships
- `07-testing-and-QA.md` - Testing strategy and QA procedures
- `08-api-documentation.md` - API endpoints and authentication
- `09-project-roadmap-template.md` - Feature planning templates
- `10-disaster-recovery-and-audit.md` - Backup and rollback procedures

### Modular Coding Standards

The coding standards have been reorganized into a comprehensive modular structure:

**Location:** `coding-standards/` (13 focused documents)

**Central Hub:** [coding-standards/README.md](./coding-standards/README.md)

**Key Documents:**
- `01-pseudo-code-standards.md` - Plan before you code
- `02-project-structure.md` - Laravel architecture & conventions
- `03-php-standards.md` - PSR-12 & Laravel patterns
- `04-javascript-standards.md` - ES6+, React standards
- `05-database-standards.md` - Schema, multi-tenant, reserved words
- `06-logging-standards.md` - Comprehensive logging
- `07-safety-rules.md` - **CRITICAL** - File & database safety
- `08-quality-standards.md` - Documentation compliance
- `09-github-jira-workflow.md` - Branch, PR, deployment
- `10-testing-standards.md` - Unit, feature, integration tests
- `11-security-standards.md` - Security best practices
- `12-performance-standards.md` - Optimization & caching

## Template Variable System

All baseline documentation uses template variables for project-agnostic reuse:

- `{{PROJECT_NAME}}` - Replace with actual project name
- `{{SERVICE_NAME}}` - Replace with service name
- `{{REPO_PATH}}` - Replace with repository path
- `{{CLAUDE_WIP_PATH}}` - Replace with claude_wip directory path (usually `{{REPO_PATH}}/claude_wip`)
- `{{CONTACT_EMAIL}}` - Replace with contact email
- `{{DOMAIN}}` - Replace with domain name
- `{{AUTH0_DOMAIN}}` - Replace with Auth0 configuration

When creating new projects from these templates, perform a find-and-replace on these variables.

**Standard Directory Convention:**
Every project should include a `claude_wip/` directory for Claude Code's temporary files and working materials. See [Working Directory Convention](#working-directory-convention-claude_wip) for details.

## Source Material Location

Legacy documentation to be normalized is located in:
- `tim_wip/markdown/wip/` - Contains 80+ source markdown files
- Source files include: architecture docs, security specs, coding standards, API documentation, deployment guides, etc.

## Documentation Generation Workflow

### Generating the Baseline Pack

To regenerate or update the baseline documentation pack:

```bash
# Read the generation instructions
cat claude-instrctions.md

# The baseline pack is generated by analyzing all source files in tim_wip/markdown/
# and normalizing them into the 10-12 baseline template files
```

### Normalization Rules

When updating baseline documentation:

1. **Consistent Metadata**: Every file must have YAML frontmatter:
```yaml
---
title: {{PROJECT_NAME}} - {{DOCUMENT_PURPOSE}}
version: 1.0
last_updated: {{DATE}}
author: TimGolden - aka GoldenEye Engineering
---
```

2. **Template Variables**: Replace all hardcoded names with template variables
3. **File Length**: Keep each file under 600 lines for readability
4. **Cross-References**: Include "See Also" links between related documents
5. **Compliance Alignment**: Reference FTC Safeguards, SOC 2, CIS Controls where applicable

## Key Architecture Patterns

### Multi-Tenant SaaS Platform

The baseline documentation describes a multi-tenant architecture with:
- **Database-level filtering**: All queries filtered by `msp_id` for tenant isolation
- **Role-Based Access Control (RBAC)**: 201+ permissions, 6 role types
- **Auth0 SSO**: OIDC/JWT authentication for user login
- **API Key Management**: JWT-based service-to-service authentication

### Technology Stack

The baseline templates cover:
- **Backend**: Laravel 11+ (PHP 8.2+), MySQL 8, Redis
- **Frontend**: React 18+, Redux Toolkit, Material-UI
- **Queue System**: Laravel Horizon with Redis
- **Scanners**: Python 3.x scripts (DNS, WHOIS, web privacy)
- **AI Integration**: Multi-provider support (OpenAI, Anthropic, GPT-OSS)

### Security Model

Key security patterns documented:
- **Field-level encryption**: Laravel `Crypt` for PII, API keys, sensitive data
- **Encryption-at-rest**: MySQL InnoDB tablespace encryption
- **Rate limiting**: Per-user and per-API-key throttling
- **Audit logging**: Comprehensive audit trail for all actions

## Working with PowerShell and Shell Scripts

The repository contains PowerShell and shell scripts in `tim_wip/` that should be analyzed to create **generic script templates** for:
- Database backup automation
- Deployment automation
- Environment setup
- Code backup utilities

When analyzing scripts, extract reusable patterns and create parameterized templates.

## Documentation Style Guidelines

### Tone and Format
- **Professional and instructional** - Clear, actionable guidance
- **Framework-agnostic** - Avoid vendor lock-in or specific product names
- **Compliance-focused** - Align with FTC Safeguards, SOC 2, CIS Controls

### Code Examples
- **Multi-language support**: Include PHP, JavaScript, and Python examples
- **Logging format**: `Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Message", $context)`
- **Security-first**: Show secure coding patterns, never insecure shortcuts

## Integration with Claude Code

### What Claude MUST do:

- **Read this file first** when starting any task in this repository
- **Use template variables** consistently in all generated documentation
- **Follow coding standards** defined in `coding-standards/` directory
- **Use `claude_wip/` directory** for all temporary files, drafts, and working materials:
  - Draft code goes in `claude_wip/drafts/`
  - Analysis and notes in `claude_wip/analysis/`
  - Experiments in `claude_wip/scratch/`
  - Backups during refactoring in `claude_wip/backups/`
- **Never commit temporary files** - `claude_wip/` is gitignored
- **Always create backups** before refactoring existing code
- **Log comprehensively** using the standard format with file and line numbers
- **Follow safety rules** in `coding-standards/07-safety-rules.md` - NEVER delete files or drop databases

### What Claude should NOT do:

- ❌ **Don't hardcode project-specific values** in baseline templates
- ❌ **Don't create files outside `claude_wip/`** without explicit direction
- ❌ **Don't skip pseudo-code planning** for complex features
- ❌ **Don't modify production code** without creating backups first
- ❌ **Don't delete files** - move to `claude_wip/backups/` instead
- ❌ **Don't commit WIP files** to version control

## File Organization

The repository follows this structure:

```
E:\github\claude_code_baseline\
├── CLAUDE.md                      # This file - AI assistant guidance
├── README.md                      # Repository overview
├── TODO.md                        # Project status and tasks
├── new-project.ps1                # Automated project setup script
├── NEW-PROJECT-SETUP.md           # Complete setup guide
├── project-config.example.json    # Configuration template
├── project-config.minimal.json    # Minimal config template
│
├── baseline_docs/                 # Core documentation templates
│   ├── README.md
│   ├── 00-overview.md
│   ├── 01-architecture.md
│   ├── 02-security.md
│   ├── 03-coding-standards.md     # REDIRECTS to coding-standards/
│   ├── 04-ai-agent-protocol.md
│   ├── 05-deployment-guide.md
│   ├── 06-database-schema.md
│   ├── 07-testing-and-QA.md
│   ├── 08-api-documentation.md
│   ├── 09-project-roadmap-template.md
│   ├── 10-disaster-recovery-and-audit.md
│   └── backup-project.ps1         # Universal backup script
│
├── coding-standards/              # Modular coding standards
│   ├── README.md                  # Central navigation
│   ├── 01-pseudo-code-standards.md
│   ├── 02-project-structure.md
│   ├── 03-php-standards.md
│   ├── 04-javascript-standards.md
│   ├── 05-database-standards.md
│   ├── 06-logging-standards.md
│   ├── 07-safety-rules.md         # ⚠️ CRITICAL
│   ├── 08-quality-standards.md
│   ├── 09-github-jira-workflow.md
│   ├── 10-testing-standards.md
│   ├── 11-security-standards.md
│   └── 12-performance-standards.md
│
├── claude_wip/                    # Claude Code working directory
│   ├── README.md                  # Usage guidelines
│   ├── drafts/                    # Draft implementations
│   ├── analysis/                  # Code analysis & research
│   ├── scratch/                   # Temporary experiments
│   └── backups/                   # Quick backups during refactoring
│
├── .claude/                       # Claude Code configuration
│   ├── settings.local.json
│   ├── SETTINGS_GUIDE.md
│   ├── ENHANCEMENT_SUMMARY.md
│   ├── QUICK_REFERENCE.md
│   └── scripts/                   # Automation scripts
│       ├── generate-readme-index.ps1
│       ├── validate-baseline.ps1
│       ├── backup-baseline.ps1
│       ├── backup-mysql.ps1
│       ├── backup-repos.ps1
│       └── check-services.ps1
│
└── tim_wip/                       # Source materials
    └── markdown/                  # 80+ original documentation files
```

## Working Directory Convention (claude_wip/)

### Purpose

The `claude_wip/` directory is a standardized workspace for Claude Code's temporary files, drafts, and working materials. This keeps production code clean while providing Claude with a dedicated space for iteration.

### Directory Structure

```
claude_wip/
├── README.md           # Usage guidelines
├── drafts/            # Draft code implementations before finalizing
├── analysis/          # Code analysis, research notes, investigations
├── scratch/           # Temporary experiments and calculations
└── backups/           # Quick backups during refactoring
```

### What to Store in claude_wip/

**✅ DO store:**
- Draft code implementations being tested
- Refactored code before replacing originals
- Analysis documents and research notes
- Temporary test files and experiments
- Generated reports and documentation drafts
- Code snippets for comparison
- Performance benchmarking results

**❌ DON'T store:**
- Final production code (use proper directories)
- Committed code (use git for version control)
- Large binary files or datasets
- Sensitive data or credentials
- Long-term documentation (use docs/ instead)

### Common Workflows

**1. Drafting New Features:**
```
1. Create draft in claude_wip/drafts/
2. Test and iterate
3. When ready, move to proper location
4. Clean up draft file
```

**2. Safe Refactoring:**
```
1. Copy original to claude_wip/backups/
2. Make changes to file in place
3. Test thoroughly
4. If successful, delete backup
5. If failed, restore from backup
```

**3. Code Analysis:**
```
1. Store analysis in claude_wip/analysis/
2. Document findings
3. Keep as reference for future work
```

### File Naming Conventions

**Drafts:**
- `{ClassName}_v{version}.{ext}` - Example: `UserService_v2.php`
- `{ClassName}_draft.{ext}` - Example: `AuthController_draft.php`
- `{feature-name}_implementation.{ext}` - Example: `payment-gateway_implementation.php`

**Analysis:**
- `{topic}-analysis.md` - Example: `security-analysis.md`
- `{component}-research.md` - Example: `caching-research.md`
- `{feature}-investigation.md` - Example: `auth-flow-investigation.md`

**Backups:**
- `{ClassName}_backup_{timestamp}.{ext}` - Example: `UserService_backup_20250115.php`
- `{file-name}_before_refactor.{ext}` - Example: `payment_before_refactor.php`

**Scratch:**
- `test_{feature}.{ext}` - Example: `test_scoring.php`
- `experiment_{topic}.{ext}` - Example: `experiment_caching.php`

### Git Configuration

The `claude_wip/` directory should be in `.gitignore`:

```gitignore
# Claude Code working directory
claude_wip/
!claude_wip/README.md
!claude_wip/**/.gitkeep
```

This keeps temporary files out of version control while preserving the directory structure.

### Cleanup Policy

**Regular Cleanup:**
- Review files weekly
- Delete outdated drafts
- Archive useful analysis to docs/
- Remove completed experiments

**Keep:**
- Active drafts in progress
- Recent analysis (< 30 days)
- Valuable research notes

**Delete:**
- Completed drafts (already moved to final location)
- Failed experiments
- Outdated backups (> 7 days)
- Duplicate files

## Common Tasks

### Creating New Baseline Documentation

1. Analyze source files in `tim_wip/markdown/`
2. Extract common patterns and normalize structure
3. Replace project-specific values with template variables
4. Follow YAML frontmatter convention
5. Cross-reference related documents
6. Keep files under 600 lines
7. Add to `baseline_docs/` directory

### Updating Coding Standards

1. Review changes in `coding-standards/` directory
2. Update relevant individual standard files
3. Maintain cross-references between files
4. Update README.md navigation if structure changes
5. Test that examples are accurate and work

### Testing Automation Scripts

1. Review script in `.claude/scripts/`
2. Test with sample data
3. Verify output and error handling
4. Update documentation if behavior changes
5. Ensure scripts work cross-platform where applicable

## Questions to Ask

When working in this repository, ask yourself:

1. **Am I using template variables** instead of hardcoded values?
2. **Should this file go in `claude_wip/`** instead of production directories?
3. **Have I created a backup** before modifying existing code?
4. **Does this follow the coding standards** in `coding-standards/`?
5. **Is my logging comprehensive** with file and line numbers?
6. **Have I cross-referenced** related documentation?
7. **Is the file under 600 lines** for readability?
8. **Have I followed safety rules** (no deletes, no drops)?

## Getting Help

- **Baseline Templates**: See `baseline_docs/README.md`
- **Coding Standards**: See `coding-standards/README.md`
- **Setup Guide**: See `NEW-PROJECT-SETUP.md`
- **Claude Configuration**: See `.claude/SETTINGS_GUIDE.md`
- **Quick Reference**: See `.claude/QUICK_REFERENCE.md`

---

**Last Updated**: 2025-01-15
**Version**: 2.0
**Maintainer**: TimGolden - aka GoldenEye Engineering
