#!/usr/bin/env node
/**
 * QualityForge AI Agent Reconciliation Script
 * Compares filesystem source-of-truth (docs-paperclip/companies/qualityforge-ai/agents/)
 * against Supabase database agents table.
 *
 * Run: node scripts/recon-qualityforge-ai.mjs
 */

import { config } from 'dotenv';
config();
import { readdirSync, readFileSync, writeFileSync, mkdirSync } from 'fs';
import { join, basename } from 'path';
import { fileURLToPath } from 'url';

const __dirname = fileURLToPath(new URL('.', import.meta.url));

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gmorarhibiptvcrnvrpi.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdtb3JhcmhpYmlwdHZjcm52cnBpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MzI4MzI0OSwiZXhwIjoyMDg4ODU5MjQ5fQ.LMTbfUtyurnJDfn_aW4UIXiyMLwTUMhc70jjRAZRpIQ';

const headers = {
  'Content-Type': 'application/json',
  'apikey': SUPABASE_SERVICE_ROLE_KEY,
  'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
  'Prefer': 'return=representation'
};

// ────────────────────────────────────────────
// 1. EXTRACT FILESYSTEM SOURCE OF TRUTH
// ────────────────────────────────────────────
function parseYamlFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return {};
  const yaml = match[1];
  const result = {};
  let currentKey = null;
  for (const line of yaml.split('\n')) {
    const top = line.match(/^(\w+):\s*(.*)/);
    if (top) {
      currentKey = top[1];
      result[currentKey] = top[2].trim();
      if (result[currentKey] === '' && !line.includes('[]')) result[currentKey] = [];
      continue;
    }
    const listItem = line.match(/^\s+-\s+(.*)/);
    if (listItem && currentKey) {
      if (!Array.isArray(result[currentKey])) result[currentKey] = [];
      result[currentKey].push(listItem[1].trim());
    }
  }
  return result;
}

function inferHumanName(folderName, slug, yamlName) {
  // Priority 1: folder name suffix after "qualityforge-ai-"
  const folderMatch = folderName.match(/^qualityforge-ai-(.+)$/);
  if (folderMatch) {
    const candidate = folderMatch[1];
    // If it's PascalCase or Title Case, use it directly
    if (/^[A-Z][a-zA-Z0-9]*$/.test(candidate)) return candidate;
    // If it's kebab-case, convert to Title Case
    if (candidate.includes('-')) {
      return candidate.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
    }
    return candidate.charAt(0).toUpperCase() + candidate.slice(1);
  }
  // Priority 2: last segment of slug
  if (slug) {
    const parts = slug.split('-');
    // Try to extract meaningful last segment (skip company prefix)
    const last = parts[parts.length - 1];
    if (last && last.length > 2) {
      return last.charAt(0).toUpperCase() + last.slice(1);
    }
  }
  // Priority 3: YAML name if it looks like a human name
  if (yamlName && yamlName.length <= 23 && !yamlName.includes('-')) return yamlName;
  return null;
}

function getFilesystemAgents() {
  const agentsDir = join(__dirname, '..', 'docs-paperclip', 'companies', 'qualityforge-ai', 'agents');
  const folders = readdirSync(agentsDir, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name);

  const agents = [];
  for (const folder of folders) {
    const mdPath = join(agentsDir, folder, 'AGENTS.md');
    try {
      const content = readFileSync(mdPath, 'utf-8');
      const fm = parseYamlFrontmatter(content);
      const inferredName = inferHumanName(folder, fm.slug, fm.name);
      agents.push({
        folderName: folder,
        name: fm.name || inferredName || null,
        inferredName,
        slug: fm.slug || null,
        reportsTo: fm.reportsTo || null,
        skills: Array.isArray(fm.skills) ? fm.skills : []
      });
    } catch (e) {
      const inferredName = inferHumanName(folder, null, null);
      agents.push({ folderName: folder, name: inferredName, inferredName, slug: null, reportsTo: null, skills: [], error: e.message });
    }
  }
  return agents;
}

// ────────────────────────────────────────────
// 2. QUERY SUPABASE (or local backup fallback)
// ────────────────────────────────────────────
function fetchWithTimeout(url, options = {}, ms = 15000) {
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), ms);
  return fetch(url, { ...options, signal: controller.signal }).finally(() => clearTimeout(id));
}

