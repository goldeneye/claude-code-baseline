---
title: {{PROJECT_NAME}} - Testing & Quality Assurance
version: 1.0
last_updated: 2025-11-02
author: {{USERNAME}} - aka GoldenEye Engineering
---

# {{PROJECT_NAME}} — Testing & Quality Assurance

## Purpose

This document defines the testing strategy, quality assurance standards, and continuous integration practices for {{PROJECT_NAME}}. It provides a framework-agnostic template for ensuring code quality, test coverage, and production readiness.

---

## Testing Philosophy

### Core Principles

1. **Test-Driven Development (TDD)**: Write tests before implementation when possible
2. **Comprehensive Coverage**: Minimum 80% code coverage for all modules
3. **Automated Testing**: All tests run automatically in CI/CD pipeline
4. **Security-First**: Security and encryption tests are blocking
5. **Fast Feedback**: Tests run in under 5 minutes for rapid iteration

---

## Testing Frameworks

### Backend Testing Stack

| Framework | Purpose | Documentation |
|-----------|---------|---------------|
| **PHPUnit** | Unit and integration testing | https://phpunit.de/ |
| **Pest** | Modern PHP testing with elegant syntax | https://pestphp.com/ |
| **Mockery** | Mock objects and external dependencies | http://docs.mockery.io/ |
| **Laravel Dusk** | Browser automation and E2E testing | https://laravel.com/docs/dusk |
| **Faker** | Generate realistic test data | https://github.com/FakerPHP/Faker |

### Frontend Testing Stack

| Framework | Purpose | Documentation |
|-----------|---------|---------------|
| **Jest** | JavaScript unit testing | https://jestjs.io/ |
| **React Testing Library** | Component testing | https://testing-library.com/react |
| **Cypress** | E2E browser testing | https://www.cypress.io/ |
| **MSW** | API mocking (Mock Service Worker) | https://mswjs.io/ |

### Quality Analysis Tools

| Tool | Purpose |
|------|---------|
| **PHP_CodeSniffer** | PSR-12 coding standards enforcement |
| **PHPStan** | Static analysis and type checking |
| **ESLint** | JavaScript/React code quality |
| **Prettier** | Code formatting automation |
| **SonarQube** | Continuous code quality inspection |

---

## Test Categories

### 1. Unit Tests

**Goal**: Validate individual functions, methods, and classes in isolation.

**Coverage Target**: 85%+

**Characteristics**:
- Fast execution (< 1 second per test)
- No external dependencies (database, API, filesystem)
- Test single responsibility
- Use mocks for dependencies

**Example Test Structure**:
```php
// tests/Unit/Services/ImportServiceTest.php
namespace Tests\Unit\Services;

use Tests\TestCase;
use App\Services\ImportService;

class ImportServiceTest extends TestCase
{
    /**
     * Test CSV import normalizes data correctly
     */
    public function test_csv_import_normalizes_client_data()
    {
        // Arrange
        $service = new ImportService();
        $csvData = "client_name,domain,email\nAcme Corp,acme.com,info@acme.com";

        // Act
        $result = $service->parseCsv($csvData);

        // Assert
        $this->assertIsArray($result);
        $this->assertEquals('Acme Corp', $result[0]['client_name']);
        $this->assertEquals('acme.com', $result[0]['domain']);
    }
}
```

**Key Test Suites**:
- **Services**: Business logic and data processing
- **Models**: Eloquent model methods and relationships
- **Utilities**: Helper functions and formatters
- **Encryption**: Field-level encryption round-trip verification
- **Validators**: Input validation rules

---

### 2. Integration Tests

**Goal**: Validate interactions between components, database queries, and API calls.

**Coverage Target**: 75%+

**Characteristics**:
- Uses test database (SQLite in-memory or dedicated test DB)
- Tests actual database queries and transactions
- Validates API endpoint responses
- May use external service mocks

**Example Test Structure**:
```php
// tests/Integration/Api/ClientApiTest.php
namespace Tests\Integration\Api;

use Tests\TestCase;
use App\Models\User;
use App\Models\Client;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ClientApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test creating a client via API endpoint
     */
    public function test_api_creates_client_with_valid_data()
    {
        // Arrange
        $user = User::factory()->create();
        $clientData = [
            'name' => 'Test Client',
            'domain' => 'testclient.com',
            'contact_email' => 'contact@testclient.com'
        ];

        // Act
        $response = $this->actingAs($user, 'api')
            ->postJson('/api/v3/clients', $clientData);

        // Assert
        $response->assertStatus(201);
        $response->assertJson(['name' => 'Test Client']);
        $this->assertDatabaseHas('clients', ['domain' => 'testclient.com']);
    }
}
```

