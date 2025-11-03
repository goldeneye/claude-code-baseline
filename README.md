# Engineering Baseline Documentation Repository

**Author**: TimGolden - aka GoldenEye Engineering timgolden.com
**Created**: November 2, 2025
**Status**: Production Ready ✅

---

## 🎯 Purpose

This repository contains **baseline documentation templates** for engineering projects. These templates provide a comprehensive starting point for:

- Multi-tenant SaaS platforms
- Compliance-focused applications
- Security assessment systems
- AI-integrated platforms
- RESTful API development

All documentation uses **template variables** (e.g., `{{PROJECT_NAME}}`, `{{DOMAIN}}`) to make them reusable across any project.

---

## 📁 Repository Structure

```
E:\github\claude_code_baseline\
├── README.md                          # This file
├── TODO.md                            # Project status and checklist
├── CLAUDE.md                          # Guide for Claude Code AI assistant
├── ENVIRONMENT.md                     # Environment configuration guide
├── WSL-SETUP.md                       # 🐧 WSL & Linux integration guide
├── setup-wsl.sh                       # 🐧 Automated WSL setup script
├── .env                               # 🔒 API keys and secrets (not in Git)
├── .env.example                       # Environment template
├── .gitignore                         # Git exclusions
│
├── 🚀 NEW PROJECT SETUP
├── new-project.ps1                    # ⭐ Automated project creation script
├── NEW-PROJECT-SETUP.md               # Complete setup guide
├── project-config.example.json        # Full configuration template
├── project-config.minimal.json        # Minimal configuration template
│
├── 🤖 CLAUDE CODE AGENTS
├── AGENTS-GUIDE.md                    # ⭐ Quick reference for using agents
├── agents\                            # 🎯 Reusable AI agent templates
│   ├── README.md                      # Agent installation and usage
│   ├── security-auditor.md            # Security vulnerability scanner
│   ├── standards-enforcer.md          # Coding standards enforcement
│   ├── gen-docs.md                    # Documentation generator
│   ├── code-documenter.md             # Code documentation enforcer
│   ├── code-reviewer.md               # Code quality reviewer
│   ├── test-runner.md                 # Test automation
│   ├── git-helper.md                  # Git operations assistant
│   └── refactorer.md                  # Code refactoring specialist
│
├── baseline_docs\                     # 🎯 Core Documentation Templates
│   ├── README.md                      # Index of all baseline files
│   ├── 00-overview.md                 # System overview template
│   ├── 01-architecture.md             # Architecture patterns
│   ├── 02-security.md                 # Security and compliance
│   ├── 03-coding-standards.md         # REDIRECTS → coding-standards/
│   ├── 04-ai-agent-protocol.md        # AI integration guide
│   ├── 05-deployment-guide.md         # Deployment procedures
│   ├── 06-database-schema.md          # Database design patterns
│   ├── 07-testing-and-QA.md           # Testing strategies
│   ├── 08-api-documentation.md        # RESTful API design
│   ├── 09-project-roadmap-template.md # Project planning
│   ├── 10-disaster-recovery-and-audit.md # DR & audit procedures
│   └── backup-project.ps1             # Universal project backup utility
│
├── coding-standards\                  # 📋 Modular Coding Standards
│   ├── README.md                      # Central navigation hub
│   ├── 01-pseudo-code-standards.md    # Plan before you code
│   ├── 02-project-structure.md        # Laravel architecture
│   ├── 03-php-standards.md            # PSR-12 & Laravel
│   ├── 04-javascript-standards.md     # ES6+, React
│   ├── 05-database-standards.md       # Schema design, multi-tenant
│   ├── 06-logging-standards.md        # Comprehensive logging
│   ├── 07-safety-rules.md             # ⚠️ CRITICAL safety rules
│   ├── 08-quality-standards.md        # Documentation compliance
│   ├── 09-github-jira-workflow.md     # Branch, PR, deployment
│   ├── 10-testing-standards.md        # Unit, feature, integration
│   ├── 11-security-standards.md       # Security best practices
│   └── 12-performance-standards.md    # Optimization & caching
│
├── claude_wip\                        # 🗂️ Claude Code Working Directory
│   ├── README.md                      # Usage guidelines
│   ├── drafts\                        # Draft implementations
│   ├── analysis\                      # Code analysis & research
│   ├── scratch\                       # Temporary experiments
│   └── backups\                       # Quick backups during refactoring
│
├── .claude\                           # 🤖 Claude Code Configuration
│   ├── settings.local.json            # Enhanced AI assistant config
│   ├── SETTINGS_GUIDE.md              # Configuration guide
│   ├── ENHANCEMENT_SUMMARY.md         # Feature summary
│   ├── QUICK_REFERENCE.md             # Command reference card
│   └── scripts\                       # PowerShell automation
│       ├── generate-readme-index.ps1  # Auto-generate README
│       ├── validate-baseline.ps1      # Validate documentation
│       ├── backup-baseline.ps1        # Backup docs
│       ├── backup-mysql.ps1           # MySQL backup
│       ├── backup-repos.ps1           # Git repo backup
│       └── check-services.ps1         # XAMPP health check
│
└── tim_wip\                           # 🗂️ Source Materials
    └── markdown\                      # 84+ original documentation files
```