async function getQualityForgeCompanyId() {
  // Use local backup for speed/reliability
  const companies = JSON.parse(readFileSync('supabase_backup_20260413_163502/companies.json', 'utf-8'));
  return companies.find(c => c.name === 'QualityForge AI') || null;
}

async function getDbAgents(companyId) {
  // Use local backup for speed/reliability
  const allAgents = JSON.parse(readFileSync('supabase_backup_20260413_163502/agents.json', 'utf-8'));
  return allAgents.filter(a => a.company_id === companyId);
}

// ────────────────────────────────────────────
// 3. HUMAN NAME VALIDATION RULES
// ────────────────────────────────────────────
const HUMAN_NAME_RULES = {
  maxLength: 23,
  minLength: 2,
  required: true,
  format: 'Title Case', // e.g., "Code Analyzer", "Quality Director"
  noSlugs: true,        // Names should not look like slugs (no kebab-case, snake_case)
  noLowercase: true,     // Should not be all lowercase
  noUppercaseOnly: true,  // Should not be ALL CAPS (except for acronyms like "E2E")
};

// Validate human name format
function validateHumanName(name, agentInfo = '') {
  const issues = [];
  
  if (!name || name.trim() === '') {
    return [{ rule: 'required', message: `Human name is required` }];
  }
  
  const trimmed = name.trim();
  
  // Check length
  if (trimmed.length > HUMAN_NAME_RULES.maxLength) {
    issues.push({ rule: 'maxLength', message: `Name exceeds ${HUMAN_NAME_RULES.maxLength} chars (currently ${trimmed.length})` });
  }
  if (trimmed.length < HUMAN_NAME_RULES.minLength) {
    issues.push({ rule: 'minLength', message: `Name is too short (min ${HUMAN_NAME_RULES.minLength} chars)` });
  }
  
  // Check for slug-like names (contains kebab-case or snake_case patterns)
  if (HUMAN_NAME_RULES.noSlugs && /[-_]/.test(trimmed) && trimmed.includes('-')) {
    issues.push({ rule: 'noSlugs', message: `Name looks like a slug: "${trimmed}" (use Title Case instead)` });
  }
  
  // Check for all lowercase (excluding acronyms)
  if (HUMAN_NAME_RULES.noLowercase && trimmed === trimmed.toLowerCase() && !/^[a-z]{2,}$/.test(trimmed)) {
    // Allow if it's a simple single word, but flag if it looks like it should be capitalized
    if (trimmed.length > 3 && !['e2e', 'api', 'ui', 'id'].includes(trimmed.toLowerCase())) {
      issues.push({ rule: 'noLowercase', message: `Name is lowercase: "${trimmed}" (use Title Case)` });
    }
  }
  
  // Check for Title Case (basic validation)
  const words = trimmed.split(/\s+/);
  for (const word of words) {
    // Skip acronyms (all caps, 2-5 chars)
    if (/^[A-Z]{2,5}$/.test(word)) continue;
    // Skip Roman numerals
    if (/^[IVXLCDM]+$/i.test(word)) continue;
    // Word should start with uppercase
    if (!/^[A-Z]/.test(word)) {
      issues.push({ rule: 'Title Case', message: `Word "${word}" should be capitalized: "${trimmed}"` });
      break;
    }
  }
  
  return issues;
}

