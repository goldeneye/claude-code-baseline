# Project Structure & File Conventions

**Laravel Multi-Tenant Assessment Platform**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- Laravel 10+ with API versioning (V3)
- Multi-tenant architecture (MSP → Company → Client)
- Auth0 authentication integration
- Role-based permission system
- Standard Laravel conventions + ComplianceScorecard extensions

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Directory Structure](#directory-structure)
3. [File Naming Conventions](#file-naming-conventions)
4. [File Header Convention](#file-header-convention)
5. [Namespace Organization](#namespace-organization)
6. [Multi-Tenant Architecture](#multi-tenant-architecture)
7. [Quick Navigation Guide](#quick-navigation-guide)

---

## Project Overview

### Technology Stack

- **Framework:** Laravel 10.x
- **PHP Version:** 8.1+
- **Database:** MySQL 8.0
- **Authentication:** Auth0
- **Frontend:** React (separate repository)
- **API:** RESTful API v3
- **Architecture:** Multi-tenant SaaS

### Core Features

- Multi-tenant assessment management
- MSP/MSSP client hierarchy
- Role-based permissions
- Auth0 SSO integration
- Assessment templates and events
- Compliance scoring and reporting

---

## Directory Structure

### Complete Project Structure

```
app/
├── Console/
│   └── Commands/                 # Artisan custom commands
│       ├── SyncAuth0Users.php
│       ├── GenerateReports.php
│       └── CleanupArchivedData.php
│
├── Exceptions/
│   └── Handler.php              # Global exception handling
│
├── Http/
│   ├── Controllers/             # HTTP controllers
│   │   ├── Api/
│   │   │   └── V3/             # API version 3 controllers
│   │   │       ├── AssessmentController.php
│   │   │       ├── AssessmentEventController.php
│   │   │       ├── AssessmentTemplateController.php
│   │   │       ├── ClientController.php
│   │   │       ├── CompanyController.php
│   │   │       └── UserController.php
│   │   └── Web/                # Web controllers (if applicable)
│   │
│   ├── Middleware/              # HTTP middleware
│   │   ├── Auth0Middleware.php
│   │   ├── CheckMSPPermission.php
│   │   ├── CheckCompanyPermission.php
│   │   └── ApiRateLimiter.php
│   │
│   ├── Requests/               # Form request validation
│   │   ├── Assessment/
│   │   │   ├── StoreAssessmentRequest.php
│   │   │   └── UpdateAssessmentRequest.php
│   │   └── Client/
│   │       ├── StoreClientRequest.php
│   │       └── UpdateClientRequest.php
│   │
│   └── Resources/              # API resources (transformers)
│       ├── AssessmentResource.php
│       ├── AssessmentEventResource.php
│       └── ClientResource.php
│
├── Jobs/                       # Queue jobs
│   ├── ProcessAssessmentReport.php
│   ├── SendAssessmentNotification.php
│   └── SyncClientData.php
│
├── Models/                     # Eloquent models
│   ├── Assessment/
│   │   ├── AssessmentEvent.php
│   │   ├── AssessmentTemplate.php
│   │   ├── AssessmentTemplateQuestion.php
│   │   ├── AssessmentEventAnswer.php
│   │   └── AssessmentScore.php
│   │
│   ├── Client/
│   │   ├── Client.php
│   │   ├── ClientContact.php
│   │   └── ClientAsset.php
│   │
│   ├── Company/
│   │   ├── Company.php
│   │   └── CompanySettings.php
│   │
│   └── User/
│       ├── User.php
│       ├── Role.php
│       ├── Permission.php
│       └── UserPermission.php
│
├── Policies/                   # Authorization policies
│   ├── AssessmentPolicy.php
│   ├── ClientPolicy.php
│   └── CompanyPolicy.php
│
├── Providers/
│   ├── AppServiceProvider.php
│   ├── AuthServiceProvider.php
│   └── RouteServiceProvider.php
│
└── Services/                   # Business logic services
    ├── Auth/
    │   ├── Auth0Service.php
    │   └── PermissionService.php
    │
    ├── Assessment/
    │   ├── AssessmentScoringService.php
    │   ├── AssessmentTemplateService.php
    │   └── AssessmentReportService.php
    │
    └── Integration/
        ├── ExternalApiService.php
        └── WebhookService.php

bootstrap/
├── app.php
└── cache/

config/
├── app.php
├── auth.php
├── database.php
├── services.php                # Auth0 and other service configs
└── ...

database/
├── factories/
│   ├── AssessmentFactory.php
│   └── ClientFactory.php
│
├── migrations/
│   ├── 2024_01_01_000000_create_companies_table.php
│   ├── 2024_01_02_000000_create_clients_table.php
│   ├── 2024_01_03_000000_create_assessment_templates_table.php
│   └── ...
│
└── seeders/
    ├── DatabaseSeeder.php
    ├── CompanySeeder.php
    ├── RolePermissionSeeder.php
    └── AssessmentTemplateSeeder.php

public/
├── index.php
└── ...

resources/
├── views/                      # Blade templates (if used)
└── lang/                       # Localization files

routes/
├── api.php                     # API routes (V3)
├── web.php                     # Web routes
└── channels.php                # Broadcasting channels

storage/
├── app/
│   ├── public/                # Publicly accessible files
│   └── private/               # Private uploads
├── framework/
└── logs/                      # Application logs

tests/
├── Feature/                   # Feature tests
│   ├── Assessment/
│   │   ├── AssessmentCreationTest.php
│   │   └── AssessmentScoringTest.php
│   └── Auth/
│       └── Auth0AuthenticationTest.php
│
└── Unit/                      # Unit tests
    ├── Models/
    │   └── AssessmentTest.php
    └── Services/
        └── AssessmentScoringServiceTest.php

vendor/                        # Composer dependencies

.env                          # Environment configuration
.env.example                  # Environment template
composer.json                 # PHP dependencies
phpunit.xml                   # PHPUnit configuration
```

---

## File Naming Conventions

### General Rules

| Type | Convention | Example |
|------|------------|---------|
| **Classes** | PascalCase | `AssessmentController` |
| **Methods** | camelCase | `calculateScore()` |
| **Variables** | camelCase | `$userId` |
| **Database Columns** | snake_case | `company_id` |
| **Database Tables** | snake_case (plural) | `assessment_events` |
| **Constants** | UPPER_SNAKE_CASE | `STATUS_PUBLISHED` |
| **Config Keys** | snake_case | `auth0_domain` |
| **Routes** | kebab-case | `/api/v3/assessment-events` |
| **Files** | Match class names | `AssessmentController.php` |

### Specific Conventions

#### Controllers
```
Pattern: {Resource}Controller.php
Examples:
  - AssessmentController.php
  - AssessmentEventController.php
  - ClientController.php
```

#### Models
```
Pattern: {Entity}.php (singular)
Examples:
  - AssessmentEvent.php
  - AssessmentTemplate.php
  - Client.php
```

#### Migrations
```
Pattern: {YYYY_MM_DD_HHMMSS}_create_{table}_table.php
Examples:
  - 2024_01_15_100000_create_assessment_events_table.php
  - 2024_01_15_101000_add_msp_id_to_companies_table.php
```

#### Services
```
Pattern: {Purpose}Service.php
Examples:
  - AssessmentScoringService.php
  - Auth0Service.php
  - PermissionService.php
```

#### Jobs
```
Pattern: {Action}{Resource}.php
Examples:
  - ProcessAssessmentReport.php
  - SendAssessmentNotification.php
  - SyncClientData.php
```

---

## File Header Convention

### Mandatory File Header

**Every PHP file MUST start with a file path comment and copyright notice:**

```php
<?php
// File: app/Http/Middleware/ApiRateLimiter.php

/*
 * © 2025 ComplianceRisk.io Inc. doing business as Compliance Scorecard. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains the property of ComplianceRisk.io Inc. and its suppliers, if any.
 * The intellectual and technical concepts contained herein are proprietary to ComplianceRisk.io Inc. and its suppliers and may be
 * covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
 *
 * Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
 * from ComplianceRisk.io Inc.
 *
 * Compliance Scorecard is a leading SaaS platform specializing in compliance and risk management solutions for Managed Service Providers (MSPs),
 * Managed Security Service Providers (MSSPs), and virtual/fractional Chief Information Security Officers (vCISOs). Our cloud-hosted application
 * empowers small and medium-sized businesses to effectively understand and manage their compliance posture. Key features include compliance
 * monitoring, risk assessment tools, policy management, assessment management, full asset governance, integration capabilities, and detailed
 * dashboards and reporting. The platform aligns with SOC 2 Trust Service Criteria to ensure security, availability, processing integrity,
 * confidentiality, and privacy.
 *
 * For the full system description, please visit: https://SystemDescription.compliancescorecard.com
 */

namespace App\Http\Middleware;

use Illuminate\Http\Request;

class ApiRateLimiter
{
    // Class implementation...
}
```

### File Header Template

```php
<?php
// File: {relative_path_from_project_root}

/*
 * © {year} ComplianceRisk.io Inc. doing business as Compliance Scorecard. All rights reserved.
 * [Full copyright notice...]
 */

namespace {Namespace};

// Imports here...

/**
 * Class {ClassName}
 *
 * {Brief description}
 *
 * @package {Package}
 */
class ClassName
{
    // Implementation
}
```

---

## Namespace Organization

### Namespace Structure

```php
// Controllers
namespace App\Http\Controllers\Api\V3;

// Models - Organized by domain
namespace App\Models\Assessment;
namespace App\Models\Client;
namespace App\Models\Company;
namespace App\Models\User;

// Services - Organized by purpose
namespace App\Services\Auth;
namespace App\Services\Assessment;
namespace App\Services\Integration;

// Middleware
namespace App\Http\Middleware;

// Jobs
namespace App\Jobs;

// Policies
namespace App\Policies;

// Requests
namespace App\Http\Requests\Assessment;
namespace App\Http\Requests\Client;

// Resources
namespace App\Http\Resources;
```

### Import Guidelines

```php
<?php

namespace App\Http\Controllers\Api\V3;

// Laravel framework imports
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

// Application imports
use App\Models\Assessment\AssessmentEvent;
use App\Services\Assessment\AssessmentScoringService;
use App\Http\Requests\Assessment\StoreAssessmentRequest;
use App\Http\Resources\AssessmentResource;

class AssessmentController extends Controller
{
    // Implementation
}
```

**Import Order:**
1. Laravel framework classes
2. Third-party packages
3. Application classes (Models, Services, etc.)

---

## Multi-Tenant Architecture

### Hierarchy Structure

```
MSP (Top Level Company)
└── Company (MSP's Client)
    └── Client (End User/Business)
```

### Model Structure Example

```php
// MSP can have multiple companies
class Company extends Model
{
    public function msp(): BelongsTo
    {
        return $this->belongsTo(Company::class, 'msp_id');
    }

    public function clients(): HasMany
    {
        return $this->hasMany(Client::class, 'company_id');
    }
}

// Client belongs to a company
class Client extends Model
{
    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class, 'company_id');
    }

    public function assessments(): HasMany
    {
        return $this->hasMany(AssessmentEvent::class, 'client_id');
    }
}

// Assessment belongs to client
class AssessmentEvent extends Model
{
    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class, 'client_id');
    }

    // Helper to get company through client
    public function company(): BelongsTo
    {
        return $this->client->company();
    }
}
```

### Multi-Tenant Scopes

```php
// Global scope for multi-tenant isolation
class TenantScope implements Scope
{
    public function apply(Builder $builder, Model $model)
    {
        if (auth()->check()) {
            $user = auth()->user();

            // Super admin sees everything
            if ($user->isSuperAdmin()) {
                return;
            }

            // MSP admin sees their companies
            if ($user->isMspAdmin()) {
                $builder->where('msp_id', $user->msp_id);
                return;
            }

            // Company user sees their company only
            $builder->where('company_id', $user->company_id);
        }
    }
}
```

---

## Quick Navigation Guide

### Finding Files by Purpose

#### Working with Assessments?
```
Controllers: app/Http/Controllers/Api/V3/AssessmentController.php
Models: app/Models/Assessment/AssessmentEvent.php
Services: app/Services/Assessment/AssessmentScoringService.php
Tests: tests/Feature/Assessment/AssessmentCreationTest.php
```

#### Working with Authentication?
```
Middleware: app/Http/Middleware/Auth0Middleware.php
Services: app/Services/Auth/Auth0Service.php
Config: config/services.php (auth0 section)
```

#### Working with Permissions?
```
Models: app/Models/User/Permission.php
Policies: app/Policies/AssessmentPolicy.php
Services: app/Services/Auth/PermissionService.php
Middleware: app/Http/Middleware/CheckMSPPermission.php
```

#### Working with Database?
```
Migrations: database/migrations/
Seeders: database/seeders/
Factories: database/factories/
Models: app/Models/
```

#### Working with API?
```
Routes: routes/api.php
Controllers: app/Http/Controllers/Api/V3/
Resources: app/Http/Resources/
Requests: app/Http/Requests/
```

### Common File Patterns

```bash
# Find a model
app/Models/{Domain}/{ModelName}.php

# Find a controller
app/Http/Controllers/Api/V3/{Resource}Controller.php

# Find a service
app/Services/{Domain}/{Purpose}Service.php

# Find a migration
database/migrations/*_{action}_{table}_table.php

# Find a test
tests/Feature/{Domain}/{Test}Test.php
tests/Unit/{Type}/{Test}Test.php
```

---

## Directory Best Practices

### DO:
- ✅ Group models by business domain
- ✅ Keep services organized by functionality
- ✅ Use meaningful directory names
- ✅ Follow Laravel conventions
- ✅ Maintain clear separation of concerns

### DON'T:
- ❌ Mix different concerns in same directory
- ❌ Create deeply nested structures (max 3-4 levels)
- ❌ Use generic names like "Helpers" or "Utils"
- ❌ Store business logic in controllers
- ❌ Put everything in root namespace

---

## Related Standards

- [PHP Standards](./03-php-standards.md) - PHP coding conventions
- [Database Standards](./05-database-standards.md) - Multi-tenant database structure
- [Quality Standards](./08-quality-standards.md) - Code organization requirements

---

**Next:** [PHP Standards →](./03-php-standards.md)

**Last Updated:** January 2025
