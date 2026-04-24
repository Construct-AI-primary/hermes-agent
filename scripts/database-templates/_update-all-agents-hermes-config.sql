-- ============================================================
-- UPDATE ALL AGENTS - HERMES AGENT CONFIGURATION
-- Company: ALL COMPANIES (24 companies)
-- Date: 2026-04-24
-- Agent: atlas-agent-creator
-- Description: Update all agents to use Hermes Agent (local) adapter
--              with 300-second heartbeat and OpenRouter API key
-- ============================================================
-- 
-- INSTRUCTIONS:
-- 1. Review this script before executing
-- 2. Backup your database before running
-- 3. This script updates ALL active agents across ALL companies
-- 4. Check FK dependencies in FK-DEPENDENCY-LEVELS.md
-- ============================================================

BEGIN;

-- ============================================================
-- PREREQUISITE: Fix any invalid reports_to values (text instead of UUID)
-- This prevents UUID validation errors during the update
-- ============================================================
UPDATE agents
SET reports_to = NULL
WHERE reports_to IS NOT NULL
  AND reports_to::text != ''
  AND reports_to::text !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- Step 1: View current state of agents (before update)
SELECT 
    c.name AS company_name,
    COUNT(a.id) AS agent_count,
    COUNT(CASE WHEN a.adapter_type = 'hermes_local' THEN 1 END) AS hermes_count,
    COUNT(CASE WHEN a.adapter_type != 'hermes_local' THEN 1 END) AS other_count
FROM agents a
JOIN companies c ON a.company_id = c.id
WHERE a.deleted_at IS NULL
  AND a.is_active = true
GROUP BY c.name
ORDER BY c.name;

-- Step 2: Update agents table with Hermes configuration
-- This updates:
-- - adapter_type: 'hermes_local' (Hermes Agent local adapter)
-- - adapter_config: includes model config and environment variables
-- - runtime_config: includes heartbeat interval (300 seconds)
UPDATE agents
SET 
    adapter_type = 'hermes_local',
    adapter_config = jsonb_set(
        COALESCE(adapter_config, '{}'::jsonb),
        '{environment}',
        to_jsonb(COALESCE(
            (adapter_config->>'environment')::jsonb,
            '{}'::jsonb
        )) || 
        '{"OPENROUTER_API_KEY": "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"}'::jsonb
    ),
    runtime_config = jsonb_set(
        COALESCE(runtime_config, '{}'::jsonb),
        '{run_heartbeat}',
        '300'::jsonb
    ),
    updated_at = NOW()
WHERE deleted_at IS NULL
  AND is_active = true
  AND adapter_type != 'hermes_local';

-- Step 3: Alternative approach - full replacement of config fields
-- Use this if the jsonb_set approach doesn't work for your PostgreSQL version
/*
UPDATE agents
SET 
    adapter_type = 'hermes_local',
    adapter_config = 
        '{"adapter": "hermes_local", "environment": {"OPENROUTER_API_KEY": "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"}}'::jsonb ||
        COALESCE(adapter_config, '{}'::jsonb),
    runtime_config = 
        '{"run_heartbeat": 300}'::jsonb ||
        COALESCE(runtime_config, '{}'::jsonb),
    updated_at = NOW()
WHERE deleted_at IS NULL
  AND is_active = true;
*/

-- Step 4: Verify the update
SELECT 
    a.name AS agent_name,
    a.adapter_type,
    a.adapter_config->>'environment' AS environment_vars,
    a.runtime_config->>'run_heartbeat' AS heartbeat_interval,
    c.name AS company_name,
    a.updated_at
FROM agents a
JOIN companies c ON a.company_id = c.id
WHERE a.deleted_at IS NULL
  AND a.is_active = true
  AND a.adapter_type = 'hermes_local'
ORDER BY c.name, a.name;

-- Step 5: Summary statistics
SELECT 
    'Total Agents Updated' AS metric,
    COUNT(*) AS value
FROM agents
WHERE deleted_at IS NULL
  AND is_active = true
  AND adapter_type = 'hermes_local';

SELECT 
    'Companies Affected' AS metric,
    COUNT(DISTINCT company_id) AS value
FROM agents
WHERE deleted_at IS NULL
  AND is_active = true
  AND adapter_type = 'hermes_local';

COMMIT;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Check all agents have Hermes adapter type
SELECT 
    adapter_type,
    COUNT(*) AS count
FROM agents
WHERE deleted_at IS NULL
  AND is_active = true
GROUP BY adapter_type
ORDER BY count DESC;

-- Check heartbeat configuration for Hermes agents
SELECT 
    c.name AS company_name,
    a.name AS agent_name,
    a.runtime_config->>'run_heartbeat' AS heartbeat_seconds,
    a.adapter_config->'environment'->>'OPENROUTER_API_KEY' AS has_openrouter_key
FROM agents a
JOIN companies c ON a.company_id = c.id
WHERE a.deleted_at IS NULL
  AND a.is_active = true
  AND a.adapter_type = 'hermes_local'
ORDER BY c.name, a.name;

-- ============================================================
-- ROLLBACK SCRIPT (if needed)
-- ============================================================
/*
BEGIN;

-- Rollback: Reset adapter_type to 'process' for all Hermes agents
UPDATE agents
SET 
    adapter_type = 'process',
    adapter_config = adapter_config - 'environment',
    runtime_config = runtime_config - 'run_heartbeat',
    updated_at = NOW()
WHERE deleted_at IS NULL
  AND is_active = true
  AND adapter_type = 'hermes_local';

COMMIT;
*/

-- ============================================================
-- PLACEHOLDER REFERENCE
-- ============================================================
-- This script updates all agents across ALL 24 companies with:
-- 1. adapter_type: 'hermes_local' (Hermes Agent local adapter)
-- 2. run_heartbeat: 300 seconds (stored in runtime_config)
-- 3. OPENROUTER_API_KEY environment variable (stored in adapter_config)
--
-- The API key value: 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
-- ============================================================