/*
  Local Values Configuration - Dev Environment
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals
    - https://docs.databricks.com/aws/en/data-governance/unity-catalog/get-started

  Centralizes project metadata, naming conventions, workspace lookups, and the
  complete 3-level Unity Catalog governance model for the dev environment:
    - Naming convention: {owner}-dbx-dep-{component}-{env}
    - Shared Unity Catalog metastore root S3 bucket (no separate buckets per catalog)
    - Optional external S3 bucket for external volumes
    - Existing workspace resolution (Data Engineering, Data Science, Data Analytics)
    - Catalogs with ISOLATED/OPEN modes, workspace attachments, and RBAC grants
    - Medallion and functional schemas with RBAC grants
    - Managed and External volumes with RBAC grants
    - Native Unity Catalog secrets (databricks_secret_uc) and workspace secret scopes
    - Basic Open Delta Sharing shares, TOKEN recipients, and SELECT grants
*/

locals {
  /* 1. Environment and Project Metadata */
  owner           = "msedek"
  env             = var.environment
  project_name    = "${local.owner}-dbx-dep"
  subproject_name = "unity-catalog"

  backend_bucket_name         = "${local.project_name}-${local.subproject_name}-s3-backend"
  uc_root_bucket_base_name    = "${local.project_name}-uc-metastore-root"
  uc_ext_vol_bucket_base_name = "${local.project_name}-uc-external-volumes"

  metastore_name         = "${local.project_name}-metastore-${var.aws_region}-${local.env}"
  metastore_iam_role     = "${local.project_name}-uc-metastore-role-${local.env}"
  external_vol_iam_role  = "${local.project_name}-uc-ext-volumes-role-${local.env}"
  external_location_name = "${local.project_name}-ext-volumes-loc-${local.env}"

  /* 2. Account-Level Identity Groups (Resolved from Project 02) */
  admin_group_name          = data.databricks_group.platform_admins.display_name
  data_engineers_group_name = data.databricks_group.data_engineers.display_name
  data_scientists_group     = data.databricks_group.data_scientists.display_name
  data_analysts_group_name  = data.databricks_group.data_analysts.display_name

  /* 3. Existing Workspaces Map (Resolved dynamically from Project 03 via Account MWS) */
  workspace_names = {
    data_engineering = "${local.project_name}-data-eng-${local.env}"
    data_science     = "${local.project_name}-data-science-${local.env}"
    data_analytics   = "${local.project_name}-data-analytics-${local.env}"
  }

  workspace_ids = {
    for k, ws_name in local.workspace_names :
    k => data.databricks_mws_workspaces.all.ids[ws_name]
  }

  governance_workspace_url = coalesce(var.governance_workspace_url, data.databricks_current_user.data_engineering.workspace_url)

  /* 4. Extra Customer-Managed KMS Keys (UC Metastore Root & External Volumes) */
  extra_kms_keys = {
    uc_root = {
      alias       = "dbx_uc_metastore_root_kms_key"
      description = "Customer-managed KMS key for Unity Catalog metastore root S3 bucket"
    }
    uc_external_volumes = {
      alias       = "dbx_uc_external_volumes_kms_key"
      description = "Customer-managed KMS key for Unity Catalog external volumes S3 bucket"
    }
  }

  /* 5. Unity Catalog Catalogs, Workspace Bindings & RBAC */
  catalogs = {
    data_engineering = {
      name            = "data_engineering_${local.env}"
      comment         = "Data Engineering catalog for raw ingestion and medallion ETL pipelines"
      isolation_mode  = "ISOLATED"
      storage_subpath = null
      properties = {
        domain      = "data-engineering"
        environment = local.env
        managed_by  = "terraform"
      }
      workspace_bindings = [
        {
          workspace_id = local.workspace_ids["data_engineering"]
          binding_type = "BINDING_TYPE_READ_WRITE"
        },
        {
          workspace_id = local.workspace_ids["data_science"]
          binding_type = "BINDING_TYPE_READ_ONLY"
        },
        {
          workspace_id = local.workspace_ids["data_analytics"]
          binding_type = "BINDING_TYPE_READ_ONLY"
        }
      ]
      grants = [
        {
          principal  = local.admin_group_name
          privileges = ["ALL_PRIVILEGES", "MANAGE"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "SELECT"]
        },
        {
          principal  = local.data_scientists_group
          privileges = ["USE_CATALOG", "SELECT"]
        },
        {
          principal  = local.data_analysts_group_name
          privileges = ["USE_CATALOG", "SELECT"]
        }
      ]
    }

    data_science = {
      name            = "data_science_${local.env}"
      comment         = "Data Science catalog for feature tables, ML experiments, and model registries"
      isolation_mode  = "ISOLATED"
      storage_subpath = null
      properties = {
        domain      = "data-science"
        environment = local.env
        managed_by  = "terraform"
      }
      workspace_bindings = [
        {
          workspace_id = local.workspace_ids["data_science"]
          binding_type = "BINDING_TYPE_READ_WRITE"
        },
        {
          workspace_id = local.workspace_ids["data_engineering"]
          binding_type = "BINDING_TYPE_READ_WRITE"
        }
      ]
      grants = [
        {
          principal  = local.admin_group_name
          privileges = ["ALL_PRIVILEGES", "MANAGE"]
        },
        {
          principal  = local.data_scientists_group
          privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE", "CREATE_VOLUME", "CREATE_FUNCTION", "EXECUTE", "MODIFY", "SELECT"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
        }
      ]
    }

    data_analytics = {
      name            = "data_analytics_${local.env}"
      comment         = "Data Analytics catalog for curated BI marts, semantic views, and executive dashboards"
      isolation_mode  = "ISOLATED"
      storage_subpath = null
      properties = {
        domain      = "data-analytics"
        environment = local.env
        managed_by  = "terraform"
      }
      workspace_bindings = [
        {
          workspace_id = local.workspace_ids["data_analytics"]
          binding_type = "BINDING_TYPE_READ_WRITE"
        },
        {
          workspace_id = local.workspace_ids["data_engineering"]
          binding_type = "BINDING_TYPE_READ_WRITE"
        }
      ]
      grants = [
        {
          principal  = local.admin_group_name
          privileges = ["ALL_PRIVILEGES", "MANAGE"]
        },
        {
          principal  = local.data_analysts_group_name
          privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_TABLE", "SELECT"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE", "MODIFY", "SELECT"]
        }
      ]
    }

    shared_enterprise = {
      name            = "shared_enterprise_${local.env}"
      comment         = "Cross-workspace shared enterprise catalog for reference data, UC secrets, and Delta Sharing"
      isolation_mode  = "OPEN"
      storage_subpath = null
      properties = {
        domain      = "enterprise-shared"
        environment = local.env
        managed_by  = "terraform"
      }
      workspace_bindings = []
      grants = [
        {
          principal  = local.admin_group_name
          privileges = ["ALL_PRIVILEGES", "MANAGE"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
        },
        {
          principal  = local.data_scientists_group
          privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
        },
        {
          principal  = local.data_analysts_group_name
          privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
        }
      ]
    }
  }

  /* 6. Unity Catalog Schemas (2nd-Level Namespace) & RBAC */
  schemas = {
    de_raw_ingestion = {
      catalog_key = "data_engineering"
      name        = "raw_ingestion"
      comment     = "Raw landing zone for external source systems and streaming ingestion"
      properties  = { layer = "landing" }
      grants = [
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_SCHEMA", "CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "SELECT", "READ_VOLUME", "WRITE_VOLUME"]
        }
      ]
    }

    de_bronze = {
      catalog_key = "data_engineering"
      name        = "bronze"
      comment     = "Bronze medallion layer storing raw historical Delta tables"
      properties  = { layer = "bronze" }
      grants = [
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_SCHEMA", "CREATE_TABLE", "MODIFY", "SELECT"]
        }
      ]
    }

    de_silver = {
      catalog_key = "data_engineering"
      name        = "silver"
      comment     = "Silver medallion layer storing cleansed, conformed, and deduplicated datasets"
      properties  = { layer = "silver" }
      grants = [
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_SCHEMA", "CREATE_TABLE", "MODIFY", "SELECT"]
        },
        {
          principal  = local.data_scientists_group
          privileges = ["USE_SCHEMA", "SELECT"]
        }
      ]
    }

    de_gold = {
      catalog_key = "data_engineering"
      name        = "gold"
      comment     = "Gold medallion layer storing business-ready aggregates"
      properties  = { layer = "gold" }
      grants = [
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_SCHEMA", "CREATE_TABLE", "MODIFY", "SELECT"]
        },
        {
          principal  = local.data_scientists_group
          privileges = ["USE_SCHEMA", "SELECT"]
        },
        {
          principal  = local.data_analysts_group_name
          privileges = ["USE_SCHEMA", "SELECT"]
        }
      ]
    }

    ds_feature_store = {
      catalog_key = "data_science"
      name        = "feature_store"
      comment     = "Curated feature tables and transformation functions for ML pipelines"
      properties  = { domain = "ml-features" }
      grants = [
        {
          principal  = local.data_scientists_group
          privileges = ["USE_SCHEMA", "CREATE_TABLE", "CREATE_FUNCTION", "EXECUTE", "MODIFY", "SELECT"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_SCHEMA", "SELECT"]
        }
      ]
    }

    ds_ml_artifacts = {
      catalog_key = "data_science"
      name        = "ml_artifacts"
      comment     = "Schema hosting model training artifacts, checkpoints, and unmanaged datasets"
      properties  = { domain = "ml-artifacts" }
      grants = [
        {
          principal  = local.data_scientists_group
          privileges = ["USE_SCHEMA", "CREATE_TABLE", "CREATE_VOLUME", "READ_VOLUME", "WRITE_VOLUME", "MODIFY", "SELECT"]
        }
      ]
    }

    da_bi_reporting = {
      catalog_key = "data_analytics"
      name        = "bi_reporting"
      comment     = "Curated reporting tables, KPIs, and exports for BI dashboards"
      properties  = { domain = "bi-reporting" }
      grants = [
        {
          principal  = local.data_analysts_group_name
          privileges = ["USE_SCHEMA", "CREATE_TABLE", "SELECT", "READ_VOLUME"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_SCHEMA", "CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "SELECT", "READ_VOLUME", "WRITE_VOLUME"]
        }
      ]
    }

    shared_external_sharing = {
      catalog_key = "shared_enterprise"
      name        = "external_sharing"
      comment     = "Curated schema dedicated to Open Delta Sharing products"
      properties  = { domain = "delta-sharing" }
      grants = [
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_SCHEMA", "CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "SELECT", "READ_VOLUME", "WRITE_VOLUME"]
        },
        {
          principal  = local.data_analysts_group_name
          privileges = ["USE_SCHEMA", "SELECT", "READ_VOLUME"]
        }
      ]
    }

    shared_security_vault = {
      catalog_key = "shared_enterprise"
      name        = "security_vault"
      comment     = "Centralized schema for governed Unity Catalog secrets (databricks_secret_uc)"
      properties  = { domain = "security-secrets" }
      grants = [
        {
          principal  = local.admin_group_name
          privileges = ["ALL_PRIVILEGES", "MANAGE"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["USE_SCHEMA"]
        },
        {
          principal  = local.data_scientists_group
          privileges = ["USE_SCHEMA"]
        }
      ]
    }
  }

  /* 7. Unity Catalog Volumes (Managed & Optional External) */
  external_locations = {
    raw_dropzone = {
      name          = local.external_location_name
      bucket_name   = module.uc_external_volumes_bucket.bucket_name
      kms_key_arn   = module.extra_kms_keys["uc_external_volumes"].kms_arn
      iam_role_name = local.external_vol_iam_role
      s3_subpath    = "external-volumes"
      comment       = "Governed external S3 location for external Unity Catalog volumes"
      grants = [
        {
          principal  = local.admin_group_name
          privileges = ["ALL_PRIVILEGES", "MANAGE"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["CREATE_EXTERNAL_VOLUME", "READ_FILES", "WRITE_FILES"]
        }
      ]
    }
  }

  volumes = {
    /* Managed Volume 1: Raw Events Landing Zone (Data Engineering) */
    de_raw_events_landing = {
      schema_key  = "de_raw_ingestion"
      name        = "raw_events_landing"
      volume_type = "MANAGED"
      comment     = "Managed Unity Catalog volume for Auto Loader JSON/CSV/Parquet landing files"
      grants = [
        {
          principal  = local.data_engineers_group_name
          privileges = ["READ_VOLUME", "WRITE_VOLUME"]
        }
      ]
    }

    /* Managed Volume 2: ML Model Checkpoints & Artifacts (Data Science) */
    ds_model_checkpoints = {
      schema_key  = "ds_ml_artifacts"
      name        = "model_checkpoints"
      volume_type = "MANAGED"
      comment     = "Managed Unity Catalog volume for ML model weights, tokenizers, and training artifacts"
      grants = [
        {
          principal  = local.data_scientists_group
          privileges = ["READ_VOLUME", "WRITE_VOLUME"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["READ_VOLUME"]
        }
      ]
    }

    /* Managed Volume 3: BI Report Exports (Data Analytics) */
    da_report_exports = {
      schema_key  = "da_bi_reporting"
      name        = "report_exports"
      volume_type = "MANAGED"
      comment     = "Managed Unity Catalog volume for scheduled BI report extracts and static reference files"
      grants = [
        {
          principal  = local.data_analysts_group_name
          privileges = ["READ_VOLUME", "WRITE_VOLUME"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["READ_VOLUME", "WRITE_VOLUME"]
        }
      ]
    }

    /* Managed Volume 4: Shared Partner Data Releases (Shared Enterprise) */
    shared_partner_releases = {
      schema_key  = "shared_external_sharing"
      name        = "partner_data_releases"
      volume_type = "MANAGED"
      comment     = "Managed Unity Catalog volume containing curated data files published via Delta Sharing"
      grants = [
        {
          principal  = local.data_engineers_group_name
          privileges = ["READ_VOLUME", "WRITE_VOLUME"]
        },
        {
          principal  = local.data_analysts_group_name
          privileges = ["READ_VOLUME"]
        }
      ]
    }

    /* External Volume 5: Partner SFTP Dropzone (Data Engineering - External S3 Location) */
    de_partner_external_dropzone = {
      schema_key            = "de_raw_ingestion"
      name                  = "partner_external_dropzone"
      volume_type           = "EXTERNAL"
      external_location_key = "raw_dropzone"
      external_subpath      = "partner-dropzone"
      comment               = "External Unity Catalog volume backed by dedicated external S3 bucket prefix"
      grants = [
        {
          principal  = local.data_engineers_group_name
          privileges = ["READ_VOLUME", "WRITE_VOLUME"]
        },
        {
          principal  = local.data_scientists_group
          privileges = ["READ_VOLUME"]
        }
      ]
    }
  }

  /* 8. Secrets in Unity Catalog (databricks_secret_uc) & Workspace Secret Scopes */
  uc_secrets = {
    external_ingestion_api_key = {
      schema_key = "shared_security_vault"
      name       = "external_ingestion_api_key"
      value      = var.uc_external_api_key_secret
      comment    = "API key for external ingestion partner REST endpoints governed in Unity Catalog"
      grants = [
        {
          principal  = local.admin_group_name
          privileges = ["ALL_PRIVILEGES", "MANAGE"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["READ_SECRET"]
        },
        {
          principal  = local.data_scientists_group
          privileges = ["READ_SECRET"]
        }
      ]
    }

    erp_jdbc_password = {
      schema_key = "de_raw_ingestion"
      name       = "erp_jdbc_password"
      value      = var.uc_jdbc_password_secret
      comment    = "JDBC password for upstream ERP ingestion pipelines governed in Unity Catalog"
      grants = [
        {
          principal  = local.admin_group_name
          privileges = ["ALL_PRIVILEGES", "MANAGE"]
        },
        {
          principal  = local.data_engineers_group_name
          privileges = ["READ_SECRET"]
        }
      ]
    }
  }

  secret_scopes = {
    uc_platform_integrations = {
      scope_name = "uc-platform-integrations-${local.env}"
      secrets = {
        external_api_key = {
          key          = "external_ingestion_api_key"
          string_value = var.uc_external_api_key_secret
        }
      }
      acls = [
        {
          principal  = local.admin_group_name
          permission = "MANAGE"
        },
        {
          principal  = local.data_engineers_group_name
          permission = "READ"
        }
      ]
    }
  }

  /* 9. Basic Open Delta Sharing Configuration */
  open_sharing_recipients = {
    external_analytics_partner = {
      name                 = "ext-analytics-partner-${local.env}"
      comment              = "External analytics partner consuming curated shared datasets via Open Delta Sharing token"
      authentication_type  = "TOKEN"
      allowed_ip_addresses = []
      properties = {
        environment = local.env
        tier        = "external-partner"
      }
    }
  }

  open_sharing_shares = {
    enterprise_open_share = {
      name    = "enterprise_open_share_${local.env}"
      comment = "Open Delta Sharing package exposing the shared_enterprise.external_sharing schema and partner volume"
      objects = [
        {
          volume_key       = "shared_partner_releases"
          data_object_type = "VOLUME"
          comment          = "Curated partner data releases volume"
        }
      ]
      recipient_keys = ["external_analytics_partner"]
    }
  }
}
