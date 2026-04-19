-- Fix ALL agents using hermes_local adapter to include the correct hermesCommand path for Render
UPDATE agents
SET adapter_config = adapter_config || jsonb_build_object(
    'hermesCommand', '/opt/render/project/src/hermes_agent/run.sh'
)
WHERE adapter_type = 'hermes_local'
AND (adapter_config->>'hermesCommand' IS NULL OR adapter_config->>'hermesCommand' = 'hermes');

-- Verify the fix
SELECT
    id,
    name,
    adapter_type,
    adapter_config->>'hermesCommand' as hermes_command
FROM agents
WHERE adapter_type = 'hermes_local';