# Discipline Workflow Setup Template

## Overview
This workflow template implements discipline workflows by creating separate projects for each workflow identified in the discipline's workflows list. Each workflow gets its own project with dedicated issues organized in a subfolder structure.

**Input**: Discipline workflows list document (e.g., `00855-geotechnical-engineering-workflows-list.md`)
**Output**: Multiple projects within the discipline folder, each with its own issues subfolder

## Prerequisites
- Discipline workflows list document exists: `{WORKFLOW_LIST_PATH}`
- Discipline folder structure exists: `docs-paperclip/disciplines/{DISCIPLINE_CODE}-{DISCIPLINE_NAME}/`
- Team cross-reference: `docs-construct-ai/codebase/agents/paperclip-teams/Paperclip_Teams_Cross_Reference.md`
- Project metadata: ID, name, CEO assignment, timeline, budget

## Workflow Steps

### 1. Discipline Analysis and Validation
**Goal**: Analyze the discipline workflows list and validate project structure

**Actions**:
- Read workflows list: `{WORKFLOW_LIST_PATH}`
- Extract workflow codes and names
- Validate discipline folder structure exists
- Confirm team assignments and agent availability

**Validation Checks**:
- [ ] Workflows list document exists and is properly formatted
- [ ] Discipline folder structure exists: `{DISCIPLINE_PATH}`
- [ ] All identified workflows have clear codes and descriptions
- [ ] Team assignments available for workflow implementation

### 2. Project Structure Creation
**Goal**: Create project folders and basic documentation for each workflow

**Project Structure Template**:
```
{DISCIPLINE_PATH}/projects/
├── {WORKFLOW_CODE}/
│   ├── project.md (project charter, scope, timeline)
│   ├── implementation.md (implementation plan)
│   └── issues/ (issues subfolder)
```

**For each workflow in the discipline**:
- Create project folder: `{DISCIPLINE_PATH}/projects/{WORKFLOW_CODE}/`
- Create `project.md` with workflow charter
- Create `implementation.md` with implementation plan
- Create `issues/` subfolder for workflow issues

### 3. Issue Creation and Assignment
**Goal**: Create comprehensive issues for each workflow project

**Issue Organization**:
- Issues created in `{PROJECT_PATH}/issues/` subfolder
- Issue naming: `{ISSUE_PREFIX}-{NUMBER}.md`
- Parent-child hierarchy maintained within project
- Links to project documentation

**Issue Template Structure**:
```
{PROJECT_PATH}/issues/
├── {ISSUE_PREFIX}-001.md (Planning & Setup)
├── {ISSUE_PREFIX}-002.md (Core Implementation)
├── {ISSUE_PREFIX}-003.md (Testing & Validation)
├── {ISSUE_PREFIX}-004.md (Documentation)
└── {ISSUE_PREFIX}-005.md (Deployment & Handover)
```

### 4. Team Assignment and Skill Validation
**Goal**: Assign appropriate agents to each workflow project

**Team Validation**:
- **Primary Company**: {PRIMARY_COMPANY}
- **Primary Team**: {PRIMARY_TEAM}
- **Primary Agents**: {PRIMARY_AGENTS}
- **Required Skills**: {PRIMARY_SKILLS}

**Skill Gap Analysis**:
| Workflow | Required Skills | Assigned Agents | Gap Status |
|----------|-----------------|-----------------|------------|
| {WORKFLOW_CODE} | {WORKFLOW_SKILLS} | {ASSIGNED_AGENTS} | {GAP_STATUS} |

### 5. Project Documentation Updates
**Goal**: Ensure all project documentation is current and accessible

**Required Documents per Project**:
- [ ] Project charter (`{PROJECT_PATH}/project.md`)
- [ ] Implementation plan (`{PROJECT_PATH}/implementation.md`)
- [ ] Issue tracking (`{PROJECT_PATH}/issues/`)
- [ ] Risk register and mitigation plans
- [ ] Communication plan and status reporting

## Template Variables Reference

### Core Discipline Variables
```
{DISCIPLINE_CODE} - Discipline identifier (e.g., 00855)
{DISCIPLINE_NAME} - Discipline name (e.g., Geotechnical Engineering)
{DISCIPLINE_PATH} - Full path to discipline folder
{WORKFLOW_LIST_PATH} - Path to discipline workflows list document
```

### Workflow-Specific Variables
```
{WORKFLOW_CODE} - Individual workflow code (e.g., GEOTECH-SITE, LOG-LIFECYCLE)
{WORKFLOW_NAME} - Individual workflow name (e.g., Site Investigation and Geotechnical Assessment)
{WORKFLOW_DESCRIPTION} - Detailed workflow description
{PROJECT_PATH} - Path to workflow project folder
{ISSUE_PREFIX} - Issue prefix for this project (matches {WORKFLOW_CODE})
```

