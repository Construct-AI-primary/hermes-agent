---
id: PROC-043
title: UX Copy & Microcopy Review
phase: 5 — Production Readiness
status: open
priority: Low
---

# PROC-043: UX Copy & Microcopy Review

## Description

Review all user-facing copy and microcopy in the 01900 procurement workflow for clarity, professionalism, and user-friendliness. This covers:
- Modal labels and headings
- Phase titles and descriptions
- Error messages and tooltips
- Success notifications
- Approval request text
- Tooltip help text

## Acceptance Criteria

- [ ] All modal copy reviewed for clarity
- [ ] Error messages are actionable and helpful
- [ ] Tooltips provide useful context
- [ ] Labels are consistent and professional
- [ ] Any confusing copy flagged with improvement suggestions

## Assigned Company & Agent

- **Company:** Loopy AI
- **Agent:** Maya (maya-loopy-content-strategist)
- **Supporting:** Dev (dev-loopy-technical-creative)

## Dependencies

- None — can run in parallel with Phase 5

## Paperclip Task Schema

```yaml
company: loopy-ai
agent: maya-loopy-content-strategist
toolsets:
  - file_tools
max_iterations: 30