---
name: reviewer
description: >
  Use when: analyzing and validating tagged markdown documents in the knowledge base, reviewing documentation for accuracy and completeness, or verifying document structure meets standards.
  Don't use when: mapping features to disciplines (use advisor), testing workflows (use coordinator), or creating test strategies (use validator).
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
metadata:
  paperclip:
    tags:
      - knowledge-engineering
      - document-analysis
      - validation
---

# Document Analysis Skill

## Purpose

This skill provides systematic analysis and validation of tagged markdown documents in the knowledge base, ensuring document integrity, tag consistency, and proper structure.

## When to Use

- When new documents are added to the knowledge base
- During regular knowledge base maintenance cycles
- When tag validation is needed
- Before running other agents that depend on document integrity

## Steps

### 1. Document Discovery

```bash
# Find all markdown files in the knowledge base
find ../docs-construct-ai -name "*.md" -type f
```

### Knowledge Base Directories

KnowledgeForge reads from these directories in `docs-construct-ai/`:

#### Primary Knowledge Sources
| Directory | Purpose | Agent |
|-----------|---------|-------|
| `disciplines/` | 50+ engineering/construction discipline knowledge | Discipline Strategist, Workflow Guardian |
| `disciplines/*/agent-data/domain-knowledge/` | Domain-specific knowledge files (e.g., `00250_DOMAIN-KNOWLEDGE.MD`) | Discipline Strategist, Sector Analyst |
| `codebase/procedures/` | Development procedures (agent-development, database-management, deployment-operations, security-privacy, testing-qa, ui-frontend, etc.) | Doc Analyzer, Arch Refactorer |
| `codebase/agents/` | Agent documentation and frameworks | ClieNT Integrator |
| `codebase/architecture/` | System design principles | Arch Refactorer |
| `codebase/coding-standards/` | Language-specific standards | App Guardian |
| `codebase/guides/` | API, debugging, and workflow guides | All agents |
| `codebase/security/` | Authentication and compliance standards | App Guardian |
| `codebase/performance/` | Optimization and monitoring guidelines | App Guardian |
| `codebase/testing/` | Testing frameworks and procedures | QA Strategist |
| `codebase/tools/` | Development tools and utilities | ClieNT Integrator |
| `memory-integration/` | Agent guidelines, daily templates, testing validation | Failure Learner, QA Strategist |
| `testing/` | Testing strategies and results | QA Strategist, Sector QA Lead |
| `error-tracking/` | Error logs and failure analysis | Failure Learner |
| `standards/` | Coding and quality standards | App Guardian |
| `hermes_agent/` | Hermes agent documentation | ClieNT Integrator |

#### PARA Knowledge System (`para/`)
| Directory | Purpose | Agent |
|-----------|---------|-------|
| `para/pages/codebase/` | Codebase documentation, analysis, architecture, audits, guides | Doc Analyzer, Arch Refactorer |
| `para/pages/codebase/analysis/` | Build error analysis, system analysis, failure reports | Failure Learner, QA Strategist |
| `para/pages/codebase/audits/` | Documentation audits, security audits, system audits | App Guardian, QA Strategist |
| `para/pages/codebase/architecture/` | Visual design standards, workflow state standards | Arch Refactorer |
| `para/pages/codebase/coding-standards/` | Agent coding standards, file naming standards | App Guardian |
| `para/pages/codebase/database/` | Database naming standards | Arch Refactorer |
| `para/pages/codebase/commands/` | Agent commands (brainstorm, execute-plan, write-plan) | All agents |
| `para/resources/project-typologies/` | 9 construction sector references (oil-gas, mining, residential, commercial, mixed-use, infrastructure, industrial, institutional, energy-power) | Sector Analyst, Sector QA Lead |
| `para/resources/locations/` | 6 environment references (desert, tropical, high-altitude, offshore-marine, polar-arctic, urban-constrained) | Sector Analyst |
| `para/areas/` | Operational domains (reserved) | Discipline Strategist |

#### Chat History (`/Users/Chat-history/Ali/tasks/`)
| Content | Purpose | Agent |
|---------|---------|-------|
| 907 task directories | Historical development decisions, problem-solving approaches | ClieNT Integrator, Failure Learner |
| 3130 JSON files | Conversation history, context, focus chains | ClieNT Integrator |
| Focus chain markdowns | Task completion checklists | QA Strategist |

### 2. Tag Validation

For each document, validate that:
- Tags follow the established schema (`discipline:*`, `wf:*`, `sec:*`, `codebase:*`, `testing:*`, `standards:*`, `error-tracking:*`)
- Tags are properly formatted (lowercase, hyphen-separated)
- Required tags are present based on document type

### 3. Structure Verification

Check that documents have:
- Proper YAML frontmatter (if applicable)
- Clear heading hierarchy
- Consistent formatting
- No broken internal links

### 4. Deduplication Check

Identify potential duplicates by:
- Comparing document titles and headings
- Analyzing content similarity
- Flagging near-duplicate content for review

### 5. Index Generation

Create or update the document index with:
- Document path and title
- All associated tags
- Last modified date
- Content summary

## Output

```json
{
  "totalDocuments": 5000,
  "validDocuments": 4985,
  "tagViolations": 12,
  "structuralIssues": 3,
  "potentialDuplicates": 5,
  "indexUpdated": true
}
```

## Error Handling

- If a document cannot be read, log the error and continue
- If tags are invalid, flag for manual review
- If structure issues are found, generate a detailed report

## Related Skills

- `qa-strategy` — Uses document index for test planning
- `discipline-strategy` — Relies on discipline tags
- `failure-learning` — Updates documents based on failure analysis