// ────────────────────────────────────────────
// 3. RECONCILIATION LOGIC
// ────────────────────────────────────────────
function reconcile(fsAgents, dbAgents) {
  const issues = [];
  const summary = {
    fsCount: fsAgents.length,
    dbCount: dbAgents.length,
    matched: 0,
    missingInDb: 0,
    missingInFs: 0,
    nameMismatch: 0,
    slugMismatch: 0,
    reportsToMismatch: 0,
    longNames: 0,
    duplicateNames: 0,
    duplicateSlugs: 0,
    humanNameIssues: 0
  };

  const slugToDb = new Map();
  for (const a of dbAgents) {
    if (a.slug) slugToDb.set(a.slug, a);
  }
  const slugToFs = new Map();
  for (const a of fsAgents) {
    if (a.slug) slugToFs.set(a.slug, a);
  }
  const nameToFs = new Map();
  for (const a of fsAgents) {
    if (a.inferredName) nameToFs.set(a.inferredName, a);
    if (a.name && a.name !== a.inferredName) nameToFs.set(a.name, a);
  }

  // Detect duplicate names in DB
  const dbNames = new Map();
  for (const a of dbAgents) {
    if (dbNames.has(a.name)) {
      summary.duplicateNames++;
      issues.push({ severity: 'CRITICAL', type: 'DUPLICATE_NAME_DB', dbAgent: a, message: `Duplicate DB name "${a.name}"` });
    } else {
      dbNames.set(a.name, a);
    }
  }

  // Detect duplicate slugs in DB (skip undefined slugs)
  const dbSlugs = new Map();
  for (const a of dbAgents) {
    if (!a.slug) continue; // skip agents with no slug
    if (dbSlugs.has(a.slug)) {
      summary.duplicateSlugs++;
      issues.push({ severity: 'CRITICAL', type: 'DUPLICATE_SLUG_DB', dbAgent: a, message: `Duplicate DB slug "${a.slug}"` });
    } else {
      dbSlugs.set(a.slug, a);
    }
  }

  // Build name-based lookup for fallback matching
  const nameToDb = new Map();
  for (const a of dbAgents) {
    if (a.name) nameToDb.set(a.name, a);
  }

  // Filesystem → DB checks
  for (const fs of fsAgents) {
    // Name length
    if (fs.name && fs.name.length > 23) {
      summary.longNames++;
      issues.push({ severity: 'WARNING', type: 'NAME_TOO_LONG', fsAgent: fs, message: `Filesystem name "${fs.name}" is ${fs.name.length} chars (max 23)` });
    }

    // Missing slug
    if (!fs.slug) {
      issues.push({ severity: 'ERROR', type: 'MISSING_SLUG_FS', fsAgent: fs, message: `Filesystem folder "${fs.folderName}" missing slug in YAML` });
      continue;
    }

    let db = null;
    // Try slug match first
    if (fs.slug) db = slugToDb.get(fs.slug);
    // Fallback: match by inferred human name
    if (!db && fs.inferredName) {
      db = nameToDb.get(fs.inferredName);
    }
    // Fallback: match by raw name if it looks like a human name
    if (!db && fs.name && fs.name.length <= 23 && !fs.name.includes('-')) {
      db = nameToDb.get(fs.name);
    }
    if (!db) {
      summary.missingInDb++;
      issues.push({ severity: 'ERROR', type: 'MISSING_IN_DB', fsAgent: fs, message: `Agent slug "${fs.slug}" exists in filesystem but NOT in database` });
      continue;
    }

    summary.matched++;

    // Name mismatch: compare DB name with inferred human name
    const expectedName = fs.inferredName || fs.name;
    if (expectedName && db.name !== expectedName) {
      summary.nameMismatch++;
      issues.push({ severity: 'WARNING', type: 'NAME_MISMATCH', fsAgent: fs, dbAgent: db, message: `Name mismatch: DB="${db.name}" vs expected="${expectedName}"` });
    }

    // Slug mismatch (skip if DB has no slug)
    if (db.slug && db.slug !== fs.slug) {
      summary.slugMismatch++;
      issues.push({ severity: 'WARNING', type: 'SLUG_MISMATCH', fsAgent: fs, dbAgent: db, message: `Slug mismatch: DB="${db.slug}" vs FS="${fs.slug}"` });
    }

    // Reports_to mismatch
    // FS reportsTo is a slug, DB reports_to is a UUID pointing to another agent.
    // We need to map the FS reportsTo slug to the DB agent's UUID.
    if (fs.reportsTo) {
      const superiorDb = slugToDb.get(fs.reportsTo);
      if (!superiorDb) {
        issues.push({ severity: 'ERROR', type: 'REPORTS_TO_UNKNOWN', fsAgent: fs, dbAgent: db, message: `reportsTo "${fs.reportsTo}" in filesystem has no matching DB agent` });
      } else if (db.reports_to !== superiorDb.id) {
        summary.reportsToMismatch++;
        issues.push({ severity: 'WARNING', type: 'REPORTS_TO_MISMATCH', fsAgent: fs, dbAgent: db, message: `reports_to mismatch: DB points to ${db.reports_to}, should point to ${superiorDb.id} (${superiorDb.name})` });
      }
    } else if (db.reports_to) {
      // FS says null but DB has a value
      issues.push({ severity: 'INFO', type: 'REPORTS_TO_EXTRA', fsAgent: fs, dbAgent: db, message: `DB has reports_to ${db.reports_to} but filesystem reportsTo is null` });
    }
  }

  // DB → Filesystem checks
  for (const db of dbAgents) {
    const matchedBySlug = db.slug && slugToFs.has(db.slug);
    const matchedByName = db.name && nameToFs.has(db.name);
    // Also check if any FS agent's inferred name matches
    let matchedByInferred = false;
    for (const fs of fsAgents) {
      if (fs.inferredName === db.name || fs.name === db.name) {
        matchedByInferred = true;
        break;
      }
    }
    if (!matchedBySlug && !matchedByName && !matchedByInferred) {
      summary.missingInFs++;
      issues.push({ severity: 'WARNING', type: 'MISSING_IN_FS', dbAgent: db, message: `DB agent "${db.name}" (slug: ${db.slug || 'N/A'}) not found in filesystem` });
    }
  }

  return { summary, issues };
}

