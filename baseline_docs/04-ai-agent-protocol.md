---
title: {{PROJECT_NAME}} - AI Agent Protocol & Claude Code Workflow
version: 1.0
last_updated: 2025-11-02
author: ComplianceScorecard Engineering
---

# {{PROJECT_NAME}} — AI Agent Protocol & Claude Code Workflow

## 1. Overview

This document defines the protocols and workflows for AI-driven development using Claude Code and other AI assistants on {{PROJECT_NAME}}. It establishes guardrails, best practices, and integration patterns for AI-augmented software engineering.

---

## 2. Claude Code Development Protocol

### 2.1 Project Context for Claude

**Essential Context Files**:
- `CODING_STANDARDS.md` - **MUST READ** before making changes
- `README.md` - Project overview and quick start
- `Architecture-Overview.md` - System design and data flows
- `.env.example` - Required environment variables

**Key Commands for Claude**:
```bash
# Read coding standards first
cat CODING_STANDARDS.md

# Understand project structure
ls -R app/ resources/js/ scanners/

# Check current status
git status
php artisan route:list
composer show

# Run tests before changes
php artisan test
npm test
```

### 2.2 Claude Code Guidelines

**What Claude MUST do**:
1. Read `CODING_STANDARDS.md` before ANY code changes
2. Follow file header convention: `// File: path/to/file.php`
3. Use logging format: `Log::info("FILENAME.php LINE " . __LINE__ . " Message")`
4. Document all classes/methods with PHPDoc blocks
5. Implement try-catch blocks for error handling
6. Run tests after changes
7. Ask clarifying questions when requirements are ambiguous

**What Claude MUST NOT do**:
- Commit sensitive data or credentials
- Modify database schema without migrations
- Skip documentation or logging
- Use deprecated patterns or libraries
- Make assumptions about business logic

### 2.3 Development Workflow with Claude

**Step-by-Step Process**:

1. **Understanding Phase**
```bash
# Claude reads existing implementation
cat app/Services/GradingService.php

# Claude asks clarifying questions
"Should the new grading scale apply to all compliance frameworks or just specific ones?"
```

2. **Planning Phase**
```bash
# Claude outlines implementation plan
"I will:
1. Add new grading scale to database
2. Update GradingService to use database-driven scales
3. Create migration for grading_rules table
4. Add tests for new grading logic
5. Update documentation"
```

3. **Implementation Phase**
```php
// Claude creates migration
php artisan make:migration create_grading_rules_table

// Claude updates service with logging
Log::info("GradingService.php LINE " . __LINE__ . " Loading grading scales from database");

// Claude adds comprehensive error handling
try {
    $scales = $this->loadScalesFromDatabase();
} catch (\Throwable $e) {
    Log::error("GradingService.php LINE " . __LINE__ . " Failed to load scales", [
        'error' => $e->getMessage(),
    ]);
    return $this->getFallbackScales();
}
```

4. **Testing Phase**
```bash
# Claude runs tests
php artisan test --filter=GradingServiceTest

# Claude verifies migration
php artisan migrate:fresh --seed
```

5. **Documentation Phase**
```markdown
# Claude updates README.md
## Grading System

The system now supports database-driven grading scales...
```

---

## 3. AI-Driven Client Segmentation

### 3.1 Architecture

**Multi-Provider Support**:
```
MSP → Configures AI Provider
        ├─> GPT-OSS (Free, Default)
        ├─> OpenAI (BYO API Key)
        ├─> Anthropic (BYO API Key)
        └─> Custom Endpoint
```

**Data Flow**:
```
Client CSV Upload
  ↓
Parse & Store (client_imports)
  ↓
Queue AI Analysis Job
  ↓
AIServiceFactory → Route to Provider
  ↓
Retrieve Encrypted API Key
  ↓
Build Segmentation Prompt
  ↓
Execute AI Request
  ↓
Validate JSON Response
  ↓
Encrypt & Store Results (segmentation_results)
  ↓
Update Audit Log
```

