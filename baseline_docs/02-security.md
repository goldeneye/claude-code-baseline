---
title: {{PROJECT_NAME}} - Security Specification
version: 1.0
last_updated: 2025-11-02
author: ComplianceScorecard Engineering
---

# {{PROJECT_NAME}} — Security Specification

## 1. Overview

This document defines the security architecture, authentication mechanisms, encryption standards, and compliance controls for {{PROJECT_NAME}}. All implementations must adhere to these specifications to ensure regulatory compliance and data protection.

---

## 2. Authentication & Authorization

### 2.1 Authentication Methods

| Method | Use Case | Technology | Token Lifetime |
|--------|----------|------------|----------------|
| **Auth0 SSO** | User login (web/mobile) | OIDC/JWT | 24 hours |
| **API Key + JWT** | Service-to-service | HS256 JWT | Configurable (default: 24h) |
| **Session Cookie** | Internal Laravel routes | Encrypted session | 2 hours (idle timeout) |

### 2.2 Auth0 Integration

**Configuration**:
```env
AUTH0_DOMAIN={{AUTH0_DOMAIN}}
AUTH0_CLIENT_ID={{AUTH0_CLIENT_ID}}
AUTH0_CLIENT_SECRET={{AUTH0_CLIENT_SECRET}}
AUTH0_AUDIENCE={{AUTH0_AUDIENCE}}
```

**Flow**:
1. User initiates login → Frontend redirects to Auth0
2. Auth0 authenticates → Returns ID Token + Access Token (JWT)
3. Frontend sends JWT in `Authorization: Bearer <token>` header
4. Backend validates JWT against Auth0 JWKS endpoint
5. User session created with `msp_id` claim for tenant filtering

**JWT Validation**:
```php
// Validate signature, expiration, issuer, audience
$token = JWTAuth::parseToken()->authenticate();
$mspId = $token->getClaim('msp_id');
```

### 2.3 API Key Management

**Generation**:
```php
$apiKey = ApiKey::create([
    'name' => 'Production Scanner',
    'key' => hash('sha256', Str::random(64)),      // Public key
    'secret_hash' => bcrypt(Str::random(128)),     // Private secret
    'msp_id' => auth()->user()->msp_id,
    'permissions' => ['scans.create', 'scans.read'],
    'rate_limit' => 100,                           // Per minute
    'daily_limit' => 10000,
]);

// Generate JWT for this API key
$jwt = $apiKey->generateJWT();
```

**Storage**:
- Public key: Stored hashed in `api_keys` table
- Secret: Shown once, then hashed (bcrypt) in `secret_hash` column
- JWT secret: Laravel `APP_KEY` used for HS256 signing

**Validation**:
```php
// Middleware: ApiAuthentication
1. Extract JWT from Authorization header
2. Verify JWT signature (HS256 with APP_KEY)
3. Lookup API key by key hash
4. Check: is_active, ip_whitelist, rate_limit
5. Inject MSP context into request
```

---

## 3. Authorization Model

### 3.1 Role-Based Access Control (RBAC)

**Roles** (defined in `roles` table):

| Role ID | Role Name | Description |
|---------|-----------|-------------|
| 1 | `super_admin` | Full system access (201+ permissions) |
| 2 | `msp_admin` | Company-wide admin (manage clients, users) |
| 3 | `company_user` | Internal team member (assigned clients) |
| 4 | `client_user` | End-client (view own assessments) |
| 5 | `auditor` | Read-only compliance access |

**Permission Naming Convention**:
```
{resource}.{action}
Examples:
  - clients.create
  - assessments.edit
  - mspglobal.view
  - super-admin.permissions.manage
```

**Permission Check** (Middleware + Manual):
```php
// Middleware
Route::middleware(['auth', 'permission:clients.create'])->group(...);

// Manual check in controller
if (!auth()->user()->hasPermission('assessments.edit')) {
    abort(403, 'Insufficient permissions');
}
```

### 3.2 Multi-Tenant Isolation

**Database-Level Filtering**:
```php
// Global scope applied to all queries
protected static function booted() {
    static::addGlobalScope('msp', function (Builder $builder) {
        if (auth()->check()) {
            $builder->where('msp_id', auth()->user()->msp_id);
        }
    });
}
```

**API-Level Enforcement**:
- All API requests include `msp_id` from authenticated user/API key
- Cross-tenant access blocked at query level
- Super admins can bypass with `withoutGlobalScope('msp')`

---

## 4. Encryption

### 4.1 Encryption-at-Rest

