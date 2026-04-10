#!/usr/bin/env node

/**
 * Generate SQL for all DomainForge AI agents from documentation
 * Reads agent documentation files and generates INSERT statements
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Company configurations
const COMPANIES = {
  domainforge: {
    id: '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
    path: path.join(__dirname, '../../docs-paperclip/companies/domainforge-ai/agents')
  },
  infraforge: {
    id: '09f438a3-4041-46f2-b3cc-96fc9446e666',
    path: path.join(__dirname, '../../docs-paperclip/companies/infraforge-ai/agents')
  }
};

// Global map to store consistent UUIDs for each slug
const slugToUuidMap = new Map();
let uuidCounter = 0;

// Generate UUID-like ID from agent slug (deterministic but unique)
function generateAgentId(slug) {
  // Use a fallback key for empty slugs
  const key = slug || `empty-slug-${uuidCounter}`;

  if (slugToUuidMap.has(key)) {
    return slugToUuidMap.get(key);
  }

  // Generate a deterministic UUID based on slug and counter
  const base = 'a1b2c3d4-e5f6-7890-abcd-';
  const counterHex = (uuidCounter++).toString(16).padStart(12, '0');
  const uuid = base + counterHex;

  slugToUuidMap.set(key, uuid);
  return uuid;
}

// Parse agent documentation file
function parseAgentFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');

  let name = '';
  let slug = '';
  let reportsTo = null;
  let skills = [];

  // Parse frontmatter
  let inFrontmatter = false;
  for (const line of lines) {
    if (line.trim() === '---') {
      inFrontmatter = !inFrontmatter;
      continue;
    }

    if (inFrontmatter) {
      if (line.startsWith('name:')) {
        name = line.split(':')[1].trim();
      } else if (line.startsWith('slug:')) {
        slug = line.split(':')[1].trim();
      } else if (line.startsWith('reportsTo:')) {
        const reportsToValue = line.split(':')[1].trim();
        reportsTo = reportsToValue === 'null' ? null : reportsToValue;
      } else if (line.startsWith('skills:')) {
        // Skills are on subsequent lines
      } else if (line.startsWith('  - ')) {
        skills.push(line.trim().substring(4));
      }
    } else if (line.startsWith('# ')) {
      // Fallback for name if not in frontmatter
      if (!name) {
        name = line.substring(2).trim();
      }
      break;
    }
  }

  return { name, slug, reportsTo, skills };
}

// Generate SQL for a single agent
function generateAgentSQL(agentData, companyId, teamName) {
  const { name, slug, reportsTo, skills } = agentData;
  const id = generateAgentId(slug);

  // Determine role based on slug patterns
  let role = 'specialist';
  let title = name;

  if (slug.includes('-ceo')) {
    role = 'ceo';
    title = 'Chief Executive Officer';
  } else if (slug.includes('-director') || slug.includes('director-')) {
    role = 'director';
    title = title.replace(/-director|-/g, ' ').trim() + ' Director';
  } else if (slug.includes('engineering')) {
    role = 'engineer';
    title = title.replace(/-engineering/g, '').trim() + ' Engineering Specialist';
  } else if (slug.includes('specialist')) {
    role = 'specialist';
    title = title.replace(/-specialist/g, '').trim() + ' Specialist';
  }

  // Generate reports_to ID if reportsTo is not null
  let reportsToId = null;
  if (reportsTo) {
    reportsToId = generateAgentId(reportsTo);
  }

  const capabilities = `${name} - Specialized in ${skills.join(', ')}`;
  const metadata = JSON.stringify({
    team: teamName,
    skills: skills,
    source: 'documentation-generated'
  });

  const adapterConfig = JSON.stringify({
    url: 'https://ecb3-102-132-198-101.ngrok-free.app/webhook',
    model: 'openrouter/qwen/qwen-3-6-plus',
    api_key: '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',
    provider: 'openrouter',
    maxIterations: 50,
    persistSession: true
  });

  const runtimeConfig = JSON.stringify({
    persistSession: true
  });

  const permissions = JSON.stringify({
    canCreateAgents: false
  });

  const modelConfig = JSON.stringify({
    model: 'anthropic/claude-3-opus',
    provider: 'openrouter',
    max_tokens: 4096,
    temperature: 0.7,
    fallback_models: ['anthropic/claude-3-sonnet']
  });

  const deviceConfig = JSON.stringify({
    priority: 1,
    device_id: 'device-1'
  });

  return `(
  '${id}',
  '${companyId}',
  '${name}',
  '${role}',
  '${title}',
  'active',
  ${reportsToId ? `'${reportsToId}'` : 'NULL'},
  '${capabilities.replace(/'/g, "''")}',
  'http',
  '${adapterConfig.replace(/'/g, "''")}',
  0,
  0,
  NULL,
  '${metadata.replace(/'/g, "''")}',
  '2026-03-30T15:53:36.729Z',
  '2026-04-09T17:00:00.000Z',
  '${runtimeConfig.replace(/'/g, "''")}',
  '${permissions.replace(/'/g, "''")}',
  NULL,
  NULL,
  NULL,
  '${modelConfig.replace(/'/g, "''")}',
  '${deviceConfig.replace(/'/g, "''")}',
  NULL,
  true
)`;
}

// Main function
function main() {
  try {
    const allAgentSQLs = [];

    for (const [companyKey, companyConfig] of Object.entries(COMPANIES)) {
      console.log(`\nProcessing ${companyKey}...`);

      // Read all agent directories for this company
      const agentDirs = fs.readdirSync(companyConfig.path)
        .filter(dir => fs.statSync(path.join(companyConfig.path, dir)).isDirectory())
        .sort();

      console.log(`Found ${agentDirs.length} agent directories for ${companyKey}`);

      for (const dir of agentDirs) {
        const agentFile = path.join(companyConfig.path, dir, 'AGENTS.md');

        if (fs.existsSync(agentFile)) {
          try {
            const agentData = parseAgentFile(agentFile);
            const teamName = companyKey === 'domainforge' ? 'DomainForge AI' : 'InfraForge AI';
            const sql = generateAgentSQL(agentData, companyConfig.id, teamName);
            allAgentSQLs.push(sql);
            console.log(`Processed: ${companyKey}/${dir}`);
          } catch (error) {
            console.error(`Error processing ${companyKey}/${dir}:`, error.message);
          }
        } else {
          console.warn(`No AGENTS.md file found in ${companyKey}/${dir}`);
        }
      }
    }

    // Generate complete SQL
    const sql = allAgentSQLs.join(',\n') + '\nON CONFLICT (id) DO UPDATE SET\n  name = EXCLUDED.name,\n  role = EXCLUDED.role,\n  title = EXCLUDED.title,\n  reports_to = EXCLUDED.reports_to,\n  capabilities = EXCLUDED.capabilities,\n  metadata = EXCLUDED.metadata,\n  updated_at = EXCLUDED.updated_at;';

    // Write to file
    const outputPath = path.join(__dirname, 'all_agents_insert.sql');
    fs.writeFileSync(outputPath, sql);

    console.log(`\nGenerated SQL for ${allAgentSQLs.length} agents total`);
    console.log(`Output written to: ${outputPath}`);

  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();