# Performance Standards

**Optimization & Caching Guidelines**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- ✅ Use eager loading to prevent N+1 queries
- ✅ Add indexes for frequently queried columns
- ✅ Cache expensive operations
- ✅ Use queues for long-running tasks
- ✅ Optimize database queries
- ✅ Monitor performance metrics
- ✅ Set appropriate cache TTLs

---

## Table of Contents

1. [Performance Philosophy](#performance-philosophy)
2. [Database Optimization](#database-optimization)
3. [Caching Strategy](#caching-strategy)
4. [Queue Optimization](#queue-optimization)
5. [Frontend Performance](#frontend-performance)
6. [Monitoring & Profiling](#monitoring--profiling)

---

## Performance Philosophy

### Performance Goals

```
Target Response Times:
- API endpoints: < 200ms (p95)
- Database queries: < 100ms (p95)
- Page loads: < 1s (p95)
- Background jobs: Complete within SLA
```

### Performance Checklist

```
EVERY FEATURE SHOULD:
☐ Prevent N+1 queries
☐ Use appropriate indexes
☐ Cache expensive operations
☐ Use queues for heavy tasks
☐ Optimize database queries
☐ Minimize API calls
☐ Lazy load when possible
☐ Monitor performance metrics
```

---

## Database Optimization

### Prevent N+1 Queries

```php
// ❌ BAD - N+1 query problem
$assessments = AssessmentEvent::all();  // 1 query

foreach ($assessments as $assessment) {
    echo $assessment->template->name;  // N queries!
    echo $assessment->client->name;    // N more queries!
}
// Total: 1 + N + N queries

// ✅ GOOD - Eager loading
$assessments = AssessmentEvent::with(['template', 'client'])->get();  // 3 queries total

foreach ($assessments as $assessment) {
    echo $assessment->template->name;  // No additional query
    echo $assessment->client->name;    // No additional query
}
// Total: 3 queries

// ✅ BETTER - Conditional eager loading
$assessments = AssessmentEvent::with([
    'template' => function ($query) {
        $query->select('id', 'name', 'description');
    },
    'client:id,name,company_id',
    'questions' => function ($query) {
        $query->where('is_active', true);
    }
])->get();
```

### Query Optimization

```php
// ❌ BAD - Fetching all columns
$users = User::all();

// ✅ GOOD - Select only needed columns
$users = User::select('id', 'name', 'email')->get();

// ✅ GOOD - Use pagination
$users = User::paginate(50);

// ✅ GOOD - Use chunking for large datasets
User::chunk(1000, function ($users) {
    foreach ($users as $user) {
        // Process user
    }
});

// ✅ GOOD - Use cursor for memory efficiency
foreach (User::cursor() as $user) {
    // Process one user at a time
}
```

### Database Indexes

```php
// Migration - Add indexes for performance
Schema::table('assessment_events', function (Blueprint $table) {
    // Single column indexes
    $table->index('company_id');
    $table->index('client_id');
    $table->index('status');
    $table->index('created_at');

    // Composite indexes for common queries
    $table->index(['company_id', 'status']);
    $table->index(['client_id', 'created_at']);
    $table->index(['company_id', 'client_id', 'status']);
});

// Query that benefits from composite index
$assessments = AssessmentEvent::where('company_id', $companyId)
    ->where('status', 'active')
    ->orderBy('created_at', 'desc')
    ->get();
```

### Query Monitoring

```php
// ✅ GOOD - Log slow queries
DB::listen(function ($query) {
    if ($query->time > 1000) {  // More than 1 second
        Log::warning("File: " . __FILE__ . ":" . __LINE__ . " - Slow query detected", [
            'sql' => $query->sql,
            'bindings' => $query->bindings,
            'time' => $query->time
        ]);
    }
});
```

---

## Caching Strategy

### Cache Expensive Operations

```php
use Illuminate\Support\Facades\Cache;

// ✅ GOOD - Cache assessment score calculation
public function getAssessmentScore(string $assessmentId): array
{
    $cacheKey = "assessment_score:{$assessmentId}";

    return Cache::remember($cacheKey, now()->addHours(1), function () use ($assessmentId) {
        Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Calculating score (not cached)", [
            'assessment_id' => $assessmentId
        ]);

        $assessment = AssessmentEvent::with('questions.answers')->find($assessmentId);

        return $this->calculateScore($assessment);
    });
}

// ✅ GOOD - Cache with tags for selective invalidation
public function getCompanyAssessments(string $companyId): Collection
{
    return Cache::tags(['company', "company:{$companyId}"])->remember(
        "company_assessments:{$companyId}",
        now()->addMinutes(30),
        function () use ($companyId) {
            return AssessmentEvent::where('company_id', $companyId)
                ->with(['template', 'client'])
                ->get();
        }
    );
}

// Invalidate cache when data changes
public function updateAssessment(Assessment $assessment, array $data): Assessment
{
    $assessment->update($data);

    // Invalidate related caches
    Cache::tags("company:{$assessment->company_id}")->flush();
    Cache::forget("assessment_score:{$assessment->id}");

    return $assessment;
}
```

### Cache Configuration

```php
// config/cache.php
'default' => env('CACHE_DRIVER', 'redis'),

'stores' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'cache',
        'lock_connection' => 'default',
    ],
],

// .env
CACHE_DRIVER=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### Cache Patterns

```php
// ✅ GOOD - Cache user permissions
public function getUserPermissions(User $user): array
{
    return Cache::remember("user_permissions:{$user->id}", now()->addHours(24), function () use ($user) {
        return $user->permissions()->pluck('name')->toArray();
    });
}

// ✅ GOOD - Cache computed values
public function getAssessmentStatistics(string $companyId): array
{
    return Cache::remember("stats:company:{$companyId}", now()->addMinutes(15), function () use ($companyId) {
        return [
            'total' => AssessmentEvent::where('company_id', $companyId)->count(),
            'completed' => AssessmentEvent::where('company_id', $companyId)
                ->where('status', 'completed')
                ->count(),
            'average_score' => AssessmentEvent::where('company_id', $companyId)
                ->where('status', 'completed')
                ->avg('score'),
        ];
    });
}

// ✅ GOOD - Cache API responses
public function getExternalData(string $endpoint): array
{
    return Cache::remember("external_api:{$endpoint}", now()->addMinutes(60), function () use ($endpoint) {
        return Http::get($endpoint)->json();
    });
}
```

---

## Queue Optimization

### When to Use Queues

```
USE QUEUES FOR:
- Email sending
- Report generation
- File processing
- External API calls
- Data imports/exports
- Image resizing
- Batch operations
```

### Queue Examples

```php
// ✅ GOOD - Dispatch to queue
use App\Jobs\SendAssessmentNotification;
use App\Jobs\GenerateAssessmentReport;

public function completeAssessment(Assessment $assessment): void
{
    $assessment->update(['status' => 'completed']);

    // Dispatch jobs to queue
    SendAssessmentNotification::dispatch($assessment);
    GenerateAssessmentReport::dispatch($assessment);
}

// Job class
class GenerateAssessmentReport implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $timeout = 300;  // 5 minutes
    public $tries = 3;

    public function __construct(
        private Assessment $assessment
    ) {}

    public function handle(): void
    {
        Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Generating report", [
            'assessment_id' => $this->assessment->id
        ]);

        $report = $this->generateReport();

        Storage::put("reports/{$this->assessment->id}.pdf", $report);

        Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Report generated", [
            'assessment_id' => $this->assessment->id
        ]);
    }

    public function failed(Throwable $exception): void
    {
        Log::error("File: " . __FILE__ . ":" . __LINE__ . " - Report generation failed", [
            'assessment_id' => $this->assessment->id,
            'error' => $exception->getMessage()
        ]);
    }
}
```

### Queue Priorities

```php
// High priority queue for critical tasks
SendUrgentNotification::dispatch($data)->onQueue('high');

// Normal priority (default)
ProcessData::dispatch($data);

// Low priority for background tasks
CleanupOldData::dispatch()->onQueue('low');

// config/queue.php
'connections' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
        'queue' => ['high', 'default', 'low'],  // Process in order
        'retry_after' => 90,
    ],
],
```

---

## Frontend Performance

### API Response Optimization

```php
// ✅ GOOD - Use API Resources for consistent formatting
class AssessmentResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'status' => $this->status,
            'created_at' => $this->created_at->toISOString(),

            // Conditionally include relationships
            'template' => TemplateResource::make($this->whenLoaded('template')),
            'client' => ClientResource::make($this->whenLoaded('client')),

            // Include computed values only when needed
            'score' => $this->when($request->include_score, function () {
                return $this->calculated_score;
            }),
        ];
    }
}