**Field-Level Encryption** (Laravel `Crypt`):

**Encrypted Fields**:
```php
protected $encryptable = [
    // User PII
    'name', 'email', 'auth0_sub',

    // Client PII
    'client_name', 'domain', 'contact_email', 'contact_phone',

    // Secrets
    'api_key', 'secret_hash', 'access_token', 'refresh_token',

    // AI/Sensitive Data
    'reason', 'suggested_action', 'metadata',
];
```

**Encryption Trait** (`app/Models/Traits/Encryptable.php`):
```php
trait Encryptable {
    public function setAttribute($key, $value) {
        if (in_array($key, $this->encryptable ?? [])) {
            $value = Crypt::encryptString($value);
        }
        return parent::setAttribute($key, $value);
    }

    public function getAttribute($key) {
        $value = parent::getAttribute($key);
        if (in_array($key, $this->encryptable ?? []) && $value) {
            $value = Crypt::decryptString($value);
        }
        return $value;
    }
}
```

**Database Tablespace Encryption**:
```sql
-- MySQL InnoDB encryption enabled
ALTER TABLESPACE innodb_system ENCRYPTION='Y';
```

**Encryption Keys**:
- **APP_KEY**: Laravel application key (base64, 32 bytes)
- **Rotation**: Annual rotation with zero-downtime migration
- **Storage**: Environment variables (never committed)

### 4.2 Encryption-in-Transit

**HTTPS/TLS**:
- **Enforced**: All production traffic HTTPS only
- **Certificate**: Let's Encrypt or commercial SSL
- **Min TLS Version**: 1.2
- **Cipher Suites**: Modern, secure ciphers only

**API Communication**:
```php
// Force HTTPS in production
if (app()->environment('production')) {
    URL::forceScheme('https');
}
```

---

## 5. Data Protection

### 5.1 Sensitive Data Handling

**Never Logged**:
- Plaintext passwords
- Decrypted API keys/secrets
- PII in log files
- Auth tokens (full values)

**Logging Standard**:
```php
// WRONG: Logs decrypted email
Log::info("User logged in: {$user->email}");

// CORRECT: Logs user ID only
Log::info("User logged in", ['user_id' => $user->id]);
```

### 5.2 Data Retention

| Data Type | Retention Period | Purge Method |
|-----------|------------------|--------------|
| **Scan Results** | 12 months | Soft delete → hard delete after 30 days |
| **Audit Logs** | 24 months | Hard delete via scheduled job |
| **Client Imports** | 12 months | Hard delete with confirmation |
| **Failed Jobs** | 7 days | Auto-purge via Horizon |
| **Session Data** | 2 hours idle | Redis TTL expiration |

**Purge Command**:
```bash
php artisan segmentation:purge-old-data --dry-run
php artisan segmentation:purge-old-data --confirm
```

---

## 6. Security Headers

**HTTP Headers** (via Middleware):
```php
response()->header('X-Frame-Options', 'DENY');
response()->header('X-Content-Type-Options', 'nosniff');
response()->header('X-XSS-Protection', '1; mode=block');
response()->header('Referrer-Policy', 'strict-origin-when-cross-origin');
response()->header('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
```

**CORS Configuration**:
```php
// config/cors.php
'allowed_origins' => [
    env('FRONTEND_URL', 'http://localhost:3000'),
    'https://{{DOMAIN}}',
],
'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
'exposed_headers' => ['X-RateLimit-Limit', 'X-RateLimit-Remaining'],
'max_age' => 3600,
'supports_credentials' => true,
```

---

## 7. Input Validation & Sanitization

### 7.1 Form Request Validation

**Pattern**: All user input validated via `FormRequest` classes
```php
class StoreScanRequest extends FormRequest {
    public function rules(): array {
        return [
            'domain' => ['required', 'string', 'max:255', 'regex:/^[a-z0-9.-]+$/i'],
            'priority' => ['nullable', 'in:high,normal,low'],
        ];
    }
}
```

### 7.2 XSS Prevention

- **Blade Templates**: Auto-escape via `{{ $variable }}`
- **Raw Output**: Only use `{!! $html !!}` for trusted content
- **Frontend**: React escapes by default

### 7.3 SQL Injection Prevention

- **Eloquent ORM**: Parameterized queries by default
- **Raw Queries**: Always use bindings
```php
// WRONG
DB::select("SELECT * FROM users WHERE id = $id");

// CORRECT
DB::select("SELECT * FROM users WHERE id = ?", [$id]);
```

### 7.4 Command Injection Prevention

