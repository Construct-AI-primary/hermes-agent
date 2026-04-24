#!/usr/bin/env node
/**
 * Fix QualityForge AI AGENTS.md naming violations
 * Replaces slug-based names with proper human display names (≤23 chars)
 */

import { readdirSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = fileURLToPath(new URL('.', import.meta.url));

const agentsDir = join(__dirname, '..', 'docs-paperclip', 'companies', 'qualityforge-ai', 'agents');

// Mapping: folder name → { displayName, slug }
const nameMap = {
  'qualityforge-ai-Apex': { name: 'Apex', slug: 'apex-qualityforge-ceo' },
  'qualityforge-ai-Architect': { name: 'Architect', slug: 'architect-qualityforge-system-architect' },
  'qualityforge-ai-Auditor': { name: 'Auditor', slug: 'auditor-qualityforge-quality-auditor' },
  'qualityforge-ai-Automation': { name: 'Automation', slug: 'automation-qualityforge-test-automation' },
  'qualityforge-ai-Codesmith': { name: 'Codesmith', slug: 'codesmith-qualityforge-code-architect' },
  'qualityforge-ai-Compatibility': { name: 'Compatibility', slug: 'compatibility-qualityforge-compatibility-testing' },
  'qualityforge-ai-Coverage': { name: 'Coverage', slug: 'coverage-qualityforge-test-coverage-analyst' },
  'qualityforge-ai-Debugger': { name: 'Debugger', slug: 'debugger-qualityforge-debugger-specialist' },
  'qualityforge-ai-Diagnostics': { name: 'Diagnostics', slug: 'diagnostics-qualityforge-diagnostics-specialist' },
  'qualityforge-ai-Documenter': { name: 'Documenter', slug: 'documenter-qualityforge-documentation-specialist' },
  'qualityforge-ai-E2E': { name: 'E2E', slug: 'e2e-qualityforge-end-to-end-testing' },
  'qualityforge-ai-Fixer': { name: 'Fixer', slug: 'fixer-qualityforge-bug-fixing-specialist' },
  'qualityforge-ai-Governor': { name: 'Governor', slug: 'governor-qualityforge-quality-director' },
  'qualityforge-ai-Guardian': { name: 'Guardian', slug: 'guardian-qualityforge-quality-guardian' },
  'qualityforge-ai-Inspector': { name: 'Inspector', slug: 'inspector-qualityforge-code-inspector' },
  'qualityforge-ai-Integration': { name: 'Integration', slug: 'integration-qualityforge-integration-testing' },
  'qualityforge-ai-Integrator': { name: 'Integrator', slug: 'integrator-qualityforge-integration-specialist' },
  'qualityforge-ai-Load': { name: 'Load', slug: 'load-qualityforge-load-testing' },
  'qualityforge-ai-Loadtester': { name: 'Loadtester', slug: 'loadtester-qualityforge-scalability-testing' },
  'qualityforge-ai-Maintainer': { name: 'Maintainer', slug: 'maintainer-qualityforge-code-maintainer' },
  'qualityforge-ai-Migrator': { name: 'Migrator', slug: 'migrator-qualityforge-migration-specialist' },
  'qualityforge-ai-Monitor': { name: 'Monitor', slug: 'monitor-qualityforge-quality-monitor' },
  'qualityforge-ai-Optimizer': { name: 'Optimizer', slug: 'optimizer-qualityforge-code-optimizer' },
  'qualityforge-ai-Performance': { name: 'Performance', slug: 'performance-qualityforge-performance-testing' },
  'qualityforge-ai-Probe': { name: 'Probe', slug: 'probe-qualityforge-prompt-testing' },
  'qualityforge-ai-Profiler': { name: 'Profiler', slug: 'profiler-qualityforge-performance-profiler' },
  'qualityforge-ai-Refactor': { name: 'Refactor', slug: 'refactor-qualityforge-refactoring-specialist' },
  'qualityforge-ai-Reporter': { name: 'Reporter', slug: 'reporter-qualityforge-quality-reporter' },
  'qualityforge-ai-Resolver': { name: 'Resolver', slug: 'resolver-qualityforge-issue-resolver' },
  'qualityforge-ai-Simulator': { name: 'Simulator', slug: 'simulator-qualityforge-workflow-simulation' },
  'qualityforge-ai-Standards': { name: 'Standards', slug: 'standards-qualityforge-standards-enforcer' },
  'qualityforge-ai-Tracer': { name: 'Tracer', slug: 'tracer-qualityforge-execution-tracer' },
  'qualityforge-ai-Trainer': { name: 'Trainer', slug: 'trainer-qualityforge-quality-trainer' },
  'qualityforge-ai-Validator': { name: 'Validator', slug: 'validator-qualityforge-validator' },
  'qualityforge-ai-accessibility': { name: 'Accessibility', slug: 'accessibility-qualityforge-accessibility-testing' },
  'qualityforge-ai-assessment-criteria-manager': { name: 'Criteria Manager', slug: 'assessment-criteria-manager-qualityforge' },
  'qualityforge-ai-code-analyzer': { name: 'Analyzer', slug: 'analyzer-qualityforge-code-analyzer' },
  'qualityforge-ai-code-reviewer': { name: 'Reviewer', slug: 'reviewer-qualityforge-code-reviewer' },
  'qualityforge-ai-compliance-validator': { name: 'Compliance Validator', slug: 'compliance-validator-qualityforge' },
  'qualityforge-ai-dbat-testing': { name: 'DBAT Testing', slug: 'dbat-testing-qualityforge' },
  'qualityforge-ai-decision-support-specialist': { name: 'Decision Support', slug: 'decision-support-specialist-qualityforge' },
  'qualityforge-ai-documentation-processor': { name: 'Documentation Processor', slug: 'documentation-processor-qualityforge' },
};

const report = [];

for (const [folder, { name, slug }] of Object.entries(nameMap)) {
  const mdPath = join(agentsDir, folder, 'AGENTS.md');
  try {
    let content = readFileSync(mdPath, 'utf-8');
    const oldName = content.match(/^name: (.+)$/m)?.[1];
    const oldSlug = content.match(/^slug: (.+)$/m)?.[1];

    // Replace name field
    content = content.replace(/^name: .+$/m, `name: ${name}`);
    // Replace or add slug field
    if (oldSlug) {
      content = content.replace(/^slug: .+$/m, `slug: ${slug}`);
    } else {
      // Insert slug after name
      content = content.replace(/^(name: .+)$/m, `$1\nslug: ${slug}`);
    }

    writeFileSync(mdPath, content);
    report.push({ folder, oldName, newName: name, oldSlug, newSlug: slug, status: '✅ Fixed' });
  } catch (e) {
    report.push({ folder, name, slug, status: `❌ Error: ${e.message}` });
  }
}

console.log('\n🔧 QualityForge AI Naming Fix Report\n');
console.log('='.repeat(80));
console.log('\n| Folder | Old Name | New Name | Status |');
console.log('|--------|----------|----------|--------|');
for (const r of report) {
  console.log(`| ${r.folder} | ${r.oldName || '—'} | ${r.newName || r.name} | ${r.status} |`);
}
console.log(`\nTotal: ${report.length} agents processed`);
