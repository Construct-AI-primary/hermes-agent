-- DevForge AI - Fix sql-query-devforge Agent Name
-- Company ID: f97b30e8-b022-4350-b4b0-30d43e2ebcf4
-- Generated: 2026-04-24

-- Find and update the agent with lowercase slug name
UPDATE agents 
SET name = 'SqlQueryDevforge', 
    title = 'SQL Query Specialist',
    updated_at = NOW()
WHERE company_id = 'f97b30e8-b022-4350-b4b0-30d43e2ebcf4'
  AND name = 'sql-query-devforge';
