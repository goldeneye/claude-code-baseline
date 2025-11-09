---
title: {{PROJECT_NAME}} - API Documentation
version: 1.0
last_updated: 2025-11-02
author: {{USERNAME}} - aka GoldenEye Engineering
---

# {{PROJECT_NAME}} — API Documentation

## Purpose

This document defines the RESTful API architecture, authentication mechanisms, and endpoint specifications for {{PROJECT_NAME}}. It provides a framework-agnostic template for building secure, scalable, and well-documented APIs.

---

## API Overview

### API Identity

| Attribute | Value |
|-----------|-------|
| **API Base URL** | {{DOMAIN}}/api |
| **Current Version** | v3 |
| **Authentication** | JWT Bearer Tokens |
| **Response Format** | JSON |
| **Rate Limiting** | Configurable per API key |
| **Documentation** | {{DOMAIN}}/api-docs |

### API Versioning Strategy

Use URL path versioning for major changes:

```
/api/v1/*  - Legacy version (deprecated)
/api/v2/*  - Previous version (maintenance only)
/api/v3/*  - Current version (active development)
```

**Version Deprecation Policy**:
- **v3 (Current)**: Active development, full support
- **v2**: Security fixes only, 12-month support window
- **v1**: Deprecated, 6-month sunset period

---

## Authentication

### JWT Token Authentication

All API requests require JWT Bearer token authentication.

#### Token Structure

```
Authorization: Bearer <JWT_TOKEN>
```

**JWT Payload**:
```json
{
  "iss": "{{DOMAIN}}",
  "sub": "auth0|user-id",
  "aud": "{{PROJECT_NAME}}",
  "exp": 1699564800,
  "iat": 1699561200,
  "msp_id": 123,
  "role": "admin"
}
```

#### Obtaining JWT Tokens

**Option 1: SSO Authentication (Auth0/OIDC)**
```http
POST {{AUTH0_DOMAIN}}/oauth/token
Content-Type: application/json

{
  "grant_type": "client_credentials",
  "client_id": "{{CLIENT_ID}}",
  "client_secret": "{{CLIENT_SECRET}}",
  "audience": "{{DOMAIN}}/api"
}
```

**Option 2: API Key Generation**
```http
POST {{DOMAIN}}/api/v3/keys/generate
Authorization: Bearer <EXISTING_JWT>
Content-Type: application/json

{
  "name": "Production API Key",
  "rate_limit": 100,
  "daily_limit": 10000,
  "permissions": ["scans.read", "scans.write", "clients.read"],
  "ip_whitelist": ["203.0.113.0/24"]
}
```

**Response**:
```json
{
  "api_key": "ck_live_xxxxxxxxxxxxxxxxxxxx",
  "secret_key": "sk_live_xxxxxxxxxxxxxxxxxxxx",
  "jwt_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2026-11-02T12:00:00Z",
  "permissions": ["scans.read", "scans.write", "clients.read"]
}
```

⚠️ **Security Note**: `secret_key` is displayed only once. Store securely.

---

### API Key Management

#### List API Keys

```http
GET {{DOMAIN}}/api/v3/keys
Authorization: Bearer <JWT>
```

**Response**:
```json
{
  "data": [
    {
      "id": 1,
      "name": "Production API Key",
      "key": "ck_live_xxxxxxxxxxxxxxxxxxxx",
      "is_active": true,
      "rate_limit": 100,
      "daily_limit": 10000,
      "usage_count": 5432,
      "last_used_at": "2025-11-02T10:30:00Z",
      "expires_at": "2026-11-02T12:00:00Z"
    }
  ]
}
```

#### Regenerate API Key

```http
POST {{DOMAIN}}/api/v3/keys/{id}/regenerate
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "secret_key": "sk_live_xxxxxxxxxxxxxxxxxxxx"
}
```

#### Revoke API Key

```http
DELETE {{DOMAIN}}/api/v3/keys/{id}
Authorization: Bearer <JWT>
```

---

## Rate Limiting

### Rate Limit Headers

All API responses include rate limit information:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1699561260
X-RateLimit-Daily-Limit: 10000
X-RateLimit-Daily-Remaining: 9543
```

### Rate Limit Exceeded Response

```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json

