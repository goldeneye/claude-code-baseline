# Pseudo Code Documentation Standards

**Plan Before You Code**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- ✅ Write pseudo code BEFORE implementing complex algorithms
- ✅ Use for business logic, multi-step workflows, and complex calculations
- ✅ Skip for simple CRUD and standard Laravel methods
- ✅ Include in PHPDoc blocks for documentation
- ✅ Use plain language mixed with code-like structures

---

## Table of Contents

1. [Overview](#overview)
2. [What is Pseudo Code?](#what-is-pseudo-code)
3. [Syntax Guidelines](#syntax-guidelines)
4. [When to Use Pseudo Code](#when-to-use-pseudo-code)
5. [Real-World Examples](#real-world-examples)
6. [For Developers](#for-developers)
7. [For Claude Code](#for-claude-code)
8. [Common Patterns](#common-patterns)

---

## Overview

Pseudo code is a high-level description of logic using plain language mixed with code-like structures. It helps plan algorithms before implementation and serves as documentation for complex business logic.

### Why Pseudo Code?

- **Plan First** - Think through logic before writing actual code
- **Communicate** - Share ideas with team members and stakeholders
- **Document** - Serve as living documentation for complex algorithms
- **Debug** - Easier to spot logical errors before implementation
- **AI-Friendly** - Help AI assistants understand intent and generate better code

---

## What is Pseudo Code?

Pseudo code bridges the gap between human thinking and code implementation. It's:
- **Not** a specific programming language
- **Not** meant to be executed
- **Is** a planning and communication tool
- **Is** language-agnostic and readable by anyone

### Example Comparison

**Natural Language:**
> "Check if the user can access the assessment, then calculate the total score by looping through questions, and return the results."

**Pseudo Code:**
```
BEGIN calculateAssessmentScore
    IF user does not have permission THEN
        RETURN error
    END IF

    total = 0
    FOR each question IN assessment
        total = total + question.score
    END FOR

    RETURN total
END calculateAssessmentScore
```

**Actual PHP Code:**
```php
public function calculateAssessmentScore(User $user, Assessment $assessment): int
{
    if (!$user->canAccess($assessment)) {
        throw new UnauthorizedException();
    }

    $total = 0;
    foreach ($assessment->questions as $question) {
        $total += $question->score;
    }

    return $total;
}
```

---

## Syntax Guidelines

### Standard Pseudo Code Structure

```
// Pseudo Code Structure:

BEGIN function_name
    INPUT: parameter descriptions
    OUTPUT: return value description

    IF condition THEN
        action1
        action2
    ELSE IF another_condition THEN
        action3
    ELSE
        default_action
    END IF

    FOR each item IN collection
        process_item(item)
    END FOR

    WHILE condition IS true
        perform_action
        update_condition
    END WHILE

    RETURN result
END function_name
```

### Key Elements

| Element | Purpose | Example |
|---------|---------|---------|
| `BEGIN/END` | Define function boundaries | `BEGIN calculateScore` |
| `INPUT/OUTPUT` | Document parameters and return values | `INPUT: user_id, assessment_id` |
| `IF/THEN/ELSE` | Conditional logic | `IF user_exists THEN` |
| `FOR/WHILE` | Loops and iterations | `FOR each question IN list` |
| `RETURN` | Return values | `RETURN calculated_score` |
| Comments | Explain complex decisions | `// Calculate weighted average` |

---

## When to Use Pseudo Code

### ✅ ALWAYS Use For:

- **Complex business logic methods** - Assessment scoring, risk calculations
- **Multi-step algorithms** - Data transformation pipelines
- **Assessment scoring calculations** - Weighted scores, percentages
- **Permission validation flows** - Multi-level access checks
- **Data transformation processes** - Import/export logic
- **Integration workflows** - Third-party API interactions

### ⚠️ CONSIDER Using For:

- **Database query optimization** - Complex joins and subqueries
- **Cache invalidation logic** - Multi-level cache clearing
- **User interface workflows** - Multi-step wizards
- **API endpoint design** - Request/response transformation
- **Error handling strategies** - Complex retry logic
- **Performance optimization** - Algorithm improvements

### ❌ SKIP For:

- **Simple CRUD operations** - Standard create/read/update/delete
- **Basic getters/setters** - Simple property access
- **Standard Laravel methods** - Framework conventions
- **Simple validation rules** - Single-field validations
- **Basic model relationships** - HasMany, BelongsTo, etc.
- **Standard authentication** - Laravel's built-in auth

---

## Real-World Examples

### Example 1: Assessment Scoring

**Business Requirement:**
Calculate the total score for an assessment, taking into account question weights, user answers, and risk levels.

**Pseudo Code:**
```
BEGIN calculateAssessmentScore
    INPUT: assessment_event_id, user_permissions
    OUTPUT: scoring_summary with totals

    // Validate user can access assessment
    IF NOT user_can_access_assessment(user, assessment)
        RETURN permission_denied_error
    END IF

    // Get all answered questions
    answered_questions = get_answered_questions(assessment_event_id)

    total_score = 0
    max_possible_score = 0

    FOR each question IN answered_questions
        question_weight = get_question_weight(question)
        user_answer_score = calculate_answer_score(question, user_answer)

        total_score += (user_answer_score * question_weight)
        max_possible_score += (max_score * question_weight)
    END FOR

    percentage_score = (total_score / max_possible_score) * 100
    risk_level = determine_risk_level(percentage_score)

    RETURN {
        total_score,
        max_possible_score,
        percentage_score,
        risk_level,
        question_count: count(answered_questions)
    }
END calculateAssessmentScore
```

**Actual Implementation:**
```php
/**
 * Calculate assessment score with weighted questions
 *
 * Pseudo Code:
 * BEGIN calculateAssessmentScore
 *   VALIDATE user has access
 *   LOOP through answered questions
 *     CALCULATE weighted score
 *   DETERMINE risk level from percentage
 *   RETURN scoring summary
 * END
 *
 * @param string $assessmentEventId
 * @param User $user
 * @return array
 */
public function calculateAssessmentScore(string $assessmentEventId, User $user): array
{
    Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Starting assessment score calculation", [
        'assessment_event_id' => $assessmentEventId,
        'user_id' => $user->id
    ]);

    $assessment = AssessmentEvent::findOrFail($assessmentEventId);

    if (!$user->canAccess($assessment)) {
        throw new UnauthorizedException("User cannot access this assessment");
    }

    $answeredQuestions = $assessment->questions()
        ->whereNotNull('user_answer')
        ->get();

    $totalScore = 0;
    $maxPossibleScore = 0;

    foreach ($answeredQuestions as $question) {
        $weight = $question->weight ?? 1;
        $answerScore = $this->calculateAnswerScore($question);

        $totalScore += ($answerScore * $weight);
        $maxPossibleScore += ($question->max_points * $weight);
    }

    $percentage = ($maxPossibleScore > 0)
        ? ($totalScore / $maxPossibleScore) * 100
        : 0;

    $riskLevel = $this->determineRiskLevel($percentage);

    Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Assessment score calculated", [
        'total_score' => $totalScore,
        'percentage' => $percentage,
        'risk_level' => $riskLevel
    ]);

    return [
        'total_score' => $totalScore,
        'max_possible_score' => $maxPossibleScore,
        'percentage_score' => $percentage,
        'risk_level' => $riskLevel,
        'question_count' => $answeredQuestions->count()
    ];
}
```

### Example 2: Multi-Tenant Permission Check

**Business Requirement:**
Verify that a user has permission to access a resource in a multi-tenant environment.

**Pseudo Code:**
```
BEGIN checkUserPermission
    INPUT: user, resource, required_permission
    OUTPUT: boolean (has_permission)

    // Super Admin bypass
    IF user.is_super_admin THEN
        RETURN true
    END IF

    // Check if user belongs to resource's company
    IF user.company_id != resource.company_id THEN
        RETURN false
    END IF

    // Check MSP hierarchy
    IF resource.requires_msp_access THEN
        IF user.msp_id != resource.msp_id THEN
            RETURN false
        END IF
    END IF

    // Check specific permission
    IF user.has_permission(required_permission) THEN
        RETURN true
    END IF

    RETURN false
END checkUserPermission
```

### Example 3: Template Cloning for MSPs

**Pseudo Code:**
```
BEGIN cloneTemplateForMSP
    INPUT: global_template_id, msp_company_id
    OUTPUT: cloned_template

    // Validate global template exists
    global_template = find_template(global_template_id)
    IF global_template IS null OR NOT global_template.is_global THEN
        THROW error "Template not found or not global"
    END IF

    // Check if clone already exists
    existing_clone = find_msp_template(msp_company_id, global_template_id)
    IF existing_clone IS NOT null THEN
        RETURN existing_clone
    END IF

    // Create new template clone
    new_template = duplicate(global_template)
    new_template.company_id = msp_company_id
    new_template.is_global_template = false
    new_template.original_template_id = global_template_id

    // Clone all questions
    FOR each question IN global_template.questions
        cloned_question = duplicate(question)
        cloned_question.template_id = new_template.id
        save(cloned_question)
    END FOR

    save(new_template)

    LOG "Template cloned successfully"

    RETURN new_template
END cloneTemplateForMSP
```

---

## For Developers

### Benefits of Pseudo Code

1. **Clarity** - Forces you to think through the logic clearly
2. **Communication** - Team members can review logic without code syntax
3. **Planning** - Identify edge cases before writing code
4. **Documentation** - Serves as in-code documentation
5. **Debugging** - Easier to spot logical errors
6. **Refactoring** - Understand original intent when modifying

### How to Write Effective Pseudo Code

1. **Start High-Level** - Outline main steps first
2. **Add Detail** - Drill down into complex sections
3. **Use Consistent Terms** - Match your domain language
4. **Keep It Readable** - Anyone should understand it
5. **Include Edge Cases** - Document error handling
6. **Think in Workflows** - Input → Process → Output

### Integration with Code

```php
/**
 * Process client assessment submission
 *
 * Pseudo Code:
 * BEGIN processSubmission
 *   VALIDATE all required questions answered
 *   CALCULATE total score and risk level
 *   UPDATE assessment status to "Completed"
 *   SEND notification to MSP admin
 *   GENERATE compliance report PDF
 *   LOG completion for audit trail
 *   RETURN submission confirmation
 * END processSubmission
 *
 * @param AssessmentEvent $assessment
 * @return SubmissionResult
 */
public function processSubmission(AssessmentEvent $assessment): SubmissionResult
{
    // Implementation follows pseudo code plan...
}
```

---

## For Claude Code

### AI Assistant Guidelines

When Claude Code (or any AI assistant) is asked to implement complex functionality:

1. **Generate Pseudo Code First**
```
User Request: "Implement assessment scoring with risk levels"

Claude Response:
"I'll start by planning this with pseudo code:

BEGIN calculateScoreWithRiskLevel
  VALIDATE assessment exists and has answers
  CALCULATE total score from questions
  DETERMINE percentage (score / max_possible)
  CLASSIFY risk level:
    - 90-100% = Low Risk
    - 70-89% = Medium Risk
    - Below 70% = High Risk
  RETURN score data with risk classification
END

Now I'll implement this plan..."
```

2. **Explain Complex Algorithms Step-by-Step**
3. **Validate Logic Before Writing Code**
4. **Document Decision-Making Process**
5. **Create Clear Implementation Plans**

### Claude Code Checklist

- [ ] Read business requirements carefully
- [ ] Write pseudo code outlining the solution
- [ ] Identify edge cases and error conditions
- [ ] Confirm approach with user if uncertain
- [ ] Implement following the pseudo code plan
- [ ] Add pseudo code to PHPDoc documentation
- [ ] Include comprehensive logging
- [ ] Write tests based on pseudo code scenarios

---

## Common Patterns

### Pattern 1: Validation → Process → Return

```
BEGIN processUserRequest
    // Validation phase
    VALIDATE input parameters
    VALIDATE user permissions
    VALIDATE business rules

    // Processing phase
    LOAD required data
    PERFORM business logic
    UPDATE database records

    // Return phase
    LOG operation results
    RETURN success response
END
```

### Pattern 2: Loop with Aggregation

```
BEGIN aggregateResults
    INITIALIZE totals = empty

    FOR each item IN collection
        CALCULATE item_value
        ADD item_value to totals
        UPDATE item status
    END FOR

    RETURN totals
END
```

### Pattern 3: Multi-Step Workflow

```
BEGIN multiStepProcess
    STEP 1: Validate inputs
        IF validation fails THEN
            RETURN error
        END IF

    STEP 2: Process data
        TRY
            EXECUTE main logic
        CATCH error
            LOG error
            ROLLBACK transaction
            RETURN error
        END TRY

    STEP 3: Finalize
        COMMIT transaction
        SEND notifications
        RETURN success
END
```

---

## Best Practices Checklist

### Writing Pseudo Code
- [ ] Use consistent indentation
- [ ] Keep statements simple and clear
- [ ] Use domain-specific terminology
- [ ] Include error handling
- [ ] Document assumptions
- [ ] Add comments for complex logic

### Using Pseudo Code
- [ ] Write before implementing
- [ ] Include in code documentation
- [ ] Review with team if complex
- [ ] Update when logic changes
- [ ] Reference in code reviews
- [ ] Use for debugging discussions

---

## Related Standards

- [PHP Standards](./03-php-standards.md) - PHPDoc integration
- [Quality Standards](./08-quality-standards.md) - Documentation requirements
- [Testing Standards](./10-testing-standards.md) - Test case planning

---

**Next:** [Project Structure →](./02-project-structure.md)

**Last Updated:** January 2025
