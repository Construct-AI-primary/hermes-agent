-- ============================================================
-- FIX INVALID REPORTS_TO REFERENCES
-- Description: Fix agents with invalid reports_to values (text instead of UUID)
-- Date: 2026-04-24
-- ============================================================

BEGIN;

-- Step 1: Find agents with invalid reports_to values
-- These are agents where reports_to contains text instead of UUID
SELECT 
    a.id AS agent_id,
    a.name AS agent_name,
    a.reports_to AS invalid_reports_to,
    c.name AS company_name
FROM agents a
JOIN companies c ON a.company_id = c.id
WHERE a.reports_to IS NOT NULL
  AND a.reports_to != ''
  AND a.reports_to !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
ORDER BY c.name, a.name;

-- Step 2: Clear invalid reports_to values (set to NULL)
UPDATE agents
SET 
    reports_to = NULL,
    updated_at = NOW()
WHERE reports_to IS NOT NULL
  AND reports_to != ''
  AND reports_to !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- Step 3: Verify the fix
SELECT 
    COUNT(*) AS remaining_invalid_reports_to
FROM agents a
WHERE a.reports_to IS NOT NULL
  AND a.reports_to != ''
  AND a.reports_to !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

COMMIT;

-- ============================================================
-- VERIFICATION: Check all reports_to values are valid UUIDs
-- ============================================================
SELECT 
    a.name AS agent_name,
    a.reports_to,
    CASE 
        WHEN a.reports_to IS NULL THEN 'Valid (NULL)'
        WHEN a.reports_to ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN 'Valid UUID'
        ELSE 'Invalid'
    END AS status
FROM agents a
WHERE a.reports_to IS NOT NULL
ORDER BY a.name;