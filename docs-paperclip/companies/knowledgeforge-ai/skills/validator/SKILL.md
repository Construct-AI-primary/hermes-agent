---
name: validator
description: >
  Use when: creating comprehensive QA test strategies for production-ready runs, designing test coverage plans, or defining validation criteria for features and workflows.
  Don't use when: generating sector-specific tests (use lead), analyzing QA failures (use investigator), or ensuring workflow integrity (use coordinator).
allowed-tools:
  - Read
  - Grep
  - Write
  - Glob
  - Bash
metadata:
  paperclip:
    tags:
      - knowledge-engineering
      - qa-strategy
      - test-planning
---

# QA Strategy Skill

## Purpose

This skill creates comprehensive QA test strategies that cover unit, integration, e2e, and sector-specific scenarios, ensuring thorough test coverage before production deployment.

## When to Use

- When new features are being developed
- Before major releases
- When test coverage falls below thresholds
- When sector-specific compliance testing is needed

## Steps

### 1. Scope Analysis

Read the feature requirements and identify:
- Core functionality that must be tested
- Integration points with existing systems
- Sector-specific compliance requirements
- Risk areas that need extra attention

### 2. Coverage Gap Analysis

```bash
# Check current test coverage
pnpm test:coverage

# Identify untested critical paths
grep -r "TODO.*test" --include="*.ts" --include="*.tsx"
```

### 3. Test Strategy Design

Create a test strategy document that includes:

**Unit Tests**
- Core business logic
- Utility functions
- Data transformations
- Edge cases and error handling

**Integration Tests**
- API endpoint interactions
- Database operations
- External service integrations
- Cross-module communication

**E2E Tests**
- Critical user journeys
- Multi-step workflows
- Cross-browser compatibility
- Performance under load

**Sector-Specific Tests**
- Regulatory compliance verification
- Sector workflow validation
- Industry-standard edge cases

### 4. Risk Prioritization

Prioritize tests based on:
- Impact on users if broken
- Likelihood of failure
- Difficulty of detection
- Recovery complexity

### 5. CI/CD Integration

Define how tests will run in the pipeline:
- Unit tests on every commit
- Integration tests on PR
- E2E tests on staging
- Sector compliance tests before release

## Output

```markdown
# QA Strategy: [Feature Name]

## Test Scope
- [ ] Unit tests: X new tests
- [ ] Integration tests: Y scenarios
- [ ] E2E tests: Z user journeys
- [ ] Sector compliance: [sector] requirements

## Risk Assessment
- High risk: [items]
- Medium risk: [items]
- Low risk: [items]

## CI/CD Pipeline
- Pre-commit: unit tests
- PR: integration tests
- Staging: E2E tests
- Release: sector compliance
```

## Error Handling

- If coverage cannot be determined, flag for manual review
- If sector requirements are unclear, escalate to Sector Analyst
- If test environment is unavailable, document and reschedule

## Related Skills

- `doc-analysis` — Uses document index for context
- `arch-refactor` — Coordinates on testability improvements
- `sector-qa` — Integrates sector-specific tests
- `app-guardian` — Provides test evidence for approval gates