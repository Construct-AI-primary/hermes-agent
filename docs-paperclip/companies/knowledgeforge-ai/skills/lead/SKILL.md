---
name: lead
description: >
  Use when: generating QA tests for sector-specific workflows (oil-gas, infrastructure, construction, energy), creating compliance test suites, or validating sector regulations are enforced.
  Don't use when: creating general QA strategies (use validator), analyzing failures (use investigator), or mapping features to disciplines (use advisor).
allowed-tools:
  - Read
  - Grep
  - Write
  - Glob
  - Bash
metadata:
  paperclip:
    tags:
      - sector-analysis
      - qa
      - sector-testing
---

# Sector QA Skill

## Purpose

This skill generates comprehensive QA tests for sector-specific workflows, ensuring that construction industry compliance and operational requirements (oil-gas, infrastructure, commercial, industrial, residential) are thoroughly tested.

## When to Use

- When sector-specific features are developed
- During test planning for sector projects
- As part of compliance verification
- When sector regulations are updated

## Steps

### 1. Sector Test Requirements Analysis

Identify testing requirements for each sector:

```bash
# Find sector-specific testing documentation
find ../docs-construct-ai/disciplines/00300_construction -path "*/testing/*" -name "*.md" -type f

# Check for sector-specific workflows
grep -r "testing" ../docs-construct-ai/disciplines/00300_construction --include="*.md"
```

### 2. Compliance Test Design

Create tests that verify regulatory compliance:

**Oil & Gas Compliance Tests**
- H2S safety system verification
- Pressure testing procedures
- Environmental spill prevention
- Emergency shutdown validation
- Permit compliance verification

**Infrastructure Compliance Tests**
- Load testing for bridges/structures
- Traffic management system validation
- Utility coordination verification
- Environmental impact monitoring
- DOT inspection workflow testing

**Commercial Compliance Tests**
- Fire safety system validation
- Accessibility (ADA) compliance
- Occupancy load verification
- Energy code compliance
- Building inspection workflows

**Industrial Compliance Tests**
- Process safety management validation
- Emissions monitoring verification
- Hazardous material handling
- Lockout/tagout procedures
- PPE compliance verification

**Residential Compliance Tests**
- Structural integrity verification
- Electrical system safety
- Plumbing code compliance
- Energy efficiency validation
- Habitability standards testing

### 3. Workflow Test Design

Create tests for sector-specific operational workflows:

**Approval Workflows**
- Multi-level approval chains
- Regulatory agency approvals
- Permit acquisition processes
- Inspection scheduling

**Inspection Workflows**
- Scheduled inspections
- Random compliance checks
- Incident-triggered inspections
- Corrective action tracking

**Reporting Workflows**
- Regulatory reporting deadlines
- Incident reporting procedures
- Compliance certification generation
- Audit trail verification

### 4. Edge Case Identification

Identify sector-specific edge cases:

**Environmental Conditions**
- Extreme weather scenarios
- Natural disaster response
- Environmental contamination events

**Operational Extremes**
- Maximum capacity scenarios
- Equipment failure situations
- Staff shortage contingencies

**Regulatory Extremes**
- Emergency regulation changes
- Variance request handling
- Violation appeal processes

### 5. Test Data Generation

Create realistic test data for sector scenarios:

**Test Scenarios**
- Normal operations
- Edge cases
- Failure scenarios
- Recovery procedures

**Test Data Sets**
- Sample permits and approvals
- Inspection records
- Compliance reports
- Incident logs

## Output

```markdown
# Sector QA Test Plan

## Sector: [Sector Name]

### Compliance Tests
| Test ID | Requirement | Status |
|---------|-------------|--------|
| [ID] | [Regulation reference] | Pass/Fail |

### Workflow Tests
| Test ID | Workflow | Status |
|---------|----------|--------|
| [ID] | [Workflow name] | Pass/Fail |

### Edge Case Tests
| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| [ID] | [Scenario] | [Expected] |

### Test Data
- [ ] Sample permits created
- [ ] Inspection records generated
- [ ] Compliance reports prepared
- [ ] Incident logs populated

## Test Execution Results
- Total tests: [Count]
- Passed: [Count]
- Failed: [Count]
- Blocked: [Count]
```

## Error Handling

- If sector requirements are unclear, escalate to Sector Analyst
- If compliance tests fail, block deployment and require remediation
- If test data cannot be generated, flag for manual creation

## Related Skills

- `sector-analysis` — Provides sector requirements
- `qa-strategy` — Integrates sector tests into overall strategy
- `workflow-guard` — Verifies workflow integrity
- `app-guardian` — Uses test results for approval decisions