### Enhanced Project Naming Convention

**Generate Descriptive Project Codes:**
- Use meaningful abbreviations based on workflow names
- Follow pattern: `{DISCIPLINE_PREFIX}-{DESCRIPTIVE_NAME}`
- Examples:
  - Procurement: `PROC-ORDER`, `PROC-INV`, `PROC-SUPP`, `PROC-TRACK`
  - Logistics: `LOG-LIFECYCLE`, `LOG-DATA-CAPTURE`, `LOG-CUSTOMS`
  - Geotechnical: `GEOTECH-SITE`, `GEOTECH-FOUNDATION`, `GEOTECH-SLOPE`
  - Safety: `SAFETY-HAZARD`, `SAFETY-INCIDENT`, `SAFETY-PPE`

**Naming Guidelines:**
- Keep under 20 characters total
- Use hyphens to separate words
- Make names self-descriptive and searchable
- Avoid generic codes like `LOG-001`, `PROC-002`

### Team and Assignment Variables
```
{PRIMARY_COMPANY} - Main development company
{PRIMARY_TEAM} - Primary development team name
{PRIMARY_AGENTS} - Comma-separated list of primary agents
{PRIMARY_SKILLS} - Required skills for primary team
{CEO_AGENT} - CEO agent slug for oversight
```

## Example Implementation: Geotechnical Engineering

### Discipline Variables
```
{DISCIPLINE_CODE} = 00855
{DISCIPLINE_NAME} = geotechnical-engineering
{DISCIPLINE_PATH} = docs-paperclip/disciplines/00855-geotechnical-engineering
{WORKFLOW_LIST_PATH} = docs-paperclip/disciplines/00855-geotechnical-engineering/00855-geotechnical-engineering-workflows-list.md
```

### Generated Project Structure
```
docs-paperclip/disciplines/00855-geotechnical-engineering/projects/
├── GEOTECH-SITE/
│   ├── project.md
│   ├── implementation.md
│   └── issues/
│       ├── GEOTECH-SITE-001.md
│       ├── GEOTECH-SITE-002.md
│       └── ...
├── GEOTECH-FOUNDATION/
│   ├── project.md
│   ├── implementation.md
│   └── issues/
│       ├── GEOTECH-FOUND-001.md
│       ├── GEOTECH-FOUND-002.md
│       └── ...
└── ... (other workflow projects)
```

## Success Criteria

### Structural Success
- [ ] Separate project folder created for each workflow
- [ ] Issues organized in `issues/` subfolder within each project
- [ ] Project documentation (`project.md`, `implementation.md`) created
- [ ] Clear naming conventions followed

### Content Success
- [ ] All workflows from list converted to projects
- [ ] Issues properly scoped to their workflow project
- [ ] Team assignments validated and documented
- [ ] Parent-child issue hierarchy maintained

### Process Success
- [ ] Template reusable across all disciplines
- [ ] Compatible with existing Paperclip task management
- [ ] Documentation complete and accessible
- [ ] Workflow execution tracked and monitored

## Risk Mitigation

### Technical Risks
- **Incomplete Workflows List**: Validate workflows list format before processing
- **Missing Team Assignments**: Cross-reference with team documentation
- **Path Conflicts**: Use consistent naming conventions
- **Documentation Drift**: Regular validation against workflows list

### Process Risks
- **Scope Creep**: Stick to workflow boundaries defined in list
- **Resource Conflicts**: Coordinate with existing project schedules
- **Quality Issues**: Implement review gates for documentation
- **Timeline Slippage**: Phase implementation with clear milestones

## Monitoring and Control

### Progress Tracking
- Workflow-to-project conversion status
- Issue creation completion rate
- Team assignment validation status
- Documentation completeness metrics

### Quality Gates
- Workflows list validation before processing
- Project structure verification after creation
- Issue hierarchy and naming convention checks
- Team assignment and skill validation

## Completion Criteria

The workflow setup is complete when:
1. All workflows from the discipline list have corresponding projects
2. Each project has complete documentation and issue structure
3. Team assignments are validated and documented
4. Issues are properly organized in project subfolders
5. Parent-child hierarchies are established within projects
6. Template is ready for reuse across other disciplines

## Related Documents

- Discipline Workflows List: `{WORKFLOW_LIST_PATH}`
- Team Cross-Reference: `docs-construct-ai/codebase/agents/paperclip-teams/Paperclip_Teams_Cross_Reference.md`
- Task Management: `docs-paperclip/guides/board-operator/managing-tasks.md`
- Core Concepts: `docs-paperclip/start/core-concepts.md`

---
**Workflow Version**: 1.0
**Created**: 2026-04-08
**Last Updated**: 2026-04-08
**Owner**: Paperclip Board Operations