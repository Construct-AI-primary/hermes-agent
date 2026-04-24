-- ============================================================
-- QUALITYFORGE AI - FIX HUMAN NAMES
-- Description: Fix human name issues identified in reconciliation
-- Date: 2026-04-24
-- ============================================================
-- HUMAN NAME RULES:
-- - Must be Title Case (e.g., "Code Analyzer")
-- - Max 23 characters
-- - No slugs/kebab-case in names
-- - No lowercase names (except acronyms like E2E)
-- ============================================================

BEGIN;

-- ============================================================
-- SECTION 1: VERIFY CURRENT HUMAN NAMES
-- ============================================================
SELECT 
    name,
    LENGTH(name) as char_count,
    name LIKE '%-%' as has_kebab,
    name = LOWER(name) as is_all_lower,
    CASE
        WHEN LENGTH(name) > 23 THEN '✗ Too long'
        WHEN name LIKE '%-%' THEN '✗ Contains kebab'
        WHEN name = LOWER(name) AND LENGTH(name) > 3 THEN '✗ All lowercase'
        WHEN name NOT LIKE '% %' AND LENGTH(name) > 3 AND name NOT IN ('E2E', 'API', 'UI', 'ID') THEN '? Single word (verify)'
        ELSE '✓'
    END as name_status
FROM agents
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef'
ORDER BY name;

-- ============================================================
-- SECTION 2: FIX HUMAN NAMES
-- ============================================================

-- Fix: Doc don → Documenter (garbled name)
UPDATE agents SET name = 'Documenter', title = 'Documentation Specialist', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'Doc don';

-- Fix: E2e → E2E (acronym should be uppercase)
UPDATE agents SET name = 'E2E', title = 'End-to-End Testing Specialist', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'E2e';

-- Fix: Openclaw gateway agent → OpenClaw Gateway (wrong case, too long)
UPDATE agents SET name = 'OpenClaw Gateway', title = 'OpenClaw Gateway Agent', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'Openclaw gateway agent';

-- Fix: loadtester-qualityforge-scalability-testing → Loadtester (slug as name)
UPDATE agents SET name = 'Loadtester', title = 'Load Testing Specialist', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'loadtester-qualityforge-scalability-testing';

-- Fix: architect-qualityforge-system-architect → Architect (slug as name)
UPDATE agents SET name = 'Architect', title = 'System Architect', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'architect-qualityforge-system-architect';

-- Fix: assessment-criteria-manager-qualityforge → Assessment Criteria Manager (slug as name)
UPDATE agents SET name = 'Assessment Criteria Manager', title = 'Assessment Criteria Manager', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'assessment-criteria-manager-qualityforge';

-- Fix: compliance-validator-qualityforge → Compliance Validator (slug as name)
UPDATE agents SET name = 'Compliance Validator', title = 'Compliance Validator', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'compliance-validator-qualityforge';

-- Fix: dbat-testing-qualityforge → DBAT Testing (slug as name)
UPDATE agents SET name = 'DBAT Testing', title = 'Database Acceptance Testing Specialist', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'dbat-testing-qualityforge';

-- Fix: decision-support-specialist-qualityforge → Decision Support Specialist (slug as name)
UPDATE agents SET name = 'Decision Support Specialist', title = 'Decision Support Specialist', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'decision-support-specialist-qualityforge';

-- Fix: documentation-processor-qualityforge → Documentation Processor (slug as name)
UPDATE agents SET name = 'Documentation Processor', title = 'Documentation Processor', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'documentation-processor-qualityforge';

-- Fix: probe-qualityforge-prompt-testing → Probe (slug as name)
UPDATE agents SET name = 'Probe', title = 'Prompt Testing Specialist', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'probe-qualityforge-prompt-testing';

-- Fix: simulator-qualityforge-workflow-simulation → Simulator (slug as name)
UPDATE agents SET name = 'Simulator', title = 'Workflow Simulation Specialist', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'simulator-qualityforge-workflow-simulation';

-- ============================================================
-- SECTION 2B: FIX NAMES TOO LONG (>23 chars)
-- ============================================================

-- Fix: Assessment Criteria Manager (27) → Assessment Manager (18)
UPDATE agents SET name = 'Assessment Manager', title = 'Assessment Criteria Manager', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'Assessment Criteria Manager';

-- Fix: Decision Support Specialist (27) → Decision Advisor (16)
UPDATE agents SET name = 'Decision Advisor', title = 'Decision Support Specialist', updated_at = NOW()
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef' AND name = 'Decision Support Specialist';

-- ============================================================
-- SECTION 3: VERIFY FIXED HUMAN NAMES
-- ============================================================
SELECT 
    name,
    LENGTH(name) as char_count,
    CASE
        WHEN LENGTH(name) > 23 THEN '✗ Too long'
        WHEN name LIKE '%-%' THEN '✗ Contains kebab'
        WHEN name = LOWER(name) AND LENGTH(name) > 3 THEN '✗ All lowercase'
        ELSE '✓'
    END as name_status
FROM agents
WHERE company_id = 'f535f9bc-00be-4b6d-9f53-c53abfacacef'
  AND name NOT IN ('Apex', 'Governor')
ORDER BY name;

COMMIT;

-- ============================================================
-- NAMING STANDARDS REFERENCE
-- ============================================================
-- Human names MUST follow these rules:
-- 
-- 1. TITLE CASE
--    Correct: "Code Analyzer", "Quality Director"
--    Wrong: "code analyzer", "CODE ANALYZER"
--
-- 2. MAX 23 CHARACTERS
--    "Decision Support" (17) ✓
--    "Decision Support Specialist" (29) ✗
--
-- 3. NO KEBAB-CASE/SLUGS IN NAMES
--    Correct: "Code Analyzer"
--    Wrong: "code-analyzer", "loadtester-qualityforge-scalability-testing"
--
-- 4. ACRONYMS ARE UPPERCASE
--    Correct: "E2E", "API", "UI", "ID"
--    Wrong: "e2e", "E2e"
--
-- 5. NO GARBLED NAMES
--    Correct: "Documenter"
--    Wrong: "Doc don"
-- ============================================================
