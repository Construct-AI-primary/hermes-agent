# Organisation Template AI

A starter template for creating your own organisation in Paperclip.

## Quick Start

1. **Copy this folder** to your desired company name:
   ```bash
   cp -r docs-paperclip/companies/org-template-ai/ docs-paperclip/companies/my-company-ai/
   ```

2. **Search and replace** all instances of `org-template-ai` with your company slug:
   ```bash
   find docs-paperclip/companies/my-company-ai/ -type f -exec sed -i '' 's/org-template-ai/my-company-ai/g' {} +
   ```

3. **Customize** the content:
   - `COMPANY.md` — Replace name, description, goals, tags
   - `.paperclip.yaml` — Update adapter config if needed
   - `agents/` — Add your actual agent roles
   - `teams/` — Update team structure
   - `skills/` — Replace with your org's skills
   - `knowledge/` — Populate with your proprietary knowledge
   - `tasks/` — Customise or remove starter tasks

## Structure

```
my-company-ai/
├── COMPANY.md                 # Organisation root — edit name, goals, tags
├── .paperclip.yaml            # Adapter config — review model/settings
├── agents/                    # Your agents
│   ├── org-ceo/               # → rename to your CEO/leader agent
│   └── org-engineering-lead/  # → rename to your tech lead
├── teams/                     # Your teams
│   ├── engineering/
│   └── operations/
├── skills/                    # Your skills (how-to guides)
│   └── org-template-ai-review/ # Quality review skill
├── tasks/                     # Starter tasks
│   └── weekly-review/         # Recurring weekly review
├── projects/                  # (empty — add your projects)
└── knowledge/                 # ← YOUR PROPRIETARY KNOWLEDGE
    ├── company-standards/     # Your internal standards
    └── industry-context/      # Your project history, methods
```

## What Goes Where

| Directory | What to Put Here | Example |
|-----------|-----------------|---------|
| `COMPANY.md` | Org identity, goals, metadata | Company name, mission, goals |
| `agents/` | Agent definitions with instructions | CEO, Engineering Lead, QA Agent |
| `teams/` | Team structures and membership | Engineering, Operations, Sales |
| `skills/` | How-to procedures for your org | Code review, deployment, QA process |
| `tasks/` | Starter and recurring tasks | Weekly review, sprint planning |
| `knowledge/company-standards/` | Your proprietary standards | Coding standards, design guidelines |
| `knowledge/industry-context/` | Your org's history and context | Project history, client relationships |

## Knowledge vs Skills

- **Skills** (`skills/`) = Procedural knowledge — HOW to do things
- **Knowledge** (`knowledge/`) = Declarative knowledge — WHAT your org knows

Skills are step-by-step procedures agents follow. Knowledge is the context, history, and standards they apply.

## Knowledge Management Procedure

Each organisation should maintain its own knowledge through this procedure:

### 1. Capture
When new standards, processes, or learnings emerge:
- Add to `knowledge/company-standards/` for standards and procedures
- Add to `knowledge/industry-context/` for project history and context

### 2. Reference External Knowledge
To reference external discipline knowledge (e.g., from `docs-construct-ai/`), use `sources[]` in your skill or agent files:

```yaml
sources:
  - kind: local-dir
    path: ../../../../docs-construct-ai/disciplines/00860_electrical-engineering/
    usage: referenced
```

This keeps your company package portable while giving agents access to industry-standard knowledge.

### 3. Review
During weekly reviews:
- Verify knowledge is up to date
- Identify gaps where new standards are needed
- Archive outdated content

## Importing

After customizing:

```bash
paperclip companies import docs-paperclip/companies/my-company-ai/
```

## Need Help?

- See `docs-paperclip/companies/companies-spec.md` for the full company package specification
- See `docs-paperclip/guides/board-operator/` for board operator guidance
- See `docs-paperclip/guides/agent-developer/` for agent development guidance