-- Add Safety Research Agent Models
-- This script assigns models to the Safety Research Team agents
-- GLM-4-Plus is updated to Z.ai: GLM 5 Turbo for all safety research agents

-- Update GLM-4-Plus to Z.ai: GLM 5 Turbo for safety research agents
UPDATE agent_models
SET model_id = 'Z.ai: GLM 5 Turbo'
WHERE agent_id IN (
    SELECT a.id::text
    FROM agents a
    WHERE a.name IN (
        'learningforge-ai-research-coordinator',
        'learningforge-ai-safety-research-agent',
        'learningforge-ai-mobile-patterns-agent',
        'learningforge-ai-domain-knowledge-agent',
        'learningforge-ai-learning-integration-agent'
    )
)
AND model_id = 'GLM-4-Plus';

-- Insert new model assignments if they don't exist
INSERT INTO agent_models (agent_id, model_id, assignment_type, is_active, created_at, updated_at)
SELECT
    a.id::text as agent_id,
    'Z.ai: GLM 5 Turbo' as model_id,
    'primary' as assignment_type,
    true as is_active,
    NOW() as created_at,
    NOW() as updated_at
FROM agents a
WHERE a.name IN (
    'learningforge-ai-research-coordinator',
    'learningforge-ai-safety-research-agent',
    'learningforge-ai-mobile-patterns-agent',
    'learningforge-ai-domain-knowledge-agent',
    'learningforge-ai-learning-integration-agent'
)
AND NOT EXISTS (
    SELECT 1 FROM agent_models am
    WHERE am.agent_id = a.id::text
    AND am.model_id = 'Z.ai: GLM 5 Turbo'
);

-- Verification queries
SELECT
    a.name as agent_name,
    am.model_id,
    am.assignment_type,
    am.is_active
FROM agents a
JOIN agent_models am ON a.id::text = am.agent_id
WHERE a.name IN (
    'learningforge-ai-research-coordinator',
    'learningforge-ai-safety-research-agent',
    'learningforge-ai-mobile-patterns-agent',
    'learningforge-ai-domain-knowledge-agent',
    'learningforge-ai-learning-integration-agent'
)
ORDER BY a.name, am.assignment_type;