{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit of 100 requests per minute exceeded",
    "retry_after": 45
  }
}
```

### Rate Limit Tiers

| Tier | Requests/Minute | Daily Limit | Cost |
|------|----------------|-------------|------|
| **Free** | 10 | 1,000 | Free |
| **Standard** | 60 | 10,000 | $29/month |
| **Plus** | 100 | 50,000 | $99/month |
| **Enterprise** | Custom | Custom | Contact Sales |

---

## API Endpoints

### 1. Authentication & Authorization

#### Get Current User

```http
GET {{DOMAIN}}/api/v3/auth/user
Authorization: Bearer <JWT>
```

**Response**:
```json
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "auth0_sub": "auth0|user-id",
  "role": "admin",
  "msp_id": 456,
  "permissions": ["clients.read", "clients.write", "scans.read"]
}
```

---

### 2. Client Management

#### List Clients

```http
GET {{DOMAIN}}/api/v3/clients
Authorization: Bearer <JWT>
```

**Query Parameters**:
- `page` - Page number (default: 1)
- `per_page` - Results per page (default: 20, max: 100)
- `status` - Filter by status: `active`, `inactive`, `onboarding`
- `industry` - Filter by industry
- `search` - Search by name or domain

**Response**:
```json
{
  "data": [
    {
      "id": 789,
      "msp_id": 456,
      "name": "Acme Corporation",
      "domain": "acme.com",
      "contact_email": "contact@acme.com",
      "industry": "Technology",
      "employee_count": 250,
      "status": "active",
      "created_at": "2025-01-15T10:30:00Z",
      "updated_at": "2025-11-02T08:15:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 145,
    "last_page": 8
  }
}
```

#### Get Client Details

```http
GET {{DOMAIN}}/api/v3/clients/{id}
Authorization: Bearer <JWT>
```

**Response**:
```json
{
  "id": 789,
  "msp_id": 456,
  "name": "Acme Corporation",
  "domain": "acme.com",
  "contact_email": "contact@acme.com",
  "contact_phone": "+1-555-0100",
  "industry": "Technology",
  "employee_count": 250,
  "status": "active",
  "feature_toggles": {
    "scans_enabled": true,
    "assessments_enabled": true,
    "ai_analysis": false
  },
  "created_at": "2025-01-15T10:30:00Z",
  "updated_at": "2025-11-02T08:15:00Z"
}
```

#### Create Client

```http
POST {{DOMAIN}}/api/v3/clients
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "name": "New Client Corp",
  "domain": "newclient.com",
  "contact_email": "info@newclient.com",
  "contact_phone": "+1-555-0200",
  "industry": "Healthcare",
  "employee_count": 150
}
```

**Response**:
```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": 790,
  "msp_id": 456,
  "name": "New Client Corp",
  "domain": "newclient.com",
  "status": "onboarding",
  "created_at": "2025-11-02T12:00:00Z"
}
```

#### Update Client

```http
PUT {{DOMAIN}}/api/v3/clients/{id}
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "name": "Updated Client Name",
  "contact_email": "newemail@client.com",
  "employee_count": 275
}
```

#### Delete Client

```http
DELETE {{DOMAIN}}/api/v3/clients/{id}
Authorization: Bearer <JWT>
```

---

### 3. Assessment Management

#### List Assessment Templates

```http
GET {{DOMAIN}}/api/v3/assessments/templates
Authorization: Bearer <JWT>
```

**Response**:
```json
{
  "data": [
    {
      "id": 1,
      "name": "CMMC Level 2 Assessment",
      "description": "Cybersecurity Maturity Model Certification Level 2",
      "version": "2.0",
      "framework": "CMMC",
      "is_active": true,
      "question_count": 110,
      "created_at": "2024-08-01T00:00:00Z"
    }
  ]
}
```

#### Create Assessment Event

```http
POST {{DOMAIN}}/api/v3/assessments/events
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "client_id": 789,
  "template_id": 1,
  "scheduled_start": "2025-11-15T09:00:00Z"
}
```

**Response**:
```http
HTTP/1.1 201 Created

