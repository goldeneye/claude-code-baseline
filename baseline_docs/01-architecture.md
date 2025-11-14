---
title: {{PROJECT_NAME}} - System Architecture
version: 1.0
last_updated: 2025-11-02
author: GoldenEye Engineering (@goldeneye)
---

# {{PROJECT_NAME}} — System Architecture

## 1. Overview

{{PROJECT_NAME}} is a multi-tenant SaaS platform built on modern microservice principles. This document details the architectural patterns, data flows, and component interactions that power the system.

---

## 2. High-Level Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                         USER LAYER                             │
│  MSP Users │ Client Users │ Auditors │ API Consumers          │
└──────────────────────┬────────────────────────────────────────┘
                       │
┌──────────────────────▼────────────────────────────────────────┐
│                   AUTHENTICATION LAYER                         │
│  Auth0 SSO (OIDC/JWT) │ API Key Management │ IP Whitelisting  │
└──────────────────────┬────────────────────────────────────────┘
                       │
┌──────────────────────▼────────────────────────────────────────┐
│                   FRONTEND LAYER                               │
│  React SPA │ Material-UI │ Redux State │ Real-time Updates    │
└──────────────────────┬────────────────────────────────────────┘
                       │
┌──────────────────────▼────────────────────────────────────────┐
│                   API GATEWAY LAYER                            │
│  Laravel Routes │ CORS │ Rate Limiting │ Request Validation   │
└──────────────────────┬────────────────────────────────────────┘
                       │
┌──────────────────────▼────────────────────────────────────────┐
│                  APPLICATION LAYER                             │
│  Controllers │ Services │ Repositories │ Event Handlers       │
└─────┬──────────────┬──────────────┬──────────────┬────────────┘
      │              │              │              │
┌─────▼────┐  ┌─────▼────┐  ┌─────▼────┐  ┌─────▼────────────┐
│  Queue   │  │ Scanner  │  │   AI     │  │  External APIs   │
│  Jobs    │  │ Services │  │ Services │  │  (CS, PSA, etc.) │
└─────┬────┘  └─────┬────┘  └─────┬────┘  └──────────────────┘
      │              │              │
┌─────▼──────────────▼──────────────▼──────────────────────────┐
│                    DATA LAYER                                  │
│  MySQL 8 │ Redis Cache │ Encrypted Storage │ Audit Logs       │
└────────────────────────────────────────────────────────────────┘
```

---

## 3. Core Components

### 3.1 Frontend Layer (React SPA)

**Technology**: React 18+ with Redux Toolkit
**Location**: `{{REPO_PATH}}/frontend-app/`

| Component | Responsibility |
|-----------|---------------|
| **Pages** | Top-level route components (Dashboard, Assessments, etc.) |
| **Features** | Redux slices with async thunks (assessments, permissions, etc.) |
| **Components** | Reusable UI elements (MDBox, Cards, Tables) |
| **Layouts** | Layout containers (DashboardLayout, AuthLayout) |
| **Routes** | Route configuration with permission guards |
| **Theme** | Material-UI theme customization |

**Key Patterns**:
- Redux Toolkit for state management
- Material-UI for consistent UI components
- Axios for HTTP requests with interceptors
- Real-time polling for async operations

### 3.2 API Gateway Layer (Laravel)

**Technology**: Laravel 11 (PHP 8.2+)
**Location**: `{{REPO_PATH}}/app/Http/`

**Middleware Stack**:
```
Request
  ├─> CORS Middleware (localhost:3000 in dev, {{DOMAIN}} in prod)
  ├─> Authentication (Auth0 JWT or API Key)
  ├─> Rate Limiting (per user/API key)
  ├─> Authorization (Permission checks)
  ├─> Request Validation
  └─> Controller Action
