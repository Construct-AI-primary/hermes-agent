---
id: PROC-000
title: Skill Remediation — Update DomainForge Procurement Skills
phase: 0 — Prerequisite
status: open
priority: Critical
---

# PROC-000: Skill Remediation — Update DomainForge Procurement Skills

## Description

Update the DomainForge procurement agent skills to explicitly reference the shared `procurement-testing` skill (located at `docs-paperclip/companies/domainforge-ai/shared/procurement-testing/SKILL.md`) and the 01900 workflow documentation.

## Problem

The following DomainForge procurement agents have generic skill descriptions that do not reference the 01900 workflow or the shared procurement-testing skill:

| Agent | Current Skill File | Issue |
|-------|-------------------|-------|
| `procurement-domainforge-procurement-contracts` | `procurement-domainforge-procurement-contracts/SKILL.md` | Generic — no 01900 reference |
| `procurement-analytics-domainforge-procurement-analytics` | `procurement-analytics-domainforge-procurement-analytics/SKILL.md` | Generic — no 01900 reference |
| `procurement-strategy-domainforge-procurement-strategy` | `procurement-strategy-domainforge-procurement-strategy/SKILL.md` | Generic — no 01900 reference |
| `supplier-management-domainforge-supplier-management` | `supplier-management-domainforge-supplier-management/SKILL.md` | Generic — no 01900 reference |

The shared `procurement-testing` skill is comprehensive (303 lines) but agents are not instructed to use it.

## Required Changes

For each of the 4 skill files above, update to include:
1. Reference to `shared/procurement-testing/SKILL.md` in the `related_skills` field
2. Reference to `docs-construct-ai/disciplines/01900_procurement/workflow_docs/` in the `related_docs` field
3. Updated description to mention 01900 procurement workflow testing

## Assigned Company & Agent

- **Company:** DevForge AI
- **Agent:** Devcore (devcore-devforge-core-development)
- **Supporting:** DomainForge AI (procurement-domainforge-procurement-contracts)

## Required Skills

- `systematic-debugging` (DevForge)
- `writing-skills` (DevForge)
- `procurement-testing` (shared — for reference only)

## Acceptance Criteria

- [ ] All 4 DomainForge procurement skill files updated with `procurement-testing` reference
- [ ] All 4 skill files include 01900 workflow documentation reference
- [ ] Skill descriptions updated to mention 01900 procurement workflow
- [ ] No other fields in skill files are broken
- [ ] Skills pass validation (`pnpm check` or equivalent)

## Dependencies

- None — this is the prerequisite issue that blocks all Phase 1-3 issues

## Paperclip Task Schema

```yaml
company: devforge-ai
agent: devcore-devforge-core-development
toolsets:
  - file_tools
  - code_execution
max_iterations: 50