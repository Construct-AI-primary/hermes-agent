---
name: monitor
description: >
  Use when: verifying that PRs and features conform to application policy documents before deployment, auditing changes against governance standards, or performing pre-deployment compliance checks.
  Don't use when: detecting cross-discipline conflicts (use liaison), testing workflow integrity (use coordinator), or creating test strategies (use validator).
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
      - policy-enforcement
      - compliance
---

# App Guardian Skill

## Purpose

This skill enforces application policies and standards before deployment, acting as the final gatekeeper for code quality, security, and compliance.

## When to Use

- On every PR before merge approval
- Before production deployments
- During security reviews
- As part of the release process

## Steps

### 1. Policy Document Review

Read the application policy documents:

```bash
# Find policy documents
find ../docs-construct-ai/standards -name "*.md" -type f
find ../docs-construct-ai/codebase/security -name "*.md" -type f
find ../docs-construct-ai/codebase/audits -name "*.md" -type f
```

### 2. Security Compliance Check

Verify security requirements:

**Authentication & Authorization**
- [ ] All endpoints require authentication
- [ ] Role-based access control is enforced
- [ ] API keys are properly validated
- [ ] Session management is secure

**Data Protection**
- [ ] Sensitive data is encrypted at rest
- [ ] Data in transit uses TLS
- [ ] PII is properly handled
- [ ] No secrets in source code

**Input Validation**
- [ ] All user inputs are validated
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection

### 3. Code Quality Verification

Check code quality standards:

**Type Safety**
- [ ] TypeScript strict mode enabled
- [ ] No `any` types without justification
- [ ] Proper type definitions for APIs

**Error Handling**
- [ ] Consistent error handling patterns
- [ ] Proper error messages
- [ ] Error logging implemented

**Testing**
- [ ] Unit tests for critical paths
- [ ] Integration tests for APIs
- [ ] Test coverage meets threshold

### 4. Architecture Compliance

Verify architectural standards:

- [ ] Layer separation maintained
- [ ] Dependency injection used correctly
- [ ] No circular dependencies
- [ ] Module boundaries respected

### 5. Documentation Check

Ensure documentation is complete:

- [ ] API documentation updated
- [ ] README files accurate
- [ ] CHANGELOG updated
- [ ] Migration guides if needed

## Output

```markdown
# App Guardian Report

## PR: [PR Number/Title]

### Security Compliance
- **Status**: Pass/Fail
- **Issues**: [List of issues]

### Code Quality
- **Status**: Pass/Fail
- **Issues**: [List of issues]

### Architecture Compliance
- **Status**: Pass/Fail
- **Issues**: [List of issues]

### Documentation
- **Status**: Pass/Fail
- **Issues**: [List of issues]

## Decision
- **Approval**: Approved / Rejected / Needs Work
- **Conditions**: [Any conditions for approval]
```

## Error Handling

- If policy documents are missing, flag for documentation creation
- If compliance cannot be verified, require manual review
- If critical issues found, block deployment and escalate

## Related Skills

- `qa-strategy` — Verifies test coverage is adequate
- `arch-refactor` — Confirms architectural compliance
- `failure-learning` — Checks for known failure patterns
- `doc-analysis` — Validates documentation completeness