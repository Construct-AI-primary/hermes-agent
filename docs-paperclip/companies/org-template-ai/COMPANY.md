---
name: Organisation Template
description: Generic organisation template for companies using Paperclip. Clone this and customize for your own organisation.
slug: org-template-ai
schema: agentcompanies/v1
version: 1.0.0
license: MIT
authors:
  - name: Paperclip
homepage: https://example.com
tags:
  - template
  - organisation
  - starter
goals:
  - Define your organisation's mission and goals
  - Build your team structure with agents and teams
  - Capture organisation-specific knowledge and standards
  - Connect to external discipline knowledge as needed
includes:
  - ./teams/engineering/TEAM.md
  - ./teams/operations/TEAM.md
  - ./skills/org-template-ai-review/SKILL.md
requirements:
  secrets:
    - OPENROUTER_API_KEY
---

# Organisation Template

This is a **starter template** for creating your own organisation in Paperclip.

## How to Use This Template

1. **Copy this entire folder** to a new company name (e.g., `my-company-ai/`)
2. **Search and replace** `org-template` with your company slug throughout all files
3. **Customize** the content below for your organisation

## What's Included

```
org-template/
├── COMPANY.md                 ← You are here (organisation root)
├── .paperclip.yaml            ← Adapter/runtime configuration
├── agents/                    ← Your organisation's agents
│   ├── org-ceo/
│   └── org-engineering-lead/
├── teams/                     ← Your organisation's teams
│   ├── engineering/
│   └── operations/
├── skills/                    ← Your organisation's skills (HOW TO)
│   └── org-review/
├── tasks/                     ← Starter tasks and recurring work
│   └── weekly-review/
├── projects/                  ← Active projects (seed with starter tasks)
└── knowledge/                 ← ← YOUR ORG'S PROPRIETARY KNOWLEDGE
    ├── company-standards/     ← Internal standards and procedures
    ├── industry-context/      ← Your project history, methodologies
    └── integrations/          ← Website content, tool configs, external refs
```

## Customization Checklist

- [ ] Replace `org-template` slug with your company slug
- [ ] Replace organisation name and description
- [ ] Update `goals` to match your organisation's mission
- [ ] Update `homepage` to your organisation's website
- [ ] Customize `agents/` with your actual agent roles
- [ ] Customize `teams/` with your actual team structure
- [ ] Replace `skills/` with your org's actual skills
- [ ] Populate `knowledge/` with your org's proprietary knowledge
- [ ] Update `.paperclip.yaml` with your adapter configuration
- [ ] Remove or customize `tasks/` and `projects/`
- [ ] Update `tags` in frontmatter

## Organisation Goals

Replace these with your actual goals:

1. Define your organisation's primary mission
2. Build and maintain your team structure
3. Capture and apply organisation-specific knowledge
4. Deliver value to clients and stakeholders

## Knowledge Sources

This organisation references:

- **Internal knowledge** (`knowledge/`) — proprietary to this organisation
- **External discipline knowledge** (`docs-construct-ai/disciplines/`) — industry-standard knowledge via `sources[]` references
- **Shared skills** from other company packages via `includes` when appropriate

## Next Steps

After customizing, import this company into Paperclip:

```sh
paperclip companies import docs-paperclip/companies/my-company-ai/