```php
// Escape shell arguments when calling Python scripts
$command = sprintf(
    '%s %s %s',
    config('scanner.python_path'),
    $scriptPath,
    escapeshellarg($domain)  // ← Critical: prevents injection
);
```

---

## 8. Rate Limiting

### 8.1 API Rate Limits

| Endpoint Group | Limit | Window | Throttle Key |
|----------------|-------|--------|--------------|
| **Public API** | 10 requests | 1 minute | IP address |
| **Authenticated API** | 60 requests | 1 minute | User ID |
| **Per-API Key** | Configurable | 1 minute + daily | API key hash |
| **Heavy Operations** | 5 requests | 1 minute | User ID |

**Implementation**:
```php
Route::middleware(['throttle:api'])->group(function () {
    // 60 requests/minute for authenticated users
});

Route::middleware(['throttle:public'])->group(function () {
    // 10 requests/minute for unauthenticated
});
```

**Custom Rate Limiting** (per API key):
```php
// In ApiAuthentication middleware
RateLimiter::attempt(
    "api-key:{$apiKey->id}",
    $apiKey->rate_limit,  // e.g., 100
    function () {
        // Request allowed
    },
    60  // 1 minute
);
```

**Headers**:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1699123456
```

---

## 9. Audit & Logging

### 9.1 Audit Log Requirements

**Logged Events**:
- User authentication (login, logout, failed attempts)
- Permission changes
- API key creation/deletion
- Client data import/export
- Scan initiation/completion
- AI analysis execution
- Data access by auditors

**Audit Log Schema** (`audit_logs` table):
```sql
CREATE TABLE audit_logs (
    id BIGINT PRIMARY KEY,
    msp_id BIGINT NOT NULL,
    action VARCHAR(50) NOT NULL,           -- e.g., 'import', 'analyze', 'convert'
    performed_by VARCHAR(255) ENCRYPTED,   -- User identifier
    metadata JSON ENCRYPTED,                -- Contextual details
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP
);
```

**Logging Format**:
```php
AuditLog::create([
    'msp_id' => auth()->user()->msp_id,
    'action' => 'client.import',
    'performed_by' => auth()->user()->email,
    'metadata' => [
        'source' => 'csv',
        'count' => 150,
        'batch_id' => $batchId,
    ],
    'ip_address' => request()->ip(),
    'user_agent' => request()->userAgent(),
]);
```

### 9.2 Security Event Logging

**Log Channels** (`config/logging.php`):
```php
'channels' => [
    'security' => [
        'driver' => 'daily',
        'path' => storage_path('logs/security.log'),
        'level' => 'warning',
        'days' => 90,
    ],
    'audit' => [
        'driver' => 'database',  // Writes to audit_logs table
        'level' => 'info',
    ],
],
```

**Security Events**:
- Failed login attempts (3+ consecutive)
- API key validation failures
- Rate limit violations
- Cross-tenant access attempts
- Suspicious IP activity
- Data export operations

**Alerting**:
```php
// Send Slack alert on critical security event
Log::channel('security')->critical("Multiple failed logins detected", [
    'user_id' => $userId,
    'ip' => $ipAddress,
    'attempts' => $count,
]);

// Trigger Apprise notification
Notification::route('slack', config('services.slack.security_webhook'))
    ->notify(new SecurityAlert($event));
```

---

## 10. Vulnerability Protection

### 10.1 Common Vulnerabilities (OWASP Top 10)

| Vulnerability | Protection Mechanism |
|---------------|---------------------|
| **Injection** | Eloquent ORM, parameterized queries, `escapeshellarg()` |
| **Broken Authentication** | Auth0, bcrypt passwords, JWT validation |
| **Sensitive Data Exposure** | Field-level encryption, HTTPS, secure headers |
| **XML External Entities** | N/A (no XML processing) |
| **Broken Access Control** | RBAC, multi-tenant scoping, permission middleware |
| **Security Misconfiguration** | Environment-based config, security headers |
| **XSS** | Blade auto-escaping, React escaping, CSP headers |
| **Insecure Deserialization** | JSON only, schema validation |
| **Using Components with Known Vulnerabilities** | `composer audit`, Dependabot alerts |
| **Insufficient Logging** | Comprehensive audit logs, security channel |

### 10.2 CSRF Protection

- **Enabled**: All POST/PUT/PATCH/DELETE routes
- **Exception**: API routes (stateless, JWT-based)
```php
// API routes exclude CSRF
Route::middleware('api')->group(function () {
    // No CSRF check
});

