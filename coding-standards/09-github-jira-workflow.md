# GitHub & Jira Workflow Standards

**MANDATORY Project Management & Deployment Rules**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- ✅ **ALWAYS** create Jira ticket before coding
- ✅ **ALWAYS** create feature branch
- ✅ **ALWAYS** test before committing
- ✅ **ALWAYS** get code review
- ✅ **NEVER** deploy to MAIN without Josh approval
- ✅ **ALWAYS** include PR notes and release notes

---

## Table of Contents

1. [Critical Workflow Rules](#critical-workflow-rules)
2. [Complete Development Workflow](#complete-development-workflow)
3. [Branch Naming Conventions](#branch-naming-conventions)
4. [Commit Message Standards](#commit-message-standards)
5. [Pull Request Template](#pull-request-template)
6. [Deployment Rules](#deployment-rules)

---

## Critical Workflow Rules

### 🌱 Branch & Development Rules - MANDATORY

1. **ALWAYS create your own/new GH branch**
2. **ALWAYS tie changes to a Jira ticket**
3. **ALWAYS test your code before committing**
4. **ALWAYS document changes in Jira AND GitHub**
5. **ALWAYS include release notes in PR**
6. **ALWAYS include PR notes and comments**

### 🚫 Deployment Restrictions - NEVER VIOLATE

7. **NEVER DEPLOY TO MAIN** without approval
8. **Only approved staff can deploy to DEV**
9. **Only authorized project staff can deploy to MAIN**
10. **Only Josh can approve PR to MAIN**

### 🧪 Quality Assurance Pipeline - MANDATORY

11. **ALL production code MUST be run through QA**
12. **All DEV code must be QA'd**
13. **All QA'd code must be documented in Jira and tied to sprints**
14. **All changes must be tied to Jira tickets and sprints**

---

## Complete Development Workflow

### Phase 1: Planning & Setup

```
Step 1: Create/Assign Jira Ticket
├── Link to specific sprint
├── Link to epic if applicable
├── Include acceptance criteria
└── Estimate story points

Step 2: Create New GitHub Branch
├── Format: feature/PROJ-123-short-description
├── Branch from: develop or main (as specified)
└── Never work directly on main/develop

Step 3: Update Jira with Branch Info
├── Link branch to ticket
├── Move ticket to "In Progress"
└── Add comment with approach
```

### Phase 2: Development & Testing

```
Step 4: Write Code Following Standards
├── Include pseudo code for complex logic
├── Add comprehensive logging
├── Follow existing patterns
├── Add PHPDoc documentation
└── Create/update tests

Step 5: Test Code Thoroughly
├── Unit tests for new functions
├── Integration tests for workflows
├── Manual testing of features
├── Test edge cases
└── Verify multi-tenant isolation

Step 6: Update Jira with Progress
├── Document testing results
├── Note any issues discovered
├── Update time estimates
└── Add screenshots if applicable
```

### Phase 3: Pull Request & Review

```
Step 7: Create PR with Complete Notes
├── Use PR template (see below)
├── Include Jira ticket link
├── Detailed description of changes
├── List all affected files/features
└── Add screenshots/videos if applicable

Step 8: Include Release Notes
├── User-facing changes
├── Technical changes
├── Breaking changes (if any)
├── Migration requirements
└── Configuration changes

Step 9: QA Review Process
├── ALL code must pass QA
├── QA documents test results
├── QA signs off in Jira
├── Fix any issues found
└── Re-submit for QA if needed
```

### Phase 4: Approval & Deployment

```
Step 10: Get Required Approvals
├── Code review approval (required)
├── QA approval (required)
├── Josh approval for MAIN (required)
└── Stakeholder sign-off (if needed)

Step 11: Deploy Following Rules
├── DEV: Approved staff only
├── STAGING: After successful DEV testing
├── MAIN: Only authorized project staff
└── Only Josh approves MAIN deployment

Step 12: Update Jira & Close Ticket
├── Document deployment details
├── Add deployment timestamp
├── Mark ticket as "Done"
└── Archive in sprint
```

---

## Branch Naming Conventions

### Standard Format

```
{type}/{ticket}-{brief-description}
```

### Branch Types

```bash
# Features - New functionality
feature/PG3-1234-assessment-scoring
feature/PG3-5678-client-dashboard

# Bug Fixes - Fixing bugs
bugfix/PG3-9012-fix-permission-check
bugfix/PG3-3456-resolve-memory-leak

# Hotfixes - Critical production fixes
hotfix/critical-auth-vulnerability
hotfix/database-connection-timeout

# Refactoring - Code improvements
refactor/PG3-7890-improve-query-performance
refactor/improve-assessment-service

# Documentation - Documentation updates
docs/PG3-2468-update-api-docs
docs/add-deployment-guide

# Chore - Maintenance tasks
chore/PG3-1357-update-dependencies
chore/cleanup-deprecated-code
```

### Examples

```bash
✅ GOOD:
feature/PG3-1234-add-assessment-templates
bugfix/PG3-5678-fix-client-access
hotfix/resolve-payment-processing

❌ BAD:
my-branch
testing
feature-123
fix-bug
```

---

## Commit Message Standards

### Format

```
{type}({scope}): {short description}

{detailed description}

{breaking changes}

{references}
```

### Commit Types

| Type | Purpose | Example |
|------|---------|---------|
| `feat` | New feature | `feat(assessment): add scoring algorithm` |
| `fix` | Bug fix | `fix(auth): resolve token expiration issue` |
| `docs` | Documentation | `docs(api): update endpoint documentation` |
| `style` | Formatting | `style(models): fix indentation` |
| `refactor` | Code restructure | `refactor(service): simplify logic` |
| `test` | Testing | `test(assessment): add unit tests` |
| `chore` | Maintenance | `chore(deps): update Laravel to 10.x` |
| `perf` | Performance | `perf(query): optimize database queries` |
| `security` | Security fixes | `security(auth): patch CSRF vulnerability` |

### Commit Message Examples

```bash
# ✅ GOOD - Clear and informative
feat(assessment): add pseudo code documentation standards

- Implement pseudo code standards for complex algorithms
- Add examples for assessment scoring
- Update documentation with AI integration guidelines
- Include database field standards and triggers

Closes #1234
References PG3-1234

# ✅ GOOD - With breaking change
feat(api): update assessment endpoint structure

Changed response format for better consistency.

BREAKING CHANGE: Assessment API now returns data in 'data' wrapper
instead of root level. Update all API consumers.

Closes #5678
References PG3-5678

# ❌ BAD - Too vague
fix: bug
update: code
changes

# ❌ BAD - No context
added feature
fixed it
updated stuff
```

---

## Pull Request Template

### MANDATORY PR Format

```markdown
## Jira Ticket
**Link:** [PROJ-123](https://{{PROJECT_NAME}}.atlassian.net/browse/PROJ-123)
**Sprint:** Sprint 15
**Epic:** Assessment System Enhancement

## Summary
Brief description of what this PR accomplishes and why it's needed.

## Changes Made
- ✅ Added comprehensive logging to AssessmentController
- ✅ Implemented pseudo code documentation standards
- ✅ Added database migration for new audit fields
- ✅ Updated unit tests for new functionality
- ✅ Fixed multi-tenant isolation bug in queries

## Testing Performed
- ✅ Unit tests: All passing (25 tests, 0 failures)
- ✅ Integration tests: All passing (12 tests, 0 failures)
- ✅ Manual testing: Tested assessment creation and scoring
- ✅ Performance testing: No regressions detected
- ✅ Multi-tenant testing: Verified data isolation

**Evidence:**
- Screenshot: [test-results.png]
- Performance report: [performance-metrics.pdf]

## Release Notes

### User-Facing Changes
- Improved assessment loading performance by 25%
- Enhanced error messaging for failed assessments
- Added audit trail for assessment modifications
- Fixed bug where clients could see other companies' data

### Technical Changes
- Added comprehensive logging throughout assessment system
- Implemented new database fields for audit tracking (migration required)
- Enhanced error handling and recovery
- Optimized database queries with proper indexing

### Breaking Changes
None

### Migration Requirements
- Run: `php artisan migrate`
- Add to .env: `ASSESSMENT_CACHE_TTL=3600`

## Documentation Updated
- ✅ Updated CODING_STANDARDS.md
- ✅ Updated CLAUDE.md with new patterns
- ✅ Added inline code documentation
- ✅ Updated Jira ticket with technical details
- ✅ Added changelog entry

## QA Checklist
- ✅ Code follows all coding standards
- ✅ All safety rules followed (no direct MAIN deployments)
- ✅ Comprehensive logging added
- ✅ Database changes properly migrated
- ✅ No breaking changes to existing APIs
- ✅ Performance impact assessed and acceptable
- ✅ Multi-tenant isolation verified
- ✅ Security review completed

## Reviewer Notes

### Focus Areas for Review
- Assessment scoring algorithm changes (AssessmentController.php:150-200)
- New database migration compatibility (migration file)
- Logging format consistency (throughout)

### Dependencies
- Requires database migration before deployment
- No breaking changes to existing integrations
- Compatible with current frontend version

### Rollback Plan
If issues arise:
1. Rollback migration: `php artisan migrate:rollback`
2. Revert to previous commit: `git revert <commit-hash>`
3. Clear cache: `php artisan cache:clear`

## Screenshots
[Attach relevant screenshots or videos]

## Additional Context
Any additional information reviewers should know.
```

---

## Deployment Rules

### Environment Hierarchy

```
Development → Staging → Production
    ↓           ↓           ↓
  Anyone    Approved    Josh Only
            Staff
```

### DEV Environment

```
WHO CAN DEPLOY: Approved staff only
APPROVAL REQUIRED: Code review + passing tests
PROCESS:
1. Create PR to develop branch
2. Get code review approval
3. Merge to develop
4. Auto-deploy to DEV (if configured)
5. Verify deployment
```

### STAGING Environment

```
WHO CAN DEPLOY: Senior developers + DevOps
APPROVAL REQUIRED: Code review + QA approval
PROCESS:
1. Code deployed to DEV and tested
2. QA signs off on functionality
3. Create PR to staging branch
4. Senior dev approves
5. Deploy to staging
6. Smoke test critical paths
```

### MAIN/PRODUCTION Environment

```
WHO CAN DEPLOY: Authorized project staff ONLY
APPROVAL REQUIRED: Josh approval + QA + Stakeholders
PROCESS:
1. Code fully tested in DEV and STAGING
2. All QA sign-offs complete
3. Release notes prepared
4. Stakeholders notified
5. Create PR to main branch
6. Josh reviews and approves
7. Schedule deployment window
8. Deploy during approved window
9. Monitor for issues
10. Mark Jira tickets as deployed
```

### Deployment Checklist

```
PRE-DEPLOYMENT:
☐ All tests passing
☐ Code review approved
☐ QA sign-off complete
☐ Database migrations ready
☐ Environment variables documented
☐ Rollback plan documented
☐ Stakeholders notified
☐ Deployment window scheduled

DURING DEPLOYMENT:
☐ Backup database
☐ Enable maintenance mode (if needed)
☐ Pull latest code
☐ Run migrations
☐ Clear caches
☐ Update dependencies (if needed)
☐ Restart services
☐ Disable maintenance mode
☐ Smoke test critical paths

POST-DEPLOYMENT:
☐ Monitor error logs
☐ Verify critical functionality
☐ Update Jira tickets
☐ Notify stakeholders
☐ Document any issues
☐ Archive deployment notes
```

---

## For AI Assistants (Claude Code)

### Claude Code Workflow Requirements

**Before Starting Work:**
```
1. ASK for Jira ticket number
2. SUGGEST appropriate branch name
3. CONFIRM sprint assignment
4. REVIEW existing code patterns
```

**During Development:**
```
1. FOLLOW all coding standards
2. ADD comprehensive logging
3. INCLUDE pseudo code for complex logic
4. WRITE tests for new functionality
5. UPDATE documentation
```

**After Development:**
```
1. GENERATE complete PR description
2. INCLUDE testing evidence
3. DOCUMENT performance impact
4. PROVIDE Jira update text
5. LIST all files changed
```

### Example Claude Interaction

```
User: "Implement assessment scoring feature"

Claude: "I'll help implement the assessment scoring feature.
First, I need some information:

1. What is the Jira ticket number for this work?
2. Which sprint is this assigned to?
3. Should I create a feature branch?
   Suggested name: feature/PROJ-XXXX-assessment-scoring
4. Are there specific scoring rules I should follow?

Once confirmed, I'll:
- Write pseudo code for the scoring algorithm
- Implement with comprehensive logging
- Add unit tests
- Create migration if database changes needed
- Generate complete PR description
"
```

---

## Related Standards

- [Quality Standards](./08-quality-standards.md)
- [Safety Rules](./07-safety-rules.md)
- [Testing Standards](./10-testing-standards.md)

---

**Next:** [Testing Standards →](./10-testing-standards.md)

**Last Updated:** January 2025
