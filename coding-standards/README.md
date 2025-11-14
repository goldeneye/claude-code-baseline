# Coding Standards & Best Practices

**{{PROJECT_NAME}}**
Enhanced for Claude Code & AI Development Assistants

---

## Overview

This directory contains comprehensive coding standards, conventions, and best practices for {{PROJECT_NAME}}. All team members and AI assistants (including Claude Code) must follow these guidelines to ensure code consistency, maintainability, security, and quality.

### Core Principles

- **Consistency** - Follow established patterns across all code
- **Maintainability** - Write code that others can understand and modify
- **Security** - Protect user data and prevent vulnerabilities
- **Performance** - Optimize for speed and efficiency
- **Documentation** - Comprehensive docs with pseudo code planning
- **AI Integration** - Standards designed for AI development assistants

---

## Quick Navigation

### 📋 Standards Overview
1. [Pseudo Code Standards](./01-pseudo-code-standards.md) - Plan before you code
2. [Project Structure](./02-project-structure.md) - Laravel architecture & conventions

### 💻 Code Standards
3. [PHP Standards](./03-php-standards.md) - PSR-12 compliance & Laravel patterns
4. [JavaScript Standards](./04-javascript-standards.md) - ES6+, React, and modern JS
5. [Database Standards](./05-database-standards.md) - Schema, reserved words, multi-tenant
6. [Logging Standards](./06-logging-standards.md) - Comprehensive logging guidelines

### 🛡️ Critical Rules
7. [Safety Rules](./07-safety-rules.md) - **MANDATORY** - File & database safety

### ✅ Quality Assurance
8. [Quality Standards](./08-quality-standards.md) - Documentation & code quality
9. [GitHub & Jira Workflow](./09-github-jira-workflow.md) - Branch, PR, and deployment rules
10. [Testing Standards](./10-testing-standards.md) - Unit, feature, and integration tests
11. [Security Standards](./11-security-standards.md) - Security best practices
12. [Performance Standards](./12-performance-standards.md) - Optimization & caching

---

## Index by Role

### For Developers
- [PHP Standards](./03-php-standards.md)
- [JavaScript Standards](./04-javascript-standards.md)
- [Pseudo Code Standards](./01-pseudo-code-standards.md)
- [Quality Standards](./08-quality-standards.md)

### For Database Developers
- [Database Standards](./05-database-standards.md)
- [Safety Rules](./07-safety-rules.md)
- [Performance Standards](./12-performance-standards.md)

### For QA Engineers
- [Testing Standards](./10-testing-standards.md)
- [Security Standards](./11-security-standards.md)
- [Quality Standards](./08-quality-standards.md)

### For DevOps/Project Managers
- [GitHub & Jira Workflow](./09-github-jira-workflow.md)
- [Safety Rules](./07-safety-rules.md)
- [Logging Standards](./06-logging-standards.md)

### For AI Assistants (Claude Code)
- [Pseudo Code Standards](./01-pseudo-code-standards.md) - **START HERE**
- [Safety Rules](./07-safety-rules.md) - **CRITICAL**
- [Logging Standards](./06-logging-standards.md)
- [Quality Standards](./08-quality-standards.md)

---

## How to Use These Standards

### For New Team Members
1. Start with [Project Structure](./02-project-structure.md) to understand the codebase
2. Read [Safety Rules](./07-safety-rules.md) - **CRITICAL** - to avoid catastrophic mistakes
3. Review the standards for your primary language:
   - Backend: [PHP Standards](./03-php-standards.md)
   - Frontend: [JavaScript Standards](./04-javascript-standards.md)
   - Database: [Database Standards](./05-database-standards.md)
4. Understand [GitHub & Jira Workflow](./09-github-jira-workflow.md) for deployments

### For AI Development Assistants
1. **ALWAYS** read [Pseudo Code Standards](./01-pseudo-code-standards.md) before implementing complex logic
2. **ALWAYS** check [Safety Rules](./07-safety-rules.md) before making file or database changes
3. **ALWAYS** add logging per [Logging Standards](./06-logging-standards.md)
4. **ALWAYS** follow [Quality Standards](./08-quality-standards.md) for documentation

### For Code Reviews
- Verify compliance with [Quality Standards](./08-quality-standards.md)
- Check [Security Standards](./11-security-standards.md) for vulnerabilities
- Ensure [Testing Standards](./10-testing-standards.md) are met
- Confirm [GitHub & Jira Workflow](./09-github-jira-workflow.md) followed

---

## Quick Reference Cards

### Must-Do Checklist ✅
- [ ] Write pseudo code for complex logic
- [ ] Add comprehensive logging with file:line
- [ ] Include multi-tenant fields (company_id, client_id, msp_id)
- [ ] Follow PSR-12 formatting standards
- [ ] Write unit tests for new functionality
- [ ] Link code to Jira ticket
- [ ] Get code review approval
- [ ] Update documentation

### Never-Do List ❌
- [ ] NEVER delete files (only rename/modify)
- [ ] NEVER drop database or tables without backup
- [ ] NEVER modify .env files without approval
- [ ] NEVER deploy to MAIN without Josh approval
- [ ] NEVER use database reserved words for columns
- [ ] NEVER log sensitive data (passwords, tokens)
- [ ] NEVER skip multi-tenant isolation checks
- [ ] NEVER commit without comprehensive logging

---

## Common Patterns & Examples

### File Header Pattern
Every PHP file must start with:
```php
<?php
// File: app/Http/Controllers/ExampleController.php

/*
 * © {{COPYRIGHT_YEAR}} {{COMPANY_NAME}}. All rights reserved.
 * [Full copyright notice...]
 */

namespace App\Http\Controllers;
```

### Logging Pattern
```php
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Action description", [
    'user_id' => $user->id,
    'company_id' => $user->company_id,
    'entity_id' => $entity->id
]);
```

### Database Standard Fields
Every table must include:
```sql
id CHAR(36) PRIMARY KEY,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at TIMESTAMP NULL,
is_archived BOOLEAN DEFAULT FALSE,
archived_at TIMESTAMP NULL,
company_id CHAR(36) NULL,
client_id CHAR(36) NULL,
msp_id CHAR(36) NULL
```

---

## Version History

- **v2.0** (2025-01) - Split into modular files, enhanced with AI assistant guidance
- **v1.0** (2024-08) - Initial comprehensive coding standards document

---

## Contributing

When updating these standards:
1. Create a branch: `docs/update-coding-standards-DESCRIPTION`
2. Update relevant document(s)
3. Update this README if adding new sections
4. Create PR with detailed description of changes
5. Get approval from team leads

---

## Support

- **Questions?** Post in #dev-standards Slack channel
- **Issues?** Create Jira ticket with "Standards" label
- **Suggestions?** Submit PR with proposed changes

---

**Last Updated:** January 2025
**Maintained By:** GoldenEye Engineering (@goldeneye)
**For:** Developers, QA, DevOps, and AI Development Assistants
