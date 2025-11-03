---
title: {{PROJECT_NAME}} - Coding Standards & Best Practices
version: 2.0
last_updated: 2025-01-15
author: ComplianceScorecard Engineering
status: REDIRECTED TO MODULAR STRUCTURE
---

# {{PROJECT_NAME}} — Coding Standards & Best Practices

## 📋 Important Notice

**This document has been reorganized into a modular, comprehensive structure for better maintainability and ease of use.**

The coding standards are now located in: **`coding-standards/`**

---

## 📁 New Modular Structure

The coding standards have been split into **13 focused documents** organized by topic:

### Central Navigation
- **[README.md](../coding-standards/README.md)** - Start here! Central hub with navigation and overview

### Standards Documentation

1. **[01-pseudo-code-standards.md](../coding-standards/01-pseudo-code-standards.md)**
   - Plan before you code
   - Pseudo code syntax and examples
   - When to use pseudo code

2. **[02-project-structure.md](../coding-standards/02-project-structure.md)**
   - Laravel architecture & conventions
   - Directory organization
   - File naming standards

3. **[03-php-standards.md](../coding-standards/03-php-standards.md)**
   - PSR-12 compliance
   - Laravel best practices
   - Class and method structure

4. **[04-javascript-standards.md](../coding-standards/04-javascript-standards.md)**
   - ES6+ standards
   - React component patterns
   - Modern JavaScript practices

5. **[05-database-standards.md](../coding-standards/05-database-standards.md)**
   - Schema design
   - Reserved words to avoid
   - Multi-tenant architecture

6. **[06-logging-standards.md](../coding-standards/06-logging-standards.md)**
   - Comprehensive logging guidelines
   - Log levels and contexts
   - Best practices

7. **[07-safety-rules.md](../coding-standards/07-safety-rules.md)** ⚠️ **CRITICAL**
   - File & database safety
   - NEVER DO rules
   - Emergency procedures

8. **[08-quality-standards.md](../coding-standards/08-quality-standards.md)**
   - Documentation compliance
   - Code quality metrics
   - Pattern consistency

9. **[09-github-jira-workflow.md](../coding-standards/09-github-jira-workflow.md)**
   - Branch naming conventions
   - PR templates
   - Deployment rules

10. **[10-testing-standards.md](../coding-standards/10-testing-standards.md)**
    - Unit, feature, and integration tests
    - Testing patterns
    - Code coverage

11. **[11-security-standards.md](../coding-standards/11-security-standards.md)**
    - Input validation
    - SQL injection prevention
    - Authentication & authorization

12. **[12-performance-standards.md](../coding-standards/12-performance-standards.md)**
    - Database optimization
    - Caching strategies
    - Queue optimization

---

## 🚀 Quick Start Guide

### For Developers
Start with the [README.md](../coding-standards/README.md), then review:
- [PHP Standards](../coding-standards/03-php-standards.md)
- [JavaScript Standards](../coding-standards/04-javascript-standards.md)
- [Safety Rules](../coding-standards/07-safety-rules.md) ⚠️

### For Database Developers
- [Database Standards](../coding-standards/05-database-standards.md)
- [Safety Rules](../coding-standards/07-safety-rules.md) ⚠️
- [Performance Standards](../coding-standards/12-performance-standards.md)

### For QA Engineers
- [Testing Standards](../coding-standards/10-testing-standards.md)
- [Security Standards](../coding-standards/11-security-standards.md)
- [Quality Standards](../coding-standards/08-quality-standards.md)

### For AI Assistants (Claude Code)
**MUST READ:**
- [Pseudo Code Standards](../coding-standards/01-pseudo-code-standards.md) - START HERE
- [Safety Rules](../coding-standards/07-safety-rules.md) - CRITICAL
- [Logging Standards](../coding-standards/06-logging-standards.md)
- [Quality Standards](../coding-standards/08-quality-standards.md)

---

## 📖 Benefits of the New Structure

### ✅ Better Organization
- Each topic in its own focused document
- Easier to find specific information
- Reduced cognitive load

### ✅ Enhanced Content
- More detailed examples
- Quick reference sections at top of each file
- Comprehensive real-world scenarios
- Enhanced with cheat sheets

### ✅ Improved Maintainability
- Update one area without affecting others
- Better Git history tracking
- Easier code reviews of standard changes

### ✅ Role-Based Access
- Find relevant standards quickly by role
- Team members can focus on their area
- Onboarding is more streamlined

---

## 🔧 Using These Standards in New Projects

When creating a new project from this baseline:

1. **Copy the entire directory:**
   ```bash
   cp -r coding-standards/ /path/to/new-project/docs/
   ```

2. **Replace template variables:**
   ```bash
   # In all files within coding-standards/
   {{PROJECT_NAME}} → Your Project Name
   {{SERVICE_NAME}} → Your Service Name
   {{REPO_PATH}} → Your Repository Path
   {{CONTACT_EMAIL}} → Your Contact Email
   ```

3. **Customize as needed:**
   - Remove standards that don't apply
   - Add project-specific conventions
   - Update examples with your domain

4. **Update your project's CLAUDE.md:**
   Point to `docs/coding-standards/README.md` as the central reference

---

## 📝 Migration Notes

### What Changed?
- **Before:** Single 1,945-line monolithic document
- **After:** 13 modular documents with ~6,000 lines of enhanced content

### What Was Added?
- ✅ Quick reference TL;DR sections
- ✅ Table of contents in each file
- ✅ More code examples (PHP, JavaScript, SQL)
- ✅ Real-world scenarios
- ✅ Enhanced AI assistant guidance
- ✅ Cheat sheets and quick lookups
- ✅ Cross-referencing between documents

### What Stayed the Same?
- ✅ All original content preserved
- ✅ Same coding principles
- ✅ Same standards and rules
- ✅ Same compliance focus

---

## 📞 Questions or Feedback?

If you have questions about the new structure or need help finding specific standards:

1. Start with [coding-standards/README.md](../coding-standards/README.md)
2. Use the role-based index to find relevant sections
3. Check cross-references at the bottom of each document
4. Refer to the quick reference sections at the top of each file

---

## 🗺️ Document History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-01-15 | Reorganized into modular structure (13 files) |
| 1.5 | 2025-01-15 | Enhanced with AI assistant guidance |
| 1.0 | 2024-08 | Initial comprehensive standards document |

---

**For the complete coding standards, please visit:**

**→ [coding-standards/README.md](../coding-standards/README.md)**
