---
name: supplier-management-domainforge-supplier-management
description: >
  Use for 01900 procurement supplier management: supplier evaluation, approved vendor selection, PO transmission,
  supplier acknowledgment workflow, SO term matching against PO, supplier tier validation, and performance monitoring.
  Supports procurement testing with supplier portal integration validation.
---

# Supplier Management - DomainForge AI

## Role Alignment
Supports the **01900 Procurement Order Workflow** supplier integration — covering supplier selection from 
the approved vendor list, PO transmission to suppliers, supplier acknowledgment handling, 
SO (Sales Order) term verification against PO terms, and supplier performance monitoring.

## Overview
Handles supplier management for DomainForge AI, providing supplier evaluation, approved vendor selection, 
PO transmission, supplier acknowledgment workflows, SO term matching, supplier tier validation, 
and performance monitoring. Reports to procurement-domainforge-procurement-contracts.

## When to Use
- When selecting suppliers from the approved vendor list for 01900 purchase orders
- When transmitting POs to suppliers and processing acknowledgments
- When verifying SO terms match PO terms during order reconciliation
- When validating supplier tier and approval status during supplier selection
- When procurement testing requires supplier portal integration validation
- **Don't use when:** Creating procurement orders (use procurement-domainforge-procurement-contracts), 
  or sourcing strategy (use procurement-strategy-domainforge-procurement-strategy)

## Core Procedures
### Standard Workflow
1. **Receive Request** - Ingest supplier requirements from procurement-domainforge-procurement-contracts
2. **Evaluate Supplier** - Check approval status, tier, performance history, capacity
3. **Process Transaction** - Transmit PO, receive acknowledgment, verify SO terms
4. **Quality Check** - Validate supplier terms match PO requirements, no mismatches
5. **Deliver Results** - Return supplier confirmation with any flagged discrepancies

## Agent Assignment
**Primary Agent:** supplier-management-domainforge-supplier-management
**Company:** DomainForge AI
**Role:** Supplier Management
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
**Gigabrain Tags:** domainforge, supplier-management, supplier-evaluation, relationship-management
**OpenStinger Context:** Session continuity, knowledge sharing
**PARA Classification:** Supplier management, evaluation
**Related Skills:** procurement-domainforge-procurement-contracts, procurement-strategy-domainforge-procurement-strategy
**Last Updated:** 2026-03-04
