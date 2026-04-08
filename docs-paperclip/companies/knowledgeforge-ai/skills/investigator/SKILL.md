---
name: investigator
description: >
  Use when: analyzing QA test failures or production incidents, extracting root causes from recurring issues, converting failure analysis into reusable skills, or building prevention strategies.
  Don't use when: creating test strategies (use validator), generating sector-specific tests (use lead), or importing task history (use integrator).
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
      - failure-analysis
      - skill-building
---

# Failure Learning Skill

## Purpose

This skill analyzes QA test failures and production incidents to identify root causes, extract lessons learned, and convert them into reusable skills that prevent future occurrences.

## When to Use

- After significant test failures
- Following production incidents
- During post-mortem analysis
- As part of the continuous improvement loop

## Steps

### 1. Failure Collection

Gather failure data:

```bash
# Find recent test failures
find ../docs-construct-ai/testing -name "*.log" -mtime -7

# Check error tracking
find ../docs-construct-ai/error-tracking -name "*.md" -type f
```

### 2. Root Cause Analysis

For each failure, perform root cause analysis:

**The 5 Whys Technique**
1. Why did the failure occur?
2. Why did that condition exist?
3. Why wasn't it prevented?
4. Why wasn't it detected earlier?
5. Why did the system allow it?

**Categorize the failure:**
- Test gap (missing test coverage)
- Design flaw (architectural issue)
- Implementation error (coding mistake)
- Environment issue (infrastructure problem)
- Process failure (workflow breakdown)

### 3. Pattern Recognition

Identify recurring patterns:
- Similar failures in different parts of the codebase
- Common root causes across multiple incidents
- Systemic issues that enable failures

### 4. Skill Generation

Convert failure analysis into reusable skills:

**New Test Cases**
```typescript
// Test that would have caught this failure
describe('prevented failure scenario', () => {
  it('should handle [specific condition]', () => {
    // Test implementation
  });
});
```

**Updated Workflows**
```markdown
# Updated Workflow: [Name]

## Changes Made
- Added validation step for [condition]
- Added error handling for [scenario]
- Added monitoring for [metric]
```

**Prevention Guidelines**
```markdown
# Prevention: [Failure Type]

## Warning Signs
- [Early indicator 1]
- [Early indicator 2]

## Prevention Steps
1. [Step to prevent]
2. [Step to detect early]
3. [Step to mitigate]
```

### 5. Knowledge Distribution

Ensure lessons are shared:
- Update relevant documentation
- Add to agent training materials
- Create alerts for early detection
- Share with affected teams

## Output

```markdown
# Failure Analysis Report

## Incident: [ID/Title]
- **Date**: [Date]
- **Impact**: [Description]
- **Root Cause**: [Analysis]

## Lessons Learned
1. [Lesson 1]
2. [Lesson 2]

## Actions Taken
- [ ] New test added: [Test name]
- [ ] Workflow updated: [Workflow name]
- [ ] Documentation updated: [Doc name]
- [ ] Monitoring added: [Alert name]

## Reusable Skills Created
- `skill-name` — [Description]
```

## Error Handling

- If root cause cannot be determined, flag for deeper investigation
- If failure is unreproducible, document investigation steps
- If fix would break existing functionality, recommend phased approach

## Related Skills

- `qa-strategy` — Enhances test coverage based on failures
- `doc-analysis` — Updates documentation with lessons learned
- `arch-refactor` — Addresses architectural root causes
- `app-guardian` — Adds prevention checks to approval gates