-- ============================================================
-- QUALITYFORGE AI - RECONCILIATION FIX SCRIPT
-- Description: Fix all issues identified in qualityforge-ai-recon-2026-04-24.md
-- Date: 2026-04-24
-- Source: docs-paperclip/reports/qualityforge-ai-recon-2026-04-24.md
-- ============================================================
-- ISSUES ADDRESSED:
-- 1. BROKEN_HIERARCHY: 33 agents report to Apex instead of Governor
-- 2. MISSING_IN_DB: 9 agents need to be registered
-- 3. NAME_MISMATCH: 2 agents need name updates
-- 4. ORPHANED_AGENTS: 3 agents not in filesystem (review/archival)
-- 5. NAMING_CONSISTENCY: Folder names must use PascalCase (e.g., qualityforge-ai-Accessibility)
-- ============================================================
-- NAMING RULES:
-- - Agent folders: qualityforge-ai-{PascalCaseName} (e.g., qualityforge-ai-Accessibility)
-- - NO kebab-case: qualityforge-ai-accessibility (WRONG)
-- - NO lowercase: qualityforge-ai-codeanalyzer (WRONG)
-- - PascalCase for multi-word names: qualityforge-ai-CodeAnalyzer, qualityforge-ai-DecisionSupportSpecialist
-- ============================================================

BEGIN;

-- ============================================================
-- SECTION 1: VERIFICATION - Current State
-- ============================================================

-- Check current hierarchy state
SELECT 
    a.name AS agent_name,
    a.reports_to,
    m.name AS manager_name,
    CASE 
        WHEN a.reports_to = '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1' THEN '✓ Correct'
        WHEN a.reports_to = '9e780111-85f6-4cc3-a110-377f23e8fdfc' THEN '✗ Wrong (Apex)'
        WHEN a.reports_to IS NULL THEN '✓ NULL (CEO)'
        ELSE '? Unknown'
    END AS status
FROM agents a
LEFT JOIN agents m ON a.reports_to = m.id
WHERE a.company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef'
ORDER BY a.name;

-- ============================================================
-- SECTION 2: FIX BROKEN HIERARCHY
-- ============================================================
-- All Quality Team agents should report to Governor, not Apex
-- Governor ID: 3d8ea615-db5d-4e0c-996c-cd1f7b738cb1
-- Apex ID: 9e780111-85f6-4cc3-a110-377f23e8fdfc

-- Step 2a: Update all agents (except Apex and Governor) to report to Governor
UPDATE agents 
SET 
    reports_to = '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef'
  AND id != '9e780111-85f6-4cc3-a110-377f23e8fdfc'  -- Exclude Apex (CEO)
  AND id != '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1'; -- Exclude Governor (Quality Director)

-- Step 2b: Verify the hierarchy fix
SELECT 
    a.name AS agent_name,
    m.name AS reports_to_manager,
    CASE 
        WHEN a.reports_to = '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1' THEN '✓'
        ELSE '✗'
    END AS hierarchy_correct
FROM agents a
LEFT JOIN agents m ON a.reports_to = m.id
WHERE a.company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef'
ORDER BY a.name;

-- ============================================================
-- SECTION 3: FIX NAME MISMATCHES
-- ============================================================

-- Analyzer -> Code Analyzer
UPDATE agents
SET 
    name = 'Code Analyzer',
    title = 'Code Analyzer',
    updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef'
  AND name = 'Analyzer';

-- Reviewer -> Code Reviewer
UPDATE agents
SET 
    name = 'Code Reviewer',
    title = 'Code Reviewer',
    updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef'
  AND name = 'Reviewer';

-- ============================================================
-- SECTION 4: REGISTER MISSING AGENTS
-- ============================================================
-- Company ID: f535f9bc-00be-4b6d-9f53-c53abfacacef
-- Governor ID: 3d8ea615-db5d-4e0c-996c-cd1f7b738cb1
-- Default Model: openrouter/anthropic/claude-sonnet-4.5

