---
name: procurement-analytics-domainforge-procurement-analytics
description: >
  Use for 01900 procurement analytics: spend analysis, procurement reporting, data extraction accuracy validation,
  PO/invoice/quotation/GRN data extraction, procurement intelligence, and budget compliance reporting within DomainForge AI.
  Supports procurement testing with data accuracy validation (>95% extraction accuracy target).
---

# Procurement Analytics - DomainForge AI

## Role Alignment
Provides analytics support for the **01900 Procurement Order Workflow** — covering spend analysis, 
data extraction accuracy validation (POs, invoices, quotations, GRNs), budget compliance reporting, 
and procurement intelligence for testing and operational scenarios.

## Overview
Handles procurement analytics for DomainForge AI, providing spend analysis, procurement reporting, 
data extraction accuracy validation, budget compliance analysis, and procurement intelligence. 
Reports to procurement-domainforge-procurement-contracts.

## When to Use
- When validating data extraction accuracy from procurement documents (target >95%)
- When generating procurement reports for 01900 order analytics dashboard
- When testing data provenance for extracted PO, invoice, quotation, and GRN fields
- When analyzing spend patterns or budget compliance for procurement orders
- **Don't use when:** Creating procurement orders (use procurement-domainforge-procurement-contracts), 
  or supplier contract administration (use supplier-management-domainforge-supplier-management)

## Core Procedures
### Standard Workflow
1. **Receive Request** - Ingest analytics requirements from procurement-domainforge-procurement-contracts
2. **Analyze Data** - Extract, validate, and transform procurement data
3. **Generate Insights** - Calculate metrics, compliance scores, accuracy rates
4. **Quality Check** - Validate extraction accuracy against source documents
5. **Deliver Results** - Return analytics with confidence scores and provenance

## Agent Assignment
**Primary Agent:** procurement-analytics-domainforge-procurement-analytics
**Company:** DomainForge AI
**Role:** Procurement Analytics
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
**Gigabrain Tags:** domainforge, procurement-analytics, spend-analysis, procurement-reporting
**OpenStinger Context:** Session continuity, knowledge sharing
**PARA Classification:** Procurement analytics, spend analysis
**Related Skills:** procurement-domainforge-procurement-contracts, finance-domainforge-finance-cost-management
**Last Updated:** 2026-03-04