**Key Test Suites**:
- **API Endpoints**: RESTful API responses and status codes
- **Authentication**: Auth0 JWT validation and token expiry
- **Database Queries**: Complex queries and relationships
- **Queue Jobs**: Job dispatching and processing
- **Event Listeners**: Event triggering and handling

---

### 3. Feature Tests

**Goal**: Test complete user workflows end-to-end within the application.

**Coverage Target**: 70%+

**Characteristics**:
- Tests complete user journeys
- Combines multiple components
- Uses realistic data scenarios
- Validates business rules

**Example Test Structure**:
```php
// tests/Feature/ClientOnboardingTest.php
namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ClientOnboardingTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test complete client onboarding workflow
     *
     * Scenario:
     * 1. MSP user authenticates
     * 2. Uploads client CSV
     * 3. Reviews imported clients
     * 4. Initiates assessment
     * 5. Verifies assessment created
     */
    public function test_complete_client_onboarding_workflow()
    {
        // Arrange
        $mspUser = User::factory()->create(['role' => 'msp_user']);

        // Act 1: Upload CSV
        $csvFile = $this->createTestCsv([
            ['name' => 'Acme Corp', 'domain' => 'acme.com', 'email' => 'info@acme.com']
        ]);
        $uploadResponse = $this->actingAs($mspUser)
            ->post('/clients/import', ['file' => $csvFile]);

        // Act 2: Review imports
        $importId = $uploadResponse->json('import_id');
        $reviewResponse = $this->actingAs($mspUser)
            ->get("/clients/imports/{$importId}");

        // Act 3: Start assessment
        $clientId = $reviewResponse->json('clients')[0]['id'];
        $assessmentResponse = $this->actingAs($mspUser)
            ->post("/assessments/create", [
                'client_id' => $clientId,
                'template_id' => 1
            ]);

        // Assert
        $uploadResponse->assertStatus(200);
        $reviewResponse->assertStatus(200);
        $assessmentResponse->assertStatus(201);
        $this->assertDatabaseHas('clients', ['domain' => 'acme.com']);
        $this->assertDatabaseHas('assessment_events', ['client_id' => $clientId]);
    }
}
```

**Key Test Suites**:
- **Client Management**: Import, create, update, archive workflows
- **Assessment Lifecycle**: Template creation through completion
- **Compliance Scanning**: Domain scan initiation through reporting
- **User Management**: Registration, role assignment, permissions
- **AI Analysis**: Client segmentation and risk scoring workflows

---

### 4. Security Tests

**Goal**: Validate security controls, encryption, and access restrictions.

**Coverage Target**: 100% (BLOCKING)

**Characteristics**:
- Tests authentication and authorization
- Validates encryption implementation
- Tests multi-tenant data isolation
- Attempts SQL injection and XSS attacks
- Validates rate limiting

**Example Test Structure**:
```php
// tests/Security/EncryptionTest.php
namespace Tests\Security;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Support\Facades\Crypt;

class EncryptionTest extends TestCase
{
    /**
     * Test encrypted fields cannot be queried in plaintext
     */
    public function test_encrypted_fields_not_queryable_in_plaintext()
    {
        // Arrange
        $user = User::factory()->create([
            'email' => 'test@example.com'
        ]);

        // Act: Try to query by plaintext email (should fail)
        $result = User::where('email', 'test@example.com')->first();

        // Assert: No result found (email is encrypted in DB)
        $this->assertNull($result);

        // Act: Verify email is actually encrypted in database
        $dbEmail = DB::table('users')->where('id', $user->id)->value('email');

        // Assert: Database value is not plaintext
        $this->assertNotEquals('test@example.com', $dbEmail);

        // Act: Decrypt and verify
        $decrypted = Crypt::decryptString($dbEmail);

        // Assert: Decryption yields original value
        $this->assertEquals('test@example.com', $decrypted);
    }

    /**
     * Test tenant isolation prevents cross-MSP data access
     */
    public function test_tenant_isolation_blocks_cross_msp_access()
    {
        // Arrange
        $msp1User = User::factory()->create(['msp_id' => 1]);
        $msp2Client = Client::factory()->create(['msp_id' => 2]);

        // Act: Attempt to access MSP2 client as MSP1 user
        $response = $this->actingAs($msp1User, 'api')
            ->getJson("/api/v3/clients/{$msp2Client->id}");

        // Assert: Access denied
        $response->assertStatus(403);
    }
}
```

