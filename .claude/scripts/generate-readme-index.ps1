# Auto-generate README.md index from baseline documentation files
# Reads frontmatter from each baseline file and creates comprehensive index

$baselineDir = "E:\github\claude_code_baseline\baseline_docs"
$outputFile = Join-Path $baselineDir "README.md"

Write-Host "Generating README.md index from baseline files..." -ForegroundColor Cyan

# Get all markdown files except README.md
$files = Get-ChildItem -Path $baselineDir -Filter "*.md" |
         Where-Object { $_.Name -ne "README.md" } |
         Sort-Object Name

$readmeContent = @"
---
title: Engineering Baseline Documentation Pack
version: 1.0
last_updated: $(Get-Date -Format "yyyy-MM-dd")
author: TimGolden - aka GoldenEye Engineering
---

# Engineering Baseline Documentation Pack

## Overview

This directory contains **framework-agnostic baseline documentation templates** for building compliance and security assessment platforms. Each document is designed to be copied and customized for new microservices, AI agents, and internal tooling projects.

## Template Variable System

All baseline documents use template variables for project-agnostic reuse:

| Variable | Purpose | Example |
|----------|---------|---------|
| ``{{PROJECT_NAME}}`` | Project/product name | ComplianceScorecard, SecurityAudit |
| ``{{SERVICE_NAME}}`` | Microservice name | client-segmentation, scan-engine |
| ``{{REPO_PATH}}`` | Repository location | github.com/company/repo |
| ``{{CONTACT_EMAIL}}`` | Support contact | support@company.com |
| ``{{DOMAIN}}`` | Production domain | app.company.com |
| ``{{DB_HOST}}`` | Database host | db.company.com |
| ``{{AUTH0_DOMAIN}}`` | Auth0 tenant | company.auth0.com |

When creating a new project, perform find-and-replace on these variables.

## Baseline Documentation Files

"@

# Process each file
$fileIndex = 1
foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Yellow

    $content = Get-Content $file.FullName -Raw

    # Extract frontmatter
    $title = "Unknown"
    $purpose = ""

    if ($content -match '(?s)^---(.*?)---') {
        $frontmatter = $matches[1]

        if ($frontmatter -match 'title:\s*(.+)') {
            $title = $matches[1].Trim()
        }
    }

    # Extract first paragraph after frontmatter as description
    if ($content -match '(?s)---\s*\n\n#[^\n]+\n\n##[^\n]+\n\n(.+?)\n\n') {
        $purpose = $matches[1].Trim() -replace '\n', ' '
        if ($purpose.Length -gt 150) {
            $purpose = $purpose.Substring(0, 147) + "..."
        }
    }

    # Add to index
    $readmeContent += @"

### $fileIndex. [$($file.Name)]($($file.Name))

**Title:** $title

**Purpose:** $purpose

"@

    $fileIndex++
}

# Add usage instructions
$readmeContent += @"

---

## How to Use This Baseline Pack

### For New Projects

1. **Copy entire baseline_docs/ directory** to your new project
2. **Find and replace all template variables** with actual values
3. **Customize content** for your specific architecture and requirements
4. **Remove placeholder sections** that don't apply
5. **Add project-specific details** and examples

### For Updates

When updating baseline documentation:

1. Maintain **template variable consistency** across all files
2. Keep **frontmatter metadata** current and complete
3. Preserve **cross-references** between documents
4. Ensure **file length stays under 600 lines** for readability
5. Follow **style guidelines** defined in coding-standards.md

### Validation

Validate baseline files for consistency:

``````bash
# Using PowerShell script
powershell -NoProfile -File .claude/scripts/validate-baseline.ps1

# Check for template variables
grep -r '{{.*}}' baseline_docs/ --include='*.md'

# Verify frontmatter
for f in baseline_docs/*.md; do head -6 "$f" | grep -q "^---$" || echo "Missing frontmatter: $f"; done

# Check file line counts
wc -l baseline_docs/*.md
``````

---

## Document Categories

### Foundation (00-02)
- **System Overview** - High-level architecture and capabilities
- **Architecture** - Detailed component design and data flows
- **Security** - Authentication, encryption, and compliance

### Development (03-05)
- **Coding Standards** - Multi-language style guide and best practices
- **AI Agent Protocol** - Claude Code workflow and integration patterns
- **Deployment Guide** - Infrastructure setup and scaling

### Reference (06-08)
- **Database Schema** - Tables, relationships, and migrations
- **Testing & QA** - Test strategies and quality assurance
- **API Documentation** - Endpoints, authentication, and examples

### Planning (09-10)
- **Project Roadmap** - Sprint planning and feature templates
- **Disaster Recovery** - Backup, rollback, and audit procedures

---

## Compliance Alignment

All baseline documentation aligns with:

- **FTC Safeguards Rule** - Encryption, access control, audit trail
- **SOC 2 (Type II)** - Security, availability, confidentiality, processing integrity
- **CIS Controls** - Security best practices and automated compliance checks
- **CMMC Level 2** - 110+ control mappings for DoD compliance

---

## Technology Coverage

The baseline templates provide guidance for:

- **Backend:** Laravel 11+, PHP 8.2+, MySQL 8, Redis
- **Frontend:** React 18+, Redux Toolkit, Material-UI, Vite
- **Queue System:** Laravel Horizon with Redis
- **Scanners:** Python 3.x (DNS, WHOIS, web privacy)
- **AI Integration:** Multi-provider (OpenAI, Anthropic, GPT-OSS)
- **Infrastructure:** Docker, Nginx, Let's Encrypt SSL

---

## Support & Contact

For questions or improvements to the baseline pack:

- **Repository:** [Engineering Baseline Documentation]({{REPO_PATH}})
- **Contact:** {{CONTACT_EMAIL}}
- **Documentation:** See CLAUDE.md for Claude Code integration

---

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Total Files:** $($files.Count)
**Status:** Production-Ready Baseline
"@

# Write to file
$readmeContent | Out-File -FilePath $outputFile -Encoding UTF8 -Force

Write-Host ""
Write-Host "README.md index generated successfully!" -ForegroundColor Green
Write-Host "Location: $outputFile" -ForegroundColor Cyan
Write-Host "Files indexed: $($files.Count)" -ForegroundColor White
