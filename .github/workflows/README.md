# GitHub Actions CI/CD Deployment Workflows

[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=github-actions)](https://docs.github.com/en/actions)
[![Terraform](https://img.shields.io/badge/Terraform-1.16.3-623CE4?logo=terraform)](https://developer.hashicorp.com/terraform/docs)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-6.66.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
[![Databricks Provider](https://img.shields.io/badge/Databricks_Provider-1.135.0-FF3621?logo=databricks)](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
[![Astral uv](https://img.shields.io/badge/uv-Package_Manager-DE5FE9?logo=python)](https://github.com/astral-sh/uv)

---

## 1. Executive Summary

- **Purpose & Scope**:
  This directory contains the GitHub Actions automation pipelines powering continuous integration, automated validation, and continuous delivery for **Databricks Unity Catalog Governance** on AWS. It implements an enterprise multi-tier workflow model ensuring all commits across all branches are validated and planned, while infrastructure deployments (`apply`) execute under manual GitHub Environment approvals.
- **Unified Deployment Architecture**:
  The project deploys all components—remote S3 backend state, dedicated customer-managed KMS keys, hardened S3 root and external volume buckets, the regional Unity Catalog metastore with least-privilege IAM roles, multi-workspace metastore assignments, domain-isolated and shared catalogs with workspace bindings, 3-level namespace schemas, managed and optional external volumes, native Unity Catalog secrets (`databricks_secret_uc`), and Open Delta Sharing shares and recipients—via a single, unified `terraform plan` and `terraform apply`.
- **Plan Immutability & Environment Gates**:
  1. **Speculative Planning**: [`dpl-02-plan.yml`](./dpl-02-plan.yml) runs static analysis, initializes Terraform, validates configurations, and generates a binary plan artifact (`dev-tfplan`).
  2. **Gated Deployment**: [`dpl-03-apply.yml`](./dpl-03-apply.yml) downloads the exact binary plan artifact and applies it within the `dev` GitHub Environment.
  3. **Unified Pipeline Orchestrator**: [`deploy-dev.yml`](./deploy-dev.yml) coordinates pre-commit quality checks, speculative planning, and deployment apply seamlessly.

---

## 2. Workflow Orchestration & Operational Flow

### 2.1 Pipeline Lifecycle & Flow

```mermaid
flowchart TD
    classDef trigger fill:#ECEFF1,stroke:#455A64,stroke-width:1.5px,color:#263238;
    classDef stage fill:#E1F5FE,stroke:#0288D1,stroke-width:1.5px,color:#01579B;
    classDef gate fill:#FFF3E0,stroke:#E65100,stroke-width:1.5px,color:#BF360C;
    classDef finish fill:#E8F5E9,stroke:#2E7D32,stroke-width:1.5px,color:#1B5E20;

    Trigger["Push (All Branches) / PR (main) / Dispatch"]:::trigger
    Precommit["Step 0: Pre-commit Quality & Security Checks<br/>(Formatting, TFLint, Gitleaks, Trivy)"]:::stage
    Plan["Step 1: dpl-02-plan.yml<br/>(Speculative Plan & Artifact Upload)"]:::stage
    Gate["Environment Gate: dev<br/>(Required Reviewers Approval)"]:::gate
    Apply["Step 2: dpl-03-apply.yml<br/>(Terraform Apply tfplan)"]:::stage
    Done["Deployment Complete"]:::finish

    Trigger --> Precommit
    Precommit --> Plan
    Plan -->|"dev-tfplan"| Gate
    Gate -->|"Approved (main branch)"| Apply
    Apply --> Done
```

### 2.2 Trigger & Branching Strategy

| Event | Target Branches | Workflow | Plan Phase | Apply Phase |
|:---|:---:|:---|:---:|:---:|
| `push` | Any branch (`**`) | `deploy-dev.yml` | Runs Speculative Plan | **No** (Skipped on feature branches; executes on `main` under approval gates) |
| `pull_request` | `main` | `deploy-dev.yml` | Runs Speculative Plan (summary attached to Job Summary) | **No** (Plan only; apply runs upon PR merge to `main`) |
| `workflow_dispatch` | Selected branch | `deploy-dev.yml` | Runs Speculative Plan | Runs Apply on `main` or if `auto_apply: true` (gated by Environment Approval) |

---

## 3. Workflow Architecture & Reusable Modules

```mermaid
graph TD
    classDef root fill:#ECEFF1,stroke:#37474F,stroke-width:2px,color:#212121;
    classDef subwf fill:#E8F5E9,stroke:#2E7D32,stroke-width:1.5px,color:#1B5E20;

    DeployDev["<b>deploy-dev.yml</b><br/>(Root Orchestrator)"]:::root
    Precommit["<b>dpl-01-precommit.yml</b><br/>(Quality & Security Checks)"]:::subwf
    Plan["<b>dpl-02-plan.yml</b><br/>(Terraform Validate & Plan)"]:::subwf
    Apply["<b>dpl-03-apply.yml</b><br/>(Terraform Apply)"]:::subwf

    DeployDev -->|"job: precommit"| Precommit
    DeployDev -->|"job: plan"| Plan
    DeployDev -->|"job: apply"| Apply
```

---

## 4. Workflow Inventory

| Workflow File | Trigger Type | Primary Role | Key Inputs / Defaults |
|:---|:---:|:---|:---|
| [`deploy-dev.yml`](./deploy-dev.yml) | `push`, `pull_request`, `workflow_dispatch` | Unified pipeline coordinating pre-commit checks, planning, and gated apply | `auto_apply: false` |
| [`dpl-01-precommit.yml`](./dpl-01-precommit.yml) | `workflow_call` | Runs linting, syntax formatting, and multi-engine security scans | `terraform_version: 1.16.3`, `tflint_version: latest`, `trivy_version: latest` |
| [`dpl-02-plan.yml`](./dpl-02-plan.yml) | `workflow_call` | Validates configuration, runs `terraform plan`, and uploads binary plan artifact | `working_directory: environments/dev`, `environment: dev`, `plan_artifact_name: dev-tfplan` |
| [`dpl-03-apply.yml`](./dpl-03-apply.yml) | `workflow_call` | Downloads plan artifact and executes `terraform apply` under environment gates | `working_directory: environments/dev`, `environment: dev`, `plan_artifact_name: dev-tfplan` |

---

## 5. Required Secrets and Variables

Configure the following secrets in GitHub (**Settings** $\rightarrow$ **Secrets and variables** $\rightarrow$ **Actions**):

### 5.1 AWS Infrastructure Secrets

| Secret Name | Required | Description | Example / Format |
|:---|:---:|:---|:---|
| `AWS_ACCESS_KEY_ID` | **Yes** | AWS IAM User access key ID for deployment automation | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | **Yes** | AWS IAM User secret access key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_SESSION_TOKEN` | Optional | Session token when using temporary AWS STS credentials | `AQoDYXdzEJr...` |
| `AWS_ACCOUNT_ID` | **Yes** | 12-digit target AWS Account ID (enforces account guardrail) | `419259485595` |
| `AWS_REGION` | Optional | Target AWS deployment region (defaults to `eu-central-1`) | `eu-central-1` |
| `AWS_PROFILE_ROLE_ARN` | Optional | IAM Role ARN to assume for the `production-admin` profile | `arn:aws:iam::419259485595:role/TerraformDeploymentRole` |

### 5.2 Databricks Platform Secrets

| Secret Name | Required | Description | Example / Format |
|:---|:---:|:---|:---|
| `DATABRICKS_ACCOUNT_ID` | **Yes** | Databricks Account ID (UUID format) from Account Console | `1980a5a1-023b-4929-9d42-9bc0f468d719` |
| `DATABRICKS_CLIENT_ID` | **Yes** | OAuth Service Principal Client ID with Account Admin & Metastore Admin privileges | `b6dd846d-1567-469e-a05b-b99eaf76de93` |
| `DATABRICKS_CLIENT_SECRET` | **Yes** | OAuth Service Principal Secret | Sensitive OAuth secret string |

> [!NOTE]
> The workflows also support `DATABRICKS_SERVICE_PRINCIPAL_ID` and `DATABRICKS_SERVICE_PRINCIPAL_SECRET` as alternative secret names.

### 5.3 GitHub Environment Configuration

To enable manual review protection before applying changes to AWS and Databricks:
1. Navigate to **Settings** $\rightarrow$ **Environments** in your GitHub repository.
2. Click **New environment** and enter name: `dev`.
3. Under **Deployment protection rules**, enable **Required reviewers** and assign designated platform engineers / reviewers.
4. (Optional) Under **Deployment branches**, restrict deployment to `main` only.

---

## 6. Important Links and Resources

### 6.1 Authoritative Documentation
- [GitHub Actions Documentation](https://docs.github.com/en/actions) - Official GitHub Actions documentation.
- [HashiCorp Setup Terraform Action](https://github.com/hashicorp/setup-terraform) - Official Terraform installer action.
- [AWS Configure AWS Credentials Action](https://github.com/aws-actions/configure-aws-credentials) - Official AWS credential provider action.
- [Astral Setup uv Action](https://github.com/astral-sh/setup-uv) - Python package and tool installer action.
- [TFLint GitHub Action](https://github.com/terraform-linters/setup-tflint) - TFLint installer action.
- [Aqua Security Setup Trivy Action](https://github.com/aquasecurity/setup-trivy) - Trivy security scanner action.
- [Databricks Terraform Provider Documentation](https://registry.terraform.io/providers/databricks/databricks/latest/docs) - Databricks provider schema reference.

### 6.2 Internal References
- [Root Deployment Pipeline](./deploy-dev.yml)
- [Pre-commit Quality & Security Workflow](./dpl-01-precommit.yml)
- [Plan Workflow](./dpl-02-plan.yml)
- [Apply Workflow](./dpl-03-apply.yml)
- [Root Deployment Runbook](../../README.md#6-deployment-runbook)
- [Dev Environment Terraform Code](../../environments/dev)
- [Project Instructions & Source of Truth](../../.ai/instructions.md)