**Key Test Suites**:
- **Encryption**: Field-level encryption verification
- **Authentication**: JWT validation and expiration
- **Authorization**: RBAC permission enforcement
- **Tenant Isolation**: Cross-MSP data access prevention
- **Input Validation**: SQL injection and XSS prevention
- **Rate Limiting**: API throttling verification
- **Audit Logging**: Security event tracking

---

### 5. Performance Tests

**Goal**: Validate response times, database query efficiency, and scalability.

**Coverage Target**: Critical paths only

**Characteristics**:
- Tests high-load scenarios
- Validates database query counts (N+1 prevention)
- Measures response times
- Tests concurrent requests

**Example Test Structure**:
```php
// tests/Performance/ClientListPerformanceTest.php
namespace Tests\Performance;

use Tests\TestCase;
use App\Models\User;
use App\Models\Client;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ClientListPerformanceTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test client list loads efficiently with many clients
     */
    public function test_client_list_performs_efficiently_with_100_clients()
    {
        // Arrange
        $user = User::factory()->create();
        Client::factory()->count(100)->create(['msp_id' => $user->msp_id]);

        // Act
        $startTime = microtime(true);
        $startQueries = DB::getQueryLog();
        DB::enableQueryLog();

        $response = $this->actingAs($user, 'api')
            ->getJson('/api/v3/clients');

        $endTime = microtime(true);
        $queryCount = count(DB::getQueryLog());

        // Assert: Response time under 500ms
        $this->assertLessThan(0.5, $endTime - $startTime);

        // Assert: Query count reasonable (no N+1)
        $this->assertLessThan(5, $queryCount);

        // Assert: Response successful
        $response->assertStatus(200);
    }
}
```

**Key Test Suites**:
- **API Response Times**: Critical endpoints under load
- **Database Queries**: N+1 query prevention
- **Large Data Sets**: Performance with 1000+ records
- **Concurrent Requests**: Multiple simultaneous users
- **Queue Processing**: Job throughput and memory usage

---

## Test Data Management

### Factory Pattern

Use factories for creating test data consistently:

```php
// database/factories/ClientFactory.php
namespace Database\Factories;

use App\Models\Client;
use Illuminate\Database\Eloquent\Factories\Factory;

class ClientFactory extends Factory
{
    protected $model = Client::class;

    public function definition()
    {
        return [
            'msp_id' => 1,
            'name' => $this->faker->company(),
            'domain' => $this->faker->domainName(),
            'contact_email' => $this->faker->companyEmail(),
            'industry' => $this->faker->randomElement(['Technology', 'Healthcare', 'Finance']),
            'employee_count' => $this->faker->numberBetween(10, 500),
            'status' => 'active'
        ];
    }
}
```

### Test Fixtures

Store reusable test data in `tests/fixtures/`:

```
tests/
├── fixtures/
│   ├── clients_sample.csv
│   ├── ai_response.json
│   ├── scan_results.json
│   └── assessment_template.json
```

### Database Seeding

Use seeders for consistent test database state:

```php
// database/seeders/TestDatabaseSeeder.php
public function run()
{
    // Create test MSP
    $msp = Msp::create(['name' => 'Test MSP', 'plan_tier' => 'standard']);

    // Create test users with different roles
    User::factory()->create(['msp_id' => $msp->id, 'role' => 'admin']);
    User::factory()->create(['msp_id' => $msp->id, 'role' => 'msp_user']);

    // Create test clients
    Client::factory()->count(10)->create(['msp_id' => $msp->id]);
}
```

---

## Mocking External Dependencies

### API Mocking

Mock external APIs to avoid network calls and ensure test reliability:

```php
// Mock Compliance Scorecard API
use GuzzleHttp\Client;
use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Psr7\Response;

public function test_external_api_sync()
{
    // Create mock responses
    $mock = new MockHandler([
        new Response(200, [], json_encode(['success' => true, 'seat_id' => 123]))
    ]);

    $handlerStack = HandlerStack::create($mock);
    $client = new Client(['handler' => $handlerStack]);

    // Inject mocked client
    $this->app->instance(Client::class, $client);

    // Test your service
    $result = $complianceService->createSeat($clientData);

    $this->assertTrue($result['success']);
}
```

### AI Response Mocking

Store AI responses in fixtures for consistent testing:

