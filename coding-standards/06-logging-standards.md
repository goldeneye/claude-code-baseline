# Comprehensive Logging Standards

**Every Significant Action Must Be Logged**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- ✅ **ALWAYS** include file path and line number: `"File: " . __FILE__ . ":" . __LINE__`
- ✅ **ALWAYS** log with context (user_id, company_id, entity_id)
- ✅ **ALWAYS** use appropriate log levels (DEBUG, INFO, WARNING, ERROR)
- ✅ **NEVER** log sensitive data (passwords, tokens, credit cards)
- ✅ **ALWAYS** log before/after critical operations
- ✅ **ALWAYS** use structured logging with arrays

---

## Table of Contents

1. [Logging Philosophy](#logging-philosophy)
2. [Standard Log Format](#standard-log-format)
3. [Log Levels](#log-levels)
4. [Required Logging Points](#required-logging-points)
5. [Context Standards](#context-standards)
6. [Laravel Logging](#laravel-logging)
7. [Production Best Practices](#production-best-practices)

---

## Logging Philosophy

**Every significant action, error, and business logic decision should be logged with context for debugging and audit purposes.**

### Why Log Everything?

1. **Debugging** - Trace issues in production without access to debuggers
2. **Auditing** - Track who did what and when
3. **Performance** - Identify slow operations and bottlenecks
4. **Security** - Detect suspicious activities and unauthorized access
5. **Compliance** - Meet regulatory requirements for audit trails
6. **Analytics** - Understand user behavior and system usage

---

## Standard Log Format

### File and Line Number Format

```php
// MANDATORY format for ALL log statements
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Your message here", [
    'context' => 'data'
]);
```

### Complete Log Statement Example

```php
use Illuminate\Support\Facades\Log;

public function createAssessment(Request $request): JsonResponse
{
    // Log method entry
    Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Creating new assessment", [
        'user_id' => auth()->id(),
        'company_id' => auth()->user()->company_id,
        'template_id' => $request->template_id,
        'client_id' => $request->client_id
    ]);

    try {
        $assessment = AssessmentEvent::create($validatedData);

        // Log success
        Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Assessment created successfully", [
            'assessment_id' => $assessment->id,
            'template_name' => $assessment->template->name,
            'client_name' => $assessment->client->name,
            'user_id' => auth()->id()
        ]);

        return response()->json(['data' => $assessment], 201);

    } catch (\Exception $e) {
        // Log error with full context
        Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Failed to create assessment", [
            'error' => $e->getMessage(),
            'template_id' => $request->template_id,
            'client_id' => $request->client_id,
            'user_id' => auth()->id(),
            'trace' => $e->getTraceAsString()
        ]);

        throw $e;
    }
}
```

---

## Log Levels

### DEBUG Level

**Use for:** Development and detailed tracing

```php
Log::debug("File: " . __FILE__ . ":" . __LINE__ . " - Variable state", [
    'variable_value' => $someVariable,
    'step' => 'processing'
]);

Log::debug("File: " . __FILE__ . ":" . __LINE__ . " - SQL query", [
    'query' => $query->toSql(),
    'bindings' => $query->getBindings()
]);

Log::debug("File: " . __FILE__ . ":" . __LINE__ . " - Algorithm step", [
    'step' => 3,
    'current_value' => $value,
    'expected_value' => $expected
]);
```

**When to use:**
- Variable values during development
- SQL query debugging
- Algorithm step-by-step tracing
- Cache hit/miss information
- API request/response details

### INFO Level

**Use for:** General information and normal operations

```php
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - User logged in", [
    'user_id' => $user->id,
    'email' => $user->email,
    'ip_address' => request()->ip()
]);

Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Assessment completed", [
    'assessment_id' => $assessment->id,
    'client_id' => $assessment->client_id,
    'score' => $assessment->score,
    'completion_time' => now()
]);

Log::info("File: " . __FILE__ . ":" . __LINE__ . " - File uploaded", [
    'file_name' => $file->getClientOriginalName(),
    'file_size' => $file->getSize(),
    'mime_type' => $file->getMimeType(),
    'user_id' => auth()->id()
]);
```

**When to use:**
- User login/logout events
- Assessment creation/completion
- File uploads/downloads
- System configuration changes
- Successful integrations
- Scheduled task execution

### WARNING Level

**Use for:** Potential issues that don't stop execution

```php
Log::warning("File: " . __FILE__ . ":" . __LINE__ . " - Slow database query detected", [
    'query_time' => $executionTime,
    'threshold' => $slowThreshold,
    'query' => $query->toSql()
]);

Log::warning("File: " . __FILE__ . ":" . __LINE__ . " - Low assessment score", [
    'assessment_id' => $assessment->id,
    'score' => $calculatedScore,
    'threshold' => 70,
    'client_id' => $assessment->client_id
]);

Log::warning("File: " . __FILE__ . ":" . __LINE__ . " - API rate limit approaching", [
    'current_requests' => $requestCount,
    'limit' => $rateLimit,
    'user_id' => auth()->id()
]);
```

**When to use:**
- Performance issues (slow queries)
- Low assessment scores
- Failed API calls (retryable)
- Deprecated feature usage
- Resource usage near limits
- Missing optional data

### ERROR Level

**Use for:** Actual errors that need attention

```php
Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Database connection failed", [
    'error' => $exception->getMessage(),
    'connection' => $connectionName,
    'trace' => $exception->getTraceAsString()
]);

Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Authentication failed", [
    'email' => $request->email,
    'ip_address' => request()->ip(),
    'reason' => 'invalid_credentials',
    'attempts' => $loginAttempts
]);

Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Assessment scoring failed", [
    'assessment_id' => $assessmentId,
    'error' => $e->getMessage(),
    'user_id' => auth()->id(),
    'trace' => $e->getTraceAsString()
]);
```

**When to use:**
- Exception handling
- Database connection failures
- Authentication/authorization failures
- File system errors
- Integration failures
- Payment processing errors

### CRITICAL/EMERGENCY Levels

**Use for:** System-threatening issues

```php
Log::critical("File: " . __FILE__ . ":" . __LINE__ . " - Database corruption detected", [
    'table' => $tableName,
    'issue' => $corruptionDetails,
    'affected_records' => $count
]);

Log::emergency("File: " . __FILE__ . ":" . __LINE__ . " - System shutdown initiated", [
    'reason' => $shutdownReason,
    'initiated_by' => auth()->id()
]);
```

---

## Required Logging Points

### Method Entry & Exit

```php
public function processAssessment(Assessment $assessment): array
{
    // Log entry
    Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Processing assessment started", [
        'assessment_id' => $assessment->id,
        'user_id' => auth()->id()
    ]);

    // ... processing logic ...

    // Log exit
    Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Processing assessment completed", [
        'assessment_id' => $assessment->id,
        'result' => $result,
        'duration' => $duration
    ]);

    return $result;
}
```

### Before Database Operations

```php
// Before creating
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Creating client record", [
    'company_id' => $companyId,
    'name' => $data['name'],
    'user_id' => auth()->id()
]);

$client = Client::create($data);

// After creating
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Client record created", [
    'client_id' => $client->id,
    'company_id' => $companyId
]);
```

### External API Calls

```php
// Before API call
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Calling external API", [
    'endpoint' => $apiEndpoint,
    'method' => 'POST',
    'user_id' => auth()->id()
]);

try {
    $response = Http::post($apiEndpoint, $data);

    // After successful call
    Log::info("File: " . __FILE__ . ":" . __LINE__ . " - API call successful", [
        'endpoint' => $apiEndpoint,
        'status_code' => $response->status(),
        'response_time' => $responseTime
    ]);

} catch (\Exception $e) {
    // On error
    Log::error("File: " . __FILE__ . ":" . __LINE__ . " - API call failed", [
        'endpoint' => $apiEndpoint,
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);

    throw $e;
}
```

### Business Logic Decisions

```php
public function calculateRiskLevel(float $score): string
{
    Log::debug("File: " . __FILE__ . ":" . __LINE__ . " - Calculating risk level", [
        'score' => $score
    ]);

    if ($score >= 90) {
        Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Risk level determined: LOW", [
            'score' => $score
        ]);
        return 'low';
    }

    if ($score >= 70) {
        Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Risk level determined: MEDIUM", [
            'score' => $score
        ]);
        return 'medium';
    }

    Log::warning("File: " . __FILE__ . ":" . __LINE__ . " - Risk level determined: HIGH", [
        'score' => $score,
        'threshold_missed' => 70
    ]);
    return 'high';
}
```

---

## Context Standards

### Required Context Fields

```php
// ALWAYS include these in context when available:
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Action performed", [
    // User context
    'user_id' => auth()->id(),
    'user_email' => auth()->user()->email,
    'company_id' => auth()->user()->company_id,
    'msp_id' => auth()->user()->msp_id,

    // Request context
    'ip_address' => request()->ip(),
    'user_agent' => request()->userAgent(),
    'request_id' => request()->header('X-Request-ID'),

    // Entity context
    'entity_type' => 'assessment',
    'entity_id' => $assessment->id,

    // Action context
    'action' => 'create',
    'timestamp' => now()->toISOString(),

    // Additional data
    'metadata' => $additionalData
]);
```

### NEVER Log Sensitive Data

```php
// ❌ NEVER log these:
Log::info("User login", [
    'password' => $request->password,        // NEVER!
    'api_token' => $user->api_token,        // NEVER!
    'credit_card' => $payment->cc_number,   // NEVER!
    'ssn' => $user->ssn,                    // NEVER!
]);

// ✅ GOOD - Log safely:
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - User login attempt", [
    'email' => $request->email,
    'ip_address' => request()->ip(),
    'success' => true
    // No sensitive data!
]);
```

---

## Laravel Logging

### Log Channel Configuration

```php
// config/logging.php

'channels' => [
    // Standard daily log
    'daily' => [
        'driver' => 'daily',
        'path' => storage_path('logs/laravel.log'),
        'level' => env('LOG_LEVEL', 'debug'),
        'days' => 30,
    ],

    // Assessment-specific log
    'assessment' => [
        'driver' => 'daily',
        'path' => storage_path('logs/assessment.log'),
        'level' => 'info',
        'days' => 60,
    ],

    // Security log
    'security' => [
        'driver' => 'daily',
        'path' => storage_path('logs/security.log'),
        'level' => 'warning',
        'days' => 365,
    ],

    // Error-only log
    'errors' => [
        'driver' => 'daily',
        'path' => storage_path('logs/errors.log'),
        'level' => 'error',
        'days' => 90,
    ],
];
```

### Using Specific Channels

```php
// Log to specific channel
Log::channel('security')->warning("File: " . __FILE__ . ":" . __LINE__ . " - Failed login attempt", [
    'email' => $email,
    'ip_address' => request()->ip()
]);

Log::channel('assessment')->info("File: " . __FILE__ . ":" . __LINE__ . " - Assessment scored", [
    'assessment_id' => $assessment->id,
    'score' => $score
]);

// Log to multiple channels
Log::stack(['daily', 'security'])->error("File: " . __FILE__ . ":" . __LINE__ . " - Security breach detected", [
    'details' => $breachDetails
]);
```

### Custom Log Helper

```php
// app/Helpers/LogHelper.php

namespace App\Helpers;

use Illuminate\Support\Facades\Log;

class LogHelper
{
    /**
     * Log with standard context
     */
    public static function logWithContext(
        string $level,
        string $message,
        array $context = []
    ): void {
        $backtrace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 2);
        $caller = $backtrace[1] ?? $backtrace[0];

        $file = $caller['file'] ?? 'unknown';
        $line = $caller['line'] ?? 0;

        $formattedMessage = sprintf(
            "File: %s:%d - %s",
            $file,
            $line,
            $message
        );

        // Add standard context
        $standardContext = [
            'file' => basename($file),
            'line' => $line,
            'timestamp' => now()->toISOString(),
        ];

        // Add user context if available
        if (auth()->check()) {
            $standardContext['user_id'] = auth()->id();
            $standardContext['company_id'] = auth()->user()->company_id;
        }

        $fullContext = array_merge($standardContext, $context);

        Log::$level($formattedMessage, $fullContext);
    }

    public static function info(string $message, array $context = []): void
    {
        self::logWithContext('info', $message, $context);
    }

    public static function error(string $message, array $context = []): void
    {
        self::logWithContext('error', $message, $context);
    }
}
```

---

## Production Best Practices

### Log Rotation

```bash
# Laravel automatically rotates daily logs
# Configure retention in config/logging.php

'daily' => [
    'days' => 30,  // Keep 30 days of logs
],
```

### Performance Considerations

```php
// ✅ GOOD - Asynchronous logging for performance
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Heavy operation", $largeContext);

// ✅ GOOD - Conditional debug logging
if (config('app.debug')) {
    Log::debug("File: " . __FILE__ . ":" . __LINE__ . " - Debug info", $debugData);
}

// ❌ BAD - Logging in tight loops
foreach ($items as $item) {
    Log::debug("Processing item", ['item' => $item]); // Too much logging!
}

// ✅ BETTER - Batch logging
Log::debug("File: " . __FILE__ . ":" . __LINE__ . " - Processing items", [
    'count' => count($items),
    'sample' => array_slice($items, 0, 5)
]);
```

### Monitoring & Alerts

```php
// Set up alerts for critical logs
Log::critical("File: " . __FILE__ . ":" . __LINE__ . " - Payment processing failed", [
    'amount' => $amount,
    'user_id' => $userId,
    'error' => $error
]);
// This should trigger an alert to operations team
```

---

## Related Standards

- [PHP Standards](./03-php-standards.md)
- [Quality Standards](./08-quality-standards.md)
- [Security Standards](./11-security-standards.md)

---

**Next:** [Safety Rules →](./07-safety-rules.md)

**Last Updated:** January 2025
