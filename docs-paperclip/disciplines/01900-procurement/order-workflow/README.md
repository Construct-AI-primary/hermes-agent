---
title: 01900 Procurement Order Workflow Testing — Issue Index
date: 2026-04-07
status: planning
---

# 01900 Procurement Order Workflow Testing — Issue Index

## Overview

This directory contains the issue tracking and planning documents for testing the **01900 Procurement Order Workflow** via the Paperclip control plane. The workflow covers the full procurement order lifecycle from UI modal interaction through SOW generation, approval routing, compliance validation, and logistics processing.

## Company Assignments

| Company | Role | Lead Issues | Supporting |
|---------|------|-------------|------------|
| **DevForge AI** | All code work — UI fixes, backend alignment, schema, orchestration | PROC-000, PROC-001, PROC-002, PROC-003, PROC-010, PROC-011, PROC-012, PROC-013 | PROC-022, PROC-033, PROC-042 |
| **QualityForge AI** | All testing execution — E2E, integration, compliance, simulation | PROC-020, PROC-021, PROC-022, PROC-023, PROC-040 | PROC-001, PROC-003, PROC-030, PROC-031, PROC-032 |
| **DomainForge AI** | Domain expertise — procurement workflows, supplier management, contract admin | PROC-010, PROC-031, PROC-032 | PROC-001, PROC-002, PROC-003, PROC-011, PROC-012, PROC-020, PROC-021, PROC-023, PROC-033 |
| **KnowledgeForge AI** | Knowledge indexing, report generation | PROC-030, PROC-041 | — |
| **InfraForge AI** | Supply chain integration | PROC-031 | PROC-022 |
| **Loopy AI** | UX copy & microcopy review | PROC-043 | — |

## Issue Files

| ID | Title | Phase | Lead Company | Priority |
|----|-------|-------|-------------|----------|
| [PROC-000](issues/PROC-000-skill-remediation.md) | Skill Remediation — Update DomainForge Procurement Skills | Prerequisite | DevForge AI | Critical |
| [PROC-001](issues/PROC-001-ui-modal-e2e-flow.md) | Verify 01900 UI Modal E2E Flow | Phase 1 — UI/Coding | DevForge AI | Critical |
| [PROC-002](issues/PROC-002-sow-template-alignment.md) | Align SOW Template Selection Code | Phase 1 — UI/Coding | DevForge AI | Critical |
| [PROC-003](issues/PROC-003-approval-matrix-integration.md) | Ensure Approval Matrix (01300) Integration | Phase 1 — UI/Coding | DevForge AI | Critical |
| [PROC-010](issues/PROC-010-procurement-input-backend.md) | Audit & Fix Procurement Input Backend | Phase 2 — Backend Workflow | DevForge AI | High |
| [PROC-011](issues/PROC-011-hitl-manager-wiring.md) | Verify HITL Manager Wiring | Phase 2 — Backend Workflow | DevForge AI | High |
| [PROC-012](issues/PROC-012-agent-orchestration-dispatch.md) | Fix Agent Orchestration Dispatch | Phase 2 — Backend Workflow | DevForge AI | High |
| [PROC-013](issues/PROC-013-database-schema-alignment.md) | Database Schema Alignment | Phase 2 — Backend Workflow | DevForge AI | High |
| [PROC-020](issues/PROC-020-e2e-procurement-tests.md) | Execute Procurement E2E Tests | Phase 3 — Testing Execution | QualityForge AI | High |
| [PROC-021](issues/PROC-021-compliance-boundary-tests.md) | Run Compliance Boundary Tests | Phase 3 — Testing Execution | QualityForge AI | High |
| [PROC-022](issues/PROC-022-integration-tests.md) | Integration Tests (order→approval→budget) | Phase 3 — Testing Execution | QualityForge AI | High |
| [PROC-023](issues/PROC-023-data-extraction-tests.md) | Data Extraction Accuracy Tests | Phase 3 — Testing Execution | QualityForge AI | Medium |
| [PROC-030](issues/PROC-030-knowledgeforge-indexing.md) | KnowledgeForge Indexing of Procurement | Phase 4 — Cross-Company | KnowledgeForge AI | Medium |
| [PROC-031](issues/PROC-031-supplier-portal-integration.md) | Supplier Portal Integration Testing | Phase 4 — Cross-Company | DomainForge AI | High |
| [PROC-032](issues/PROC-032-multi-discipline-appendix.md) | Multi-Discipline Appendix Validation | Phase 4 — Cross-Company | DomainForge AI | Medium |
| [PROC-033](issues/PROC-033-gantt-chart-verification.md) | Gantt Chart Integration Verification | Phase 4 — Cross-Company | DevForge AI | Medium |
| [PROC-040](issues/PROC-040-full-simulation.md) | Full E2E Procurement Simulation | Phase 5 — Production Readiness | QualityForge AI | Critical |
| [PROC-041](issues/PROC-041-testing-summary-report.md) | Generate Testing Summary Report | Phase 5 — Production Readiness | KnowledgeForge AI | High |
| [PROC-042](issues/PROC-042-readiness-dashboard-update.md) | Procurement Readiness Dashboard Update | Phase 5 — Production Readiness | DevForge AI | Medium |
| [PROC-043](issues/PROC-043-ux-copy-review.md) | UX Copy & Microcopy Review | Phase 5 — Production Readiness | Loopy AI | Low |

## Dependency Graph

```
PROC-000 (Skill Remediation)
    └── PROC-001 ──┐
    ├── PROC-002 ──┤
    ├── PROC-003 ──┤── All must pass before Phase 3
    │               │
PROC-010 ──────────┤
PROC-011 ──────────┤
PROC-012 ──────────┤
PROC-013 ──────────┘
    │
    ├── PROC-020 ──┐
    ├── PROC-021 ──┤
    ├── PROC-022 ──┤── Phase 3 Testing
    ├── PROC-023 ──┘
    │
    ├── PROC-030 (KnowledgeForge)
    ├── PROC-031 (Supplier Portal)
    ├── PROC-032 (Multi-Discipline)
    ├── PROC-033 (Gantt Chart)
    │
    ├── PROC-040 ──┐
    ├── PROC-041 ──┤── Phase 5 Final
    ├── PROC-042 ──┤
    └── PROC-043 ──┘
```

## Master Plan

- [2026-04-07-procurement-workflow-testing.md](2026-04-07-procurement-workflow-testing.md) — Full testing plan document