---

## 🚀 Quick Start

### Option 1: Automated Setup (⭐ Recommended)

**Create a new project in 30 seconds:**

```powershell
# Run the automated setup script
.\new-project.ps1 -ProjectName "MyApp" -DestinationPath "E:\projects\myapp"
```

The script will:
- ✅ Copy all baseline documentation
- ✅ Set up coding standards (13 comprehensive files)
- ✅ Create `claude_wip/` working directory
- ✅ Replace all template variables with your values
- ✅ Initialize Git repository with `.gitignore`
- ✅ Verify setup completion

**See:** [`NEW-PROJECT-SETUP.md`](NEW-PROJECT-SETUP.md) for complete instructions

### Option 2: Install Claude Code Agents (⭐ Recommended)

**Get AI-powered assistance across ALL your projects:**

The agents are **already installed globally** at `C:\Users\TimGolden\.claude\agents\` and are available system-wide to all your projects!

**Available agents:**
- 🔒 **security-auditor** - Scan for vulnerabilities
- ✓ **standards-enforcer** - Enforce coding standards
- 📚 **gen-docs** - Generate documentation
- 📝 **code-documenter** - Add code documentation
- 👁️ **code-reviewer** - Review code quality
- 🧪 **test-runner** - Run and fix tests
- 🌿 **git-helper** - Git operations
- ♻️ **refactorer** - Refactor code

**See:** [`AGENTS-GUIDE.md`](AGENTS-GUIDE.md) for complete agent documentation

**Configuration Options:**

```powershell
# Interactive (prompts for values)
.\new-project.ps1 -ProjectName "MyApp" -DestinationPath "E:\projects\myapp"

# With configuration file (fully automated)
.\new-project.ps1 -ProjectName "MyApp" -DestinationPath "E:\projects\myapp" -ConfigFile "project-config.json"

# Minimal (command line values)
.\new-project.ps1 -ProjectName "MyApp" -DestinationPath "E:\projects\myapp" -ContactEmail "dev@myapp.com" -Domain "myapp.com"
```

### Option 2: Manual Setup

1. **Browse the templates**: Start with [`baseline_docs/README.md`](baseline_docs/README.md)

2. **Copy template files** to your project:
   ```bash
   cp baseline_docs/00-overview.md your-project/docs/
   cp baseline_docs/01-architecture.md your-project/docs/
   ```

3. **Replace template variables**:
   - `{{PROJECT_NAME}}` → Your project name
   - `{{DOMAIN}}` → Your domain (e.g., `https://api.example.com`)
   - `{{REPO_PATH}}` → Your repository path
   - `{{CONTACT_EMAIL}}` → Your contact email
   - See full list in each template file

4. **Customize** the content to match your specific project needs

### Environment Setup (Required for API Access)

If you plan to use Claude Code or other AI services:

1. **Copy the environment template**:
   ```bash
   cp .env.example .env
   ```

2. **Add your API keys** to `.env`:
   ```env
   ANTHROPIC_API_KEY=sk-ant-api03-your-key-here
   ```