{
  "id": 456,
  "event_code": "EZRYKMYZNWW4RK",
  "client_id": 789,
  "template_id": 1,
  "status": "pending",
  "scheduled_start": "2025-11-15T09:00:00Z",
  "created_at": "2025-11-02T12:00:00Z"
}
```

#### Get Assessment Status

```http
GET {{DOMAIN}}/api/v3/assessments/events/{id}
Authorization: Bearer <JWT>
```

**Response**:
```json
{
  "id": 456,
  "event_code": "EZRYKMYZNWW4RK",
  "client": {
    "id": 789,
    "name": "Acme Corporation",
    "domain": "acme.com"
  },
  "template": {
    "id": 1,
    "name": "CMMC Level 2 Assessment",
    "framework": "CMMC"
  },
  "status": "in_progress",
  "progress": {
    "total_questions": 110,
    "answered": 45,
    "percent_complete": 41
  },
  "started_at": "2025-11-15T09:00:00Z",
  "estimated_completion": "2025-11-15T17:00:00Z"
}
```

---

### 4. Compliance Scanning

#### Submit Domain Scan

```http
POST {{DOMAIN}}/api/v3/scans
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "domain": "example.com",
  "scan_types": ["dns_security", "ssl_security", "email_security", "web_privacy"],
  "priority": "high"
}
```

**Response**:
```http
HTTP/1.1 202 Accepted

{
  "scan_id": "550e8400-e29b-41d4-a716-446655440000",
  "domain": "example.com",
  "status": "queued",
  "estimated_completion": "2025-11-02T12:05:00Z",
  "status_url": "{{DOMAIN}}/api/v3/scans/550e8400-e29b-41d4-a716-446655440000/status"
}
```

#### Check Scan Status

```http
GET {{DOMAIN}}/api/v3/scans/{scan_id}/status
Authorization: Bearer <JWT>
```

**Response (In Progress)**:
```json
{
  "scan_id": "550e8400-e29b-41d4-a716-446655440000",
  "domain": "example.com",
  "status": "processing",
  "progress": {
    "total_checks": 45,
    "completed_checks": 28,
    "percent_complete": 62
  },
  "started_at": "2025-11-02T12:00:00Z",
  "estimated_completion": "2025-11-02T12:05:00Z"
}
```

**Response (Completed)**:
```json
{
  "scan_id": "550e8400-e29b-41d4-a716-446655440000",
  "domain": "example.com",
  "status": "completed",
  "overall_grade": "B+",
  "overall_score": 85.5,
  "summary": {
    "total_checks": 45,
    "passed_checks": 38,
    "failed_checks": 4,
    "warning_checks": 3
  },
  "categories": [
    {
      "name": "DNS Security",
      "grade": "A",
      "score": 95.0,
      "passed": 18,
      "failed": 1,
      "warnings": 0
    },
    {
      "name": "Email Security",
      "grade": "B",
      "score": 82.5,
      "passed": 14,
      "failed": 3,
      "warnings": 2
    }
  ],
  "started_at": "2025-11-02T12:00:00Z",
  "completed_at": "2025-11-02T12:04:32Z",
  "results_url": "{{DOMAIN}}/api/v3/scans/550e8400-e29b-41d4-a716-446655440000"
}
```

#### Get Full Scan Results

```http
GET {{DOMAIN}}/api/v3/scans/{scan_id}
Authorization: Bearer <JWT>
```

**Response**: (Comprehensive JSON with all check results)

#### Get Domain Scan History

```http
GET {{DOMAIN}}/api/v3/domains/{domain}/scans
Authorization: Bearer <JWT>
```

**Query Parameters**:
- `page` - Page number
- `per_page` - Results per page (max: 50)
- `from_date` - Filter scans after date (ISO 8601)
- `to_date` - Filter scans before date (ISO 8601)

**Response**:
```json
{
  "domain": "example.com",
  "data": [
    {
      "scan_id": "550e8400-e29b-41d4-a716-446655440000",
      "status": "completed",
      "overall_grade": "B+",
      "overall_score": 85.5,
      "started_at": "2025-11-02T12:00:00Z",
      "completed_at": "2025-11-02T12:04:32Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 12,
    "last_page": 1
  }
}
```

#### Get Latest Scan for Domain

```http
GET {{DOMAIN}}/api/v3/domains/{domain}/latest
Authorization: Bearer <JWT>
```

---

### 5. Permissions Management

#### Get All Roles and Permissions

```http
GET {{DOMAIN}}/api/v3/super-admin/permissions
Authorization: Bearer <JWT>
```

**Response**:
```json
{
  "roles": [
    {
      "id": 1,
      "name": "admin",
      "description": "Full system access"
    }
  ],
  "permissions": [
    {
      "id": 1,
      "name": "clients.view",
      "description": "View client list",
      "category": "clients"
    }
  ],
  "rolePermissions": {
    "1": [1, 2, 3, 5, 8, 13]  // Role ID -> Permission IDs
  }
}
```

#### Update Role Permissions

```http
POST {{DOMAIN}}/api/v3/super-admin/permissions/save
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "role_id": 1,
  "permission_ids": [1, 2, 3, 5, 8, 13, 21]
}
```

---

### 6. AI Analysis & Segmentation

#### Analyze Client Risk Profile

```http
POST {{DOMAIN}}/api/v3/ai/analyze/client/{client_id}
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "provider": "openai",
  "model": "gpt-4"
}
```

**Response**:
```json
{
  "client_id": 789,
  "analysis": {
    "score": 85,
    "segment": "ideal",
    "reason": "Strong security posture with modern infrastructure and active compliance program",
    "suggested_action": "Continue quarterly assessments, consider expanding to additional frameworks",
    "risk_factors": [
      "No formal incident response plan documented",
      "Third-party vendor assessments overdue"
    ],
    "strengths": [
      "Multi-factor authentication enforced",
      "Regular security awareness training",
      "Documented security policies"
    ]
  },
  "model_used": "gpt-4",
  "confidence": 0.92,
  "analyzed_at": "2025-11-02T12:00:00Z"
}
```

---

## Error Handling

### Standard Error Response Format

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      "field": "Specific error details"
    },
    "request_id": "req_xyz123",
    "timestamp": "2025-11-02T12:00:00Z"
  }
}
```

### HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| **200** | OK | Successful GET, PUT, PATCH requests |
| **201** | Created | Successful POST creating new resource |
| **202** | Accepted | Request accepted for async processing |
| **204** | No Content | Successful DELETE request |
| **400** | Bad Request | Invalid request syntax or parameters |
| **401** | Unauthorized | Missing or invalid authentication |
| **403** | Forbidden | Valid auth but insufficient permissions |
| **404** | Not Found | Resource does not exist |
| **409** | Conflict | Request conflicts with existing state |
| **422** | Unprocessable Entity | Valid syntax but semantic errors |
| **429** | Too Many Requests | Rate limit exceeded |
| **500** | Internal Server Error | Server-side error |
| **503** | Service Unavailable | Temporary unavailability |

### Common Error Codes

| Error Code | Description |
|------------|-------------|
| `AUTHENTICATION_FAILED` | Invalid or expired JWT token |
| `AUTHORIZATION_FAILED` | Insufficient permissions for action |
| `RATE_LIMIT_EXCEEDED` | API rate limit exceeded |
| `VALIDATION_ERROR` | Request validation failed |
| `RESOURCE_NOT_FOUND` | Requested resource not found |
| `DUPLICATE_ENTRY` | Resource already exists |
| `TENANT_ISOLATION_VIOLATION` | Attempted cross-tenant access |
| `EXTERNAL_SERVICE_ERROR` | External service (Auth0, AI) unavailable |

### Error Response Examples

**Validation Error (422)**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": {
      "domain": ["The domain field is required"],
      "contact_email": ["The contact email must be a valid email address"]
    },
    "request_id": "req_abc123"
  }
}
```

**Authorization Error (403)**:
```json
{
  "error": {
    "code": "AUTHORIZATION_FAILED",
    "message": "Insufficient permissions to access this client",
    "details": {
      "required_permission": "clients.view",
      "user_permissions": ["scans.read", "scans.write"]
    },
    "request_id": "req_def456"
  }
}
```

---

## Webhooks

### Webhook Configuration

Configure webhooks to receive notifications for events:

```http
POST {{DOMAIN}}/api/v3/webhooks
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "url": "https://your-app.com/webhooks/scans",
  "events": ["scan.completed", "scan.failed", "assessment.completed"],
  "secret": "whsec_your_secret_key"
}
```

### Webhook Event Format

```json
{
  "id": "evt_xyz123",
  "type": "scan.completed",
  "data": {
    "scan_id": "550e8400-e29b-41d4-a716-446655440000",
    "domain": "example.com",
    "overall_grade": "B+",
    "completed_at": "2025-11-02T12:04:32Z"
  },
  "created_at": "2025-11-02T12:04:33Z"
}
```

### Webhook Signature Verification

Verify webhook authenticity using HMAC-SHA256:

```python
import hmac
import hashlib

