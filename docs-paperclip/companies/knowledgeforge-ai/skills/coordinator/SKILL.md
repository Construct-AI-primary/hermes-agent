---
name: coordinator
description: >
  Use when: verifying that new code changes don't break existing discipline-specific workflows, reviewing PRs for workflow impact, or running regression checks against workflow specifications.
  Don't use when: mapping features to disciplines (use advisor), proposing refactors (use architect), or creating test strategies (use validator).
allowed-tools:
  - Read
  - Grep
  - Write
  - Glob
  - Bash
metadata:
  paperclip:
    tags:
      - discipline-operations
      - workflow-integrity
      - change-protection
---

# Workflow Guardian Skill

## Purpose

This skill verifies that discipline-specific workflows (e.g., PO-materials, safety-inspections, procurement-approval) aren't broken by new code changes, acting as a guardian for established operational processes.

## When to Use

- Before any change that touches workflow-related code
- During workflow design and modification
- As part of the regression testing process
- When workflow documentation needs updating

## Steps

### 1. Workflow Identification

Identify workflows affected by the change:

```bash
# Find workflow documentation
find ../docs-construct-ai/disciplines -path "*/workflow_docs/*" -name "*.md" -type f

# Find workflow-related code
grep -r "workflow" --include="*.ts" --include="*.tsx" src/
```

### 2. Workflow Integrity Verification

For each affected workflow, verify:

**Step Integrity**
- [ ] All workflow steps are preserved
- [ ] Step ordering is maintained
- [ ] Conditional branches are handled correctly
- [ ] Error paths are properly defined

**Data Flow**
- [ ] Input data matches expected format
- [ ] Output data meets downstream requirements
- [ ] Data transformations are correct
- [ ] Validation rules are enforced

**User Interactions**
- [ ] UI elements match workflow requirements
- [ ] User permissions are correctly enforced
- [ ] Notifications are triggered appropriately
- [ ] Audit trails are maintained

### 3. Process Compliance Check

Verify compliance with operational procedures:

- Review documented procedures for the workflow
- Check that all required steps are present
- Verify approval chains are correct
- Ensure regulatory requirements are met

### 4. Regression Detection

Detect potential regressions:

**Functional Regressions**
- Compare current behavior with expected behavior
- Check for missing or altered functionality
- Verify edge cases are still handled

**Performance Regressions**
- Check workflow execution time
- Verify resource usage is acceptable
- Ensure scalability is maintained

**Integration Regressions**
- Verify cross-workflow interactions
- Check data exchange with other systems
- Ensure external integrations work

### 5. Documentation Update

Update workflow documentation if needed:

- Document any workflow changes
- Update workflow diagrams
- Revise procedure documents
- Notify affected stakeholders

## Output

```markdown
# Workflow Integrity Report

## Affected Workflows
| Workflow | Discipline | Status | Issues |
|----------|------------|--------|--------|
| [Name] | [Discipline] | Pass/Fail | [Count] |

## Integrity Verification
### [Workflow Name]
- **Step Integrity**: Pass/Fail
- **Data Flow**: Pass/Fail
- **User Interactions**: Pass/Fail

## Compliance Check
- [ ] Procedure compliance verified
- [ ] Regulatory requirements met
- [ ] Approval chains correct

## Regression Detection
- [ ] No functional regressions
- [ ] No performance regressions
- [ ] No integration regressions

## Issues Found
1. **[Issue]** — [Description] — [Severity]
2. **[Issue]** — [Description] — [Severity]

## Recommendations
1. [Recommendation]
2. [Recommendation]
```

## Error Handling

- If workflow documentation is missing, flag for documentation creation
- If regression is detected, block deployment and require fix
- If compliance cannot be verified, require manual review

## Related Skills

- `discipline-strategy` — Provides workflow mappings
- `cross-discipline-guard` — Handles cross-workflow conflicts
- `qa-strategy` — Creates workflow regression tests
- `failure-learning` — Learns from workflow failures