### 3.2 AI Prompt Engineering

**Segmentation Prompt Template**:
```json
{
  "system": "You are a cybersecurity analyst specializing in SMB/MSP client assessment.",
  "user": "Analyze the following client data and provide segmentation:\n\nClient: {{CLIENT_NAME}}\nDomain: {{DOMAIN}}\nIndustry: {{INDUSTRY}}\nEmployees: {{EMPLOYEE_COUNT}}\n\nProvide JSON output with:\n- score (0-100)\n- segment (ideal/emerging/risky)\n- reason (brief explanation)\n- suggested_action (next step for MSP)",
  "temperature": 0.3,
  "max_tokens": 500
}
```

**Expected AI Response Format**:
```json
{
  "score": 88,
  "segment": "ideal",
  "reason": "M365 active, 25-50 employees, healthcare industry with high compliance needs",
  "suggested_action": "Offer FTC Safeguards audit + HIPAA compliance package"
}
```

### 3.3 AI Integration Guardrails

**Prompt Injection Prevention**:
```php
// Sanitize user input before AI prompt
$sanitizedDomain = preg_replace('/[^a-z0-9.-]/i', '', $domain);
$sanitizedIndustry = substr($industry, 0, 50);  // Limit length
```

**Output Validation**:
```php
// Validate AI response schema
$schema = [
    'score' => 'required|integer|between:0,100',
    'segment' => 'required|in:ideal,emerging,risky',
    'reason' => 'required|string|max:500',
    'suggested_action' => 'required|string|max:500',
];

$validator = Validator::make($aiResponse, $schema);
if ($validator->fails()) {
    throw new \RuntimeException('Invalid AI response format');
}
```

**Rate Limiting**:
```php
// Per-MSP AI request limits
'ai_rate_limit' => [
    'requests_per_minute' => 10,
    'requests_per_day' => 1000,
    'token_limit_per_request' => 2000,
];
```

### 3.4 BYO API Key Management

**Secure Storage Pattern**:
```php
// Store encrypted API key
MspAiSetting::create([
    'msp_id' => $mspId,
    'provider' => 'openai',
    'api_key' => Crypt::encryptString($apiKey),  // ← Encrypted
    'endpoint' => 'https://api.openai.com/v1/chat/completions',
    'model' => 'gpt-4',
]);

// Retrieve and decrypt at runtime
$setting = MspAiSetting::where('msp_id', $mspId)->first();
$apiKey = Crypt::decryptString($setting->api_key);

// Never log decrypted key
Log::info("AIService.php LINE " . __LINE__ . " Using provider", [
    'provider' => $setting->provider,
    'model' => $setting->model,
    // 'api_key' => $apiKey,  // ❌ NEVER LOG THIS
]);
```

**AI Provider Factory**:
```php
class AIServiceFactory
{
    public static function create(MspAiSetting $setting): AIServiceInterface
    {
        return match($setting->provider) {
            'openai' => new OpenAIService($setting),
            'anthropic' => new AnthropicService($setting),
            'gpt-oss' => new GPTOSSService($setting),
            default => new GPTOSSService($setting),  // Fallback to free
        };
    }
}
```

---

## 4. Automated Code Review with AI

### 4.1 Pre-Commit AI Review

**Claude Code Review Checklist**:
```markdown
# Code Review Checklist (AI-Assisted)

## Security
- [ ] No hardcoded secrets or credentials
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (escaping output)
- [ ] CSRF protection (where applicable)
- [ ] Encrypted sensitive fields

## Code Quality
- [ ] Follows PSR-12 coding standards
- [ ] Comprehensive error handling (try-catch)
- [ ] Logging with file + line number
- [ ] PHPDoc documentation complete
- [ ] No N+1 query problems

## Testing
- [ ] Unit tests for new services
- [ ] Feature tests for new endpoints
- [ ] Tests pass locally
- [ ] Edge cases covered

## Performance
- [ ] Database queries optimized (eager loading)
- [ ] Caching implemented for expensive operations
- [ ] Queue jobs for long-running tasks
```

