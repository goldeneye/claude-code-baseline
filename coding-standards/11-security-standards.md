# Security Standards

**Protecting User Data & System Integrity**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- ✅ Validate ALL user inputs
- ✅ Use Eloquent ORM (prevents SQL injection)
- ✅ Escape ALL outputs in Blade
- ✅ Enable CSRF protection
- ✅ Never hardcode secrets
- ✅ Use environment variables for sensitive config
- ✅ Rate limit API endpoints
- ✅ Implement proper authentication & authorization

---

## Table of Contents

1. [Security Principles](#security-principles)
2. [Input Validation](#input-validation)
3. [SQL Injection Prevention](#sql-injection-prevention)
4. [XSS Protection](#xss-protection)
5. [Authentication & Authorization](#authentication--authorization)
6. [Secrets Management](#secrets-management)
7. [API Security](#api-security)
8. [File Upload Security](#file-upload-security)

---

## Security Principles

### Defense in Depth

```
Multiple layers of security:
1. Input validation
2. Authentication & authorization
3. SQL injection prevention
4. XSS protection
5. CSRF protection
6. Rate limiting
7. Logging & monitoring
```

### Security Checklist

```
EVERY FEATURE MUST:
☐ Validate all inputs
☐ Escape all outputs
☐ Check user permissions
☐ Use parameterized queries
☐ Protect against CSRF
☐ Log security events
☐ Handle errors securely
☐ Use HTTPS
```

---

## Input Validation

### Laravel Request Validation

```php
// ✅ GOOD - Use Form Request validation
<?php

namespace App\Http\Requests\Assessment;

use Illuminate\Foundation\Http\FormRequest;

class StoreAssessmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Assessment::class);
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'template_id' => ['required', 'uuid', 'exists:assessment_templates,id'],
            'client_id' => ['required', 'uuid', 'exists:clients,id'],
            'description' => ['nullable', 'string', 'max:5000'],
            'due_date' => ['nullable', 'date', 'after:today'],
        ];
    }

    public function messages(): array
    {
        return [
            'template_id.exists' => 'The selected template does not exist.',
            'client_id.exists' => 'The selected client does not exist.',
        ];
    }
}

// Controller usage
public function store(StoreAssessmentRequest $request): JsonResponse
{
    // Request is already validated and authorized
    $assessment = AssessmentEvent::create($request->validated());

    return response()->json(['data' => $assessment], 201);
}
```

### Custom Validation Rules

```php
// ✅ GOOD - Custom validation for business rules
public function rules(): array
{
    return [
        'email' => ['required', 'email', 'unique:users,email'],
        'company_id' => [
            'required',
            'uuid',
            Rule::exists('companies', 'id')->where(function ($query) {
                $query->where('is_active', true);
            })
        ],
        'subscription_type' => [
            'required',
            Rule::in(['lite', 'plus', 'enterprise'])
        ],
    ];
}
```

### Sanitize User Input

```php
// ✅ GOOD - Sanitize before using
$cleanName = strip_tags($request->name);
$cleanEmail = filter_var($request->email, FILTER_SANITIZE_EMAIL);

// ✅ GOOD - Laravel sanitization
$data = $request->only(['name', 'email', 'description']);
$data['description'] = clean($data['description']); // Use helper
```

---

## SQL Injection Prevention

### ALWAYS Use Eloquent ORM

```php
// ✅ GOOD - Eloquent ORM (safe)
$assessments = AssessmentEvent::where('company_id', $companyId)
    ->where('status', 'active')
    ->get();

// ✅ GOOD - Query Builder with bindings
$assessments = DB::table('assessment_events')
    ->where('company_id', $companyId)
    ->where('status', 'active')
    ->get();

// ✅ GOOD - Raw query with bindings
$assessments = DB::select(
    'SELECT * FROM assessment_events WHERE company_id = ? AND status = ?',
    [$companyId, 'active']
);

// ❌ NEVER - Raw SQL with concatenation
$assessments = DB::select(
    "SELECT * FROM assessment_events WHERE company_id = '{$companyId}'"
);  // SQL INJECTION VULNERABILITY!
```

### WhereRaw with Bindings

```php
// ✅ GOOD - WhereRaw with bindings
$assessments = AssessmentEvent::whereRaw(
    'DATE(created_at) = ?',
    [now()->toDateString()]
)->get();

// ❌ BAD - WhereRaw without bindings
$date = $request->date;
$assessments = AssessmentEvent::whereRaw(
    "DATE(created_at) = '{$date}'"
)->get();  // SQL INJECTION VULNERABILITY!
```

---

## XSS Protection

### Blade Template Escaping

```blade
{{-- ✅ GOOD - Auto-escaped output --}}
<h1>{{ $assessment->name }}</h1>
<p>{{ $user->email }}</p>

{{-- ❌ DANGEROUS - Unescaped output --}}
<h1>{!! $assessment->name !!}</h1>  {{-- Only use for trusted HTML --}}

{{-- ✅ GOOD - Escape in JavaScript --}}
<script>
    const userName = @json($user->name);  // Properly escaped
</script>

{{-- ❌ BAD - Direct interpolation --}}
<script>
    const userName = "{{ $user->name }}";  // Potential XSS!
</script>
```

### JavaScript Output Escaping

```javascript
// ✅ GOOD - Escape before inserting into DOM
const escapeHtml = (unsafe) => {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
};

element.textContent = userInput;  // Safe - textContent auto-escapes
element.innerHTML = escapeHtml(userInput);  // Explicitly escaped

// ❌ DANGEROUS
element.innerHTML = userInput;  // XSS VULNERABILITY!
```

---

## Authentication & Authorization

### Multi-Tenant Authorization

```php
// ✅ GOOD - Policy-based authorization
class AssessmentPolicy
{
    public function view(User $user, Assessment $assessment): bool
    {
        // Super admin can view all
        if ($user->isSuperAdmin()) {
            return true;
        }

        // MSP can view their companies' assessments
        if ($user->isMspAdmin()) {
            return $assessment->msp_id === $user->msp_id;
        }

        // User can only view their company's assessments
        return $assessment->company_id === $user->company_id;
    }

    public function update(User $user, Assessment $assessment): bool
    {
        return $user->company_id === $assessment->company_id
            && $user->hasPermission('assessment:edit');
    }
}

// Controller usage
public function update(Request $request, Assessment $assessment): JsonResponse
{
    $this->authorize('update', $assessment);

    // User is authorized...
    $assessment->update($request->validated());

    return response()->json(['data' => $assessment]);
}
```

### Middleware Protection

```php
// routes/api.php
Route::middleware(['auth:sanctum', 'check.company'])->group(function () {
    Route::apiResource('assessments', AssessmentController::class);
});

// app/Http/Middleware/CheckCompanyAccess.php
class CheckCompanyAccess
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        $companyId = $request->route('company');

        // Verify user belongs to company
        if ($companyId && $user->company_id !== $companyId) {
            abort(403, 'Unauthorized access to company resources');
        }

        return $next($request);
    }
}
```

---

## Secrets Management

### Environment Variables

```php
// ✅ GOOD - Use environment variables
config/services.php:
'auth0' => [
    'domain' => env('AUTH0_DOMAIN'),
    'client_id' => env('AUTH0_CLIENT_ID'),
    'client_secret' => env('AUTH0_CLIENT_SECRET'),
],

// ❌ NEVER - Hardcode secrets
'auth0' => [
    'client_secret' => 'abc123secret',  // SECURITY VULNERABILITY!
],
```

### .env File Security

```bash
# ✅ GOOD - .env file (NEVER commit to git)
DB_PASSWORD=secure_password_here
AUTH0_CLIENT_SECRET=secret_key_here
API_KEY=api_key_here

# .gitignore MUST include:
.env
.env.*
!.env.example
```

### Encryption

```php
// ✅ GOOD - Encrypt sensitive data
use Illuminate\Support\Facades\Crypt;

// Encrypt
$encrypted = Crypt::encryptString($sensitiveData);

// Decrypt
$decrypted = Crypt::decryptString($encrypted);

// Database column encryption
protected $casts = [
    'ssn' => 'encrypted',
    'credit_card' => 'encrypted',
];
```

---

## API Security

### Rate Limiting

```php
// routes/api.php
Route::middleware(['throttle:60,1'])->group(function () {
    // 60 requests per minute
    Route::post('/login', [AuthController::class, 'login']);
});

Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
    // Uses default API rate limit
    Route::apiResource('assessments', AssessmentController::class);
});

// config/services.php - Custom rate limits
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});
```

### API Token Security

```php
// ✅ GOOD - Sanctum API tokens
$token = $user->createToken('api-token', ['assessment:read', 'assessment:write']);

// Verify token abilities
if ($request->user()->tokenCan('assessment:write')) {
    // User has permission
}

// ❌ NEVER - Expose tokens in logs
Log::info('User login', [
    'user_id' => $user->id,
    'token' => $token->plainTextToken  // NEVER LOG TOKENS!
]);
```

### CORS Configuration

```php
// config/cors.php
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE'],
    'allowed_origins' => [
        'https://app.compliancescorecard.com',
        'https://dashboard.compliancescorecard.com'
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

---

## File Upload Security

### Validate File Uploads

```php
// ✅ GOOD - Comprehensive file validation
public function rules(): array
{
    return [
        'file' => [
            'required',
            'file',
            'max:10240',  // 10MB max
            'mimes:pdf,doc,docx,xls,xlsx',
            'mimetypes:application/pdf,application/msword',
        ],
        'avatar' => [
            'required',
            'image',
            'max:2048',  // 2MB max
            'dimensions:min_width=100,min_height=100,max_width=2000,max_height=2000',
        ],
    ];
}
```

### Secure File Storage

```php
// ✅ GOOD - Store files securely
public function uploadDocument(Request $request): JsonResponse
{
    $request->validate([
        'document' => 'required|file|mimes:pdf|max:10240'
    ]);

    // Generate unique filename
    $filename = Str::uuid() . '.' . $request->file('document')->extension();

    // Store in private storage
    $path = $request->file('document')->storeAs(
        'documents/' . auth()->user()->company_id,
        $filename,
        'private'
    );

    // Save to database with access control
    $document = Document::create([
        'filename' => $filename,
        'path' => $path,
        'company_id' => auth()->user()->company_id,
        'uploaded_by' => auth()->id()
    ]);

    return response()->json(['data' => $document]);
}

// Download with authorization
public function download(Document $document)
{
    $this->authorize('view', $document);

    return Storage::disk('private')->download($document->path);
}
```

---

## Security Best Practices Checklist

```
PRE-DEPLOYMENT SECURITY CHECKLIST:
☐ All inputs validated
☐ All outputs escaped
☐ No hardcoded secrets
☐ CSRF protection enabled
☐ SQL injection prevented (using ORM)
☐ XSS protection in place
☐ Authentication required for protected routes
☐ Authorization checks on resources
☐ Rate limiting configured
☐ File uploads validated
☐ HTTPS enforced
☐ Security headers configured
☐ Error messages don't leak sensitive info
☐ Logging doesn't expose sensitive data
☐ Multi-tenant isolation verified
☐ Dependencies up to date
```

---

## Related Standards

- [Quality Standards](./08-quality-standards.md)
- [Testing Standards](./10-testing-standards.md)
- [Database Standards](./05-database-standards.md)

---

**Next:** [Performance Standards →](./12-performance-standards.md)

**Last Updated:** January 2025