-- 4a. Architect
INSERT INTO agents (
    id, company_id, name, role, title, status, reports_to,
    capabilities, adapter_type, adapter_config, runtime_config,
    budget_monthly_cents, spent_monthly_cents, permissions, metadata,
    created_at, updated_at, is_active
)
SELECT 
    gen_random_uuid(),
    'f535f9bc-00be-4b6d-9f53-c53abfacacef',
    'architect-qualityforge-system-architect',
    'specialist',
    'Architect',
    'idle',
    '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    'System architecture; Quality frameworks; Process design.',
    'hermes_local',
    '{"persistSession": true, "toolsets": ["file_tools", "terminal_tools", "code_execution"]}'::jsonb,
    '{"max_iterations": 50}'::jsonb,
    50000000, 0,
    '{"company_access": "QualityForge AI"}'::jsonb,
    '{"human_name": "Architect", "specialization": "system-architecture", "created_via": "reconciliation-fix"}'::jsonb,
    NOW(), NOW(), true
WHERE NOT EXISTS (SELECT 1 FROM agents WHERE name = 'architect-qualityforge-system-architect');

-- 4b. Loadtester
INSERT INTO agents (
    id, company_id, name, role, title, status, reports_to,
    capabilities, adapter_type, adapter_config, runtime_config,
    budget_monthly_cents, spent_monthly_cents, permissions, metadata,
    created_at, updated_at, is_active
)
SELECT 
    gen_random_uuid(),
    'f535f9bc-00be-4b6d-9f53-c53abfacacef',
    'loadtester-qualityforge-scalability-testing',
    'specialist',
    'Loadtester',
    'idle',
    '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    'Load testing; Scalability analysis; Performance benchmarking.',
    'hermes_local',
    '{"persistSession": true, "toolsets": ["file_tools", "terminal_tools", "code_execution"]}'::jsonb,
    '{"max_iterations": 50}'::jsonb,
    50000000, 0,
    '{"company_access": "QualityForge AI"}'::jsonb,
    '{"human_name": "Loadtester", "specialization": "scalability-testing", "created_via": "reconciliation-fix"}'::jsonb,
    NOW(), NOW(), true
WHERE NOT EXISTS (SELECT 1 FROM agents WHERE name = 'loadtester-qualityforge-scalability-testing');

-- 4c. Probe
INSERT INTO agents (
    id, company_id, name, role, title, status, reports_to,
    capabilities, adapter_type, adapter_config, runtime_config,
    budget_monthly_cents, spent_monthly_cents, permissions, metadata,
    created_at, updated_at, is_active
)
SELECT 
    gen_random_uuid(),
    'f535f9bc-00be-4b6d-9f53-c53abfacacef',
    'probe-qualityforge-prompt-testing',
    'specialist',
    'Probe',
    'idle',
    '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    'Prompt testing; AI validation; Quality probing.',
    'hermes_local',
    '{"persistSession": true, "toolsets": ["file_tools", "terminal_tools", "code_execution"]}'::jsonb,
    '{"max_iterations": 50}'::jsonb,
    50000000, 0,
    '{"company_access": "QualityForge AI"}'::jsonb,
    '{"human_name": "Probe", "specialization": "prompt-testing", "created_via": "reconciliation-fix"}'::jsonb,
    NOW(), NOW(), true
WHERE NOT EXISTS (SELECT 1 FROM agents WHERE name = 'probe-qualityforge-prompt-testing');

-- 4d. Simulator
INSERT INTO agents (
    id, company_id, name, role, title, status, reports_to,
    capabilities, adapter_type, adapter_config, runtime_config,
    budget_monthly_cents, spent_monthly_cents, permissions, metadata,
    created_at, updated_at, is_active
)
SELECT 
    gen_random_uuid(),
    'f535f9bc-00be-4b6d-9f53-c53abfacacef',
    'simulator-qualityforge-workflow-simulation',
    'specialist',
    'Simulator',
    'idle',
    '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    'Workflow simulation; Process modeling; Scenario testing.',
    'hermes_local',
    '{"persistSession": true, "toolsets": ["file_tools", "terminal_tools", "code_execution"]}'::jsonb,
    '{"max_iterations": 50}'::jsonb,
    50000000, 0,
    '{"company_access": "QualityForge AI"}'::jsonb,
    '{"human_name": "Simulator", "specialization": "workflow-simulation", "created_via": "reconciliation-fix"}'::jsonb,
    NOW(), NOW(), true