// Controller with selective loading
public function index(Request $request): JsonResponse
{
    $query = AssessmentEvent::query();

    // Load relationships only if requested
    if ($request->has('include')) {
        $includes = explode(',', $request->include);
        $query->with($includes);
    }

    $assessments = $query->paginate(50);

    return AssessmentResource::collection($assessments)->response();
}
```

### Pagination

```php
// ✅ GOOD - Use pagination for large datasets
public function index(): JsonResponse
{
    $assessments = AssessmentEvent::with(['template', 'client'])
        ->paginate(50);

    return response()->json([
        'data' => AssessmentResource::collection($assessments),
        'meta' => [
            'current_page' => $assessments->currentPage(),
            'total' => $assessments->total(),
            'per_page' => $assessments->perPage(),
            'last_page' => $assessments->lastPage(),
        ]
    ]);
}

// ✅ GOOD - Cursor pagination for better performance
$assessments = AssessmentEvent::latest()
    ->cursorPaginate(50);
```

---

## Monitoring & Profiling

### Laravel Telescope

```php
// Install Telescope for development
composer require laravel/telescope --dev
php artisan telescope:install
php artisan migrate

// Monitor:
// - Queries
// - Requests
// - Jobs
// - Cache hits/misses
// - Mail
// - Exceptions
```

### Performance Monitoring

```php
// ✅ GOOD - Monitor execution time
$start = microtime(true);

