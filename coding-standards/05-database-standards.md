# Database Architecture Standards

**Schema Design, Multi-Tenant Architecture & Reserved Words**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- ✅ **ALWAYS** include standard fields (id, timestamps, archived fields, multi-tenant IDs)
- ✅ **NEVER** use MySQL reserved words for table/column names
- ✅ **ALWAYS** add multi-tenant fields (company_id, client_id, msp_id)
- ✅ **ALWAYS** use UUIDs for primary keys
- ✅ **ALWAYS** create migrations with proper indexes
- ✅ **ALWAYS** implement soft deletes

---

## Table of Contents

1. [Standard Database Fields](#standard-database-fields)
2. [Multi-Tenant Architecture](#multi-tenant-architecture)
3. [Reserved Words to AVOID](#reserved-words-to-avoid)
4. [Naming Conventions](#naming-conventions)
5. [Indexes & Performance](#indexes--performance)
6. [Migrations & Seeders](#migrations--seeders)
7. [Laravel Model Standards](#laravel-model-standards)

---

## Standard Database Fields

### MANDATORY Fields for ALL Tables

```sql
CREATE TABLE example_table (
    -- Primary Key (MANDATORY)
    id CHAR(36) PRIMARY KEY,

    -- Timestamps (MANDATORY)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    -- Archival Fields (MANDATORY)
    is_archived BOOLEAN DEFAULT FALSE,
    archived_at TIMESTAMP NULL,
    archived_by CHAR(36) NULL,
    archived_reason TEXT NULL,

    -- Audit Trail (MANDATORY)
    created_by CHAR(36) NULL,
    updated_by CHAR(36) NULL,
    deleted_by CHAR(36) NULL,

    -- Multi-Tenant Fields (MANDATORY for tenant-scoped data)
    company_id CHAR(36) NULL,
    client_id CHAR(36) NULL,
    msp_id CHAR(36) NULL,

    -- Metadata (RECOMMENDED)
    notes TEXT NULL,
    metadata JSON NULL,

    -- Business Logic Fields (AS NEEDED)
    status ENUM('active', 'inactive', 'draft', 'published') DEFAULT 'active',
    sort_order INT DEFAULT 0,

    -- Your specific fields here...
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,

    -- Indexes (MANDATORY)
    INDEX idx_created_at (created_at),
    INDEX idx_updated_at (updated_at),
    INDEX idx_deleted_at (deleted_at),
    INDEX idx_status (status),
    INDEX idx_company_client (company_id, client_id),
    INDEX idx_msp_company (msp_id, company_id),
    INDEX idx_archived (is_archived, archived_at),

    -- Foreign Keys (AS NEEDED)
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (archived_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);
```

### Standard Triggers

```sql
-- Auto-update timestamp trigger
DELIMITER $$
CREATE TRIGGER tr_example_table_updated_at
    BEFORE UPDATE ON example_table
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

-- Soft delete validation trigger
CREATE TRIGGER tr_example_table_soft_delete
    BEFORE UPDATE ON example_table
    FOR EACH ROW
BEGIN
    IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
        SET NEW.is_archived = TRUE;
        SET NEW.archived_at = CURRENT_TIMESTAMP;
    END IF;
END$$

-- Archive timestamp trigger
CREATE TRIGGER tr_example_table_archive
    BEFORE UPDATE ON example_table
    FOR EACH ROW
BEGIN
    IF NEW.is_archived = TRUE AND OLD.is_archived = FALSE THEN
        SET NEW.archived_at = CURRENT_TIMESTAMP;
    END IF;
END$$
DELIMITER ;
```

---

## Multi-Tenant Architecture

### Hierarchy Structure

```
MSP (Master Service Provider)
└── Company (MSP's Client/Partner)
    └── Client (End User Business)
        └── Resources (Assessments, Assets, etc.)
```

### Multi-Tenant Fields Explained

| Field | Purpose | Example |
|-------|---------|---------|
| `msp_id` | Top-level MSP/MSSP identifier | Main MSP organization |
| `company_id` | MSP's client company | Company using the platform |
| `client_id` | End-user business | Company's client/customer |

### Data Isolation Example

```sql
-- Assessment events belong to specific clients
CREATE TABLE assessment_events (
    id CHAR(36) PRIMARY KEY,
    template_id CHAR(36) NOT NULL,

    -- Multi-tenant hierarchy
    msp_id CHAR(36) NULL,           -- Which MSP owns this
    company_id CHAR(36) NOT NULL,   -- Which company manages this
    client_id CHAR(36) NOT NULL,    -- Which client this is for

    -- Assessment data
    name VARCHAR(255) NOT NULL,
    status ENUM('draft', 'in_progress', 'completed', 'archived') DEFAULT 'draft',
    completed_at TIMESTAMP NULL,

    -- Standard fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    is_archived BOOLEAN DEFAULT FALSE,
    archived_at TIMESTAMP NULL,

    -- Indexes for multi-tenant queries
    INDEX idx_msp_company_client (msp_id, company_id, client_id),
    INDEX idx_company_client (company_id, client_id),
    INDEX idx_client (client_id),
    INDEX idx_status (status),

    FOREIGN KEY (msp_id) REFERENCES companies(id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (template_id) REFERENCES assessment_templates(id)
);
```

### Multi-Tenant Query Patterns

```sql
-- MSP viewing all their companies' data
SELECT * FROM assessment_events
WHERE msp_id = '123e4567-e89b-12d3-a456-426614174000';

-- Company viewing all their clients' assessments
SELECT * FROM assessment_events
WHERE company_id = '123e4567-e89b-12d3-a456-426614174001';

-- Client viewing only their assessments
SELECT * FROM assessment_events
WHERE client_id = '123e4567-e89b-12d3-a456-426614174002';
```

---

## Reserved Words to AVOID

### 🚫 CRITICAL: Common Reserved Words

**NEVER use these as table or column names!**

#### High-Risk Reserved Words

| ❌ Reserved Word | ✅ Safe Alternative | Usage Context |
|-----------------|-------------------|---------------|
| `order` | `sort_order`, `display_order`, `sequence_order` | Sorting/ordering |
| `group` | `user_group`, `item_group`, `group_name` | Grouping data |
| `user` | `users`, `user_account`, `system_user` | User tables |
| `key` | `api_key`, `lookup_key`, `unique_key` | Keys/identifiers |
| `value` | `setting_value`, `item_value`, `config_value` | Value storage |
| `index` | `sort_index`, `item_index`, `position_index` | Index positions |
| `date` | `created_date`, `due_date`, `start_date` | Date fields |
| `time` | `start_time`, `end_time`, `created_time` | Time fields |
| `timestamp` | `created_at`, `updated_at` | Timestamp fields |
| `table` | `data_table`, `lookup_table` | Table references |

#### SQL Command Reserved Words

| ❌ Reserved Word | ✅ Safe Alternative |
|-----------------|-------------------|
| `select` | `selected_items`, `user_selection` |
| `from` | `source_from`, `range_from` |
| `where` | `filter_where`, `condition_where` |
| `insert` | `insert_date`, `batch_insert` |
| `update` | `last_update`, `update_count` |
| `delete` | `deleted_at`, `delete_reason` |
| `create` | `created_at`, `create_reason` |
| `drop` | `drop_date`, `item_dropped` |
| `alter` | `alter_date`, `modification_log` |
| `grant` | `permission_grant`, `access_grant` |

### Examples: Bad vs Good

```sql
-- ❌ BAD - Uses reserved words
CREATE TABLE order (
    key VARCHAR(255),
    value TEXT,
    date TIMESTAMP,
    user INT,
    group VARCHAR(100),
    index INT
);

-- ✅ GOOD - Descriptive, non-reserved names
CREATE TABLE purchase_orders (
    id CHAR(36) PRIMARY KEY,
    order_key VARCHAR(255),
    order_value DECIMAL(10,2),
    order_date TIMESTAMP,
    user_id CHAR(36),
    user_group_name VARCHAR(100),
    sort_index INT
);
```

### Fixing Existing Tables with Reserved Words

```php
// Laravel Migration to fix reserved words
public function up()
{
    Schema::table('existing_table', function (Blueprint $table) {
        // Rename reserved word columns
        $table->renameColumn('order', 'sort_order');
        $table->renameColumn('group', 'user_group');
        $table->renameColumn('key', 'lookup_key');
        $table->renameColumn('value', 'setting_value');
    });
}

// Update Model accordingly
protected $fillable = [
    'sort_order',     // was: 'order'
    'user_group',     // was: 'group'
    'lookup_key',     // was: 'key'
    'setting_value',  // was: 'value'
];
```

---

## Naming Conventions

### Table Names

```
✅ GOOD Examples:
- users
- companies
- clients
- assessment_events
- assessment_templates
- assessment_template_questions
- client_contacts
- user_permissions

Rules:
- snake_case (lowercase with underscores)
- Plural form
- Descriptive and clear
- No reserved words
```

### Column Names

```
✅ GOOD Examples:
- id
- name
- company_id
- created_at
- is_active
- sort_order
- email_address

Rules:
- snake_case (lowercase with underscores)
- Singular form
- Foreign keys: {table}_id
- Booleans: is_{condition}
- Timestamps: {action}_at
```

### Index Names

```sql
-- Pattern: idx_{column(s)}
INDEX idx_company_id (company_id)
INDEX idx_created_at (created_at)
INDEX idx_company_client (company_id, client_id)
INDEX idx_status_archived (status, is_archived)
```

### Foreign Key Names

```sql
-- Pattern: fk_{table}_{column}
CONSTRAINT fk_assessments_company_id
    FOREIGN KEY (company_id) REFERENCES companies(id)

CONSTRAINT fk_assessments_client_id
    FOREIGN KEY (client_id) REFERENCES clients(id)
```

---

## Indexes & Performance

### Required Indexes

```sql
-- ALWAYS index these fields:
INDEX idx_created_at (created_at)
INDEX idx_updated_at (updated_at)
INDEX idx_deleted_at (deleted_at)
INDEX idx_status (status)

-- Multi-tenant queries (CRITICAL):
INDEX idx_company_id (company_id)
INDEX idx_client_id (client_id)
INDEX idx_msp_id (msp_id)
INDEX idx_company_client (company_id, client_id)
INDEX idx_msp_company_client (msp_id, company_id, client_id)

-- Foreign keys (MANDATORY):
INDEX idx_fk_{column} ({column}) -- For each foreign key
```

### Composite Indexes

```sql
-- ✅ GOOD - Matches common query patterns
INDEX idx_company_status (company_id, status)
INDEX idx_client_date (client_id, created_at)
INDEX idx_msp_company_active (msp_id, company_id, is_archived)

-- Query that benefits:
SELECT * FROM assessments
WHERE company_id = ? AND status = 'active'
ORDER BY created_at DESC;
```

---

## Migrations & Seeders

### Laravel Migration Template

```php
<?php
// File: database/migrations/2025_01_15_100000_create_assessments_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('assessment_events', function (Blueprint $table) {
            // Primary Key
            $table->uuid('id')->primary();

            // Foreign Keys
            $table->uuid('template_id');
            $table->uuid('company_id');
            $table->uuid('client_id');
            $table->uuid('msp_id')->nullable();

            // Assessment Fields
            $table->string('name');
            $table->text('description')->nullable();
            $table->enum('status', [
                'draft',
                'in_progress',
                'completed',
                'archived'
            ])->default('draft');
            $table->timestamp('completed_at')->nullable();

            // Standard Timestamps
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();
            $table->softDeletes();

            // Archival Fields
            $table->boolean('is_archived')->default(false);
            $table->timestamp('archived_at')->nullable();
            $table->uuid('archived_by')->nullable();
            $table->text('archived_reason')->nullable();

            // Audit Trail
            $table->uuid('created_by')->nullable();
            $table->uuid('updated_by')->nullable();

            // Metadata
            $table->text('notes')->nullable();
            $table->json('metadata')->nullable();

            // Indexes
            $table->index('company_id');
            $table->index('client_id');
            $table->index('template_id');
            $table->index('status');
            $table->index('created_at');
            $table->index(['company_id', 'client_id'], 'idx_company_client');
            $table->index(['msp_id', 'company_id'], 'idx_msp_company');
            $table->index('is_archived');

            // Foreign Keys
            $table->foreign('template_id')
                ->references('id')
                ->on('assessment_templates')
                ->onDelete('cascade');

            $table->foreign('company_id')
                ->references('id')
                ->on('companies')
                ->onDelete('cascade');

            $table->foreign('client_id')
                ->references('id')
                ->on('clients')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('assessment_events');
    }
};
```

---

## Laravel Model Standards

### Complete Model Example

```php
<?php
// File: app/Models/Assessment/AssessmentEvent.php

namespace App\Models\Assessment;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class AssessmentEvent extends Model
{
    use SoftDeletes, HasUuids;

    // Table name (if different from convention)
    protected $table = 'assessment_events';

    // MANDATORY: Define fillable fields
    protected $fillable = [
        'template_id',
        'company_id',
        'client_id',
        'msp_id',
        'name',
        'description',
        'status',
        'completed_at',
        'is_archived',
        'archived_reason',
        'notes',
        'metadata',
    ];

    // MANDATORY: Define casts for special data types
    protected $casts = [
        'id' => 'string',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
        'completed_at' => 'datetime',
        'archived_at' => 'datetime',
        'is_archived' => 'boolean',
        'metadata' => 'array',
    ];

    // RECOMMENDED: Define constants for status values
    public const STATUS_DRAFT = 'draft';
    public const STATUS_IN_PROGRESS = 'in_progress';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_ARCHIVED = 'archived';

    // MANDATORY: Implement standard scopes
    public function scopeActive($query)
    {
        return $query->where('status', '!=', self::STATUS_ARCHIVED);
    }

    public function scopeNotArchived($query)
    {
        return $query->where('is_archived', false);
    }

    public function scopeForCompany($query, string $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    public function scopeForClient($query, string $clientId)
    {
        return $query->where('client_id', $clientId);
    }

    // MANDATORY: Implement archival methods
    public function archive(?string $userId = null, ?string $reason = null): bool
    {
        $this->is_archived = true;
        $this->archived_at = now();
        $this->archived_by = $userId;
        $this->archived_reason = $reason;

        return $this->save();
    }

    public function unarchive(): bool
    {
        $this->is_archived = false;
        $this->archived_at = null;
        $this->archived_by = null;
        $this->archived_reason = null;

        return $this->save();
    }

    // Relationships
    public function template()
    {
        return $this->belongsTo(AssessmentTemplate::class, 'template_id');
    }

    public function company()
    {
        return $this->belongsTo(Company::class, 'company_id');
    }

    public function client()
    {
        return $this->belongsTo(Client::class, 'client_id');
    }
}
```

---

## Related Standards

- [PHP Standards](./03-php-standards.md)
- [Safety Rules](./07-safety-rules.md)
- [Performance Standards](./12-performance-standards.md)

---

**Next:** [Logging Standards →](./06-logging-standards.md)

**Last Updated:** January 2025