WHERE NOT EXISTS (SELECT 1 FROM agents WHERE name = 'simulator-qualityforge-workflow-simulation');

-- 4e. Assessment Criteria Manager
INSERT INTO agents (
    id, company_id, name, role, title, status, reports_to,
    capabilities, adapter_type, adapter_config, runtime_config,
    budget_monthly_cents, spent_monthly_cents, permissions, metadata,
    created_at, updated_at, is_active
)
SELECT 
    gen_random_uuid(),
    'f535f9bc-00be-4b6d-9f53-c53abfacacef',
    'assessment-criteria-manager-qualityforge',
    'specialist',
    'Assessment Criteria Manager',
    'idle',
    '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    'Assessment criteria management; Quality standards; Evaluation frameworks.',
    'hermes_local',
    '{"persistSession": true, "toolsets": ["file_tools", "terminal_tools", "code_execution"]}'::jsonb,
    '{"max_iterations": 50}'::jsonb,
    50000000, 0,
    '{"company_access": "QualityForge AI"}'::jsonb,
    '{"human_name": "Assessment Criteria Manager", "specialization": "criteria-management", "created_via": "reconciliation-fix"}'::jsonb,
    NOW(), NOW(), true
WHERE NOT EXISTS (SELECT 1 FROM agents WHERE name = 'assessment-criteria-manager-qualityforge');

-- 4f. Compliance Validator
INSERT INTO agents (
    id, company_id, name, role, title, status, reports_to,
    capabilities, adapter_type, adapter_config, runtime_config,
    budget_monthly_cents, spent_monthly_cents, permissions, metadata,
    created_at, updated_at, is_active
)
SELECT 
    gen_random_uuid(),
    'f535f9bc-00be-4b6d-9f53-c53abfacacef',
    'compliance-validator-qualityforge',
    'specialist',
    'Compliance Validator',
    'idle',
    '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    'Regulatory compliance; Industry standards; Policy conformance.',
    'hermes_local',
    '{"persistSession": true, "toolsets": ["file_tools", "terminal_tools", "code_execution"]}'::jsonb,
    '{"max_iterations": 50}'::jsonb,
    50000000, 0,
    '{"company_access": "QualityForge AI"}'::jsonb,
    '{"human_name": "Compliance Validator", "specialization": "compliance-validation", "created_via": "reconciliation-fix"}'::jsonb,
    NOW(), NOW(), true
WHERE NOT EXISTS (SELECT 1 FROM agents WHERE name = 'compliance-validator-qualityforge');

-- 4g. DBAT Testing
INSERT INTO agents (
    id, company_id, name, role, title, status, reports_to,
    capabilities, adapter_type, adapter_config, runtime_config,
    budget_monthly_cents, spent_monthly_cents, permissions, metadata,
    created_at, updated_at, is_active
)
SELECT 
    gen_random_uuid(),
    'f535f9bc-00be-4b6d-9f53-c53abfacacef',
    'dbat-testing-qualityforge',
    'specialist',
    'DBAT Testing',
    'idle',
    '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    'Database acceptance testing; DBAT validation; Data integrity testing.',
    'hermes_local',
    '{"persistSession": true, "toolsets": ["file_tools", "terminal_tools", "code_execution"]}'::jsonb,
    '{"max_iterations": 50}'::jsonb,
    50000000, 0,
    '{"company_access": "QualityForge AI"}'::jsonb,
    '{"human_name": "DBAT Testing", "specialization": "dbat-testing", "created_via": "reconciliation-fix"}'::jsonb,
    NOW(), NOW(), true
WHERE NOT EXISTS (SELECT 1 FROM agents WHERE name = 'dbat-testing-qualityforge');