### 4.2 AI-Generated Test Cases

**Prompt for Claude**:
```
Generate comprehensive test cases for the GradingService::evaluateResultSet() method.
Include:
- Happy path tests
- Edge cases (zero total, negative values)
- Boundary tests (exactly 90%, 89.9%)
- Error handling tests
```

**Claude Output**:
```php
public function test_evaluate_result_set_with_perfect_score(): void
{
    $service = app(GradingService::class);
    $result = $service->evaluateResultSet(50, 50, 'scan');

    $this->assertEquals('A', $result['label']);
    $this->assertEquals(4.0, $result['gpa']);
    $this->assertEquals(100.0, $result['percent']);
}

public function test_evaluate_result_set_with_zero_total(): void
{
    $service = app(GradingService::class);
    $result = $service->evaluateResultSet(0, 0, 'scan');

    $this->assertEquals('F', $result['label']);
    $this->assertEquals(0.0, $result['gpa']);
}

// ... more tests
```

---

## 5. AI Debugging Assistant Protocol

### 5.1 Debugging Workflow

**Step 1: Gather Context**
```bash
# Claude reads error logs
tail -100 storage/logs/laravel.log | grep ERROR

# Claude examines failing code
cat app/Jobs/RunDomainScanner.php

# Claude checks database state
php artisan tinker
>>> ScanResult::find(101)->results->count()
```

**Step 2: Hypothesize Root Cause**
```markdown
Claude's Analysis:
"The scan is failing because RunWebPrivacyScan is dispatched AFTER
compliance checks, but web privacy checks need that data. The execution
order was changed (see comment on line 161)."
```

**Step 3: Propose Solution**
```php
// Current (broken)
Line 98:  RunCheckJob::dispatchSync(...);  // Runs first
Line 164: RunWebPrivacyScan::dispatchSync(...);  // Runs AFTER checks

// Proposed fix
Line 75:  RunWebPrivacyScan::dispatchSync(...);  // Run BEFORE checks
Line 98:  RunCheckJob::dispatchSync(...);
```

**Step 4: Implement & Verify**
```bash
# Claude makes change
# Claude runs test
php artisan test --filter=WebPrivacyCheckTest

# Success! Tests pass
```

### 5.2 Common Debugging Patterns

**Database Relationship Issues**:
```php
// Claude identifies N+1 query
// Before:
$scans = ScanResult::all();
foreach ($scans as $scan) {
    echo $scan->results->count();  // ❌ Query per iteration
}

// After (Claude's fix):
$scans = ScanResult::withCount('results')->get();
foreach ($scans as $scan) {
    echo $scan->results_count;  // ✅ Single query
}
```

**Missing Data Access**:
```php
// Claude traces data flow
$dns = $this->getDnsResult($scan);  // Returns null
// Claude checks scanner execution order
// Claude finds: DNS scan not run yet
// Claude proposes: Ensure RunDnsScan runs synchronously first
```

---

## 6. AI Documentation Generation

### 6.1 Auto-Generated API Docs

**OpenAPI/Swagger Annotation**:
```php
/**
 * @OA\Post(
 *     path="/api/v1/scan",
 *     summary="Submit domain for scanning",
 *     @OA\RequestBody(
 *         required=true,
 *         @OA\JsonContent(
 *             @OA\Property(property="domain", type="string", example="example.com"),
 *             @OA\Property(property="priority", type="string", enum={"high","normal","low"})
 *         )
 *     ),
 *     @OA\Response(response=200, description="Scan initiated"),
 *     @OA\Response(response=422, description="Validation error")
 * )
 */
public function store(Request $request): JsonResponse
{
    // ...
}
```