3. **Get your API key** from [Anthropic Console](https://console.anthropic.com/)

**See:** [`ENVIRONMENT.md`](ENVIRONMENT.md) for complete environment configuration guide

⚠️ **Security**: The `.env` file is automatically excluded from Git via `.gitignore`. Never commit API keys!

### WSL Setup (Windows Subsystem for Linux) 🐧

If you want to use this repository from WSL (Ubuntu, etc.):

**Quick Setup:**
```bash
# From WSL terminal
cd /mnt/e/github/claude_code_baseline
./setup-wsl.sh

# Then reload your shell
source ~/.bashrc
```

**What it does:**
- ✅ Adds convenient bash aliases (`baseline`, `load-baseline`)
- ✅ Configures Git for cross-platform work
- ✅ Sets up .gitattributes for line endings
- ✅ Makes shell scripts executable
- ✅ Verifies .env configuration

**Manual Access:**
```bash
# Navigate to repo from WSL
cd /mnt/e/github/claude_code_baseline

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Verify
echo $ANTHROPIC_API_KEY
```

**See:** [`WSL-SETUP.md`](WSL-SETUP.md) for complete WSL integration guide

### Using with Claude Code

If you're using Claude Code (AI assistant), read [`CLAUDE.md`](CLAUDE.md) for:
- Repository structure explanation
- Template variable system
- Automated project setup
- Common development tasks
- Automation script usage

---

## 📚 Documentation Overview

### Core Baseline Files (10 Templates)

| File | Purpose | Size | Key Features |
|------|---------|------|--------------|
| **00-overview.md** | System overview | ~150 lines | Quick reference, tech stack, capabilities |
| **01-architecture.md** | System architecture | ~400 lines | Multi-tenant design, component hierarchy |
| **02-security.md** | Security & compliance | ~450 lines | Auth0, encryption, RBAC, compliance mapping |
| **03-coding-standards.md** | Coding standards | ~500 lines | PHP, JavaScript, Python standards |
| **04-ai-agent-protocol.md** | AI integration | ~400 lines | Claude Code workflow, prompt engineering |
| **05-deployment-guide.md** | Deployment procedures | ~500 lines | Docker, manual deploy, database setup |
| **06-database-schema.md** | Database design | ~600 lines | Multi-tenant schema, encryption, retention |
| **07-testing-and-QA.md** | Testing strategy | ~550 lines | Unit, integration, security, CI/CD |
| **08-api-documentation.md** | API design | ~650 lines | RESTful endpoints, JWT auth, webhooks |
| **09-project-roadmap-template.md** | Project planning | ~700 lines | 5-phase roadmap, timeline, KPIs |
| **10-disaster-recovery-and-audit.md** | DR & audit | ~700 lines | Backup strategies, recovery procedures |

**Total**: ~5,600 lines of comprehensive, reusable documentation

---

## 🛠️ Automation Scripts

All scripts located in `.claude/scripts/`:

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
```

### Documentation Operations
```powershell
# Generate README.md index
powershell -NoProfile -File .claude/scripts/generate-readme-index.ps1

# Backup baseline documentation
powershell -NoProfile -File .claude/scripts/backup-baseline.ps1
```

See [`.claude/QUICK_REFERENCE.md`](.claude/QUICK_REFERENCE.md) for all available commands.

---

## 🎓 Key Features

### Template Variables System

All baseline files use consistent template variables for easy customization:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Project display name | ComplianceScorecard Platform |
| `{{SERVICE_NAME}}` | Service/microservice name | Client Segmentation Service |
| `{{DOMAIN}}` | Primary domain | https://api.example.com |
| `{{REPO_PATH}}` | Repository path | /var/www/app |
| `{{CONTACT_EMAIL}}` | Technical contact | devops@example.com |
| `{{DB_HOST}}` | Database host | db.example.com |
| `{{AUTH0_DOMAIN}}` | Auth0 SSO domain | example.auth0.com |

See each baseline file for the complete list of variables.

### Framework-Agnostic Design

Templates work with any technology stack:
- **Backend**: Laravel, Node.js, Django, .NET, Go
- **Frontend**: React, Vue, Angular, Svelte
- **Database**: MySQL, PostgreSQL, MongoDB
- **Cloud**: AWS, Azure, GCP, self-hosted

### Compliance Alignment

Documentation designed for:
- ✅ **FTC Safeguards Rule**
- ✅ **SOC 2 Type II**
- ✅ **CIS Controls v8**
- ✅ **CMMC Level 2**
- ✅ **GDPR** (data protection)

---

## 📊 Project Status

See [`TODO.md`](TODO.md) for detailed status and checklist.

**Current Status**: ✅ Production Ready

**Completed**:
- ✅ 10 baseline documentation templates created
- ✅ README index auto-generated
- ✅ 6 PowerShell automation scripts
- ✅ Claude Code configuration enhanced
- ✅ Template variable system implemented
- ✅ Comprehensive guides created

**Remaining** (Optional):
- Test all automation scripts with actual data
- Set up Windows Task Scheduler for automated backups
- Analyze PowerShell/shell scripts for generic templates

---

## 🔧 Development Environment

### Tools Configured

| Tool | Path | Purpose |
|------|------|---------|
| **XAMPP** | `E:\xampp` | MySQL, Apache, PHP |
| **Python** | `E:\python` | Python 3.x |
| **Composer** | `E:\composer` | PHP dependencies |
| **Nmap** | `E:\Nmap` | Network scanning |
| **PuTTY** | `E:\PuTTY` | SSH client |

### Backup Locations

| Type | Location | Retention |
|------|----------|-----------|
| **MySQL** | `E:\mysql_backups` | 30 days |
| **Repositories** | `E:\backup` | 90 days |
| **Baseline Docs** | `E:\backup\baseline_docs` | 60 days |

---

## 📖 How to Use This Repository

### For New Projects

1. **Choose templates** relevant to your project phase
2. **Copy to your project** documentation folder
3. **Replace template variables** with your values
4. **Customize** content to match your architecture
5. **Maintain** as living documentation

### For Existing Projects

1. **Review existing documentation** gaps
2. **Identify applicable templates** to fill gaps
3. **Merge content** with existing docs
4. **Standardize** on template variable approach
5. **Update** regularly with project changes

### For Claude Code Integration

1. Read [`CLAUDE.md`](CLAUDE.md) for AI assistant guidance
2. Configure `.claude/settings.local.json` for your environment
3. Use automation scripts for routine tasks
4. Leverage Claude Code for documentation generation

---

## 🤝 Contributing

This repository is maintained by **TimGolden - aka GoldenEye Engineering**.

### Contribution Guidelines

1. **Maintain template variable consistency**
2. **Keep files under 700 lines** for readability
3. **Include YAML frontmatter** in all baseline files
4. **Add cross-references** to related documents
5. **Test automation scripts** before committing
6. **Update README.md** when adding new templates

---

## 📞 Support

### Documentation

- **Baseline Templates**: [`baseline_docs/README.md`](baseline_docs/README.md)
- **Environment Setup**: [`ENVIRONMENT.md`](ENVIRONMENT.md) 🔐
- **WSL Integration**: [`WSL-SETUP.md`](WSL-SETUP.md) 🐧
- **Claude Configuration**: [`.claude/SETTINGS_GUIDE.md`](.claude/SETTINGS_GUIDE.md)
- **Quick Reference**: [`.claude/QUICK_REFERENCE.md`](.claude/QUICK_REFERENCE.md)

### Issues

For questions or issues:
1. Check documentation in `.claude/` directory
2. Review `CLAUDE.md` for common tasks
3. Validate configuration with validation script

---

## 📜 License

This baseline documentation repository is maintained by TimGolden - aka GoldenEye Engineering for internal use and project standardization.

---

## 🏆 Achievements

- **10 comprehensive baseline templates** covering full project lifecycle
- **6 automation scripts** (~980 lines of PowerShell)
- **5,600+ lines** of reusable documentation
- **Framework-agnostic design** for maximum reusability
- **Compliance-aligned** for FTC, SOC 2, CIS, CMMC
- **Template variable system** for easy customization
- **Auto-generated indexes** for easy navigation

---

**Last Updated**: 2025-11-02
**Repository Status**: ✅ Production Ready
**Maintainer**: TimGolden - aka GoldenEye Engineering
