# PHP Coding Standards

**PSR-12 Compliance & Laravel Best Practices**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- Follow PSR-12 standard strictly
- 4 spaces for indentation (NO tabs)
- 120 character line limit
- Type hints for all parameters and returns
- Comprehensive PHPDoc blocks
- Laravel conventions and patterns

---

## Table of Contents

1. [PSR-12 Compliance](#psr-12-compliance)
2. [Class Structure](#class-structure)
3. [Method Standards](#method-standards)
4. [PHPDoc Documentation](#phpdoc-documentation)
5. [Type Declarations](#type-declarations)
6. [Laravel-Specific Patterns](#laravel-specific-patterns)
7. [Common Patterns](#common-patterns)
8. [Code Examples](#code-examples)

---

## PSR-12 Compliance

### Core Requirements

- ✅ **4 spaces** for indentation (never tabs)
- ✅ **120 characters** maximum line length
- ✅ **Opening braces** on same line for methods
- ✅ **One blank line** after namespace declaration
- ✅ **Proper namespace** declarations
- ✅ **Type declarations** for all parameters
- ✅ **Return type declarations** for all methods
- ✅ **Visibility** declared on all properties and methods

### Formatting Rules

```php
<?php

namespace App\Http\Controllers\Api\V3;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ExampleController extends Controller
{
    private AssessmentService $service;

    public function __construct(AssessmentService $service)
    {
        $this->service = $service;
    }

    public function index(Request $request): JsonResponse
    {
        // Method body with 4-space indentation
        return response()->json([
            'data' => $this->service->getAll()
        ]);
    }
}
```

### Indentation Examples

```php
// ✅ GOOD - 4 spaces
if ($condition) {
    foreach ($items as $item) {
        if ($item->isValid()) {
            processItem($item);
        }
    }
}

// ❌ BAD - Tabs or 2 spaces
if ($condition) {
  foreach ($items as $item) {  // 2 spaces - WRONG
	if ($item->isValid()) {      // Tab - WRONG
	  processItem($item);
	}
  }
}
```

---

## Class Structure

### Standard Class Organization

```php
<?php
// File: app/Models/Assessment/AssessmentTemplate.php

/*
 * © 2025 ComplianceRisk.io Inc. ...
 */

namespace App\Models\Assessment;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Collection;
use Carbon\Carbon;

/**
 * Class AssessmentTemplate
 *
 * Represents assessment templates in the multi-tenant system.
 * Templates can be global (Super Admin) or MSP-specific.
 *
 * @package App\Models\Assessment
 *
 * @property string $id
 * @property string $name
 * @property string|null $description
 * @property bool $is_global_template
 * @property string|null $original_template_id
 * @property string|null $subscription_category
 * @property string $status
 * @property string|null $company_id
 * @property string|null $msp_id
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property Carbon|null $deleted_at
 *
 * @property-read Collection|AssessmentEvent[] $events
 * @property-read Collection|AssessmentTemplateQuestion[] $questions
 * @property-read AssessmentTemplate|null $originalTemplate
 */
class AssessmentTemplate extends Model
{
    use SoftDeletes;

    // ========================================
    // 1. CONSTANTS
    // ========================================

    public const STATUS_DRAFT = 'Draft';
    public const STATUS_PUBLISHED = 'Published';
    public const STATUS_ARCHIVED = 'Archived';

    public const SUBSCRIPTION_LITE = 'lite';
    public const SUBSCRIPTION_PLUS = 'plus';
    public const SUBSCRIPTION_ENTERPRISE = 'enterprise';

    // ========================================
    // 2. PROPERTIES
    // ========================================

    protected $fillable = [
        'name',
        'description',
        'is_global_template',
        'original_template_id',
        'subscription_category',
        'status',
        'company_id',
        'msp_id',
    ];

    protected $casts = [
        'is_global_template' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected $attributes = [
        'status' => self::STATUS_DRAFT,
        'is_global_template' => false,
    ];

    // ========================================
    // 3. RELATIONSHIPS
    // ========================================

    public function events(): HasMany
    {
        return $this->hasMany(AssessmentEvent::class, 'template_id');
    }

    public function questions(): HasMany
    {
        return $this->hasMany(AssessmentTemplateQuestion::class, 'template_id')
            ->orderBy('sort_order');
    }

    public function originalTemplate(): BelongsTo
    {
        return $this->belongsTo(AssessmentTemplate::class, 'original_template_id');
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class, 'company_id');
    }

    // ========================================
    // 4. ACCESSORS & MUTATORS
    // ========================================

    public function getIsGlobalAttribute(): bool
    {
        return $this->is_global_template;
    }

    public function getSubscriptionTypeAttribute(): ?string
    {
        return $this->subscription_category;
    }

    public function getIsPublishedAttribute(): bool
    {
        return $this->status === self::STATUS_PUBLISHED;
    }

    // ========================================
    // 5. SCOPES
    // ========================================

    public function scopePublished($query)
    {
        return $query->where('status', self::STATUS_PUBLISHED);
    }

    public function scopeGlobal($query)
    {
        return $query->where('is_global_template', true);
    }

    public function scopeForCompany($query, string $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    public function scopeActive($query)
    {
        return $query->where('status', '!=', self::STATUS_ARCHIVED);
    }

    // ========================================
    // 6. PUBLIC METHODS
    // ========================================

    /**
     * Clone this template for an MSP company
     *
     * Pseudo Code:
     * BEGIN cloneForMsp
     *   VALIDATE template is global
     *   CHECK if clone already exists
     *   CREATE template replica
     *   CLONE all questions
     *   RETURN cloned template
     * END
     *
     * @param string $companyId The MSP company ID
     * @return self The cloned template
     * @throws \InvalidArgumentException If template is not global
     */
    public function cloneForMsp(string $companyId): self
    {
        if (!$this->is_global_template) {
            throw new \InvalidArgumentException('Only global templates can be cloned');
        }

        // Check for existing clone
        $existing = self::where('company_id', $companyId)
            ->where('original_template_id', $this->id)
            ->first();

        if ($existing) {
            return $existing;
        }

        $clone = $this->replicate();
        $clone->company_id = $companyId;
        $clone->is_global_template = false;
        $clone->original_template_id = $this->id;
        $clone->status = self::STATUS_DRAFT;
        $clone->save();

        // Clone questions
        foreach ($this->questions as $question) {
            $clonedQuestion = $question->replicate();
            $clonedQuestion->template_id = $clone->id;
            $clonedQuestion->save();
        }

        return $clone;
    }

    /**
     * Check if user has access to this template
     *
     * @param User $user
     * @return bool
     */
    public function isAccessibleBy(User $user): bool
    {
        // Super admin can access all
        if ($user->isSuperAdmin()) {
            return true;
        }

        // Global templates accessible with right subscription
        if ($this->is_global_template) {
            return $user->hasSubscription($this->subscription_category);
        }

        // Company templates accessible to company members
        return $this->company_id === $user->company_id;
    }

    /**
     * Publish this template
     *
     * @return bool
     */
    public function publish(): bool
    {
        $this->status = self::STATUS_PUBLISHED;
        return $this->save();
    }

    // ========================================
    // 7. PROTECTED/PRIVATE METHODS
    // ========================================

    protected function validateQuestions(): bool
    {
        return $this->questions()->count() > 0;
    }
}
```

### Class Organization Order

1. **Constants** - Class constants (STATUS_, TYPE_, etc.)
2. **Properties** - $fillable, $casts, $attributes, etc.
3. **Relationships** - Eloquent relationships
4. **Accessors & Mutators** - get/set attribute methods
5. **Scopes** - Query scopes
6. **Public Methods** - Public API methods
7. **Protected/Private Methods** - Internal helper methods

---

## Method Standards

### Method Structure

```php
/**
 * Brief description of what the method does
 *
 * Detailed explanation of business logic, edge cases,
 * and any important implementation notes.
 *
 * Pseudo Code:
 * BEGIN methodName
 *   VALIDATE inputs
 *   PERFORM main logic
 *   RETURN result
 * END
 *
 * @param string $param1 Description of parameter
 * @param int $param2 Description of parameter
 * @return array The result data
 * @throws InvalidArgumentException When validation fails
 */
public function methodName(string $param1, int $param2): array
{
    // 1. Input validation
    if (empty($param1)) {
        throw new InvalidArgumentException('param1 cannot be empty');
    }

    // 2. Business logic
    $result = $this->processData($param1, $param2);

    // 3. Return result
    return $result;
}
```

### Method Visibility

```php
// ✅ GOOD - Explicit visibility
public function publicMethod(): void { }
protected function protectedMethod(): void { }
private function privateMethod(): void { }

// ❌ BAD - No visibility declared
function badMethod(): void { }  // Missing visibility
```

### Method Naming

```php
// ✅ GOOD - Descriptive camelCase
public function calculateAssessmentScore(): int { }
public function getUserPermissions(): array { }
public function isUserAuthorized(): bool { }
public function hasValidSubscription(): bool { }

// ❌ BAD - Unclear or wrong case
public function calc(): int { }  // Too short
public function Calculate_Score(): int { }  // Wrong case
public function get(): array { }  // Not descriptive
```

---

## PHPDoc Documentation

### Complete PHPDoc Template

```php
/**
 * Brief one-line description (under 80 chars)
 *
 * Detailed multi-line description explaining the purpose,
 * business logic, assumptions, and any important notes
 * about the implementation.
 *
 * Pseudo Code:
 * BEGIN functionName
 *   STEP 1: Describe first step
 *   STEP 2: Describe second step
 *   STEP 3: Describe return
 * END functionName
 *
 * @param string $userId The unique user identifier
 * @param array<string, mixed> $options Configuration options:
 *     - 'include_archived' (bool): Include archived records
 *     - 'limit' (int): Maximum results to return
 * @param bool $forceRefresh Whether to bypass cache
 *
 * @return array<string, mixed> {
 *     'success': bool,
 *     'data': array,
 *     'message': string,
 *     'count': int
 * }
 *
 * @throws InvalidArgumentException When userId is empty
 * @throws UnauthorizedException When user lacks permission
 * @throws \Exception When unexpected error occurs
 *
 * @example
 * $result = $service->getUserData('123', ['limit' => 10]);
 * // Returns: ['success' => true, 'data' => [...], 'count' => 10]
 *
 * @see UserService::getUser()
 * @link https://docs.compliancescorecard.com/api/users
 *
 * @since 1.2.0
 * @author ComplianceScorecard Dev Team
 */
public function getUserData(
    string $userId,
    array $options = [],
    bool $forceRefresh = false
): array {
    // Implementation...
}
```

### Property Documentation

```php
/**
 * Class AssessmentEvent
 *
 * @property string $id UUID primary key
 * @property string $template_id Reference to template
 * @property string $client_id Reference to client
 * @property string $status Current status
 * @property Carbon|null $completed_at Completion timestamp
 * @property Carbon $created_at Creation timestamp
 * @property Carbon $updated_at Last update timestamp
 *
 * @property-read AssessmentTemplate $template
 * @property-read Client $client
 * @property-read Collection|AssessmentEventAnswer[] $answers
 */
class AssessmentEvent extends Model
{
    // ...
}
```

---

## Type Declarations

### Strict Types

```php
<?php
declare(strict_types=1);

namespace App\Services;

class ExampleService
{
    // Strict type checking enabled
}
```

### Parameter Type Hints

```php
// ✅ GOOD - All parameters typed
public function processAssessment(
    Assessment $assessment,
    User $user,
    array $options = [],
    ?string $comment = null
): AssessmentResult {
    // Implementation
}

// ❌ BAD - No type hints
public function processAssessment($assessment, $user, $options, $comment) {
    // Implementation
}
```

### Return Type Declarations

```php
// ✅ GOOD - Return types declared
public function getUser(string $id): ?User { }
public function getUserIds(): array { }
public function isValid(): bool { }
public function getCount(): int { }
public function getScore(): float { }
public function processData(): void { }

// ❌ BAD - No return type
public function getUser(string $id) { }  // Missing return type
```

### Nullable Types

```php
// ✅ GOOD - Properly handle nullables
public function findUser(string $id): ?User
{
    return User::find($id);  // May return null
}

public function getUserName(?User $user): string
{
    return $user?->name ?? 'Unknown';
}

// Union types (PHP 8+)
public function getValue(string $key): int|string|null
{
    return $this->data[$key] ?? null;
}
```

---

## Laravel-Specific Patterns

### Controller Pattern

```php
<?php
// File: app/Http/Controllers/Api/V3/AssessmentController.php

namespace App\Http\Controllers\Api\V3;

use App\Http\Controllers\Controller;
use App\Http\Requests\Assessment\StoreAssessmentRequest;
use App\Http\Resources\AssessmentResource;
use App\Models\Assessment\AssessmentEvent;
use App\Services\Assessment\AssessmentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AssessmentController extends Controller
{
    private AssessmentService $service;

    public function __construct(AssessmentService $service)
    {
        $this->service = $service;
    }

    /**
     * Display a listing of assessments
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Fetching assessments", [
            'user_id' => auth()->id(),
            'company_id' => auth()->user()->company_id
        ]);

        $assessments = $this->service->getAll($request->all());

        return response()->json([
            'data' => AssessmentResource::collection($assessments),
            'meta' => [
                'total' => $assessments->total(),
                'per_page' => $assessments->perPage()
            ]
        ]);
    }

    /**
     * Store a newly created assessment
     *
     * @param StoreAssessmentRequest $request
     * @return JsonResponse
     */
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
            Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Assessment creation failed", [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            throw $e;
        }
    }
}
```

### Service Pattern

```php
<?php
// File: app/Services/Assessment/AssessmentScoringService.php

namespace App\Services\Assessment;

use App\Models\Assessment\AssessmentEvent;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class AssessmentScoringService
{
    /**
     * Calculate assessment score
     *
     * Pseudo Code:
     * BEGIN calculateScore
     *   VALIDATE assessment and permissions
     *   LOOP through questions
     *     CALCULATE weighted scores
     *   DETERMINE risk level
     *   RETURN score summary
     * END
     *
     * @param AssessmentEvent $assessment
     * @param User $user
     * @return array
     */
    public function calculateScore(AssessmentEvent $assessment, User $user): array
    {
        $this->validateAccess($assessment, $user);

        $questions = $assessment->questions()
            ->whereNotNull('user_answer')
            ->get();

        $totalScore = 0;
        $maxScore = 0;

        foreach ($questions as $question) {
            $weight = $question->weight ?? 1;
            $answerScore = $this->calculateQuestionScore($question);

            $totalScore += ($answerScore * $weight);
            $maxScore += ($question->max_points * $weight);
        }

        $percentage = $maxScore > 0 ? ($totalScore / $maxScore) * 100 : 0;
        $riskLevel = $this->determineRiskLevel($percentage);

        return [
            'total_score' => $totalScore,
            'max_score' => $maxScore,
            'percentage' => round($percentage, 2),
            'risk_level' => $riskLevel,
            'question_count' => $questions->count()
        ];
    }

    private function validateAccess(AssessmentEvent $assessment, User $user): void
    {
        if (!$user->canAccess($assessment)) {
            throw new \UnauthorizedException('User cannot access this assessment');
        }
    }

    private function determineRiskLevel(float $percentage): string
    {
        return match(true) {
            $percentage >= 90 => 'low',
            $percentage >= 70 => 'medium',
            default => 'high'
        };
    }
}
```

### Model Pattern with Traits

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use App\Traits\HasUuid;
use App\Traits\BelongsToTenant;
use App\Traits\Archivable;

class Client extends Model
{
    use SoftDeletes, HasUuid, BelongsToTenant, Archivable;

    protected $fillable = [
        'name',
        'company_id',
        'contact_email',
        'status'
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];
}
```

---

## Common Patterns

### Array Handling

```php
// ✅ GOOD - Type-safe array handling
/** @param array<string, mixed> $data */
public function processData(array $data): array
{
    $result = [];

    foreach ($data as $key => $value) {
        $result[$key] = $this->transformValue($value);
    }

    return $result;
}

// Collection usage
public function getActiveUsers(): Collection
{
    return User::where('active', true)
        ->get()
        ->map(fn($user) => [
            'id' => $user->id,
            'name' => $user->name
        ]);
}
```

### Error Handling

```php
public function processRequest(Request $request): JsonResponse
{
    try {
        DB::beginTransaction();

        $result = $this->performOperation($request->all());

        DB::commit();

        return response()->json(['data' => $result]);
    } catch (ValidationException $e) {
        DB::rollBack();

        Log::warning("File: " . __FILE__ . ":" . __LINE__ . " - Validation failed", [
            'errors' => $e->errors()
        ]);

        return response()->json(['errors' => $e->errors()], 422);
    } catch (\Exception $e) {
        DB::rollBack();

        Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Operation failed", [
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);

        return response()->json(['error' => 'Operation failed'], 500);
    }
}
```

---

## Related Standards

- [Pseudo Code Standards](./01-pseudo-code-standards.md)
- [Quality Standards](./08-quality-standards.md)
- [Testing Standards](./10-testing-standards.md)

---

**Next:** [JavaScript Standards →](./04-javascript-standards.md)

**Last Updated:** January 2025
