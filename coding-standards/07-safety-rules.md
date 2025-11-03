# File & Database Safety Standards

**⚠️ MANDATORY - PRODUCTION CRITICAL RULES ⚠️**

[← Back to Index](./README.md)

---

## 🚨 CRITICAL WARNING

**These are production-critical safety rules. Violation of these rules can cause:**
- ✗ System downtime
- ✗ Data loss
- ✗ Security breaches
- ✗ Production outages
- ✗ Client data corruption

**ALL team members and AI assistants MUST follow these rules.**

---

## Quick Reference

### 🚫 NEVER DO THESE

- ❌ NEVER delete files
- ❌ NEVER drop the database
- ❌ NEVER drop tables without backup
- ❌ NEVER modify .env files without approval
- ❌ NEVER change composer.json without approval
- ❌ NEVER modify existing API routes
- ❌ NEVER alter database indexes without backup
- ❌ NEVER modify foreign key constraints

### ✅ ALWAYS DO THESE

- ✅ ALWAYS backup files before changes
- ✅ ALWAYS update changelog
- ✅ ALWAYS create migrations for DB changes
- ✅ ALWAYS create seeders for test data
- ✅ ALWAYS use working folder for tests
- ✅ ALWAYS get approval for critical changes
- ✅ ALWAYS test thoroughly
- ✅ ALWAYS document changes

---

## Table of Contents