// Web routes require CSRF token
Route::middleware('web')->group(function () {
    // CSRF enforced
});
```

---

## 11. Incident Response

### 11.1 Security Breach Protocol

**Severity Levels**:
- **Critical**: Data breach, unauthorized access to production
- **High**: API key compromise, failed security controls
- **Medium**: Rate limit abuse, suspicious activity
- **Low**: Failed login attempts, minor misconfigurations

**Response Steps**:
1. **Detect**: Automated alerts via Sentry/Datadog
2. **Contain**: Revoke compromised keys, block IPs
3. **Investigate**: Review audit logs, identify scope
4. **Remediate**: Patch vulnerability, rotate secrets
5. **Notify**: Inform affected MSPs within 24 hours (critical)
6. **Document**: Post-mortem report, lessons learned

**Notification SLA**:
- Critical breaches: 24 hours
- High severity: 72 hours
- Medium/Low: Next business day

### 11.2 Key Rotation

**Scheduled Rotation**:
- **APP_KEY**: Annually
- **Auth0 Client Secret**: Quarterly
- **API Keys** (per MSP): On request or every 90 days
- **Database Passwords**: Annually

**Emergency Rotation** (after compromise):
```bash
# Generate new APP_KEY
php artisan key:generate --force

# Rotate database password
# (Manual process, update .env + restart services)

# Revoke all API keys for MSP
php artisan api:revoke-msp {msp_id} --reason="Security incident"
```

---

## 12. Compliance Alignment

### 12.1 FTC Safeguards Rule

| Requirement | Implementation |
|-------------|----------------|
| **Encryption** | Field-level + tablespace encryption |
| **Access Controls** | RBAC + multi-tenant isolation |
| **Audit Trail** | Comprehensive audit_logs table |
| **Incident Response** | Documented protocol with SLAs |
| **Data Retention** | 12-24 month retention with auto-purge |

### 12.2 SOC 2 (Type II)

**Control Objectives Met**:
- **Security**: Encryption, access controls, monitoring
- **Availability**: 99.9% uptime, load balancing, backups
- **Confidentiality**: Encrypted storage, secure transmission
- **Processing Integrity**: Input validation, error handling
- **Privacy**: GDPR-ready consent management (future)

### 12.3 CIS Controls

| Control | Implementation |
|---------|----------------|
| **Inventory of Assets** | Asset discovery, dependency tracking |
| **Secure Configuration** | Environment-based configs, secrets management |
| **Data Protection** | Encryption, backups, retention policies |
| **Access Control** | RBAC, MFA (Auth0), least privilege |
| **Audit Log Management** | 90-day retention, tamper-proof logs |
| **Email & Web Browser Protection** | SPF/DMARC scanning, web privacy checks |

---

## 13. Security Testing

### 13.1 Automated Security Scans

- **Dependency Scanning**: `composer audit` (weekly)
- **Static Analysis**: PHP_CodeSniffer, Psalm (CI/CD)
- **Penetration Testing**: Annual third-party audit

### 13.2 Security Test Suite

```php
// tests/Feature/SecurityTest.php
public function test_api_requires_authentication() {
    $response = $this->getJson('/api/v3/clients');
    $response->assertStatus(401);
}

public function test_cross_tenant_access_blocked() {
    $otherMspClient = Client::factory()->create(['msp_id' => 999]);
    $response = $this->actingAs($this->user)
                     ->getJson("/api/v3/clients/{$otherMspClient->id}");
    $response->assertStatus(404);  // Not found (filtered by msp_id)
}

public function test_encrypted_fields_not_exposed() {
    $client = Client::factory()->create();
    $raw = DB::table('clients')->find($client->id);

    $this->assertNotEquals($client->email, $raw->email);  // Encrypted in DB
    $this->assertEquals($client->email, Crypt::decryptString($raw->email));
}
```

---

## 14. Quick Reference

### Security Checklist for New Features

- [ ] Input validation via FormRequest
- [ ] Encrypted fields identified and configured
- [ ] Permission checks implemented
- [ ] Multi-tenant filtering applied
- [ ] Rate limiting configured
- [ ] Audit logging added
- [ ] Security tests written
- [ ] No secrets in code/logs
- [ ] HTTPS enforced (production)
- [ ] Dependencies audited

---

## See Also

- [Architecture Overview](01-architecture.md) - Authentication flows
- [Database Schema](06-database-schema.md) - Encrypted field definitions
- [API Documentation](08-api-documentation.md) - API authentication examples

---

**Last Updated**: 2025-11-02
**Document Version**: 1.0
**Status**: Production-Ready Baseline