```json
// tests/fixtures/ai_response.json
{
  "score": 85,
  "segment": "ideal",
  "reason": "Strong security posture with modern infrastructure",
  "suggested_action": "Continue quarterly assessments"
}
```

```php
public function test_ai_analysis_workflow()
{
    // Load fixture
    $aiResponse = json_decode(
        file_get_contents(__DIR__ . '/../fixtures/ai_response.json'),
        true
    );

    // Mock AI service
    $mockAiService = Mockery::mock(AIAnalyzerService::class);
    $mockAiService->shouldReceive('analyze')
        ->once()
        ->andReturn($aiResponse);

    $this->app->instance(AIAnalyzerService::class, $mockAiService);

    // Run test
    $result = $segmentationService->analyzeClient($client);

    $this->assertEquals(85, $result['score']);
}
```

---

## Code Quality Standards

### PSR-12 Compliance

All code must follow PSR-12 coding standards:

```bash
# Check code style
./vendor/bin/phpcs --standard=PSR12 app/

# Auto-fix code style issues
./vendor/bin/phpcbf --standard=PSR12 app/
```

### Static Analysis

Use PHPStan for type checking and error detection:

```bash
# Run static analysis
./vendor/bin/phpstan analyse app/ --level=8
```

**Configuration (`phpstan.neon`)**:
```yaml
parameters:
    level: 8
    paths:
        - app
    excludePaths:
        - app/Http/Middleware/VerifyCsrfToken.php
```

### Documentation Coverage

All methods must have PHPDoc blocks:

```php
/**
 * Import clients from CSV file
 *
 * Algorithm:
 * 1. Validate CSV format and required columns
 * 2. Parse CSV rows into normalized array
 * 3. Encrypt PII fields (name, email, phone)
 * 4. Validate business rules (unique domain per MSP)
 * 5. Bulk insert with transaction safety
 *
 * @param UploadedFile $file CSV file with client data
 * @param int $mspId Tenant identifier
 * @return array{import_id: string, count: int, errors: array}
 * @throws ValidationException If CSV format invalid
 * @throws EncryptionException If PII encryption fails
 */
public function importClientsFromCsv(UploadedFile $file, int $mspId): array
{
    // Implementation
}
```

---

## Continuous Integration

### CI/CD Pipeline

All tests run automatically on every commit:

**GitHub Actions Example (`.github/workflows/tests.yml`)**:
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: testing
        ports:
          - 3306:3306

    steps:
      - uses: actions/checkout@v3

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: 8.2
          extensions: mbstring, pdo_mysql
          coverage: xdebug

      - name: Install Dependencies
        run: composer install --prefer-dist --no-progress

      - name: Copy Environment
        run: cp .env.testing .env

      - name: Generate Application Key
        run: php artisan key:generate

      - name: Run Migrations
        run: php artisan migrate --env=testing

      - name: Run Tests
        run: php artisan test --coverage --min=80

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

### Pipeline Blocking Conditions

The CI pipeline blocks merges if:

1. **Test Failures**: Any test fails
2. **Coverage Threshold**: Coverage < 80%
3. **Security Tests**: Any security test fails
4. **Code Style**: PSR-12 violations detected
5. **Static Analysis**: PHPStan errors at level 8

---

## Test Commands

### Running Tests

```bash
# Run all tests
php artisan test

# Run specific test suite
php artisan test --testsuite=Unit
php artisan test --testsuite=Feature
php artisan test --testsuite=Integration

# Run specific test file
php artisan test tests/Unit/Services/ImportServiceTest.php

# Run specific test method
php artisan test --filter=test_csv_import_normalizes_client_data

# Run with coverage report
php artisan test --coverage
php artisan test --coverage-html=reports/coverage

# Run in parallel (faster)
php artisan test --parallel
```

### Code Quality Commands

```bash
# Check code style (PSR-12)
./vendor/bin/phpcs --standard=PSR12 app/

# Fix code style automatically
./vendor/bin/phpcbf --standard=PSR12 app/

# Run static analysis
./vendor/bin/phpstan analyse app/ --level=8

# Run all quality checks
composer quality-check
```

**Composer Script (`composer.json`)**:
```json
{
    "scripts": {
        "quality-check": [
            "@phpcs",
            "@phpstan",
            "@test"
        ],
        "phpcs": "./vendor/bin/phpcs --standard=PSR12 app/",
        "phpstan": "./vendor/bin/phpstan analyse app/ --level=8",
        "test": "php artisan test --coverage --min=80"
    }
}
```

---

## Test Environment Configuration

### Test Database

