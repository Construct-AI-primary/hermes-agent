---
title: Organisational Knowledge Management Procedure
description: How this organisation creates, maintains, and uses its proprietary knowledge base.
version: 1.0
last_updated: 2026-04-06
---

# Knowledge Management Procedure

## Purpose

This procedure defines how `org-template-ai` creates, organises, maintains, and retires organisational knowledge. It ensures knowledge stays current, accurate, and accessible to all agents.

## Knowledge Categories

### 1. Company Standards (`knowledge/company-standards/`)

**What goes here:** Internal standards, procedures, and best practices that are proprietary to this organisation.

**Examples:**
- Coding standards and conventions
- Design guidelines and brand standards
- Security policies and procedures
- Deployment and operations runbooks
- Quality assurance checklists

**Lifecycle:**
1. **Create** — When a new standard is needed, draft in `company-standards/`
2. **Review** — Have relevant team lead review and approve
3. **Publish** — Commit to knowledge base, notify relevant agents
4. **Revise** — Update when standards change; keep revision history in markdown
5. **Archive** — Move deprecated standards to `knowledge/archive/standards/`

### 2. Industry Context (`knowledge/industry-context/`)

**What goes here:** Organisation-specific understanding of industry context, project history, methodologies, and client relationships.

**Examples:**
- Project history and outcomes
- Client relationship notes
- Lessons learned from past work
- Organisation's unique methodologies and approaches
- Market/sector intelligence

**Lifecycle:**
1. **Capture** — Add after project completion or when new context emerges
2. **Tag** — Add relevant metadata (date, project, participants, tags)
3. **Review** — During weekly reviews, verify context is still accurate
4. **Archive** — Move outdated context to `knowledge/archive/context/`

### 3. Integrations (`knowledge/integrations/`)

**What goes here:** Configuration and setup knowledge for external tools, services, and systems the organisation uses.

**Examples:**
- Website content and branding guidelines
- Tool configurations and setup instructions
- API integration notes
- External service documentation

## Creating New Knowledge

When creating new knowledge files:

1. **Choose the right category** — Standards vs Context vs Integrations
2. **Use clear filename** — `kebab-case-description.md`
3. **Include frontmatter:**
   ```yaml
   ---
   title: Human Readable Title
   description: Short description of what this knowledge covers
   version: 1.0
   created: 2026-04-06
   last_updated: 2026-04-06
   owner: role-or-person
   tags:
     - relevant-tag-1
     - relevant-tag-2
   ---
   ```
4. **Write in markdown** — Use clear headings, lists, code blocks as needed
5. **Cross-reference** — Link to related knowledge files

## Referencing External Knowledge

When your organisation's agents need access to external discipline knowledge (standard industry knowledge from `docs-construct-ai/`), use `sources[]` in skill or agent files:

```yaml
sources:
  - kind: local-dir
    path: ../../../../../docs-construct-ai/disciplines/00860_electrical-engineering/
    usage: referenced
    description: External electrical engineering discipline knowledge
```

**Rules:**
- Use `usage: referenced` — do not vendoring external content
- Include `description` explaining what the reference is for
- Keep paths relative to the referencing file
- One entry per external knowledge source

## Knowledge Review Schedule

### Weekly Review
- Check for new knowledge that needs to be added
- Verify existing knowledge is current
- Archive outdated documents

### Monthly Deep Review
- Comprehensive review of all company standards
- Validate industry context against current practices
- Clean up archive; remove very outdated items
- Update cross-references between knowledge files

### Quarterly Audit
- Full audit of knowledge completeness
- Identify gaps where standards are missing
- Ensure all active work references current knowledge
- Review archive for deletion candidates

## Knowledge Quality Rules

1. **No stale knowledge** — If you notice outdated info, flag it or fix it
2. **Everything is versioned** — Use version frontmatter for tracking
3. **Single source of truth** — Each piece of knowledge lives in exactly one place
4. **Agents follow knowledge** — Agents should reference this knowledge in their work
5. **Document exceptions** — If knowledge must be bypassed, document why

## Archive Policy

Items move to archive when:
- A standard is superseded by a new one
- Context is no longer relevant (old project methods, past strategies)
- An integration is decommissioned

Archive structure:
```
knowledge/archive/
├── standards/    # Deprecated standards
├── context/      # Outdated industry context
└── integrations/ # Decommissioned integration notes
```

Archive items are **read-only historical reference**. Do not delete archive items unless they contain sensitive data that must be purged.

## Responsibilities

| Role | Knowledge Responsibility |
|------|------------------------|
| CEO | Overall knowledge strategy, quarterly audit |
| Engineering Lead | Technical standards, codebase knowledge |
| All Agents | Capture knowledge from work, flag outdated content |