def verify_webhook(payload, signature, secret):
    expected = hmac.new(
        secret.encode('utf-8'),
        payload.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature)
```

---

## SDK & Client Libraries

### Official SDKs

| Language | Package | Documentation |
|----------|---------|---------------|
| **PHP** | `{{PROJECT_NAME}}/sdk-php` | https://github.com/{{ORG}}/sdk-php |
| **Python** | `{{PROJECT_NAME}}-sdk` | https://github.com/{{ORG}}/sdk-python |
| **Node.js** | `@{{ORG}}/sdk-node` | https://github.com/{{ORG}}/sdk-node |
| **Go** | `github.com/{{ORG}}/sdk-go` | https://github.com/{{ORG}}/sdk-go |

### Quick Start Example (PHP)

```php
<?php
require 'vendor/autoload.php';

use {{PROJECT_NAMESPACE}}\SDK\Client;

$client = new Client([
    'api_key' => 'ck_live_xxxxxxxxxxxxxxxxxxxx',
    'api_secret' => 'sk_live_xxxxxxxxxxxxxxxxxxxx',
]);

// Submit scan
$scan = $client->scans->create([
    'domain' => 'example.com',
    'scan_types' => ['dns_security', 'email_security']
]);

// Poll for results
while ($scan->status !== 'completed') {
    sleep(5);
    $scan = $client->scans->retrieve($scan->scan_id);
}

echo "Grade: {$scan->overall_grade}\n";
```

---

## API Best Practices

### 1. Use Pagination

Always paginate large result sets:

```http
GET {{DOMAIN}}/api/v3/clients?page=1&per_page=50
```

### 2. Filter Responses

Use sparse fieldsets to reduce response size:

```http
GET {{DOMAIN}}/api/v3/clients?fields=id,name,domain,status
```

### 3. Handle Rate Limits Gracefully

Implement exponential backoff on 429 responses:

```python
import time

def api_call_with_retry(func, max_retries=3):
    for attempt in range(max_retries):
        try:
            return func()
        except RateLimitError as e:
            if attempt < max_retries - 1:
                wait = (2 ** attempt) + random.random()
                time.sleep(wait)
            else:
                raise
```

### 4. Cache Responses

Cache GET responses to reduce API calls:

```http
GET {{DOMAIN}}/api/v3/scans/{scan_id}
Cache-Control: max-age=300
ETag: "33a64df551425fcc55e4d42a148795d9"
```

### 5. Use Webhooks for Async Operations

Instead of polling scan status, configure webhooks:

```json
{
  "url": "https://your-app.com/webhooks/scans",
  "events": ["scan.completed"]
}
```

---

## Interactive API Documentation

### Swagger/OpenAPI

Access interactive API documentation:

```
{{DOMAIN}}/api-docs
```

**Features**:
- Interactive request builder
- Authentication testing
- Request/response examples
- Schema validation
- Code generation (multiple languages)

---

## See Also

- **[02-security.md](02-security.md)** - API security and encryption standards
- **[06-database-schema.md](06-database-schema.md)** - API data models
- **[07-testing-and-QA.md](07-testing-and-QA.md)** - API testing strategies
- **[05-deployment-guide.md](05-deployment-guide.md)** - API deployment procedures

---

## Template Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Project display name | ComplianceScorecard Platform |
| `{{DOMAIN}}` | API base domain | https://api.example.com |
| `{{AUTH0_DOMAIN}}` | Auth0 domain | https://example.auth0.com |
| `{{PROJECT_NAMESPACE}}` | PHP namespace | ComplianceScorecard |
| `{{ORG}}` | GitHub organization | compliancescorecard |
| `{{CLIENT_ID}}` | OAuth client ID | abc123... |
| `{{CLIENT_SECRET}}` | OAuth client secret | xyz789... |
| `{{CONTACT_EMAIL}}` | API support email | api-support@example.com |

---

**Document Version**: 1.0
**Last Updated**: 2025-11-02
**Author**: {{USERNAME}} - aka GoldenEye Engineering
**Review Cycle**: Quarterly or after major API changes