$result = $this->performExpensiveOperation();

$duration = (microtime(true) - $start) * 1000;  // Convert to ms

Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Operation completed", [
    'duration_ms' => $duration,
    'threshold_ms' => 1000
]);

if ($duration > 1000) {
    Log::warning("File: " . __FILE__ . ":" . __LINE__ . " - Slow operation detected", [
        'duration_ms' => $duration
    ]);
}
```

### Query Debugging

```php
// ✅ GOOD - Debug queries in development
if (app()->environment('local')) {
    DB::enableQueryLog();
}

$assessments = AssessmentEvent::with('template')->get();

if (app()->environment('local')) {
    $queries = DB::getQueryLog();
    Log::debug("Queries executed", ['queries' => $queries]);
}
```

---

## Performance Best Practices

### DO:
- ✅ Profile before optimizing
- ✅ Measure actual performance
- ✅ Use indexes appropriately
- ✅ Cache expensive operations
- ✅ Use queues for heavy tasks
- ✅ Paginate large result sets
- ✅ Monitor query performance
- ✅ Optimize only when needed

### DON'T:
- ❌ Premature optimization
- ❌ Cache everything blindly
- ❌ Ignore database indexes
- ❌ Load unnecessary relationships
- ❌ Run heavy tasks in requests
- ❌ Forget to monitor performance

---

## Performance Checklist

```
BEFORE DEPLOYMENT:
☐ No N+1 queries
☐ Proper indexes on frequently queried columns
☐ Expensive operations cached
☐ Heavy tasks moved to queues
☐ API responses paginated
☐ Database queries optimized
☐ Frontend assets minified
☐ Images optimized
☐ Performance tested under load
☐ Monitoring configured
```

---

## Related Standards

- [Database Standards](./05-database-standards.md)
- [Quality Standards](./08-quality-standards.md)
- [Testing Standards](./10-testing-standards.md)

---

**🎉 Congratulations!** You've completed all coding standards documents.

**[← Back to Index](./README.md)**

**Last Updated:** January 2025
