---
name: procurement-strategy-domainforge-procurement-strategy
description: >
  Use for 01900 procurement strategy: sourcing strategy, procurement optimization, strategic sourcing, 
  supplier tiering, order complexity assessment, and approval threshold optimization within DomainForge AI.
  Supports procurement testing with multi-scenario validation (simple/standard/complex/emergency/compliance).
---

# Procurement Strategy - DomainForge AI

## Role Alignment
Provides strategic analysis and optimization for the **01900 Procurement Order Workflow** — covering 
sourcing strategy, complexity-level assignment (simple/standard/complex/emergency/compliance), 
approval threshold optimization, and supplier tiering decisions.

## Overview
Handles procurement strategy for DomainForge AI, providing sourcing strategy, procurement optimization, 
strategic sourcing, supplier tiering, order complexity assessment, and procurement intelligence. 
Reports to procurement-domainforge-procurement-contracts.

## When to Use
- When determining optimal complexity level for procurement orders (affects workflow routing and discipline assignment)
- When optimizing approval thresholds based on historical procurement data
- When developing sourcing strategies for supplier selection in 01900 orders
- When procurement testing requires complex/emergency/compliance scenario validation
- **Don't use when:** Creating procurement orders (use procurement-domainforge-procurement-contracts), 
  or analyzing spend data (use procurement-analytics-domainforge-procurement-analytics)

## Core Procedures
### Standard Workflow
1. **Receive Request** - Ingest strategy requirements from procurement-domainforge-procurement-contracts
2. **Analyze Strategy** - Evaluate complexity, costs, compliance needs, sourcing options
3. **Develop Strategy** - Recommend complexity level, sourcing approach, approval configuration
4. **Quality Check** - Validate strategy against organizational policies and budget constraints
5. **Deliver Results** - Return strategy with rationale and recommended workflow configuration

## Agent Assignment
**Primary Agent:** procurement-strategy-domainforge-procurement-strategy
**Company:** DomainForge AI
**Role:** Procurement Strategy
**Reports To:** procurement-domainforge-procurement-contracts

## Success Metrics
- Task completion rate: >=95%
- Quality score: >=90%
- Response time: <4 hours
- Stakeholder satisfaction: >=90%

## Error Handling
- **Error:** Task execution failure
  **Response:** Retry with adjusted approach, escalate to procurement-domainforge-procurement-contracts if persistent
- **Error:** Quality validation fails
  **Response:** Re-work task, apply quality improvements, re-validate

## Cross-Team Integration
**Gigabrain Tags:** domainforge, procurement-strategy, sourcing, strategic-sourcing
**OpenStinger Context:** Session continuity, knowledge sharing
**PARA Classification:** Procurement strategy, sourcing
**Related Skills:** procurement-domainforge-procurement-contracts, supplier-management-domainforge-supplier-management
**Last Updated:** 2026-03-04
