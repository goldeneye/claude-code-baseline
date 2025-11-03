# Testing Standards

**Comprehensive Testing Guidelines**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- ✅ Write tests for all new features
- ✅ Unit tests for business logic
- ✅ Feature tests for API endpoints
- ✅ Integration tests for workflows
- ✅ Test multi-tenant isolation
- ✅ Aim for 80%+ code coverage

---

## Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [Unit Tests](#unit-tests)
3. [Feature Tests](#feature-tests)
4. [Integration Tests](#integration-tests)
5. [Test Naming Conventions](#test-naming-conventions)
6. [Laravel Testing Patterns](#laravel-testing-patterns)

---

## Testing Philosophy

### Why Test?

- **Confidence** - Know your code works as expected
- **Regression Prevention** - Catch bugs before they reach production
- **Documentation** - Tests show how code should be used
- **Refactoring Safety** - Change code without fear
- **Quality Assurance** - Maintain high code quality

### Testing Pyramid

```
       /\
      /  \    E2E Tests (Few)
     /____\
    /      \   Integration Tests (Some)
   /________\
  /          \ Unit Tests (Many)
 /____________\
```

---

## Unit Tests

### What to Test

- Business logic methods
- Calculation functions
- Data transformation
- Validation rules
- Helper functions
- Model scopes
- Accessors/Mutators

### Unit Test Example

```php
<?php
// File: tests/Unit/Services/AssessmentScoringServiceTest.php

namespace Tests\Unit\Services;

use App\Models\Assessment\AssessmentEvent;
use App\Models\User;
use App\Services\Assessment\AssessmentScoringService;
use Tests\TestCase;

class AssessmentScoringServiceTest extends TestCase
{
    private AssessmentScoringService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new AssessmentScoringService();
    }

    /**
     * Test scoring with all questions answered correctly
     */
    public function test_calculates_perfect_score_when_all_answers_correct(): void
    {
        // Arrange
        $assessment = AssessmentEvent::factory()
            ->withQuestions(10)
            ->allAnswersCorrect()
            ->create();

        $user = User::factory()->create();

        // Act
        $result = $this->service->calculateScore($assessment, $user);

        // Assert
        $this->assertEquals(100, $result['percentage']);
        $this->assertEquals('low', $result['risk_level']);
        $this->assertEquals(10, $result['question_count']);
    }

    /**
     * Test scoring with partial correct answers
     */
    public function test_calculates_partial_score_correctly(): void
    {
        // Arrange
        $assessment = AssessmentEvent::factory()
            ->withQuestions(10)
            ->withAnsweredQuestions(7, correct: true)
            ->withAnsweredQuestions(3, correct: false)
            ->create();

        $user = User::factory()->create();

        // Act
        $result = $this->service->calculateScore($assessment, $user);

        // Assert
        $this->assertEquals(70, $result['percentage']);
        $this->assertEquals('medium', $result['risk_level']);
    }

    /**
     * Test risk level determination
     */
    public function test_determines_risk_level_correctly(): void
    {
        // Test low risk (90-100%)
        $this->assertEquals('low', $this->service->determineRiskLevel(95));

        // Test medium risk (70-89%)
        $this->assertEquals('medium', $this->service->determineRiskLevel(80));

        // Test high risk (<70%)
        $this->assertEquals('high', $this->service->determineRiskLevel(65));
    }

    /**
     * Test throws exception when user lacks permission
     */
    public function test_throws_exception_when_user_lacks_permission(): void
    {
        // Arrange
        $assessment = AssessmentEvent::factory()->create();
        $unauthorizedUser = User::factory()->create([
            'company_id' => 'different-company'
        ]);

        // Assert & Act
        $this->expectException(UnauthorizedException::class);

        $this->service->calculateScore($assessment, $unauthorizedUser);
    }
}
```

---

## Feature Tests

### What to Test

- API endpoints
- HTTP requests/responses
- Authentication flows
- Authorization checks
- Validation errors
- Database interactions
- Multi-tenant isolation

### Feature Test Example

```php
<?php
// File: tests/Feature/Api/AssessmentControllerTest.php

namespace Tests\Feature\Api;

use App\Models\Assessment\AssessmentEvent;
use App\Models\Assessment\AssessmentTemplate;
use App\Models\Client;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AssessmentControllerTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test user can view their assessments
     */
    public function test_user_can_view_their_company_assessments(): void
    {
        // Arrange
        $user = User::factory()->create();
        $assessment = AssessmentEvent::factory()->create([
            'company_id' => $user->company_id
        ]);

        // Act
        $response = $this->actingAs($user)
            ->getJson('/api/v3/assessments');

        // Assert
        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'name', 'status', 'created_at']
                ]
            ])
            ->assertJsonFragment([
                'id' => $assessment->id
            ]);
    }

    /**
     * Test user cannot view other company's assessments
     */
    public function test_user_cannot_view_other_company_assessments(): void
    {
        // Arrange
        $user = User::factory()->create();
        $otherCompanyAssessment = AssessmentEvent::factory()->create([
            'company_id' => 'different-company-id'
        ]);

        // Act
        $response = $this->actingAs($user)
            ->getJson('/api/v3/assessments');

        // Assert
        $response->assertStatus(200)
            ->assertJsonMissing([
                'id' => $otherCompanyAssessment->id
            ]);
    }

    /**
     * Test creating assessment with valid data
     */
    public function test_can_create_assessment_with_valid_data(): void
    {
        // Arrange
        $user = User::factory()->create();
        $template = AssessmentTemplate::factory()->create();
        $client = Client::factory()->create([
            'company_id' => $user->company_id
        ]);

        $data = [
            'template_id' => $template->id,
            'client_id' => $client->id,
            'name' => 'Test Assessment',
            'description' => 'Test Description'
        ];

        // Act
        $response = $this->actingAs($user)
            ->postJson('/api/v3/assessments', $data);

        // Assert
        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => ['id', 'name', 'status']
            ]);

        $this->assertDatabaseHas('assessment_events', [
            'name' => 'Test Assessment',
            'company_id' => $user->company_id,
            'client_id' => $client->id
        ]);
    }

    /**
     * Test validation errors when creating assessment
     */
    public function test_validation_errors_when_creating_assessment(): void
    {
        // Arrange
        $user = User::factory()->create();

        // Act
        $response = $this->actingAs($user)
            ->postJson('/api/v3/assessments', []);

        // Assert
        $response->assertStatus(422)
            ->assertJsonValidationErrors(['template_id', 'client_id', 'name']);
    }

    /**
     * Test unauthorized access returns 401
     */
    public function test_unauthenticated_user_cannot_access_assessments(): void
    {
        // Act
        $response = $this->getJson('/api/v3/assessments');

        // Assert
        $response->assertStatus(401);
    }
}
```

---

## Integration Tests

### What to Test

- Complete user workflows
- Multi-step processes
- External API interactions
- Queue jobs
- Email notifications
- File uploads/downloads

### Integration Test Example

```php
<?php
// File: tests/Integration/AssessmentWorkflowTest.php

namespace Tests\Integration;

use App\Jobs\SendAssessmentNotification;
use App\Models\Assessment\AssessmentEvent;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Tests\TestCase;

class AssessmentWorkflowTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test complete assessment creation and completion workflow
     */
    public function test_complete_assessment_workflow(): void
    {
        Queue::fake();

        // Arrange - Create user and assessment
        $user = User::factory()->create();
        $assessment = AssessmentEvent::factory()->create([
            'company_id' => $user->company_id,
            'status' => 'draft'
        ]);

        // Act 1 - Start assessment
        $this->actingAs($user)
            ->putJson("/api/v3/assessments/{$assessment->id}", [
                'status' => 'in_progress'
            ]);

        // Assert 1 - Status updated
        $this->assertDatabaseHas('assessment_events', [
            'id' => $assessment->id,
            'status' => 'in_progress'
        ]);

        // Act 2 - Answer questions
        foreach ($assessment->questions as $question) {
            $this->actingAs($user)
                ->postJson("/api/v3/assessments/{$assessment->id}/answers", [
                    'question_id' => $question->id,
                    'answer' => 'Yes'
                ]);
        }

        // Assert 2 - All questions answered
        $this->assertEquals(
            $assessment->questions->count(),
            $assessment->answers()->count()
        );

        // Act 3 - Complete assessment
        $this->actingAs($user)
            ->putJson("/api/v3/assessments/{$assessment->id}", [
                'status' => 'completed'
            ]);

        // Assert 3 - Assessment completed
        $this->assertDatabaseHas('assessment_events', [
            'id' => $assessment->id,
            'status' => 'completed'
        ]);

        $this->assertNotNull($assessment->fresh()->completed_at);

        // Assert 4 - Notification job dispatched
        Queue::assertPushed(SendAssessmentNotification::class, function ($job) use ($assessment) {
            return $job->assessment->id === $assessment->id;
        });
    }
}
```

---

## Test Naming Conventions

### Standard Format

```
test_{method}_{expected_behavior}_when_{condition}
```

### Examples

```php
// ✅ GOOD - Clear and descriptive
test_calculate_score_returns_percentage_when_all_questions_answered()
test_create_assessment_throws_exception_when_user_lacks_permission()
test_update_client_updates_timestamp_when_data_changed()
test_archive_assessment_sets_archived_flag_when_called()

// ❌ BAD - Too vague
test_scoring()
test_create()
test_it_works()
test_assessment_test()
```

### Arrange-Act-Assert Pattern

```php
public function test_method_performs_action_when_condition(): void
{
    // Arrange - Set up test data
    $user = User::factory()->create();
    $assessment = AssessmentEvent::factory()->create();

    // Act - Perform the action
    $result = $this->service->performAction($assessment, $user);

    // Assert - Verify expectations
    $this->assertTrue($result);
    $this->assertDatabaseHas('assessments', ['id' => $assessment->id]);
}
```

---

## Laravel Testing Patterns

### Database Testing

```php
// ✅ Use factories
$assessment = AssessmentEvent::factory()->create([
    'company_id' => $companyId
]);

// ✅ Assert database state
$this->assertDatabaseHas('assessment_events', [
    'name' => 'Test Assessment'
]);

$this->assertDatabaseMissing('assessment_events', [
    'status' => 'deleted'
]);

// ✅ Assert database count
$this->assertDatabaseCount('assessment_events', 5);
```

### Authentication Testing

```php
// ✅ Acting as user
$response = $this->actingAs($user)
    ->getJson('/api/v3/assessments');

// ✅ Testing unauthenticated
$response = $this->getJson('/api/v3/assessments');
$response->assertStatus(401);
```

### Mocking & Faking

```php
// ✅ Fake queue
Queue::fake();
// ... perform actions
Queue::assertPushed(JobClass::class);

// ✅ Fake mail
Mail::fake();
// ... send email
Mail::assertSent(WelcomeEmail::class);

// ✅ Fake events
Event::fake();
// ... trigger event
Event::assertDispatched(AssessmentCompleted::class);

// ✅ Mock external service
$mock = Mockery::mock(ExternalApi::class);
$mock->shouldReceive('getData')->once()->andReturn(['data']);
$this->app->instance(ExternalApi::class, $mock);
```

### Test Coverage

```bash
# Run tests with coverage
php artisan test --coverage

# Coverage minimum threshold
php artisan test --coverage --min=80
```

---

## Related Standards

- [PHP Standards](./03-php-standards.md)
- [Quality Standards](./08-quality-standards.md)
- [Security Standards](./11-security-standards.md)

---

**Next:** [Security Standards →](./11-security-standards.md)

**Last Updated:** January 2025
