-- ============================================================
-- Find Duplicate Agent Names
-- Created: 2026-04-22
-- Purpose: Identify all duplicate agent names blocking unique constraint
-- ============================================================

-- 1. Find exact duplicate names (same name, same company)
SELECT 'SAME COMPANY DUPLICATES:' as check_type;
SELECT name, company_id, COUNT(*) as cnt, 
  array_agg(id) as agent_ids
FROM agents
GROUP BY name, company_id
HAVING COUNT(*) > 1
ORDER BY name;

-- 2. Find same name across different companies
SELECT 'CROSS-COMPANY DUPLICATES:' as check_type;
SELECT name, COUNT(DISTINCT company_id) as company_count,
  array_agg(DISTINCT company_id) as company_ids,
  array_agg(id) as agent_ids
FROM agents
GROUP BY name
HAVING COUNT(DISTINCT company_id) > 1
ORDER BY name;

-- 3. Show all agents with duplicate names (full details)
SELECT 'FULL DETAILS OF DUPLICATES:' as check_type;
SELECT a.id, a.name, a.role, a.title, a.status, 
  c.name as company_name, a.created_at, a.updated_at
FROM agents a
JOIN companies c ON a.company_id = c.id
WHERE a.name IN (
  SELECT name FROM agents 
  GROUP BY name 
  HAVING COUNT(*) > 1
)
ORDER BY a.name, c.name;

-- 4. Count total duplicates
SELECT 'SUMMARY:' as check_type;
SELECT 
  (SELECT COUNT(*) FROM (
    SELECT name FROM agents 
    GROUP BY name HAVING COUNT(*) > 1
  ) AS dup_names) as duplicate_names,
  (SELECT COUNT(*) FROM agents 
   WHERE name IN (
     SELECT name FROM agents 
     GROUP BY name HAVING COUNT(*) > 1
   )) as total_agents_with_duplicates;