**Generate Docs**:
```bash
php artisan l5-swagger:generate
```

### 6.2 AI-Generated Change Logs

**Prompt for Claude**:
```
Analyze the git diff and generate a changelog entry in this format:

## [Version] - YYYY-MM-DD
### Added
- New features
### Changed
- Modifications
### Fixed
- Bug fixes
```

**Claude Output**:
```markdown
## [1.2.0] - 2025-11-02
### Added
- AI-driven client segmentation with multi-provider support
- BYO API key management for OpenAI/Anthropic
- Encrypted storage for AI analysis results

### Changed
- Updated GradingService to support database-driven grading scales
- Moved web privacy scan execution before compliance checks

### Fixed
- Fixed N+1 query issue in ScanResult results loading
- Resolved cross-tenant data access in client segmentation
```

---

## 7. AI Testing & QA Protocol

### 7.1 Test-Driven Development with AI

**Process**:
1. Claude writes failing test first
2. Human reviews test logic
3. Claude implements feature to pass test
4. Human reviews implementation
5. Refactor if needed

**Example**:
```php
// Step 1: Claude writes test
public function test_ai_segmentation_validates_schema(): void
{
    $invalidResponse = ['score' => 150];  // Invalid score

    $this->expectException(\RuntimeException::class);
    $this->expectExceptionMessage('Invalid AI response format');

    app(AIAnalyzerService::class)->validateResponse($invalidResponse);
}

// Step 2: Claude implements validation
public function validateResponse(array $response): void
{
    $validator = Validator::make($response, [
        'score' => 'required|integer|between:0,100',
        'segment' => 'required|in:ideal,emerging,risky',
    ]);

    if ($validator->fails()) {
        throw new \RuntimeException('Invalid AI response format');
    }
}
```

### 7.2 AI-Generated Edge Case Tests

**Prompt**:
```
Generate edge case tests for the email validation function.
Consider: empty strings, special characters, internationalized domains,
very long emails, SQL injection attempts.
```

**Claude Output**:
```php
public function test_email_validation_edge_cases(): void
{
    $service = app(EmailValidationService::class);

    // Empty/null
    $this->assertFalse($service->isValid(''));
    $this->assertFalse($service->isValid(null));

    // Special characters
    $this->assertTrue($service->isValid('user+tag@example.com'));
    $this->assertFalse($service->isValid('user@'));

    // Internationalized
    $this->assertTrue($service->isValid('user@münchen.de'));

    // SQL injection attempt
    $this->assertFalse($service->isValid("'; DROP TABLE users--"));
}
```

---

## 8. Best Practices Summary

### 8.1 For Human Developers

- **Review AI Code**: Never merge AI-generated code without review
- **Provide Context**: Give Claude comprehensive project documentation
- **Ask Questions**: Clarify ambiguous AI responses before implementing
- **Test Thoroughly**: Run full test suite after AI changes

### 8.2 For AI Assistants (Claude)

- **Read Standards First**: Always consult CODING_STANDARDS.md
- **Log Comprehensively**: Include file + line number in all logs
- **Handle Errors**: Implement try-catch with detailed error messages
- **Document Everything**: PHPDoc for classes/methods
- **Test Changes**: Run tests and verify output before completing

### 8.3 Security Guardrails

- **Never Log Secrets**: API keys, passwords, tokens
- **Validate AI Output**: Schema validation for all AI responses
- **Encrypt Sensitive Data**: Use `Crypt` for PII and keys
- **Sanitize Prompts**: Prevent prompt injection attacks
- **Rate Limit AI**: Protect against abuse and cost overruns

---

## See Also

- [Coding Standards](coding-standards.md) - Comprehensive style guide
- [Security Specification](02-security.md) - Security protocols
- [Testing Guide](07-testing-and-QA.md) - Testing strategies

---

**Last Updated**: 2025-11-02
**Document Version**: 1.0
**Status**: Production-Ready Baseline