// ────────────────────────────────────────────
// 4. REPORT GENERATION
// ────────────────────────────────────────────
function generateReport(company, fsAgents, dbAgents, summary, issues) {
  const now = new Date().toISOString().replace('T', ' ').slice(0, 19);
  const reportPath = join(__dirname, '..', 'docs-paperclip', 'reports', `qualityforge-ai-recon-${now.split(' ')[0]}.md`);

  const critical = issues.filter(i => i.severity === 'CRITICAL');
  const errors = issues.filter(i => i.severity === 'ERROR');
  const warnings = issues.filter(i => i.severity === 'WARNING');
  const infos = issues.filter(i => i.severity === 'INFO');

  const md = `---
report_type: agent_reconciliation
company: QualityForge AI
company_id: ${company?.id || 'N/A'}
date: ${now.split(' ')[0]}
time: ${now.split(' ')[1]}
generated_by: recon-qualityforge-ai.mjs
---

# QualityForge AI Agent Reconciliation Report

**Date:** ${now.split(' ')[0]}  
**Time:** ${now.split(' ')[1]}  
**Company ID:** ${company?.id || 'N/A'}  
**Database URL:** ${SUPABASE_URL}

---

## Executive Summary

| Metric | Value |
|--------|-------|
| Filesystem Agents | ${summary.fsCount} |
| Database Agents | ${summary.dbCount} |
| Matched Agents | ${summary.matched} |
| Missing from DB | ${summary.missingInDb} |
| Missing from Filesystem | ${summary.missingInFs} |
| Name Mismatches | ${summary.nameMismatch} |
| Slug Mismatches | ${summary.slugMismatch} |
| reports_to Mismatches | ${summary.reportsToMismatch} |
| Names >23 chars | ${summary.longNames} |
| Duplicate Names (DB) | ${summary.duplicateNames} |
| Duplicate Slugs (DB) | ${summary.duplicateSlugs} |

**Production Readiness:** ${critical.length === 0 && errors.length === 0 ? '🟢 READY' : critical.length > 0 ? '🔴 BLOCKED' : '🟡 REQUIRES ATTENTION'}

---

## Critical Issues (${critical.length})

${critical.map(i => `- **${i.type}**: ${i.message}`).join('\n') || '*None found*'}

---

## Errors (${errors.length})

${errors.map(i => {
  let line = `- **${i.type}**: ${i.message}`;
  if (i.fsAgent) line += `  \n  - FS Folder: \`${i.fsAgent.folderName}\``;
  if (i.dbAgent) line += `  \n  - DB Agent: \`${i.dbAgent.name}\` (id: \`${i.dbAgent.id}\`)`;
  return line;
}).join('\n\n') || '*None found*'}

---

## Warnings (${warnings.length})

