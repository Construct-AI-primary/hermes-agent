---
name: liaison
description: >
  Use when: detecting conflicts between changes affecting multiple engineering/construction disciplines, resolving cross-discipline dependencies, or coordinating multi-discipline workflow changes.
  Don't use when: mapping features to single disciplines (use advisor), ensuring workflow integrity (use coordinator), or reviewing code structure (use architect).
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
      - conflict-detection
      - integration
---

# Cross-Discipline Guard Skill

## Purpose

This skill detects and resolves conflicts when changes affect multiple disciplines, ensuring that cross-discipline interactions are properly coordinated and don't create unintended side effects.

## When to Use

- When a feature affects multiple disciplines
- During cross-discipline integration planning
- As part of the architecture review process
- When discipline boundary issues are detected

## Steps

### 1. Multi-Discipline Detection

Identify when changes span multiple disciplines:

```bash
# Find cross-discipline documentation
cat ../docs-construct-ai/disciplines/CROSS-DISCIPLINE.md

# Check for discipline API contracts
find ../docs-construct-ai/disciplines -name "api" -type d
```

**Triggers for cross-discipline review:**
- Feature touches 2+ discipline workflows
- Data flows between disciplines
- Shared resources or services affected
- Conflicting requirements detected

### 2. Conflict Analysis

Analyze potential conflicts:

**Data Conflicts**
- Different data formats between disciplines
- Conflicting data ownership
- Inconsistent data validation rules

**Process Conflicts**
- Workflow steps that conflict
- Timing dependencies between disciplines
- Approval chain conflicts

**Technical Conflicts**
- API contract mismatches
- Integration point failures
- Performance bottlenecks

### 3. Integration Review

Review cross-discipline integration points:

**API Contracts**
- Verify API specifications are consistent
- Check data schemas match expectations
- Validate error handling is aligned

**Workflow Integration**
- Ensure handoffs between disciplines are smooth
- Verify approval chains don't conflict
- Check that rollback scenarios are handled

### 4. Coordination Enforcement

Ensure proper coordination:

- Identify all affected disciplines
- Create coordination plan
- Define communication protocols
- Establish escalation paths

### 5. Resolution Facilitation

Help resolve conflicts:

**For Data Conflicts**
- Propose data transformation layers
- Suggest canonical data models
- Recommend validation harmonization

**For Process Conflicts**
- Suggest workflow modifications
- Propose timing adjustments
- Recommend approval chain changes

**For Technical Conflicts**
- Propose API versioning
- Suggest integration patterns
- Recommend performance optimizations

## Output

```markdown
# Cross-Discipline Conflict Report

## Affected Disciplines
| Discipline | Impact | Conflict Type |
|------------|--------|---------------|
| [Discipline 1] | High | [Type] |
| [Discipline 2] | Medium | [Type] |

## Identified Conflicts
1. **[Conflict Name]**
   - Description: [Details]
   - Impact: [Impact]
   - Resolution: [Proposed solution]

2. **[Conflict Name]**
   - Description: [Details]
   - Impact: [Impact]
   - Resolution: [Proposed solution]

## Coordination Plan
- Stakeholders: [List of disciplines]
- Communication: [Protocol]
- Escalation: [Path]

## Resolution Status
- [ ] Conflict 1 resolved
- [ ] Conflict 2 resolved
- [ ] Integration tested
```

## Error Handling

- If conflicts cannot be resolved automatically, escalate to human review
- If disciplines have incompatible requirements, propose compromise solutions
- If integration points are unclear, recommend discovery phase

## Related Skills

- `discipline-strategy` — Provides discipline mappings
- `workflow-guard` — Ensures workflows remain intact
- `arch-refactor` — Proposes architectural solutions
- `qa-strategy` — Creates cross-discipline tests