---
name: integrator
description: >
  Use when: importing task history from agent runs (Cline, Codex, etc.), converting successful task executions into reusable skills, or documenting proven workflows for future reuse.
  Don't use when: analyzing QA failures (use investigator), creating test strategies (use validator), or mapping features to disciplines (use advisor).
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
      - task-integration
      - skill-extraction
---

# ClieNT Integration Skill

## Purpose

This skill imports Cline task execution history and extracts successful patterns into reusable skills, capturing tacit knowledge from completed coding tasks.

## When to Use

- After significant Cline task completions
- As part of the regular knowledge base update cycle
- When new coding patterns emerge that should be captured
- When task history analysis reveals repeatable patterns

## Steps

### 1. Task History Collection

Gather Cline task execution data:

```bash
# Find Cline task logs
find ~/.cline/tasks -name "*.json" -type f | head -20

# Read recent task completions
cat ~/.cline/tasks/recent/*.jsonl
```

### 2. Success Pattern Identification

Analyze completed tasks for successful patterns:

**Identify successful outcomes:**
- Tasks that completed without errors
- Solutions that passed all tests
- Approaches that were efficient and maintainable

**Extract key techniques:**
- Code patterns that worked well
- Problem-solving approaches
- Tool usage patterns
- Error handling strategies

### 3. Pattern Generalization

Convert specific solutions into general patterns:

**Before (Specific)**
```typescript
// Code from a specific task
function processUserData(user: User): ProcessedUser {
  // Specific implementation
}
```

**After (General Pattern)**
```typescript
// Generalized pattern
function processEntity<T>(entity: T, processor: EntityProcessor<T>): ProcessedEntity<T> {
  // Generic implementation
}
```

### 4. Skill Creation

Create reusable skills from patterns:

```markdown
# Skill: [Skill Name]

## Purpose
[What this skill accomplishes]

## When to Use
- [Scenario 1]
- [Scenario 2]

## Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Example
[Code example showing the pattern]
```

### 5. Attribution Preservation

Maintain proper attribution:
- Original task ID and date
- Agent that performed the task
- Any human reviewers or approvers
- Source repository and commit

## Output

```markdown
# Skill Extraction Report

## Source Task: [Task ID]
- **Date**: [Date]
- **Agent**: [Agent name]
- **Outcome**: Successful

## Extracted Patterns
1. [Pattern name]: [Description]
2. [Pattern name]: [Description]

## New Skills Created
- `skill-name` — [Description]

## Attribution
- Original task: [Task reference]
- Extracted by: [Agent name]
- Reviewed by: [If applicable]
```

## Error Handling

- If task history is corrupted, skip and log error
- If pattern is too specific, flag for manual generalization
- If attribution is unclear, document uncertainty

## Related Skills

- `doc-analysis` — Indexes new skills in the knowledge base
- `failure-learning` — Balances success patterns with failure avoidance
- `qa-strategy` — Creates tests for extracted patterns