-- 4h. Decision Support Specialist
INSERT INTO agents (
    id, company_id, name, role, title, status, reports_to,
    capabilities, adapter_type, adapter_config, runtime_config,
    budget_monthly_cents, spent_monthly_cents, permissions, metadata,
    created_at, updated_at, is_active
)
SELECT 
    gen_random_uuid(),
    'f535f9bc-00be-4b6d-9f53-c53abfacacef',
    'decision-support-specialist-qualityforge',
    'specialist',
    'Decision Support Specialist',
    'idle',
    '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    'Decision support; Quality recommendations; Analysis and insights.',
    'hermes_local',
    '{"persistSession": true, "toolsets": ["file_tools", "terminal_tools", "code_execution"]}'::jsonb,
    '{"max_iterations": 50}'::jsonb,
    50000000, 0,
    '{"company_access": "QualityForge AI"}'::jsonb,
    '{"human_name": "Decision Support Specialist", "specialization": "decision-support", "created_via": "reconciliation-fix"}'::jsonb,
    NOW(), NOW(), true
WHERE NOT EXISTS (SELECT 1 FROM agents WHERE name = 'decision-support-specialist-qualityforge');

-- 4i. Documentation Processor
INSERT INTO agents (
    id, company_id, name, role, title, status, reports_to,
    capabilities, adapter_type, adapter_config, runtime_config,
    budget_monthly_cents, spent_monthly_cents, permissions, metadata,
    created_at, updated_at, is_active
)
SELECT 
    gen_random_uuid(),
    'f535f9bc-00be-4b6d-9f53-c53abfacacef',
    'documentation-processor-qualityforge',
    'specialist',
    'Documentation Processor',
    'idle',
    '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1',
    'Documentation processing; Quality documentation; Standards documentation.',
    'hermes_local',
    '{"persistSession": true, "toolsets": ["file_tools", "terminal_tools", "code_execution"]}'::jsonb,
    '{"max_iterations": 50}'::jsonb,
    50000000, 0,
    '{"company_access": "QualityForge AI"}'::jsonb,
    '{"human_name": "Documentation Processor", "specialization": "documentation-processing", "created_via": "reconciliation-fix"}'::jsonb,
    NOW(), NOW(), true
WHERE NOT EXISTS (SELECT 1 FROM agents WHERE name = 'documentation-processor-qualityforge');

-- ============================================================
-- SECTION 5: VERIFICATION - Final State
-- ============================================================

-- Count agents after fix
SELECT 
    'QualityForge AI Agents' AS metric,
    COUNT(*) AS count
FROM agents
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef';

-- Verify hierarchy is correct
SELECT 
    a.name AS agent_name,
    m.name AS reports_to_manager,
    CASE 
        WHEN a.reports_to = '3d8ea615-db5d-4e0c-996c-cd1f7b738cb1' THEN '✓'
        WHEN a.reports_to IS NULL THEN '✓ (CEO)'
        ELSE '✗'
    END AS hierarchy_status
FROM agents a
LEFT JOIN agents m ON a.reports_to = m.id
WHERE a.company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef'
ORDER BY a.name;

-- Check for any remaining issues
SELECT 
    a.name AS agent_name,
    CASE
        WHEN a.reports_to = '9e780111-85f6-4cc3-a110-377f23e8fdfc' THEN '✗ Still reports to Apex'
        WHEN a.reports_to IS NULL AND a.name NOT IN ('Apex') THEN '? NULL (check if correct)'
        ELSE '✓'
    END AS issue_check
FROM agents a
WHERE a.company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef'
  AND a.name NOT IN ('Apex', 'Governor', 'OpenClaw Gateway Agent', 'Tester', 'Authenticator')
ORDER BY a.name;

COMMIT;

-- ============================================================
-- SECTION 6: ORPHANED AGENTS (Manual Review Required)
-- ============================================================
-- The following agents exist in DB but not in filesystem:
-- 1. OpenClaw Gateway Agent - Legacy gateway (consider archiving)
-- 2. Tester - Browser UI testing (consider archiving or creating FS entry)
-- 3. Authenticator - HITL workflow testing (consider archiving or creating FS entry)
--
-- To archive an agent:
-- UPDATE agents SET is_active = false, status = 'archived' WHERE name = 'AgentName';
-- ============================================================
