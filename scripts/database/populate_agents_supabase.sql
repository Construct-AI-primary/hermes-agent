-- Supabase Agents Data Population
-- Populates DomainForge AI and InfraForge AI companies and agent data into Supabase tables
-- Run this against your Supabase database

-- Insert companies first (required for foreign key constraints)
-- Note: DFA prefix already exists (DevForge AI: f97b30e8-b022-4350-b4b0-30d43e2ebcf4)
-- Using unique prefixes to avoid conflicts
INSERT INTO companies (
  id,
  name,
  description,
  status,
  issue_prefix,
  issue_counter,
  budget_monthly_cents,
  spent_monthly_cents,
  require_board_approval_for_new_agents,
  brand_color,
  created_at,
  updated_at
) VALUES
(
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'DomainForge AI',
  'Multi-discipline autonomous AI company specializing in comprehensive engineering expertise across civil engineering disciplines',
  'active',
  'DOM',
  0,
  0,
  0,
  true,
  '#2563eb',
  '2026-03-30T15:53:00.000Z',
  '2026-03-30T15:53:00.000Z'
),
(
  '09f438a3-4041-46f2-b3cc-96fc9446e666',
  'InfraForge AI',
  'Dedicated infrastructure services autonomous AI company specializing in comprehensive infrastructure management, system orchestration, data processing, security, and operational excellence',
  'active',
  'INF',
  0,
  0,
  0,
  true,
  '#7c3aed',
  '2026-03-30T15:54:00.000Z',
  '2026-03-30T15:54:00.000Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  status = EXCLUDED.status,
  brand_color = EXCLUDED.brand_color,
  updated_at = EXCLUDED.updated_at;

-- Insert agents data
INSERT INTO agents (
  id,
  company_id,
  name,
  role,
  title,
  capabilities,
  status,
  reports_to,
  created_at,
  updated_at,
  metadata
) VALUES
-- DomainForge AI Agents (Updated with correct names from team documentation)
(
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Orion',
  'ceo',
  'Chief Domain Orchestrator',
  'Central nervous system for domain engineering orchestration and coordination. Oversees multi-disciplinary engineering workflow orchestration, cross-functional team coordination, dependency management, performance monitoring, and engineering quality assurance.',
  'active',
  NULL,
  '2026-03-30T15:53:36.729Z',
  '2026-03-30T15:53:36.729Z',
  '{"team": "DomainForge AI", "specialization": "Domain Orchestration", "permissions": ["can_create_agents", "can_assign_tasks"]}'
),
(
  'a1b2c3d4-e5f6-4789-a0b1-c2d3e4f5a6b7',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Civil',
  'engineer',
  'Civil Engineering Specialist',
  'Comprehensive civil engineering expertise across all disciplines. Handles general civil engineering analysis, multi-disciplinary coordination, civil engineering standards and best practices, and cross-discipline integration.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:53:40.000Z',
  '2026-03-30T15:53:40.000Z',
  '{"team": "DomainForge AI", "discipline": "Civil Engineering"}'
),
(
  'b03a9911-2a30-4c48-b501-35a42eb7e933',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Strategos',
  'general',
  'Strategic Planning Director',
  'Long-term strategic direction for civil engineering and infrastructure development. Handles infrastructure market analysis, competitive intelligence, strategic planning for large-scale construction projects, risk assessment, growth planning, technology adoption, and innovation strategy.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:53:51.580Z',
  '2026-03-30T15:53:51.580Z',
  '{"team": "DomainForge AI", "specialization": "Strategic Planning"}'
),
(
  'f9e4dcab-bef2-407d-920a-9beab25d5aad',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Council',
  'general',
  'Governance & Standards Director',
  'Collective strategic governance and policy development for engineering. Handles engineering policy development, governance frameworks, cross-disciplinary coordination, engineering standards enforcement, compliance validation, and regulatory framework development.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:53:55.244Z',
  '2026-03-30T15:53:55.244Z',
  '{"team": "DomainForge AI", "specialization": "Governance & Standards"}'
),
(
  '73e8b756-f623-471d-afc2-6c60f8e95faa',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Structural',
  'engineer',
  'Structural Engineering Specialist',
  'Structural analysis, design, and integrity assessment. Handles structural analysis and design calculations, load analysis, foundation design, structural integrity verification, structural safety assessment, and construction documentation.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:53:59.867Z',
  '2026-03-30T15:53:59.867Z',
  '{"team": "DomainForge AI", "discipline": "Structural Engineering"}'
),
(
  '5171c41d-e021-4565-a7cd-e572ddbb9d72',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Geotechnical',
  'engineer',
  'Geotechnical Engineering Specialist',
  'Soil mechanics, foundation engineering, and ground investigation. Handles soil investigation and characterization, foundation design and bearing capacity analysis, slope stability analysis, groundwater analysis, and earthquake engineering.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:03.544Z',
  '2026-03-30T15:54:03.544Z',
  '{"team": "DomainForge AI", "discipline": "Geotechnical Engineering"}'
),
(
  '241c2581-7296-4d7f-b5bb-9fae8cb1c3cb',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Transportation',
  'engineer',
  'Transportation Engineering Specialist',
  'Highway, railway, and transportation infrastructure design. Handles geometric design and alignment, traffic engineering and capacity analysis, intersection and interchange design, and transportation safety analysis.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:10.681Z',
  '2026-03-30T15:54:10.681Z',
  '{"team": "DomainForge AI", "discipline": "Transportation Engineering"}'
),
-- Additional DomainForge AI agents from team documentation (using existing IDs)
(
  '56789012-5678-5678-5678-567890123ef0',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Construction Engineering',
  'engineer',
  'Construction Engineering Specialist',
  'Construction engineering and project management. Handles construction methodologies, project scheduling, resource allocation, quality control, and construction safety.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:15.000Z',
  '2026-03-30T15:54:15.000Z',
  '{"team": "DomainForge AI", "discipline": "Construction Engineering"}'
),
(
  'f6f6f6f6-6666-6666-6666-666666666666',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Mobile Testing',
  'engineer',
  'Mobile Testing Specialist',
  'Mobile application testing and quality assurance. Handles mobile app testing, device compatibility, performance testing, and user experience validation.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:20.000Z',
  '2026-03-30T15:54:20.000Z',
  '{"team": "DomainForge AI", "discipline": "Mobile Testing"}'
),
(
  'e5e5e5e5-5555-5555-5555-555555555555',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Mobile Workflow Designer',
  'engineer',
  'Mobile Workflow Design Specialist',
  'Mobile workflow design and optimization. Handles mobile user experience design, workflow automation, interface design, and mobile process optimization.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:25.000Z',
  '2026-03-30T15:54:25.000Z',
  '{"team": "DomainForge AI", "discipline": "Mobile Workflow Design"}'
),
(
  '12345678-1234-1234-1234-123456789abc',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Buyer Specialist',
  'specialist',
  'Procurement and Contracts Specialist',
  'Procurement strategy and vendor management. Handles contract negotiation, supplier evaluation, procurement planning, cost optimization, and supply chain integration.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:30.000Z',
  '2026-03-30T15:54:30.000Z',
  '{"team": "DomainForge AI", "specialization": "Procurement and Contracts"}'
),
(
  'a1a1a1a1-1111-1111-1111-111111111111',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Procurement Strategy',
  'specialist',
  'Procurement Strategy Specialist',
  'Strategic procurement planning and optimization. Handles procurement strategy development, category management, sourcing strategies, spend analysis, supplier consolidation, total cost of ownership analysis, procurement transformation initiatives, and procurement best practices implementation.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:35.000Z',
  '2026-03-30T15:54:35.000Z',
  '{"team": "DomainForge AI", "specialization": "Procurement Strategy"}'
),
(
  'd4d4d4d4-4444-4444-4444-444444444444',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Procurement Analytics',
  'specialist',
  'Procurement Analytics Specialist',
  'Data-driven procurement insights and analytics. Handles spend analysis and reporting, procurement KPI tracking and dashboards, supplier performance analytics, cost savings tracking and validation, procurement forecasting and predictive analytics, market intelligence and benchmarking, and procurement data visualization.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:40.000Z',
  '2026-03-30T15:54:40.000Z',
  '{"team": "DomainForge AI", "specialization": "Procurement Analytics"}'
),
(
  'b2b2b2b2-2222-2222-2222-222222222222',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Supplier Management',
  'specialist',
  'Supplier Management Specialist',
  'Comprehensive supplier relationship and performance management. Handles supplier qualification and onboarding, supplier performance monitoring and scorecards, supplier risk assessment and mitigation, supplier development programs, supplier collaboration and innovation, supplier diversity initiatives, and supplier relationship management.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:45.000Z',
  '2026-03-30T15:54:45.000Z',
  '{"team": "DomainForge AI", "specialization": "Supplier Management"}'
),
(
  '23456789-2345-2345-2345-234567890bcd',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Dispatcher Specialist',
  'specialist',
  'Logistics and Supply Chain Specialist',
  'Supply chain and logistics management. Handles logistics planning, inventory management, transportation coordination, distribution optimization, and supply chain risk management.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:50.000Z',
  '2026-03-30T15:54:50.000Z',
  '{"team": "DomainForge AI", "specialization": "Logistics and Supply Chain"}'
),
(
  'c3c3c3c3-3333-3333-3333-333333333333',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Contract Administration',
  'specialist',
  'Contract Administration Specialist',
  'Contract lifecycle management and administration. Handles contract drafting and negotiation, contract compliance monitoring, contract amendment and renewal management, contract performance tracking, contract risk management, contract repository management, and contract audit and reporting.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:54:55.000Z',
  '2026-03-30T15:54:55.000Z',
  '{"team": "DomainForge AI", "specialization": "Contract Administration"}'
),
(
  'c9c9c9c9-9999-9999-9999-999999999999',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Financial Compliance',
  'specialist',
  'Procurement Financial Compliance Specialist',
  'Procurement-specific financial compliance and budget management. Handles budget approval workflows, financial authority matrices, procurement budget tracking, cost allocation and coding, financial compliance validation, audit trail management, financial reporting for procurement, and procurement fraud prevention.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:55:00.000Z',
  '2026-03-30T15:55:00.000Z',
  '{"team": "DomainForge AI", "specialization": "Financial Compliance"}'
),
(
  '34567890-3456-3456-3456-345678901cde',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Counsel - specialist',
  'specialist',
  'Legal and Regulatory Compliance Specialist',
  'Legal compliance and regulatory affairs. Handles contract law, regulatory compliance, risk assessment, legal documentation, and governance frameworks.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:55:05.000Z',
  '2026-03-30T15:55:05.000Z',
  '{"team": "DomainForge AI", "specialization": "Legal and Regulatory Compliance"}'
),
(
  '67890123-6789-6789-6789-678901234f01',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Guardian 2',
  'specialist',
  'Safety and Risk Management Specialist',
  'Safety protocols and risk management. Handles hazard identification, risk assessment, safety training, emergency response planning, and safety compliance.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:55:10.000Z',
  '2026-03-30T15:55:10.000Z',
  '{"team": "DomainForge AI", "specialization": "Safety and Risk Management"}'
),
(
  '89012345-8901-8901-8901-890123456123',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Inspector Specialist',
  'specialist',
  'Quality Control Specialist',
  'Quality inspection and control. Handles quality inspection, testing procedures, defect prevention, compliance verification, and quality metrics tracking.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:55:15.000Z',
  '2026-03-30T15:55:15.000Z',
  '{"team": "DomainForge AI", "specialization": "Quality Control"}'
),
(
  '78901234-7890-7890-7890-789012345012',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Scrutineer',
  'specialist',
  'Quality Assurance Specialist',
  'Quality management and assurance. Handles quality management systems, process improvement, standards compliance, audit coordination, and continuous improvement initiatives.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:55:20.000Z',
  '2026-03-30T15:55:20.000Z',
  '{"team": "DomainForge AI", "specialization": "Quality Assurance"}'
),
(
  '45678901-4567-4567-4567-456789012def',
  '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d',
  'Treasurer 2',
  'specialist',
  'Finance and Cost Management Specialist',
  'Financial planning and cost management. Handles budget management, cost analysis, financial reporting, economic evaluation, and financial risk assessment.',
  'active',
  '91223cfa-cf03-4f71-a5b0-c6afa1b02ac5',
  '2026-03-30T15:55:25.000Z',
  '2026-03-30T15:55:25.000Z',
  '{"team": "DomainForge AI", "specialization": "Finance and Cost Management"}'
),
-- InfraForge AI Agents (Updated with correct names from team documentation)
(
  '2876f20c-220c-4bf7-9baf-6ea668f85ef6',
  '09f438a3-4041-46f2-b3cc-96fc9446e666',
  'Orchestrator',
  'ceo',
  'Infrastructure Orchestration Specialist',
  'Central orchestration of infrastructure services and system integration. Oversees infrastructure service orchestration and coordination, system integration and API management, service dependency management, and infrastructure performance optimization.',
  'active',
  NULL,
  '2026-03-30T15:54:36.134Z',
  '2026-03-30T15:54:36.134Z',
  '{"team": "InfraForge AI", "specialization": "Infrastructure Orchestration", "permissions": ["can_create_agents", "can_assign_tasks"]}'
),
(
  '45c97946-2bdc-44f9-8d05-f3a19d15ea4c',
  '09f438a3-4041-46f2-b3cc-96fc9446e666',
  'Database',
  'engineer',
  'Database Infrastructure Specialist',
  'Database design, optimization, and management for engineering data. Handles database architecture and schema design, performance optimization and query tuning, data backup and recovery, and database security.',
  'active',
  '2876f20c-220c-4bf7-9baf-6ea668f85ef6',
  '2026-03-30T15:54:44.386Z',
  '2026-03-30T15:54:44.386Z',
  '{"team": "InfraForge AI", "specialization": "Database Infrastructure"}'
),
-- Additional InfraForge AI agents from team documentation
(
  'a7a7a7a7-7777-7777-7777-777777777777',
  '09f438a3-4041-46f2-b3cc-96fc9446e666',
  'Mobile API',
  'engineer',
  'Mobile API Integration Specialist',
  'Mobile API design, development, and integration. Handles mobile API architecture, authentication systems, offline synchronization, and mobile app integration.',
  'active',
  '2876f20c-220c-4bf7-9baf-6ea668f85ef6',
  '2026-03-30T15:54:48.000Z',
  '2026-03-30T15:54:48.000Z',
  '{"team": "InfraForge AI", "specialization": "Mobile API Integration"}'
),
(
  'b8b8b8b8-8888-8888-8888-888888888888',
  '09f438a3-4041-46f2-b3cc-96fc9446e666',
  'Supply Chain Integration',
  'specialist',
  'Supply Chain Integration Specialist',
  'Supply chain system integration and connectivity. Handles EDI integration, supplier portal development, delivery tracking systems, and inventory management integration.',
  'active',
  '2876f20c-220c-4bf7-9baf-6ea668f85ef6',
  '2026-03-30T15:54:52.000Z',
  '2026-03-30T15:54:52.000Z',
  '{"team": "InfraForge AI", "specialization": "Supply Chain Integration"}'
)
ON CONFLICT (id) DO UPDATE SET
  company_id = EXCLUDED.company_id,
  name = EXCLUDED.name,
  role = EXCLUDED.role,
  title = EXCLUDED.title,
  capabilities = EXCLUDED.capabilities,
  status = EXCLUDED.status,
  reports_to = EXCLUDED.reports_to,
  updated_at = EXCLUDED.updated_at,
  metadata = EXCLUDED.metadata;

-- Note: The agents table has a 'permissions' JSONB column built-in.
-- There is no separate 'agent_permissions' table in the Paperclip schema.
-- Permissions are stored directly in the agents.permissions column.

-- Verification queries
-- SELECT COUNT(*) as total_agents FROM agents WHERE company_id IN ('2d7d9c60-c02f-42a7-8f6a-7db86ecc879d', '09f438a3-4041-46f2-b3cc-96fc9446e666');
-- SELECT name, role, title FROM agents WHERE company_id = '2d7d9c60-c02f-42a7-8f6a-7db86ecc879d' ORDER BY created_at;
-- SELECT name, role, title FROM agents WHERE company_id = '09f438a3-4041-46f2-b3cc-96fc9446e666' ORDER BY created_at;