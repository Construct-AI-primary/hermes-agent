-- DevForge AI - Register Missing Agents
-- Company ID: f97b30e8-b022-4350-b4b0-30d43e2ebcf4
-- Generated: 2026-04-24
-- Run this AFTER folder renames are complete

BEGIN;

-- Ally (Partnership Management) - reports to Merchant (Growth Governor)
INSERT INTO agents (id, company_id, name, role, title, status, reports_to, capabilities, adapter_type, adapter_config, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'f97b30e8-b022-4350-b4b0-30d43e2ebcf4',
  'Ally',
  'growth',
  'Partnership Management',
  'active',
  '380d7281-02a0-4c6b-97f3-9ef6113afbc1', -- Merchant
  'Partnership management and alliance coordination',
  'http',
  '{"url": "https://placeholder.webhook", "model": "openrouter/qwen/qwen-3-6-plus", "maxIterations": 50, "persistSession": true}',
  NOW(),
  NOW()
);

-- Document Generation Specialist - reports to Forge (Engineering Governor)
INSERT INTO agents (id, company_id, name, role, title, status, reports_to, capabilities, adapter_type, adapter_config, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'f97b30e8-b022-4350-b4b0-30d43e2ebcf4',
  'Document Generation Specialist',
  'engineering',
  'Document Generation',
  'active',
  'd9ab69e1-ef1c-45b4-8c7d-87d58cd4e797', -- Forge
  'Automated document generation and templating',
  'http',
  '{"url": "https://placeholder.webhook", "model": "openrouter/qwen/qwen-3-6-plus", "maxIterations": 50, "persistSession": true}',
  NOW(),
  NOW()
);

-- Financial Validator - reports to Ledger (Financial Governor)
INSERT INTO agents (id, company_id, name, role, title, status, reports_to, capabilities, adapter_type, adapter_config, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'f97b30e8-b022-4350-b4b0-30d43e2ebcf4',
  'Financial Validator',
  'executive',
  'Financial Validation',
  'active',
  '67b23a8c-10ab-4605-91de-e8502df8b39e', -- Ledger
  'Financial validation and compliance checking',
  'http',
  '{"url": "https://placeholder.webhook", "model": "openrouter/qwen/qwen-3-6-plus", "maxIterations": 50, "persistSession": true}',
  NOW(),
  NOW()
);

-- Multi-Discipline Coordinator - reports to Council (Strategy Governor)
INSERT INTO agents (id, company_id, name, role, title, status, reports_to, capabilities, adapter_type, adapter_config, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'f97b30e8-b022-4350-b4b0-30d43e2ebcf4',
  'Multi-Discipline Coordinator',
  'strategy',
  'Cross-Discipline Coordination',
  'active',
  '3e0c1736-dd5a-4c6b-a491-4d67ee47ed83', -- Council
  'Coordinating across multiple engineering disciplines',
  'http',
  '{"url": "https://placeholder.webhook", "model": "openrouter/qwen/qwen-3-6-plus", "maxIterations": 50, "persistSession": true}',
  NOW(),
  NOW()
);

-- Transaction Processor - reports to Dataforge (Data Governor)
INSERT INTO agents (id, company_id, name, role, title, status, reports_to, capabilities, adapter_type, adapter_config, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'f97b30e8-b022-4350-b4b0-30d43e2ebcf4',
  'Transaction Processor',
  'data',
  'Transaction Processing',
  'active',
  '8e829517-c212-4641-86a5-724b101c61e1', -- Dataforge
  'Transaction processing and data pipeline management',
  'http',
  '{"url": "https://placeholder.webhook", "model": "openrouter/qwen/qwen-3-6-plus", "maxIterations": 50, "persistSession": true}',
  NOW(),
  NOW()
);

-- Workflow Complexity Analyzer - reports to Strategos (Executive Governor)
INSERT INTO agents (id, company_id, name, role, title, status, reports_to, capabilities, adapter_type, adapter_config, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'f97b30e8-b022-4350-b4b0-30d43e2ebcf4',
  'Workflow Complexity Analyzer',
  'executive',
  'Workflow Analysis',
  'active',
  '73b02951-e5fe-47c5-b545-0e6c2dabf5f3', -- Strategos
  'Analyzing and optimizing workflow complexity',
  'http',
  '{"url": "https://placeholder.webhook", "model": "openrouter/qwen/qwen-3-6-plus", "maxIterations": 50, "persistSession": true}',
  NOW(),
  NOW()
);

-- Workflow Learning Coordinator - reports to Strategos (Executive Governor)
INSERT INTO agents (id, company_id, name, role, title, status, reports_to, capabilities, adapter_type, adapter_config, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'f97b30e8-b022-4350-b4b0-30d43e2ebcf4',
  'Workflow Learning Coordinator',
  'executive',
  'Workflow Learning',
  'active',
  '73b02951-e5fe-47c5-b545-0e6c2dabf5f3', -- Strategos
  'Coordinating workflow learning and optimization',
  'http',
  '{"url": "https://placeholder.webhook", "model": "openrouter/qwen/qwen-3-6-plus", "maxIterations": 50, "persistSession": true}',
  NOW(),
  NOW()
);

COMMIT;