```

**Route Groups**:
- `/api/v3/*` - Versioned REST API
- `/api/private/v1/*` - Private API for system-to-system integration
- `/super-admin/*` - Admin-only routes with elevated permissions

### 3.3 Application Layer

#### Controllers
**Pattern**: Thin controllers, fat services
**Location**: `app/Http/Controllers/Api/V3/`

```php
PermissionsController   // Role-permission matrix management
AssessmentController    // Assessment CRUD operations
ClientController        // Client management
ScanController          // Security scan orchestration
ApiKeyController        // API key lifecycle management
```

#### Services
**Pattern**: Business logic encapsulation
**Location**: `app/Services/`

```php
GradingService          // Letter-grade calculation (A-F)
ScanGradeService        // Scan-specific grading logic
WhoisService            // WHOIS data processing
AIAnalyzerService       // AI-driven client segmentation
FrameworkScoreService   // Compliance framework coverage
```

#### Repositories
**Pattern**: Data access abstraction
**Location**: `app/Repositories/`

- Eloquent ORM with query scoping
- Multi-tenant filtering (`msp_id`)
- Soft deletes for audit trail
- Encrypted field handling via traits

### 3.4 Queue System

**Technology**: Redis + Laravel Horizon
**Location**: `app/Jobs/`

**Job Hierarchy**:
```
MasterScanJob (Orchestrator)
  ├─> RunDnsScan (Python integration)
  ├─> RunWhoisScan (Python integration)
  ├─> RunWebPrivacyScan (Python integration)
  ├─> RunNmapScan (Port scanning)
  └─> RunCheckJob (70+ compliance checks)
        └─> Individual check classes (DNS, Email, Web, etc.)
```

**Queue Configuration**:
- **Driver**: Redis
- **Timeout**: 60-300s depending on job
- **Retries**: 1-3 attempts with exponential backoff
- **Monitoring**: Laravel Horizon dashboard

### 3.5 Scanner Services

**Technology**: Python 3.x with specialized libraries
**Location**: `{{REPO_PATH}}/scanners/`

| Scanner | Purpose | Libraries |
|---------|---------|-----------|
| `dns_scanner.py` | DNS records, email security (SPF/DMARC/DKIM) | checkdmarc, dnspython |
| `whois_scanner.py` | Domain registration, expiration | python-whois |
| `web_privacy_scanner.py` | Privacy policy detection, web headers | requests, beautifulsoup4 |

**Integration Pattern**:
```php
// Laravel job executes Python script
$process = new Process([$pythonPath, $scriptPath, $domain]);
$process->run();
$output = json_decode($process->getOutput(), true);

// Store raw JSON + structured data
DnsBaseResult::create(['raw_json' => $output]);
DnsCheckDetail::create(['parsed_data' => $structured]);
```

### 3.6 AI Integration Layer

**Technology**: Multi-provider support (OpenAI, Anthropic, GPT-OSS)
**Location**: `app/Services/Automation/`

**Architecture**:
```
AIServiceFactory
  ├─> OpenAIService (paid, BYO key)
  ├─> AnthropicService (paid, BYO key)
  └─> GPTOSSService (free, default)
```

**Flow**:
1. MSP configures AI provider in `msp_ai_settings`
2. Factory routes request to appropriate provider
3. API key retrieved (encrypted) from database
4. AI analysis executed (client segmentation, risk scoring)
5. Results stored encrypted in `segmentation_results`

---

## 4. Data Flow Diagrams

### 4.1 User Authentication Flow

```
User                    Frontend                Auth0                 Backend
  │                        │                       │                      │
  ├──Login Request────────>│                       │                      │
  │                        ├──Redirect to Auth0──>│                      │
  │                        │                       │                      │
  │<──Auth0 Login UI───────┤                       │                      │
  ├──Credentials──────────────────────────────────>│                      │
  │                        │                       │                      │
  │                        │<──ID Token + JWT──────┤                      │
  │                        │                       │                      │
  │                        ├──API Request + JWT──────────────────────────>│
  │                        │                       │                      │
  │                        │                       │<──Validate JWT (JWKS)─┤
  │                        │                       │                      │
  │                        │<──User Data + Session─────────────────────────┤
  │<──Dashboard View───────┤                       │                      │
```

### 4.2 Compliance Scan Flow

```
User Request
    │
    ├─> ScanController::submitDomain()
    │     ├─> Validate domain
    │     ├─> Create ScanResult record
    │     └─> Dispatch MasterScanJob
    │
    ├─> MasterScanJob::handle()
    │     ├─> Update scan status: "processing"
    │     ├─> Dispatch RunDnsScan (sync)
    │     │     └─> Execute dns_scanner.py
    │     │           └─> Store results in dns_base_results
    │     │
    │     ├─> Dispatch RunWhoisScan (async)
    │     │     └─> Execute whois_scanner.py
    │     │
    │     ├─> Dispatch 70+ RunCheckJob instances (sync)
    │     │     └─> Each check:
    │     │           ├─> Retrieve scanner data (DNS/WHOIS/Web)
    │     │           ├─> Apply compliance logic
    │     │           └─> Store CheckResult (pass/fail/warn)
    │     │
    │     ├─> Dispatch RunWebPrivacyScan (sync)
    │     │     └─> Execute web_privacy_scanner.py
    │     │
    │     └─> ScanGradeService::runForScan()
    │           ├─> Calculate category grades
    │           ├─> Calculate overall grade (A-F)
    │           └─> Update scan status: "completed"
    │
    └─> Frontend polls /scan/{id}/progress
          └─> Redirects to results when complete
```

### 4.3 AI Client Segmentation Flow

```
MSP User                  Backend                  AI Provider
    │                        │                          │
    ├──Upload CSV/API────────>│                          │
    │                        ├──Parse clients            │
    │                        ├──Store in client_imports  │
    │                        │                          │
    ├──Request Analysis─────>│                          │
    │                        ├──Queue AI job            │
    │                        │                          │
    │                        ├──Retrieve encrypted key  │
    │                        ├──Build prompt────────────>│
    │                        │                          │
    │                        │<──Segmentation JSON──────┤
    │                        │                          │
    │                        ├──Validate schema         │
    │                        ├──Encrypt + store results │
    │                        └──Update audit_logs       │
    │                        │                          │
    │<──Results Dashboard────┤                          │
```

---

## 5. Database Architecture

### 5.1 Multi-Tenant Isolation

**Pattern**: Shared database, filtered by `msp_id`

```sql
-- All queries auto-filtered by tenant
SELECT * FROM clients WHERE msp_id = {{CURRENT_MSP_ID}};

-- Implemented via Eloquent global scopes
class Client extends Model {
    protected static function booted() {
        static::addGlobalScope('msp', function (Builder $builder) {
            $builder->where('msp_id', auth()->user()->msp_id);
        });
    }
}
```

### 5.2 Table Groups

| Group | Tables | Purpose |
|-------|--------|---------|
| **Authentication** | users, roles, permissions, role_permission | RBAC system |
| **Multi-Tenant** | companies (MSPs), clients | Organizational hierarchy |
| **Assessments** | assessment_templates, assessment_events, assessment_template_questions | Compliance assessments |
| **Scanning** | scan_results, check_results, compliance_checks, compliance_controls | Security scanning |
| **AI/Segmentation** | client_imports, segmentation_results, msp_ai_settings | AI-driven analysis |
| **API Management** | api_keys, automation_api_keys, automation_api_credentials | API lifecycle |
| **Audit** | audit_logs, activity_logs | Compliance trail |

### 5.3 Encryption Strategy

**Encrypted Fields** (via Laravel `Crypt`):
- User PII: `email`, `name`
- Client data: `client_name`, `domain`, `contact_email`
- API keys: `api_key`, `secret_hash`, `access_token`, `refresh_token`
- AI data: `reason`, `suggested_action`

**Tablespace Encryption**: MySQL InnoDB encryption-at-rest

---

## 6. Security Architecture

### 6.1 Authentication Methods

| Method | Use Case | Token Type |
|--------|----------|-----------|
| **Auth0 SSO** | User login (web) | ID Token (JWT) |
| **API Keys** | Service-to-service | JWT Bearer |
| **Session** | Internal Laravel routes | Encrypted cookie |

### 6.2 Authorization Model

**Hierarchical Permission Check**:
```
Super Admin → Has all permissions
     │
MSP Admin → Has company-wide permissions
     │
Company User → Has role-based permissions
     │
Client User → Has client-scoped permissions
```

**Permission Naming Convention**:
```
{resource}.{action}
Examples:
  - clients.create
  - assessments.view
  - mspglobal.manage
```

### 6.3 Rate Limiting

| Layer | Limit | Window |
|-------|-------|--------|
| **API (authenticated)** | 60 requests | per minute |
| **API (public)** | 10 requests | per minute |
| **Per-API Key** | Configurable | per minute + daily cap |

---

## 7. Integration Points

### 7.1 External Services

| Service | Purpose | Authentication |
|---------|---------|---------------|
| **Auth0** | User authentication | OIDC/OAuth2 |
| **External Client API** | Client data sync | API Key (encrypted) |
| **PSA Systems** | Client import (via CS) | Via CS API |
| **AI Providers** | Analysis (OpenAI/Anthropic) | BYO API Key |
| **GPT-OSS** | Free AI inference | None (local) |

### 7.2 Webhook Architecture

```
Event Trigger → Event Dispatcher → Webhook Queue → External URL
                                          │
                                    Retry Logic (3x)
                                          │
                                   Delivery Confirmation
```

---

## 8. Performance Optimization

### 8.1 Caching Strategy

```php
// Grading scales cached for 60 minutes
Cache::remember('grading_scales_cache', 60, function () {
    return DB::table('grading_scales')->get();
});

// Scan results cached for 5 minutes
Cache::remember("scan_{$scanId}", 5, function () use ($scanId) {
    return ScanResult::with('results')->find($scanId);
});
```

### 8.2 Query Optimization

- **Eager Loading**: Prevent N+1 queries
- **Indexes**: All foreign keys + frequently queried fields
- **Pagination**: API responses default to 50 items per page
- **Query Scopes**: Reusable query filters

### 8.3 Queue Optimization

- **Job Batching**: Group related checks
- **Priority Queues**: High/normal/low priority
- **Horizon Monitoring**: Real-time queue metrics

---

## 9. Deployment Architecture

### 9.1 Container Structure (Docker)

```
services:
  app:              # PHP-FPM + Laravel
  nginx:            # Reverse proxy
  mysql:            # Database
  redis:            # Cache + queue
  horizon:          # Queue worker
  gpt-oss:          # Optional AI engine
```

### 9.2 Scaling Model

**Horizontal Scaling**:
- Multiple PHP-FPM containers behind load balancer
- Dedicated queue worker containers
- Redis cluster for distributed cache

**Vertical Scaling**:
- Managed RDS (MySQL) with read replicas
- ElastiCache (Redis) for high throughput

---

## 10. Future Enhancements

### Planned Architecture Improvements

- **Event Sourcing**: Full audit trail with event replay
- **CQRS**: Separate read/write models for performance
- **GraphQL API**: Alternative to REST for complex queries
- **WebSocket Support**: Real-time scan progress without polling
- **Kubernetes**: Container orchestration for cloud-native deployment
- **Multi-Region**: Geographic distribution for global MSPs

---

## See Also

- [Security Specification](02-security.md) - Detailed security architecture
- [Database Schema](06-database-schema.md) - Table structures and relationships
- [API Documentation](08-api-documentation.md) - Endpoint reference

---

**Last Updated**: 2025-11-02
**Document Version**: 1.0
**Status**: Production-Ready Baseline