Use separate database for testing (`.env.testing`):

```ini
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=testing
DB_USERNAME=root
DB_PASSWORD=

# Or use SQLite in-memory for speed
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```

### Test Environment Settings

```ini
APP_ENV=testing
APP_DEBUG=true
APP_KEY=base64:your-test-key-here

CACHE_DRIVER=array
SESSION_DRIVER=array
QUEUE_CONNECTION=sync

MAIL_MAILER=log
BROADCAST_DRIVER=log
```

---

## Quality Metrics

### Code Coverage Targets

| Category | Target | Current | Status |
|----------|--------|---------|--------|
| **Overall** | 80% | - | 🎯 |
| **Unit Tests** | 85% | - | 🎯 |
| **Integration Tests** | 75% | - | 🎯 |
| **Feature Tests** | 70% | - | 🎯 |
| **Security Tests** | 100% | - | 🎯 |

### Code Quality Metrics

| Metric | Target | Tool |
|--------|--------|------|
| **PSR-12 Compliance** | 100% | PHP_CodeSniffer |
| **Static Analysis** | Level 8 | PHPStan |
| **Documentation Coverage** | 100% | Manual Review |
| **Cyclomatic Complexity** | < 10 | SonarQube |
| **Duplicate Code** | < 3% | SonarQube |

---

## Best Practices

### 1. Arrange-Act-Assert Pattern

Structure all tests clearly:

```php
public function test_example()
{
    // Arrange: Set up test data and mocks
    $user = User::factory()->create();
    $data = ['name' => 'Test'];

    // Act: Execute the code under test
    $result = $service->doSomething($user, $data);

    // Assert: Verify expected outcomes
    $this->assertTrue($result);
}
```

### 2. Test Isolation

Each test should be independent:

```php
use Illuminate\Foundation\Testing\RefreshDatabase;

class ExampleTest extends TestCase
{
    use RefreshDatabase; // Fresh database for each test

    public function test_something()
    {
        // This test doesn't affect other tests
    }
}
```

### 3. Descriptive Test Names

Use clear, descriptive test method names:

```php
// ✅ GOOD: Clear intent
public function test_user_cannot_access_other_msp_clients()

// ❌ BAD: Unclear purpose
public function test_client_access()
```

### 4. One Assertion Concept Per Test

Focus each test on a single concept:

```php
// ✅ GOOD: Tests one concept (encryption)
public function test_email_field_is_encrypted()
{
    $user = User::factory()->create(['email' => 'test@example.com']);
    $dbEmail = DB::table('users')->where('id', $user->id)->value('email');
    $this->assertNotEquals('test@example.com', $dbEmail);
}

// ❌ BAD: Tests multiple concepts
public function test_user_creation()
{
    // Tests encryption, validation, database insertion, events, etc.
}
```

### 5. Test Edge Cases

Always test boundary conditions:

```php
public function test_pagination_handles_empty_results()
{
    // Test with zero records
}

public function test_pagination_handles_exactly_one_page()
{
    // Test with exactly page size
}

public function test_pagination_handles_many_pages()
{
    // Test with multiple pages
}
```

---

## Troubleshooting Tests

### Common Issues

**1. Database Conflicts**
```bash
# Reset test database
php artisan migrate:fresh --env=testing
php artisan db:seed --env=testing
```

**2. Cache Issues**
```bash
# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

**3. Permission Errors**
```bash
# Fix storage permissions
chmod -R 775 storage/
chmod -R 775 bootstrap/cache/
```

**4. Slow Tests**
```bash
# Use in-memory SQLite for speed
DB_CONNECTION=sqlite
DB_DATABASE=:memory:

# Run tests in parallel
php artisan test --parallel
```

---

## See Also

- **[coding-standards.md](coding-standards.md)** - Coding standards and documentation requirements
- **[02-security.md](02-security.md)** - Security testing requirements
- **[06-database-schema.md](06-database-schema.md)** - Database testing strategies
- **[05-deployment-guide.md](05-deployment-guide.md)** - Production testing procedures

---

## Template Variables Reference

When implementing this testing strategy, replace the following template variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Project display name | MyProject Platform |
| `{{REPO_PATH}}` | Repository path | /var/www/project |
| `{{CONTACT_EMAIL}}` | QA team contact | qa-team@example.com |

---

**Document Version**: 1.0
**Last Updated**: 2025-11-02
**Author**: {{USERNAME}} - aka GoldenEye Engineering
**Review Cycle**: Quarterly or after major test strategy changes