1. [File System Safety](#file-system-safety)
2. [Database Safety](#database-safety)
3. [Application Core Safety](#application-core-safety)
4. [Environment & Configuration Safety](#environment--configuration-safety)
5. [Safety Checklist](#safety-checklist)
6. [Emergency Procedures](#emergency-procedures)

---

## File System Safety

### 🚫 NEVER Delete Files

```bash
# ❌ NEVER DO THIS
rm app/Models/User.php
del app/Http/Controllers/AssessmentController.php

# ✅ ALWAYS DO THIS INSTEAD
# 1. Backup the file first
cp app/Models/User.php ~/backups/User_$(date +%Y%m%d_%H%M%S).php

# 2. Rename/archive instead of delete
mv app/Models/OldModel.php app/Models/Archive/OldModel.php.archive
```

### ✅ ALWAYS Backup Before Modifying

```bash
# ✅ GOOD - Backup before editing
cp app/Http/Controllers/AssessmentController.php \
   ~/backups/AssessmentController_$(date +%Y%m%d_%H%M%S).php

# Now safe to edit
nano app/Http/Controllers/AssessmentController.php
```

### File System Organization

#### Approved Locations for Development

```
✅ SAFE FOR DEVELOPMENT/TESTING:
- tims_working_folder/claude-testing/
- tims_working_folder/scratch/
- storage/app/temp/
- tests/
- database/seeders/

❌ AVOID DIRECT MODIFICATION:
- app/Models/ (backup first!)
- app/Http/Controllers/ (backup first!)
- config/ (get approval!)
- routes/ (get approval!)
- database/migrations/ (migrations only!)
```

#### Backup Directory Structure

```
backups/
├── code/
│   ├── controllers/
│   │   └── AssessmentController_20250115_143022.php
│   ├── models/
│   │   └── User_20250115_143022.php
│   └── services/
│       └── AssessmentService_20250115_143022.php
├── database/
│   ├── full_backup_20250115.sql
│   └── table_backups/
│       └── assessments_20250115.sql
└── config/
    └── database_20250115.php
```

---

## Database Safety

### 🚫 NEVER Drop Database or Tables

```sql
-- ❌ NEVER DO THIS - CATASTROPHIC!
DROP DATABASE polygon_compliance;
DROP TABLE assessments;
TRUNCATE TABLE users;

-- ❌ NEVER DO THIS - Even in development!
php artisan migrate:fresh  -- Drops all tables!
php artisan db:wipe        -- Wipes database!
```

### ✅ ALWAYS Use Migrations

```php
// ✅ GOOD - Create migration for changes
php artisan make:migration add_msp_fields_to_assessments_table

// In migration file:
public function up(): void
{
    Schema::table('assessments', function (Blueprint $table) {
        $table->uuid('msp_id')->nullable()->after('company_id');
        $table->index('msp_id');
    });
}

public function down(): void
{
    Schema::table('assessments', function (Blueprint $table) {
        $table->dropIndex(['msp_id']);
        $table->dropColumn('msp_id');
    });
}
```

### ✅ ALWAYS Backup Before Database Changes

```bash
# ✅ GOOD - Full database backup
mysqldump -u username -p polygon_compliance > \
    ~/backups/polygon_compliance_$(date +%Y%m%d_%H%M%S).sql

# ✅ GOOD - Single table backup
mysqldump -u username -p polygon_compliance assessments > \
    ~/backups/assessments_$(date +%Y%m%d_%H%M%S).sql

# Then run migration
php artisan migrate
```

### Database Modification Rules

#### ✅ SAFE Database Operations

```php
// ✅ Adding new columns
Schema::table('assessments', function (Blueprint $table) {
    $table->string('new_field')->nullable();
});

// ✅ Adding new indexes
Schema::table('assessments', function (Blueprint $table) {
    $table->index('company_id');
});

// ✅ Creating new tables
Schema::create('new_table', function (Blueprint $table) {
    // Table definition
});
```

#### ⚠️ REQUIRES APPROVAL

```php
// ⚠️ Modifying existing columns - GET APPROVAL
Schema::table('assessments', function (Blueprint $table) {
    $table->string('name', 500)->change();  // Changing length
});

// ⚠️ Dropping columns - GET APPROVAL & BACKUP
Schema::table('assessments', function (Blueprint $table) {
    $table->dropColumn('old_field');
});

// ⚠️ Renaming columns - GET APPROVAL
Schema::table('assessments', function (Blueprint $table) {
    $table->renameColumn('old_name', 'new_name');
});
```

#### 🚫 NEVER Do Without Explicit Approval

```php
// ❌ NEVER - Dropping tables
Schema::dropIfExists('assessments');  // NEVER!

// ❌ NEVER - Dropping foreign keys
Schema::table('assessments', function (Blueprint $table) {
    $table->dropForeign(['template_id']);  // REQUIRES APPROVAL!
});

// ❌ NEVER - Dropping indexes without backup
Schema::table('assessments', function (Blueprint $table) {
    $table->dropIndex(['company_id']);  // REQUIRES APPROVAL!
});
```

---

## Application Core Safety

### 🚫 NEVER Modify Without Approval

```
❌ RESTRICTED - Requires Approval:

1. Model Relationships
   - app/Models/*/relationships
   - Changes can break the entire system

2. Authentication/Authorization
   - app/Http/Middleware/Auth*.php
   - app/Policies/
   - Can create security vulnerabilities

3. Validation Rules
   - app/Http/Requests/
   - Can allow invalid data

4. Queue Jobs
   - app/Jobs/
   - Can cause data processing issues

5. Event Listeners
   - app/Listeners/
   - Can break async operations

6. Multi-Tenant Logic
   - Any code handling company_id, client_id, msp_id
   - Can expose data across tenants!

7. Permission Systems
   - app/Services/Auth/PermissionService.php
   - Can grant unauthorized access
```

### Safe Change Process for Core Files

```
✅ SAFE CHANGE WORKFLOW:

1. Create Jira ticket
2. Discuss with team lead
3. Get explicit approval
4. Backup original file
5. Create feature branch
6. Make minimal changes
7. Add comprehensive tests
8. Document changes
9. Code review
10. QA testing
11. Deployment approval
```

---

## Environment & Configuration Safety

### 🚫 NEVER Modify Production Config

```bash
# ❌ NEVER modify these in production:
.env
.env.production
config/database.php
config/auth.php
config/services.php
composer.json
package.json
```

### ✅ Configuration Change Process

```
1. Create ticket
2. Document proposed changes
3. Get approval from DevOps/Lead
4. Test in development
5. Test in staging
6. Schedule production change window
7. Backup current config
8. Apply changes
9. Verify functionality
10. Monitor for issues
```

### Environment Variables

```bash
# ✅ GOOD - Add new optional variables
NEW_FEATURE_ENABLED=false

# ⚠️ REQUIRES APPROVAL - Modify existing
DB_CONNECTION=mysql  # Changing this requires approval

# ❌ NEVER - Delete without understanding impact
# DB_HOST=127.0.0.1  # DON'T COMMENT OUT OR DELETE!
```

---

## Safety Checklist

### Before Making ANY Change

```
Pre-Change Checklist:
☐ Have I created a Jira ticket?
☐ Do I understand what this change affects?
☐ Have I backed up the files I'm modifying?
☐ Do I have approval if this is a restricted area?
☐ Am I working in the correct environment?
☐ Have I tested this in development first?
☐ Do I have a rollback plan?
☐ Have I updated the changelog?
```

### For Database Changes

```
Database Change Checklist:
☐ Have I backed up the database?
☐ Have I backed up affected tables?
☐ Am I using a migration (not raw SQL)?
☐ Have I included a down() method for rollback?
☐ Have I tested on a copy of production data?
☐ Do I know the impact on existing data?
☐ Have I checked for foreign key constraints?
☐ Will this cause downtime?
☐ Do I have approval for this change?
```

### For Code Deployment

```
Deployment Checklist:
☐ All tests passing?
☐ Code review completed?
☐ QA testing completed?
☐ Documentation updated?
☐ Changelog updated?
☐ Database migrations ready?
☐ Environment variables documented?
☐ Rollback plan documented?
☐ Deployment approval obtained?
☐ Stakeholders notified?
```

---

## Emergency Procedures

### If You Accidentally Delete a File

```bash
# 1. STOP - Don't panic
# 2. Check if file is in Git
git status
git checkout app/Models/DeletedFile.php

# 3. Check backups
ls -la ~/backups/

# 4. Restore from backup
cp ~/backups/DeletedFile_20250115.php app/Models/DeletedFile.php

# 5. Verify restoration
git diff app/Models/DeletedFile.php

# 6. Document incident in Jira
```

### If You Accidentally Drop a Table

```bash
# 1. STOP ALL OPERATIONS IMMEDIATELY
# 2. Alert team lead and DevOps
# 3. Do NOT run any more database commands
# 4. Restore from most recent backup

# If you have backup:
mysql -u username -p polygon_compliance < ~/backups/latest_backup.sql

# 5. Verify data integrity
# 6. Document incident
# 7. Review what went wrong
# 8. Update procedures to prevent recurrence
```

### If You Break Production

```
IMMEDIATE ACTIONS:
1. Alert team lead immediately
2. Alert DevOps immediately
3. Document what happened
4. Prepare rollback if available
5. Do NOT attempt fixes without approval
6. Assist in recovery as directed
7. Post-incident: Document and learn
```

---

## For AI Assistants (Claude Code)

### Claude Code Safety Protocol

**Before making ANY changes, Claude Code MUST:**

#### Pre-Change Protocol
```
1. Identify if change is in restricted area
2. Check if approval is required
3. Determine backup requirements
4. Verify working in correct location
5. Plan rollback strategy
```

#### For File Modifications
```
1. Create backup with timestamp
2. Document original state
3. Make minimal necessary changes
4. Test changes
5. Update changelog
6. Provide rollback instructions
```

#### For Database Changes
```
1. Create migration (never raw SQL)
2. Include down() method
3. Add proper indexes
4. Include all mandatory fields
5. Test with sample data
6. Document impact
```

#### For Critical Areas
```
IF modifying:
  - Models/relationships
  - Auth/permissions
  - Multi-tenant logic
  - API routes
  - Core services
THEN:
  - STOP
  - ASK user for explicit approval
  - EXPLAIN risks
  - WAIT for confirmation
  - PROCEED only if approved
```

---

## Related Standards

- [Database Standards](./05-database-standards.md)
- [GitHub & Jira Workflow](./09-github-jira-workflow.md)
- [Quality Standards](./08-quality-standards.md)

---

## Summary

**REMEMBER:**
- 🔒 **Safety First** - Always backup before changes
- 🚫 **Never Delete** - Rename or archive instead
- ✅ **Always Document** - Update changelog and Jira
- 🛡️ **Get Approval** - For critical system changes
- 📋 **Follow Process** - Use established workflows
- 🧪 **Test First** - Development → Staging → Production

**When in doubt, ASK! It's better to ask than to break production.**

---

**Next:** [Quality Standards →](./08-quality-standards.md)

**Last Updated:** January 2025
