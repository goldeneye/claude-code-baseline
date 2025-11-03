# Code Quality & Documentation Standards

**Ensuring Consistency, Maintainability & Excellence**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- ✅ Follow ALL coding standards documentation
- ✅ Add comprehensive PHPDoc to all public methods
- ✅ Include pseudo code for complex logic
- ✅ Match existing code patterns
- ✅ Update documentation with every change
- ✅ Code reviews are MANDATORY

---

## Table of Contents

1. [Documentation Compliance](#documentation-compliance)
2. [PHPDoc Standards](#phpdoc-standards)
3. [Pattern Consistency](#pattern-consistency)
4. [Code Quality Metrics](#code-quality-metrics)
5. [Code Review Standards](#code-review-standards)
6. [Best Practices](#best-practices)

---

## Documentation Compliance

### Core Documentation Files

ALL team members and AI assistants MUST reference these files:

```
MANDATORY REFERENCES:
├── CODING_STANDARDS.html (if exists)
├── CLAUDE.md (Central project reference)
├── README.md (Project overview)
└── coding-standards/ (This directory)
    ├── 01-pseudo-code-standards.md
    ├── 02-project-structure.md
    ├── 03-php-standards.md
    ├── 04-javascript-standards.md
    ├── 05-database-standards.md
    ├── 06-logging-standards.md
    ├── 07-safety-rules.md
    └── ... (all standards)
```

### Before Writing Code

```
PRE-CODING CHECKLIST:
☐ Read relevant coding standards
☐ Review CLAUDE.md for patterns
☐ Check existing similar code
☐ Understand multi-tenant requirements
☐ Plan pseudo code if complex
☐ Identify required documentation
```

### After Writing Code

```
POST-CODING CHECKLIST:
☐ Added comprehensive PHPDoc
☐ Included pseudo code if needed
☐ Added comprehensive logging
☐ Updated relevant documentation
☐ Followed existing patterns
☐ Passed all tests
☐ Updated changelog
```

---

## PHPDoc Standards

### Complete PHPDoc Template

```php
/**
 * Brief one-line description of what this method does
 *
 * Detailed multi-line explanation of the business logic,
 * assumptions, edge cases, and any important implementation
 * notes that developers should be aware of.
 *
 * Pseudo Code:
 * BEGIN methodName
 *   STEP 1: Validate inputs and permissions
 *   STEP 2: Process business logic
 *   STEP 3: Update database and cache
 *   STEP 4: Return formatted results
 * END methodName
 *
 * @param Assessment $assessment The assessment entity to process
 * @param User $user The user performing the action
 * @param array<string, mixed> $options Configuration options:
 *     - 'force_recalculate' (bool): Bypass cache, default false
 *     - 'include_archived' (bool): Include archived data, default false
 *     - 'format' (string): Output format (json|array), default 'array'
 *
 * @return array<string, mixed> {
 *     'success': bool,
 *     'score': int,
 *     'percentage': float,
 *     'risk_level': string,
 *     'metadata': array
 * }
 *
 * @throws UnauthorizedException When user lacks permission
 * @throws ValidationException When assessment is invalid
 * @throws \Exception When unexpected error occurs
 *
 * @example
 * $result = $service->calculateScore($assessment, $user, [
 *     'force_recalculate' => true
 * ]);
 * // Returns: ['success' => true, 'score' => 85, ...]
 *
 * @see AssessmentScoringService::validateScoring()
 * @link https://docs.compliancescorecard.com/assessment-scoring
 *
 * @since 2.1.0
 * @author ComplianceScorecard Dev Team
 */
public function calculateScore(
    Assessment $assessment,
    User $user,
    array $options = []
): array {
    // Implementation with comprehensive logging...
}
```

### Minimum PHPDoc Requirements

```php
// ✅ MINIMUM for all public methods
/**
 * Brief description
 *
 * @param Type $param Description
 * @return Type Description
 * @throws ExceptionType When condition
 */
public function methodName($param): Type
{
    // Implementation
}

// ✅ REQUIRED for complex methods
/**
 * Brief description
 *
 * Detailed explanation of logic.
 *
 * Pseudo Code:
 * BEGIN methodName
 *   STEPS...
 * END
 *
 * @param Type $param
 * @return Type
 * @throws Exception
 * @example Usage example
 */
public function complexMethod($param): Type
{
    // Implementation
}
```

---

## Pattern Consistency

### ALWAYS Follow Existing Patterns

#### Code Structure Patterns

```php
// ✅ GOOD - Follows existing controller pattern
public function store(StoreAssessmentRequest $request): JsonResponse
{
    Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Creating assessment", [
        'user_id' => auth()->id(),
        'data' => $request->validated()
    ]);

    try {
        $assessment = $this->service->create($request->validated());

        return response()->json([
            'data' => new AssessmentResource($assessment),
            'message' => 'Assessment created successfully'
        ], 201);
    } catch (\Exception $e) {
        Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Creation failed", [
            'error' => $e->getMessage()
        ]);

        throw $e;
    }
}

// ❌ BAD - Doesn't follow pattern
public function store($r) {
    $a = Assessment::create($r->all());
    return $a;  // No logging, no error handling, no pattern compliance
}
```

#### Service Layer Patterns

```php
// ✅ GOOD - Follows existing service pattern
class AssessmentService
{
    private AssessmentRepository $repository;
    private PermissionService $permissions;

    public function __construct(
        AssessmentRepository $repository,
        PermissionService $permissions
    ) {
        $this->repository = $repository;
        $this->permissions = $permissions;
    }

    public function create(array $data): Assessment
    {
        $this->permissions->ensureCanCreate(auth()->user(), 'assessment');

        DB::beginTransaction();

        try {
            $assessment = $this->repository->create($data);

            Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Assessment created", [
                'id' => $assessment->id
            ]);

            DB::commit();

            return $assessment;
        } catch (\Exception $e) {
            DB::rollBack();

            Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Create failed", [
                'error' => $e->getMessage()
            ]);

            throw $e;
        }
    }
}
```

#### Error Handling Patterns

```php
// ✅ GOOD - Consistent error handling
try {
    $result = $this->performOperation();

    Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Operation succeeded", [
        'result' => $result
    ]);

    return $result;
} catch (ValidationException $e) {
    Log::warning("File: " . __FILE__ . ":" . __LINE__ . " - Validation error", [
        'errors' => $e->errors()
    ]);

    throw $e;
} catch (UnauthorizedException $e) {
    Log::warning("File: " . __FILE__ . ":" . __LINE__ . " - Unauthorized", [
        'user_id' => auth()->id()
    ]);

    throw $e;
} catch (\Exception $e) {
    Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Unexpected error", [
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);

    throw $e;
}
```

---

## Code Quality Metrics

### Code Complexity

```php
// ✅ GOOD - Simple, readable
public function isEligible(User $user): bool
{
    if (!$user->isActive()) {
        return false;
    }

    if (!$user->hasSubscription()) {
        return false;
    }

    if ($user->isSuspended()) {
        return false;
    }

    return true;
}

// ❌ BAD - Too complex, nested
public function isEligible(User $user): bool
{
    if ($user->isActive()) {
        if ($user->hasSubscription()) {
            if (!$user->isSuspended()) {
                if ($user->company->isActive()) {
                    if ($user->company->hasValidPayment()) {
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

// ✅ BETTER - Refactor complex logic
public function isEligible(User $user): bool
{
    return $this->isUserActive($user)
        && $this->hasValidSubscription($user)
        && $this->companyInGoodStanding($user->company);
}
```

### Method Length

```
GUIDELINES:
- Keep methods under 50 lines
- If over 50 lines, consider refactoring
- Extract complex logic to private methods
- One method should do one thing well
```

### Naming Clarity

```php
// ✅ GOOD - Clear, descriptive names
public function calculateAssessmentCompletionPercentage(Assessment $assessment): float
public function getUserActiveSubscriptions(User $user): Collection
public function validateClientHasRequiredPermissions(Client $client): bool

// ❌ BAD - Unclear, abbreviated
public function calc(Assessment $a): float
public function getUSub(User $u): Collection
public function chkPerm(Client $c): bool
```

---

## Code Review Standards

### Code Review Checklist

```
REVIEWER CHECKLIST:
☐ Follows all coding standards
☐ Includes comprehensive PHPDoc
☐ Has pseudo code for complex logic
☐ Includes comprehensive logging
☐ Follows existing patterns
☐ No security vulnerabilities
☐ Proper error handling
☐ Tests included and passing
☐ Documentation updated
☐ No hardcoded values
☐ Multi-tenant isolation maintained
☐ Performance considerations addressed
```

### What to Look For

#### 1. Documentation Quality
```php
// ✅ APPROVED
/**
 * Calculate weighted assessment score
 *
 * Pseudo Code:
 * BEGIN calculateScore
 *   VALIDATE assessment has questions
 *   CALCULATE weighted total
 *   RETURN percentage
 * END
 *
 * @param Assessment $assessment
 * @return float
 */

// ❌ REJECTED - Insufficient documentation
// Calculate score
public function calc($a) { }
```

#### 2. Safety Compliance
```php
// ✅ APPROVED - Safe database operation
Schema::table('assessments', function (Blueprint $table) {
    $table->string('new_field')->nullable();
});

// ❌ REJECTED - Unsafe operation
Schema::dropIfExists('assessments');  // NEVER without approval!
```

#### 3. Pattern Consistency
```php
// ✅ APPROVED - Matches existing patterns
Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Action", [
    'user_id' => auth()->id()
]);

// ❌ REJECTED - Doesn't follow logging standard
error_log("Action");  // Wrong pattern!
```

---

## Best Practices

### Clean Code Principles

```php
// ✅ GOOD - Clean, self-documenting
public function processAssessmentSubmission(Assessment $assessment): array
{
    $this->validateAssessment($assessment);
    $score = $this->calculateScore($assessment);
    $risk = $this->determineRiskLevel($score);

    return [
        'score' => $score,
        'risk_level' => $risk,
        'completed_at' => now()
    ];
}

// ❌ BAD - Unclear, no structure
public function process($a) {
    $s = 0;
    foreach ($a->q as $q) {
        $s += $q->s;
    }
    return ['s' => $s];
}
```

### DRY (Don't Repeat Yourself)

```php
// ✅ GOOD - Reusable method
private function formatUserName(User $user): string
{
    return trim("{$user->first_name} {$user->last_name}");
}

public function getUserDisplay(User $user): string
{
    return $this->formatUserName($user);
}

public function getAssessmentCreator(Assessment $assessment): string
{
    return $this->formatUserName($assessment->creator);
}

// ❌ BAD - Repeated code
public function getUserDisplay(User $user): string
{
    return trim("{$user->first_name} {$user->last_name}");
}

public function getAssessmentCreator(Assessment $assessment): string
{
    return trim("{$assessment->creator->first_name} {$assessment->creator->last_name}");
}
```

### SOLID Principles

```php
// ✅ GOOD - Single Responsibility
class AssessmentScorer
{
    public function calculate(Assessment $assessment): float
    {
        // Only responsible for scoring
    }
}

class AssessmentReporter
{
    public function generate(Assessment $assessment): Report
    {
        // Only responsible for reports
    }
}

// ❌ BAD - Multiple responsibilities
class AssessmentManager
{
    public function calculate() { }
    public function generateReport() { }
    public function sendEmail() { }
    public function updateDatabase() { }
    // Too many responsibilities!
}
```

---

## Quality Gates

### Before Committing

```bash
# Run these checks:
✅ php artisan test           # All tests pass
✅ ./vendor/bin/phpstan        # Static analysis
✅ ./vendor/bin/phpcs          # Code style
✅ npm run lint                # JavaScript linting
✅ npm run test                # Frontend tests
```

### Before Creating PR

```
PR QUALITY CHECKLIST:
☐ All tests passing
☐ Code review completed
☐ Documentation updated
☐ Changelog updated
☐ No console.log() or dd() left
☐ No commented code
☐ No TODO comments without tickets
☐ Performance tested
☐ Security reviewed
```

---

## Related Standards

- [PHP Standards](./03-php-standards.md)
- [JavaScript Standards](./04-javascript-standards.md)
- [Safety Rules](./07-safety-rules.md)
- [Testing Standards](./10-testing-standards.md)

---

**Next:** [GitHub & Jira Workflow →](./09-github-jira-workflow.md)

**Last Updated:** January 2025
