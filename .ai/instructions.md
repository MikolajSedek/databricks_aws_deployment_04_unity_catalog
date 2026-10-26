# AI Assistant Guidelines & Sources of Truth

This project deploys AWS and Databricks infrastructure for **Enterprise Databricks Unity Catalog** using a **Hub and Spoke Architecture** via Terraform. When generating, reviewing, or modifying Terraform code, architecture, or AWS/Databricks configurations, strictly adhere to the following guidelines and authoritative sources of truth.

---

## 1. Project Context & Architectural Goal

- **Objective**: Provision an enterprise-grade AWS and Databricks foundation for **Unity Catalog governance** (metastore root storage, cross-account IAM trust policies, external locations, storage credentials, 3-level namespace catalog hierarchies, and account-to-workspace bindings) and Databricks E2 workspaces using a **Hub and Spoke** architecture with centralized firewall inspection (AWS Network Firewall / Transit Gateway).
- **Core Reference Architecture**: Follow the official Databricks guides on [Unity Catalog Getting Started](https://docs.databricks.com/aws/en/data-governance/unity-catalog/get-started) and [AWS E2 Firewall Hub and Spoke Architecture](https://github.com/databricks/terraform-provider-databricks/blob/main/docs/guides/aws-e2-firewall-hub-and-spoke.md).
- **Base Repository Template**: Use [https://github.com/MikolajSedek/databricks_aws_deployment_01_vpc_networking](https://github.com/MikolajSedek/databricks_aws_deployment_01_vpc_networking) as the mandatory base template for all new repositories (see [Section 6](#6-repository-scaffolding-module-architecture--operational-guardrails)).

---

## 2. Authoritative Sources of Truth

Always ground implementations in official, up-to-date documentation. Do not rely on assumptions or potentially outdated training data when designing AWS architecture or writing Terraform resource definitions.

### A. Databricks AWS Official Documentation *(Imperative Sources of Truth)*
- **Databricks AWS Unity Catalog Skill (`databricks-aws-unity-catalog`)**:
  - Use the vendored skill at [`.ai/skills/databricks-aws-unity-catalog/SKILL.md`](./skills/databricks-aws-unity-catalog/SKILL.md) for architecting, provisioning, configuring, and governing Databricks Unity Catalog on AWS with Terraform (metastore root storage, cross-account IAM trust policies, storage credentials, external locations, 3-level namespace catalog hierarchy, and account-to-workspace bindings).
- **Databricks Unity Catalog Getting Started Guide**:
  - [Get Started with Unity Catalog | Databricks on AWS](https://docs.databricks.com/aws/en/data-governance/unity-catalog/get-started) *(Official foundational guide for setting up Unity Catalog, configuring admin roles, workspaces, users, compute isolation, and data governance capabilities)*
- **Databricks Automated Unity Catalog Setup with Terraform**:
  - [Automate Unity Catalog Setup with Terraform | Databricks on AWS](https://docs.databricks.com/aws/en/dev-tools/terraform/automate-uc) *(Official guide outlining requirements, IAM roles, S3 buckets, environment variables, validation tips, and execution lifecycle for Terraform-driven UC automation)*
- **Databricks Terraform Provider Unity Catalog Guide**:
  - [Unity Catalog Setup on AWS | Databricks Terraform Provider Documentation](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog) *(Definitive resource reference and step-by-step Terraform guide for metastores, storage credentials, external locations, catalogs, schemas, and grants)*
- **Databricks AWS Unity Catalog Terraform Example Module**:
  - [Databricks AWS UC Terraform Module Example](https://registry.terraform.io/modules/databricks/examples/databricks/latest/examples/aws-databricks-uc) *(Official Terraform registry module example demonstrating end-to-end AWS and Databricks resource orchestration)*
- **Databricks Terraform Examples Repository (`aws-databricks-uc`)**:
  - [Databricks Terraform Examples Repository - aws-databricks-uc](https://github.com/databricks/terraform-databricks-examples/tree/v0.2.28/examples/aws-databricks-uc) *(Official source implementation covering account-level identities, S3 metastore buckets, cross-account IAM trust policies, storage credentials, metastore assignment, and workspace catalogs)*
- **Databricks AWS Workspace Provisioning Skill (`databricks-aws-workspace`)**:
  - Use the vendored skill at [`.ai/skills/databricks-aws-workspace/SKILL.md`](./skills/databricks-aws-workspace/SKILL.md) for architecting, provisioning, configuring, and troubleshooting Databricks Workspaces on AWS with Terraform (both Classic Customer-Managed VPC and Serverless compute modes).
- **Databricks AWS Workspace Provisioning Guide**:
  - [Databricks AWS Workspace Terraform Guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-workspace#databricks-workspace) *(Authoritative step-by-step guide for deploying Databricks E2 workspaces with VPC, root bucket, cross-account IAM role, and provider authentication)*
- **Databricks on AWS Workspace Administration Guide**:
  - [Databricks on AWS Workspace Administration Guide](https://docs.databricks.com/aws/en/admin/workspace/) *(Authoritative reference for workspace lifecycle, choosing between serverless and classic workspaces, account console configuration, and operational updates)*
- **Databricks Terraform Provider Official Documentation**:
  - [Databricks Terraform Registry Docs](https://registry.terraform.io/providers/databricks/databricks/latest/docs) *(Authoritative schema and reference for all Databricks Terraform provider resources, data sources, and authentication attributes)*
- **Databricks Cloud Automation Best Practices**:
  - [Automating Databricks Deployments on AWS Best Practices (Part 3)](https://www.databricks.com/blog/best-practices-and-guidance-cloud-engineers-deploy-databricks-aws-part-3) *(Authoritative architectural guidance on 3-tier API endpoints: AWS, Databricks Account, and Databricks Workspace; decoupling modules, and automation guardrails)*
- **Databricks on AWS Official Documentation**:
  - [Databricks on AWS Documentation](https://docs.databricks.com/aws/en/) *(Imperative source of truth for all Databricks AWS configurations, architecture, security, compute, storage, and networking requirements)*
- **Databricks Agent Skill (`databricks-docs`)**:
  - Use the vendored skill at [`.ai/skills/databricks-docs/SKILL.md`](./skills/databricks-docs/SKILL.md) to reference the Databricks `llms.txt` index (`https://docs.databricks.com/llms.txt`) when a topic is not fully covered in project modules or direct Databricks docs navigation.
- **Official Databricks GitHub Repositories**:
  - [Official Databricks GitHub Repositories](https://github.com/orgs/databricks/repositories?type=all) *(Authoritative source for official Databricks reference solutions, blueprints, tools, examples, and Terraform providers)*
- **Databricks Terraform Provider Examples**:
  - [Databricks Terraform Provider Examples](https://github.com/databricks/terraform-databricks-examples) *(Extra source of information with examples of using Databricks Terraform provider; when deploying with AWS, use only AWS examples)*
- **Hub & Spoke Firewall Guide**:
  - [Databricks AWS E2 Firewall Hub and Spoke Guide](https://github.com/databricks/terraform-provider-databricks/blob/main/docs/guides/aws-e2-firewall-hub-and-spoke.md)
- **Databricks Customer-Managed VPC**:
  - [Databricks Customer-Managed VPC Configuration Guide](https://docs.databricks.com/aws/en/administration-guide/cloud-configurations/aws/customer-managed-vpc)
- **Databricks AWS PrivateLink Workspace Terraform Guide**:
  - [Databricks AWS PrivateLink Workspace Guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-private-link-workspace) *(Imperative source of truth for provisioning Databricks and AWS resources needed for private connectivity between the data plane and control plane, including VPC endpoint registration (`databricks_mws_vpc_endpoint`), private access settings (`databricks_mws_private_access_settings`), customer-managed network VPC endpoint associations (`databricks_mws_networks`), and private workspace provisioning)*
- **Databricks Classic PrivateLink & Control Plane Connectivity Guide**:
  - [Databricks Classic Private Connectivity Documentation](https://docs.databricks.com/aws/en/security/network/classic/privatelink) *(Imperative source of truth for configuring AWS PrivateLink for classic compute plane back-end private connectivity to Databricks control plane services, covering workspace REST API and secure cluster connectivity relay VPC endpoint requirements, private access settings, DNS configuration, and security isolation)*

### B. AWS Official Documentation
- **AWS Documentation MCP Server (`aws-docs`)**:
  - Use `search_documentation`, `read_documentation`, `read_sections`, and `recommend` to verify service limits, IAM policy requirements, encryption specifications, networking constraints (VPC, Transit Gateway, Network Firewall), and Well-Architected Framework guidelines.
- **Web Documentation**:
  - [AWS Official Documentation](https://docs.aws.amazon.com/)
  - [AWS Network Firewall Developer Guide](https://docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html)
  - [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html)
  - [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### C. Terraform AWS Provider & Registry
- **Terraform MCP Server (`terraform`)**:\
  - Use `providerDetails`, `moduleDetails`, and available registry tools to verify provider version requirements, argument names, schema types, and deprecated attributes.
- **Web Documentation**:
  - [Terraform AWS Provider Registry Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
  - [Terraform Language Documentation](https://developer.hashicorp.com/terraform/docs)

### D. GitHub Actions Official Documentation *(Authoritative Source for Deployments)*
- **Web Documentation**:
  - [GitHub Actions Documentation](https://docs.github.com/en/actions) *(Authoritative source of truth for GitHub Actions CI/CD workflows, pipeline syntax, runner configurations, deployment environments, OIDC authentication, and automation)*

---

## 3. MCP Server & Resource Usage Protocol

When assisting with infrastructure tasks:

1. **Align with Databricks Hub-and-Spoke Pattern**:
   - Check routing rules, subnet divisions (public, firewall, TGW attachment, spoke private data/control plane subnets), and firewall domain allowlists against the [Databricks AWS E2 Firewall Guide](https://github.com/databricks/terraform-provider-databricks/blob/main/docs/guides/aws-e2-firewall-hub-and-spoke.md).
2. **Verify Resource Syntax**:
   - Query the **Terraform MCP Server** or official registry documentation to confirm the exact arguments, required blocks, and valid attribute values for `hashicorp/aws` and `databricks/databricks` resources.
3. **Use Databricks Documentation Skill for Gap Coverage**:
   - If requirements are unclear after checking the referenced architecture docs, use `databricks-docs` skill guidance to fetch `https://docs.databricks.com/llms.txt`, then follow the linked page that matches the exact feature.
4. **Follow Databricks AWS Workspace Provisioning Routing (`databricks-aws-workspace`)**:
   - When designing, creating, configuring, or modifying Databricks workspaces on AWS, strictly consult and follow the [`.ai/skills/databricks-aws-workspace/SKILL.md`](./skills/databricks-aws-workspace/SKILL.md) skill.
   - Enforce the 3-tier API lifecycle (AWS Cloud -> Databricks Account MWS -> Databricks Workspace).
   - Ensure complete decoupling between account-level workspace creation (`provider = databricks.mws`) and workspace-level resource orchestration (`provider = databricks`) across separate modules.
   - Prevent credential validation race conditions (`MALFORMED_REQUEST: Failed credentials validation checks`) by injecting `time_sleep` dependencies between IAM policy attachment and workspace deployment.
5. **Follow Databricks AWS Unity Catalog Routing (`databricks-aws-unity-catalog`)**:
   - When designing, creating, configuring, or modifying Unity Catalog resources on AWS, strictly consult and follow the [`.ai/skills/databricks-aws-unity-catalog/SKILL.md`](./skills/databricks-aws-unity-catalog/SKILL.md) skill.
   - Enforce the 2-tier provider scoping model: Account-level MWS provider (`provider = databricks.mws`) for metastores, account identities, and workspace metastore assignments; Workspace-level provider (`provider = databricks`) for storage credentials, external locations, catalogs, schemas, volumes, and grants.
   - Prevent credential validation race conditions (`MALFORMED_REQUEST: Failed credentials validation checks`) by injecting `time_sleep` dependencies (at least 20s) between AWS IAM role/policy attachment and Databricks metastore data access or storage credential deployment.
   - Enforce the single metastore per region rule.
   - Decouple metastore root S3 storage from individual catalog storage roots to isolate blast radiuses across environments.
6. **Validate AWS Service Constraints & IAM Policies**:
   - Query the **AWS Documentation MCP Server (`aws-docs`)** to verify security best practices (e.g., KMS key policies, bucket policies, VPC endpoint routing, IAM cross-account roles).
7. **Check for Deprecations**:
   - Verify that new resource blocks follow modern AWS provider syntax (e.g., standalone `aws_s3_bucket_*`, `aws_route_table`, `aws_networkfirewall_*` resources).
8. **Adhere to Control Plane Private Connectivity Standards (AWS PrivateLink)**:
   - When configuring private connectivity between the customer data plane and the Databricks control plane, strictly consult the [Databricks AWS PrivateLink Workspace Guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-private-link-workspace) and [Databricks Classic Private Connectivity Documentation](https://docs.databricks.com/aws/en/security/network/classic/privatelink).
   - Ensure the required AWS interface VPC endpoints (workspace API `com.amazonaws.vpce.<region>.k8s-workspace` and SCC relay `com.amazonaws.vpce.<region>.k8s-tunnel`) are created with dedicated endpoint subnets and security groups.
   - Register VPC endpoints in the Databricks account using `databricks_mws_vpc_endpoint`, configure `databricks_mws_private_access_settings`, attach endpoint IDs to `databricks_mws_networks` (`vpc_endpoints.rest_api` and `vpc_endpoints.dataplane_relay`), and attach `private_access_settings_id` to `databricks_mws_workspaces`.

---

## 4. Documentation Standards & Authoritative README Template

### A. Mandatory README Template Usage
All `README.md` files produced across the repository—both for environments (`environments/<env>/README.md`) and reusable modules (`modules/<category>/<module_name>/README.md`)—**must strictly adhere** to the authoritative template:
- **Template Path**: [`.ai/README_TEMPLATE.md`](file:///.ai/README_TEMPLATE.md)

### B. Required README Structure
Every `README.md` must include the following standard sections:
1. **Executive Summary**: High-level purpose, problem solved, scope, and key business/security outcomes.
2. **General Logic of the Module / Environment**: Operational lifecycle, input calculation flow, and end-to-end traffic flow (egress, control plane, east-west).
3. **Architecture of the Module / Environment**: Subnet allocation, CIDR breakdown, routing matrix, KMS encryption, and security groups.
4. **Architecture C4 Visualisation**: Multi-tier Mermaid diagrams (System Context, Container/Network Infrastructure, and Component/Terraform orchestration).
5. **All Modules Used with Short Summaries**: Comprehensive inventory table and deep-dive descriptions for all submodules invoked.
6. **Terraform Documentation Interface**: Explicit reference to the auto-generated [`TERRAFORM.md`](./TERRAFORM.md) (maintained by `terraform-docs` via pre-commit hooks) alongside key highlighted inputs and outputs.
7. **Important Links and Resources**: Verified, active external links to official Databricks and AWS documentation, plus internal references.

### C. Documentation & Link Validation
- **Mandatory Link Verification**: Whenever any hyperlink (URL) is added to markdown (`.md`) files, it **must** be validated prior to committing to ensure it is active, reachable, and returns a valid HTTP response (HTTP 200, no dead or 404 links).
- **No Validation Boilerplate in READMEs**: Do NOT include verification notices, disclaimers, or boilerplate validation sentences (e.g., "Link Validation: All hyperlinks below have been checked and verified to return HTTP 200 responses" or "Link Integrity Requirement: ...") inside generated `README.md` files. Link validation is an internal quality and engineering standard for authors and CI/CD pipelines, not consumer-facing documentation content.

### D. Mermaid Syntax, CLI Installation & Validation Guide

All Mermaid diagrams generated for architecture visualizations (C4 System Context, Container/Network Infrastructure, Component/Terraform orchestration) **must be parsed and validated** before committing to eliminate syntax and rendering errors.

#### 1. Mermaid CLI (`mmdc`) Installation Instructions
Mermaid CLI (`@mermaid-js/mermaid-cli`) parses markdown files, extracts fenced `mermaid` code blocks, and validates or compiles them via headless Chromium (Puppeteer).

- **Prerequisites**:
  - [Node.js](https://nodejs.org/) (`>= 18.0.0` or current LTS) and `npm` installed and accessible in `PATH`.
  - Verify environment:
    ```bash
    node --version
    npm --version
    ```

- **Installation Methods**:
  - **Option 1: Global CLI Installation** (Recommended for local developer workstations):
    ```bash
    npm install -g @mermaid-js/mermaid-cli

    # Verify installation
    mmdc --version
    ```
  - **Option 2: On-Demand Execution via `npx`** (Zero-installation, ideal for CI/CD pipelines and automated agent workflows):
    ```bash
    # Runs the latest mermaid-cli directly without prior installation
    npx -y @mermaid-js/mermaid-cli --version
    ```
  - **Option 3: Project-Level Dependency**:
    ```bash
    npm install --save-dev @mermaid-js/mermaid-cli
    ```

- **Linux / CI Headless Configuration**:
  In headless Linux containers (e.g., GitHub Actions, Docker) where Chromium sandbox restrictions apply, supply a `puppeteer-config.json`:
  ```json
  {
    "args": ["--no-sandbox", "--disable-setuid-sandbox"]
  }
  ```
  Pass the configuration flag to `mmdc`:
  ```bash
  mmdc -p puppeteer-config.json -i input.md -o output.md
  ```

#### 2. Reusable Usage Instructions (Validation & Rendering)

- **Single Markdown File Validation**:
  Parse and validate all embedded Mermaid diagrams in a markdown file without altering the source file. If syntax errors exist, the command returns a non-zero exit code and outputs the line and error details:
  ```bash
  # Linux / macOS (Bash):
  npx -y @mermaid-js/mermaid-cli -i path/to/README.md -o /tmp/validate_out.md

  # Windows (PowerShell):
  npx -y @mermaid-js/mermaid-cli -i path\to\README.md -o "$env:TEMP\validate_out.md"
  ```

- **Standalone Diagram File Compilation (SVG / PNG)**:
  Compile an individual `.mmd` definition file into vector graphics or high-resolution bitmaps:
  ```bash
  # Render SVG vector diagram
  npx -y @mermaid-js/mermaid-cli -i architecture.mmd -o architecture.svg

  # Render high-resolution PNG (scaled 2x, 2048px width)
  npx -y @mermaid-js/mermaid-cli -i architecture.mmd -o architecture.png -w 2048 -s 2
  ```

- **Batch Repository-Wide Validation (Reusable Node.js Script)**:
  Use the following reusable script to scan and validate all markdown documentation across the repository:
  ```javascript
  // validate_mermaid.mjs
  import { execSync } from 'child_process';
  import fs from 'fs';
  import path from 'path';

  const filesToValidate = [
    'README.md',
    '.ai/README.md',
    '.ai/README_TEMPLATE.md',
    'environments/dev/README.md',
    'modules/01.networking/001.generic_vpc/README.md',
    'modules/01.networking/002.spoke_vpc/README.md',
    'modules/01.networking/003.spoke_privatelink/README.md',
    'modules/01.networking/004.hub_vpc/README.md',
    'modules/01.networking/005.transit_gateway_spoke_hub/README.md',
    'modules/01.networking/006.hub_networking_firewall/README.md',
    'modules/02.security/001.kms_key/README.md',
    'modules/03.storage/001.env_backend_bucket/README.md'
  ];

  const tempOut = path.resolve('temp_mermaid_validation.md');
  let failures = 0;

  for (const file of filesToValidate) {
    if (!fs.existsSync(file)) continue;
    process.stdout.write(`Validating: ${file} ... `);
    try {
      execSync(`npx -y @mermaid-js/mermaid-cli -i "${path.resolve(file)}" -o "${tempOut}"`, {
        stdio: 'pipe'
      });
      console.log('✅ PASS');
    } catch (err) {
      console.log('❌ FAIL');
      const output = (err.stderr?.toString() || '') + (err.stdout?.toString() || '');
      console.error(output);
      failures++;
    }
  }

  if (fs.existsSync(tempOut)) {
    fs.unlinkSync(tempOut);
  }

  if (failures > 0) {
    console.error(`\nValidation failed on ${failures} file(s).`);
    process.exit(1);
  } else {
    console.log('\nAll Mermaid diagrams validated successfully.');
  }
  ```
  Execute the runner:
  ```bash
  node validate_mermaid.mjs
  ```

#### 3. Core Mermaid Syntax Rules (Strictly Enforced)
1. **Subgraph Classing & Styling**:
   - **Prohibited**: `subgraph Id["Title"]:::className` (causes parser error `Expecting 'SEMI', 'NEWLINE', 'EOF', got 'STYLE_SEPARATOR'`).
   - **Mandatory**: Declare `subgraph Id ["Title"]` ... `end`, and assign the class on a dedicated line following the block:
     ```mermaid
     flowchart TD
         subgraph HubVPC ["Hub VPC"]
             NAT["NAT Gateway"]
         end
         class HubVPC hubVpcStyle;
     ```
2. **Node Label Quoting**:
   - Always enclose node labels in explicit double quotes: `nodeId["Service Name (VPC / Subnet)"]`.
   - Never leave unquoted parentheses, colons, brackets, or slashes inside labels.
3. **HTML Tags in Node Labels**:
   - Restrict HTML in node labels strictly to architectural icon embeddings (`<img .../>`), line breaks (`<br/>`), and bold titles (`<b>...</b>`).
   - All HTML tag attributes MUST use single quotes (`'...'`) inside the outer double-quoted node label string `["..."]`.
4. **Valid Connector Syntax**:
  - Standard solid arrow: `A --> B`
  - Labeled solid arrow: `A -->|"Encrypted TLS (443)"| B`
  - Labeled dotted reference: `A -.->|"KMS Key ARN"| B`

#### 4. Official AWS and Databricks Architecture Icons & Sizing Protocol

To achieve publication-grade, professional C4 diagrams in markdown, embed official AWS and Databricks architecture icons directly inside Mermaid node labels.

##### a. Authoritative CDN Icon Sources
Use the verified CDN asset paths from the [`mingrammer/diagrams`](https://github.com/mingrammer/diagrams) open-source architecture icon repository and the [`oieduardorabelo/databricks-architecture-icons`](https://github.com/oieduardorabelo/databricks-architecture-icons) library (built from official Databricks SVG artwork; see [web catalog](https://oieduardorabelo.github.io/databricks-architecture-icons/) for all 71 products across `svg/`, `svg-mono/`, `svg-tile/`, `svg-outline/`, `png/`, `png-tile/`, and `png-outline/` variants):
- **Databricks General & Platform**:
  - Databricks Brand Logo (`mingrammer`): `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/onprem/analytics/databricks.png`
  - Databricks Platform Mark: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/databricks.png`
  - Data Intelligence Platform: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/data-intelligence-platform.png`
  - Lakehouse Architecture: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/lakehouse.png`
- **Databricks Workspaces, Compute & Runtime**:
  - Databricks Workspace: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/workspace.png`
  - Compute Clusters (All-Purpose / Job): `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/compute-clusters.png`
  - Serverless Compute: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/serverless-compute.png`
  - Databricks Runtime (DBR / ML): `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/databricks-runtime.png`
  - Apache Spark: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/apache-spark.png`
  - Photon Engine: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/photon.png`
- **Databricks Governance, Security & Storage**:
  - Unity Catalog: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/unity-catalog.png`
  - Enterprise Security (PrivateLink / CMK / Network Isolation): `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/enterprise-security.png`
  - Attribute-Based Access Control (ABAC): `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/abac.png`
  - Data Lineage: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/data-lineage.png`
  - System Tables: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/system-tables.png`
  - Delta Lake: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/delta-lake.png`
  - Lakehouse Storage (Managed Delta / Iceberg Tables): `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/lakehouse-storage.png`
  - Delta Sharing: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/delta-sharing.png`
- **Databricks SQL, Data Engineering & AI**:
  - SQL Warehouse: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/sql-warehouse.png`
  - Databricks SQL: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/databricks-sql.png`
  - AI/BI Dashboards: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/ai-bi-dashboards.png`
  - Lakeflow (Data Engineering Suite): `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/lakeflow.png`
  - Lakeflow Jobs (Workflows): `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/lakeflow-jobs.png`
  - Lakeflow Declarative Pipelines (Delta Live Tables): `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/spark-declarative-pipelines.png`
  - Auto Loader: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/auto-loader.png`
  - MLflow: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/mlflow.png`
  - Model Serving: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/model-serving.png`
- **Databricks DevTools & Automation**:
  - Databricks Terraform Provider: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/terraform-provider.png`
  - Databricks Asset Bundles: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/asset-bundles.png`
  - Collaborative Notebooks: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/notebooks.png`
  - Git Folders (Repos): `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/git-folders.png`
  - Databricks CLI: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/databricks-cli.png`
  - REST API: `https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/rest-api.png`
- **AWS General & Identity**:
  - Users / Data Engineers: `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/users.png`
  - Cloud / General AWS Service: `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/general.png`
  - Public Internet / External SaaS: `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/internet-alt1.png`
- **AWS Networking**:
  - Virtual Private Cloud (VPC): `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/vpc.png`
  - Transit Gateway (TGW): `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/transit-gateway.png`
  - Internet Gateway (IGW): `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/internet-gateway.png`
  - NAT Gateway: `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/nat-gateway.png`
  - PrivateLink: `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/privatelink.png`
  - VPC Endpoints (Interface / Gateway): `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/endpoint.png`
- **AWS Security & Storage**:
  - Identity and Access Management (IAM): `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/identity-and-access-management-iam.png`
  - Simple Storage Service (S3): `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3.png`
  - Key Management Service (KMS): `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/key-management-service.png`
  - AWS Network Firewall / Shield: `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/shield.png`
- **AWS Compute**:
  - EC2 / Spark Worker Instances: `https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/compute/ec2.png`

##### b. Mandatory Resizing, Aspect Ratio & Anti-Flattening Rules
> [!IMPORTANT]
> **Anti-Flattening Protection**: Markdown engines (PyCharm, IntelliJ JCEF, GitHub, GitLab, and browser previewers) apply global CSS resets (e.g., `img { width: 100%; max-width: 100%; }`). Inside Mermaid SVG `<foreignObject>`, this reset forces square icons to stretch horizontally to 100% of the node width while remaining clamped vertically, causing icons to look squashed or flattened like a pancake.

To guarantee perfect 1:1 square proportions and avoid diagram bloat, **strictly adhere to the following rules**:
1. **Declare Both HTML Dimensions AND Inline CSS**:
   Always declare `width`, `height`, AND an explicit inline `style` with `max-width` and `max-height`.
2. **Mandatory Tag Template**:
   ```html
   <img src='<ICON_URL>' width='<SIZE>' height='<SIZE>' style='width:<SIZE>px;height:<SIZE>px;max-width:<SIZE>px;max-height:<SIZE>px;display:block;margin:0 auto;object-fit:contain;' /><br/><b><TITLE></b><br/>(<SUBTITLE>)
   ```
3. **CSS Property Requirements**:
   - `display: block; margin: 0 auto;`: Centers the icon squarely above node text and eliminates inline baseline alignment collapse.
   - `object-fit: contain;`: Enforces strict preservation of the source 1:1 aspect ratio.
   - `max-width:<SIZE>px; max-height:<SIZE>px;`: Overrides global previewer `width: 100%` resets to eliminate horizontal stretching.
4. **Standard Size Hierarchy**:
   - **Primary Architecture Tier (`36px`)**: Level 1 systems/actors (Data Engineers, Databricks Control Plane, AWS Stack) and Level 2 core backbones (Transit Gateway, Databricks Clusters).
     ```html
     <img src='...' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' />
     ```
   - **Secondary Network & Security Tier (`32px`)**: Gateways and perimeter services (IGW, NAT, Network Firewall, PrivateLink, S3 Endpoint).
     ```html
     <img src='...' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' />
     ```
   - **Component & Module Inventory Tier (`28px`)**: Subnets in Level 2 and Terraform module inventory boxes in Level 3.
     ```html
     <img src='...' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' />
     ```

---

## 5. Project Standards & Best Practices

- **Security First**:
  - Enforce server-side encryption with customer-managed KMS keys where applicable.
  - Enforce least privilege in IAM and KMS key policies.
  - Block public access on all S3 buckets by default unless explicitly intended.
- **Unity Catalog Governance Integrity**:
  - Maintain a strict single metastore per region model across all attached workspaces.
  - Isolate metastore root storage from catalog-specific storage roots to enforce multi-tenant and multi-environment boundaries.
  - Prevent IAM race conditions during cross-account role validation by using explicit `time_sleep` delays (at least 20 seconds).
  - Never run automated pipelines using individual user accounts or the account owner; use a dedicated Service Principal with OAuth M2M.
- **Networking Integrity**:
  - Maintain strict separation of concerns between Hub VPC (Transit Gateway, Network Firewall, NAT Gateways, Internet Gateway) and Spoke VPCs (Databricks Workspace compute and storage subnets).
  - Ensure all Databricks control plane and storage traffic routes through the firewall or VPC endpoints as dictated by the architecture guide.
  - For back-end private connectivity to the Databricks control plane, strictly provision the required AWS PrivateLink interface VPC endpoints and register them with Databricks Account MWS resources according to the authoritative guides.
- **State Management**:
  - Terraform remote state is stored in versioned, KMS-encrypted S3 buckets with DynamoDB state locking (`LockID` attribute) or S3 native lockfiles (`use_lockfile = true`).
- **CI/CD & GitHub Actions Deployments**:
  - Ground all workflow configurations, action plugins, OIDC authentication, and deployment automation in the official [GitHub Actions Documentation](https://docs.github.com/en/actions).
  - Retain all original pipeline jobs and steps (Pre-commit checks, Terraform Validate & Plan with plan caching, and Terraform Apply gated by Environment protection rules).
- **Code Organization**:
  - Follow modular architecture in `modules/` with isolated environments in `environments/<env>/` .
  - Maintain consistent file structure (`main.tf`, `variables.tf`, `locals.tf`, `outputs.tf` (only when active downstream consumers exist; delete if empty/unneeded), `README.md`, `TERRAFORM.md`).
- **Formatting & Validation**:
  - Run `terraform fmt -recursive` and validate against configured linters (TFLint, Trivy, Checkov).

---

## 6. Repository Scaffolding, Module Architecture & Operational Guardrails

### A. Mandatory Base Repository Template (Absolute Requirement)
> [!IMPORTANT]
> **Base Template Requirement**: Whenever building a new repository for Databricks / AWS infrastructure, using this repository as the base template is an **absolute requirement**:
> - **Template Repository URL**: [https://github.com/MikolajSedek/databricks_aws_deployment_01_vpc_networking](https://github.com/MikolajSedek/databricks_aws_deployment_01_vpc_networking)
> - **Replication Scope**: Replicate the foundational repository structure, CI/CD GitHub Actions pipelines, pre-commit hook suites (`pre-commit`), security/linter configurations ([`.tflint.hcl`](file:///.tflint.hcl), [`.trivyignore`](file:///.trivyignore)), documentation templates ([`.ai/README_TEMPLATE.md`](file:///.ai/README_TEMPLATE.md)), and governance instructions ([`.ai/instructions.md`](file:///.ai/instructions.md)).

### B. Module Categorization & Functional Hierarchy
- **Functional Grouping (Not Technology)**:
  - Add new folders under `modules/` based strictly on **business and infrastructure functionality**, **never by raw technology or resource type**.
  - **Correct (Functional)**: `modules/01.networking/`, `modules/02.security/`, `modules/03.storage/`.
  - **Incorrect (Technological)**: `modules/ec2/`, `modules/s3/`, `modules/iam/`, `modules/databricks/`.
- **Subfolder Structure & Numbering**:
  - Place all new modules within `modules/{category_number.functionality}/{module_number.module_name}/` using zero-padded sequential prefixes.
  - Examples:
    - `modules/01.networking/001.generic_vpc/`
    - `modules/01.networking/002.spoke_vpc/`
    - `modules/02.security/001.kms_key/`
    - `modules/03.storage/001.env_backend_bucket/`
- **DRY vs. Pragmatism**:
  - Keep HCL code **DRY** (Don't Repeat Yourself) through reusable variables, locals, and submodules.
  - **Avoid over-engineering**: Do not introduce unnecessary layers of indirection, excessive meta-arguments, or rigid abstractions that obscure readability and maintenance.

### C. Module & Environment File Structure Rules
When creating any new module or root environment, strictly follow this standard file layout:
- **`variables.tf`** (*Required*): All input variable definitions with explicit `type`, `description`, and appropriate `validation` blocks.
- **`main.tf`** (*Required*): Core primary resource declarations.
- **`locals.tf`** (*Optional*): Internal computations, mapped tags, and transformed data structures.
- **`outputs.tf`** (*Optional*): Return values and attributes strictly exported for consumption by downstream modules, external systems, or automation pipelines. Never declare speculative, unused, or duplicate outputs. **If no active downstream consumers exist, omit or delete `outputs.tf` entirely** (especially in root environments under `environments/<env>/`).
- **Extra Functional Files**:
  - Break resources into additional dedicated files named by functionality to keep `main.tf` modular and compact (e.g., `vpc_spoke_endpoints.tf`, `vpc_spoke_route_tables.tf`, `vpc_spoke_security_groups.tf`, `network_firewall_rule_groups.tf`).
- **File Length Limit**:
  - Keep `main.tf` compact: **avoid any `main.tf` exceeding 250 lines**.

### D. Output Minimization & Anti-Redundancy Rule (Strictly Enforced)
- **Universal Scope (Modules & Environments)**:
  - This rule applies equally to reusable child modules (`modules/`) and root deployment environments (`environments/<env>/`).
- **Downstream-Driven Exports Only**:
  - Every module or environment output must be actively consumed by a downstream module, parent environment, root orchestrator, external automation pipeline (e.g., CI/CD workflow steps), or remote state reader (`terraform_remote_state`).
- **Delete `outputs.tf` When Unneeded in Environments & Modules**:
  - If a module or root environment does not require outputs for downstream consumption or automation, **do not keep an empty, commented-out, or speculative `outputs.tf` file—delete the `outputs.tf` file entirely**.
- **No Speculative or Display-Only Outputs**:
  - Never export resource attributes "just in case", for speculative future requirements, or merely for manual terminal inspection. If no active resource, data source, calling module, or automated pipeline consumes `module.<name>.<output>` or an environment output, it must not exist.
  - **No Redundant / Duplicate Formats**: Avoid exporting both granular scalar attributes and compound objects/maps containing the identical data unless strictly required by downstream consumers with differing consumption models.
  - **Audit and Prune on Refactor**: Whenever refactoring inputs, resources, dependencies, or environments, immediately audit all outputs across modified modules and environments. Remove any orphaned outputs, and delete `outputs.tf` if zero active outputs remain.
  - **Documentation Alignment**: Keep `README.md` and generated `TERRAFORM.md` in sync across both modules and environments whenever outputs are added, modified, or pruned (regenerate via `terraform-docs`).

### E. Authoritative Verification & Anti-Hallucination Policy
- **Authoritative Source Verification**:
  - Always use official, authoritative AWS and Databricks documentation and repositories (including [Official Databricks GitHub Repositories](https://github.com/orgs/databricks/repositories?type=all), [Databricks Terraform Provider Examples](https://github.com/databricks/terraform-databricks-examples), and [Unity Catalog Automation Guides](https://docs.databricks.com/aws/en/dev-tools/terraform/automate-uc) — when deploying with AWS, use only AWS examples) when creating new Terraform code for any repository.
  - Verify every resource, block type, argument name, and behavior against official documentation or live MCP tools (`aws-docs`, `terraform`).
  - **Strict Anti-Hallucination**: Do not guess or invent resource arguments, attributes, or default values.
- **Databricks Provider Scopes (Account-Level vs. Workspace-Level)**:
  - Be explicitly aware that Databricks resources require different provider scopes:
    - **Workspace-Level Provider** (`host = https://<workspace-instance>.cloud.databricks.com/`): Used for:
      - Unity Catalog governance objects: `databricks_storage_credential` (AWS IAM role ARN mapping for external storage), `databricks_external_location` (binding S3 URI to storage credentials), `databricks_catalog` (with optional dedicated `storage_root`), `databricks_schema`, `databricks_volume`, `databricks_table`, and fine-grained `databricks_grants`.
      - Workspace compute & workloads: clusters (`databricks_cluster` configured with `data_security_mode = "USER_ISOLATION"` or `"SINGLE_USER"`), SQL Warehouses, notebooks, jobs, pipelines, repos, secret scopes, and permissions.
    - **Account-Level Provider** (`host = "https://accounts.cloud.databricks.com"`, `account_id = var.databricks_account_id`): Required for account-level provisioning including:
      - Unity Catalog metastores & bindings: `databricks_metastore` (single metastore per AWS region), `databricks_metastore_data_access` (default storage credential linking AWS IAM role to metastore), `databricks_metastore_assignment` (binding workspace IDs to the regional metastore).
      - Account identities & roles: `databricks_user`, `databricks_group`, `databricks_group_member`, `databricks_user_role`.
      - MWS network and workspace infrastructure: MWS networks (`databricks_mws_networks`), storage configurations (`databricks_mws_storage_configurations`), credentials (`databricks_mws_credentials`), workspaces (`databricks_mws_workspaces`), and **Control Plane Private Connectivity resources**:
        - `databricks_mws_vpc_endpoint`: Registers AWS PrivateLink interface VPC endpoints (workspace REST API and secure cluster connectivity relay) with Databricks Account MWS.
        - `databricks_mws_private_access_settings`: Defines Private Access Settings (PAS) governing public access flags, allowed VPC endpoint IDs, and private access levels (`ACCOUNT` or `ENDPOINT`).
        - `databricks_mws_networks` (`vpc_endpoints` block): Binds registered VPC endpoints (`rest_api` and `dataplane_relay`) to the customer-managed VPC network configuration.
        - `databricks_mws_workspaces` (`private_access_settings_id` attribute): Links Private Access Settings to the workspace instance.
  - **Unity Catalog Environment Variables & Variables Scaffolding (`environments/dev/variables.tf`)**:
    - Root deployment environments must declare standardized, validated input variables for Unity Catalog:
      - Target AWS settings: `aws_region`, `aws_account_id`, `profile`, `environment`.
      - Databricks OAuth M2M credentials: `service_principal_id`, `service_principal_secret`, `databricks_account_id`.
      - Unity Catalog governance: `unity_admin_group` (metastore owner group), `databricks_metastore_admins` (list of admin emails), `databricks_users` (list of user emails), `databricks_workspace_ids` (workspace IDs for metastore binding).
    - All variables in `environments/dev/variables.tf` must include explicit `type`, `description`, and strict regex/contains `validation` blocks where appropriate.
  - **Control Plane Private Connectivity Architecture (AWS PrivateLink)**:
    - Ground all private connectivity designs in the [Databricks AWS PrivateLink Workspace Guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-private-link-workspace) and [Databricks Classic Private Connectivity Documentation](https://docs.databricks.com/aws/en/security/network/classic/privatelink).
    - Maintain strict separation between AWS Cloud provider resources (`aws_vpc_endpoint`, dedicated VPC endpoint subnets, security groups) and Databricks Account MWS provider resources (`databricks_mws_vpc_endpoint`, `databricks_mws_private_access_settings`, `databricks_mws_networks`, `databricks_mws_workspaces`).
  - **Databricks AWS Workspace & Unity Catalog Provisioning Routing**:
    - For all workspace provisioning patterns, refer to the [`.ai/skills/databricks-aws-workspace/SKILL.md`](./skills/databricks-aws-workspace/SKILL.md) skill.
    - For all Unity Catalog metastore, storage, and governance patterns, refer to the [`.ai/skills/databricks-aws-unity-catalog/SKILL.md`](./skills/databricks-aws-unity-catalog/SKILL.md) skill.
    - Follow the strict separation rule between account-level creation modules (`provider = databricks.mws`) and downstream workspace management modules (`provider = databricks`).
  - **Never guess provider scopes**: Always check the official [Databricks Terraform Provider Documentation](https://registry.terraform.io/providers/databricks/databricks/latest/docs) to determine whether a resource operates at the account or workspace level.

### F. Pre-Commit Execution, Documentation & Exception Handling
- **Pre-Commit Execution**:
  - Always execute pre-commit checks (`pre-commit run --all-files`) against newly created or modified code to validate formatting, linting, and security compliance.
- **Module README Generation**:
  - Provide a comprehensive `README.md` for each module adhering to the authoritative template ([`.ai/README_TEMPLATE.md`](file:///.ai/README_TEMPLATE.md)).
  - Ensure the corresponding `TERRAFORM.md` is generated and up-to-date (via `terraform-docs`).
- **Clear Documentation of Security Exceptions**:
  - If a security or linting exception is required (e.g., in [`.trivyignore`](file:///.trivyignore), [`.tflint.hcl`](file:///.tflint.hcl), or checkov skip comments), **always document it clearly and comprehensively**.
  - Document the Rule ID, Description, Target Resource, and detailed Justification covering:
    1. Functional requirement.
    2. Cloud provider / tooling limitation.
    3. Compensating security control (see [`.trivyignore`](file:///.trivyignore) for reference format).

### G. Verification & Operational Guardrails
- **Terraform Verification / Validation**:
  - At the end of implementation, always run `terraform validate` (`terraform verify`) across all modified modules and environments to ensure structural and syntactic validity.
- **Strict Apply Guardrail**:
  > [!CAUTION]
  > **NEVER run `terraform apply` without clear, explicit user consent.**