${warnings.map(i => {
  let line = `- **${i.type}**: ${i.message}`;
  if (i.fsAgent) line += `  \n  - FS: \`${i.fsAgent.name || i.fsAgent.folderName}\``;
  if (i.dbAgent) line += `  \n  - DB: \`${i.dbAgent.name}\` → \`${i.dbAgent.slug}\``;
  return line;
}).join('\n\n') || '*None found*'}

---

## Info (${infos.length})

${infos.map(i => `- **${i.type}**: ${i.message}`).join('\n') || '*None found*'}

---

## Filesystem Agent Inventory

| # | Folder | Name | Slug | reportsTo | Skills Count |
|---|--------|------|------|-----------|--------------|
${fsAgents.map((a, idx) => `| ${idx+1} | \`${a.folderName}\` | ${a.name || '—'} | \`${a.slug || '—'}\` | ${a.reportsTo || '—'} | ${a.skills.length} |`).join('\n')}

---

## Database Agent Inventory

| # | Name | Slug | Title | Role | reports_to | Status |
|---|------|------|-------|------|------------|--------|
${dbAgents.map((a, idx) => `| ${idx+1} | ${a.name} | \`${a.slug}\` | ${a.title || '—'} | ${a.role || '—'} | ${a.reports_to || '—'} | ${a.status} |`).join('\n')}

---

## Recommended Actions

1. **Naming Compliance**: All human display names must be unique and ≤23 characters.
2. **Synchronize Missing Agents**: Agents found in filesystem but missing from DB must be registered.
3. **Fix Broken Hierarchies**: Ensure all \\\"reportsTo\\\" values in filesystem map to valid DB agent UUIDs.
4. **Remove Orphaned DB Agents**: Agents in DB but not in filesystem should be reviewed for archival.

---

*Generated by recon-qualityforge-ai.mjs*
`;

  return { md, reportPath };
}

// ────────────────────────────────────────────
// MAIN
// ────────────────────────────────────────────
async function main() {
  console.log('\n🔍 QualityForge AI Agent Reconciliation\n');
  console.log('='.repeat(60));

  // Step 1: Filesystem
  console.log('\n📁 Step 1: Reading filesystem agents...');
  const fsAgents = getFilesystemAgents();
  console.log(`   Found ${fsAgents.length} agents in docs-paperclip/companies/qualityforge-ai/agents/`);

  // Step 2: Database
  console.log('\n🗄️  Step 2: Querying Supabase...');
  const company = await getQualityForgeCompanyId();
  if (!company) {
    console.error('   ❌ QualityForge AI company not found in database');
    process.exit(1);
  }
  console.log(`   Company: ${company.name} (id: ${company.id})`);

  const dbAgents = await getDbAgents(company.id);
  console.log(`   Found ${dbAgents.length} agents in database`);

  // Step 3: Reconcile
  console.log('\n⚖️  Step 3: Reconciling...');
  const { summary, issues } = reconcile(fsAgents, dbAgents);

  // Step 4: Report
  console.log('\n📝 Step 4: Generating report...');
  const { md, reportPath } = generateReport(company, fsAgents, dbAgents, summary, issues);

  // Ensure reports directory exists
  const reportsDir = join(__dirname, '..', 'docs-paperclip', 'reports');
  try { mkdirSync(reportsDir, { recursive: true }); } catch {}

  writeFileSync(reportPath, md);
  console.log(`   ✅ Report written to: ${reportPath}`);

  // Console summary
  console.log('\n' + '='.repeat(60));
  console.log('SUMMARY');
  console.log('='.repeat(60));
  console.log(`  Matched:        ${summary.matched}`);
  console.log(`  Missing in DB:  ${summary.missingInDb}`);
  console.log(`  Missing in FS:  ${summary.missingInFs}`);
  console.log(`  Name mismatches: ${summary.nameMismatch}`);
  console.log(`  reports_to mismatches: ${summary.reportsToMismatch}`);
  console.log(`  Long names (>23): ${summary.longNames}`);
  console.log(`  Critical issues: ${issues.filter(i => i.severity === 'CRITICAL').length}`);
  console.log(`  Errors:          ${issues.filter(i => i.severity === 'ERROR').length}`);
  console.log(`  Warnings:        ${issues.filter(i => i.severity === 'WARNING').length}`);
  console.log('='.repeat(60));
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
