---
name: org-template-ai-review
description: >
  Use when reviewing any organisational deliverable for quality, standards compliance, and alignment with company goals. Provides a systematic review checklist tailored to your organisation's specific standards.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
---

# Organisation Review

Systematic review process for organisational deliverables.

## When to Use

- When reviewing any deliverable before delivery or publication
- When validating work against organisational standards
- Before merging changes to important deliverables
- **Don't use when:** Quick informal checks only — use this for formal reviews

## Core Procedures

### Step 1: Understand the Deliverable

- Read the full deliverable thoroughly
- Identify the deliverable type, scope, and intended audience
- Note any dependencies or related work
- Understand what standards and requirements apply

### Step 2: Check Against Organisational Standards

- Review against `knowledge/company-standards/` (your org's internal standards)
- Verify alignment with organisational goals from COMPANY.md
- Check that team/agent responsibilities are properly addressed
- Validate compliance with quality expectations

### Step 3: Technical and Quality Review

- Verify completeness and accuracy
- Check for consistency with existing organisational knowledge
- Identify any risks, gaps, or areas of concern
- Validate that all requirements are met

### Step 4: Provide Structured Feedback

For each finding, provide:
```
FINDING: [brief description]
SEVERITY: [critical/high/medium/low]
TYPE: [bug/style/standards/missing/enhancement]
LOCATION: [file/path/section if applicable]
EXPLANATION: [clear description of the issue]
SUGGESTION: [specific recommendation for fixing]
```

### Step 5: Summary Decision

```
REVIEW SUMMARY
==============
Pass/Fail: [overall assessment]
Critical Issues: [count]
Blockers: [list any blocking issues]
Recommended Actions: [next steps]
```

## Quality Checklist

- [ ] Standards compliance verified
- [ ] All requirements addressed
- [ ] No critical or blocking issues
- [ ] Feedback is specific and actionable
- [ ] Risk areas identified and documented

## Error Handling

- **Error:** Critical issue found during review
  **Response:** Block delivery, escalate to appropriate lead, document issue clearly
- **Error:** Standards gap found (no internal standard exists)
  **Response:** Note the gap, propose a standard, flag for knowledge update