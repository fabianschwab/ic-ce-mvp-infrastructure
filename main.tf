terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.75.1"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibm_cloud_api_key
  region           = var.ibm_region
}

resource "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "ibm_code_engine_project" "code_engine_project" {
  name              = var.code_engine_project_name
  resource_group_id = ibm_resource_group.group.id
}

module "container_registry" {
  source = "./modules/container-registry"

  container_registry_name = var.container_registry_name
  resource_group_id       = ibm_resource_group.group.id
}

module "postgresql" {
  count  = var.create_postgresql ? 1 : 0
  source = "./modules/postgresql"

  pg_database_name       = var.pg_database_name
  resource_group_id      = ibm_resource_group.group.id
  region                 = var.ibm_region
  pg_database_endpoint   = var.pg_database_endpoint
  code_engine_project_id = ibm_code_engine_project.code_engine_project.id
}

# -----------------------------------------------------------
# ------------------------ Toolchain ------------------------
# -----------------------------------------------------------
resource "ibm_cd_toolchain" "ci_cd_toolchain" {
  name              = var.toolchain
  resource_group_id = ibm_resource_group.group.id
}

# Repository: Connect a git repository to the toolchain
resource "ibm_cd_toolchain_tool_githubconsolidated" "tekton_repository" {

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    type     = "link"
    repo_url = var.repository_url_pipeline
  }
  parameters {
    repo_url = var.repository_url_pipeline
  }
}
resource "ibm_cd_toolchain_tool_githubconsolidated" "tekton_catalog" {

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    type     = "link"
    repo_url = var.repository_url_pipeline_catalog
  }
  parameters {
    repo_url = var.repository_url_pipeline_catalog
  }
}
resource "ibm_cd_toolchain_tool_githubconsolidated" "code_repository" {

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    git_id   = "integrated"
    repo_url = var.code_repository_url
    type     = "link"
  }
  parameters {
    git_id   = "integrated"
    repo_url = var.code_repository_url
    type     = "link"
  }
}

# Delivery: Pipeline
resource "ibm_cd_toolchain_tool_pipeline" "ci_cd_pipeline" {
  parameters {
    name = "ci_cd_pipeline"
  }
  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
}
# -----------------------------------------------------------------
# ------------------------ Tekton Pipeline ------------------------
resource "ibm_cd_tekton_pipeline" "tekton_pipeline" {
  worker {
    id = "public"
  }
  pipeline_id = ibm_cd_toolchain_tool_pipeline.ci_cd_pipeline.tool_id
}

# ------------------------ Tekton Definition ------------------------
# Tekton pipeline definition, this holds the Tekton files of the build pipeline
resource "ibm_cd_tekton_pipeline_definition" "cd_tekton_pipeline_definition_instance_tasks" {
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  source {
    type = "git"
    properties {
      url    = var.repository_url_pipeline
      branch = "main"
      path   = "./tekton/tasks"
    }
  }
}
resource "ibm_cd_tekton_pipeline_definition" "cd_tekton_pipeline_definition_instance_cicd" {
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  source {
    type = "git"
    properties {
      url    = var.repository_url_pipeline
      branch = "main"
      path   = "./tekton/cicd"
    }
  }
}
resource "ibm_cd_tekton_pipeline_definition" "cd_tekton_pipeline_definition_instance_common_01" {
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  source {
    type = "git"
    properties {
      url    = var.repository_url_pipeline_catalog
      branch = "main"
      path   = "./toolchain"
    }
  }
}
resource "ibm_cd_tekton_pipeline_definition" "cd_tekton_pipeline_definition_instance_common_02" {
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  source {
    type = "git"
    properties {
      url    = var.repository_url_pipeline_catalog
      branch = "main"
      path   = "./git"
    }
  }
}
resource "ibm_cd_tekton_pipeline_definition" "cd_tekton_pipeline_definition_instance_common_03" {
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  source {
    type = "git"
    properties {
      url    = var.repository_url_pipeline_catalog
      branch = "main"
      path   = "./container-registry"
    }
  }
}
resource "ibm_cd_tekton_pipeline_definition" "cd_tekton_pipeline_definition_instance_common_04" {
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  source {
    type = "git"
    properties {
      url    = var.repository_url_pipeline_catalog
      branch = "main"
      path   = "./linter"
    }
  }
}
resource "ibm_cd_tekton_pipeline_definition" "cd_tekton_pipeline_definition_instance_common_05" {
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  source {
    type = "git"
    properties {
      url    = var.repository_url_pipeline_catalog
      branch = "main"
      path   = "./tester"
    }
  }
}

# ------------------------ Tekton Trigger ------------------------
resource "ibm_cd_tekton_pipeline_trigger" "cd_tekton_pipeline_trigger_manual" {
  event_listener      = "manual-run"
  max_concurrent_runs = 1
  name                = "Manual Trigger"
  pipeline_id         = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type                = "manual"
}
resource "ibm_cd_tekton_pipeline_trigger" "cd_tekton_pipeline_trigger_commit" {
  event_listener      = "github-commit"
  max_concurrent_runs = 1
  name                = "Git Commit Trigger"
  pipeline_id         = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type                = "scm"
  events              = ["push"]
  source {
    type = "git"
    properties {
      url    = var.code_repository_url
      branch = "main"
    }
  }
}

# ------------------------ Tekton Properties ------------------------
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_00" {
  name        = "repository"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = var.code_repository_url
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_01" {
  name        = "apikey"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "secure"
  value       = var.ibm_cloud_api_key
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_02" {
  name        = "app-concurrency"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "100"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_03" {
  name        = "app-deployment-timeout"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "300"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_04" {
  name        = "app-health-endpoint"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "/api/health"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_05" {
  name        = "app-max-scale"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "1"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_06" {
  name        = "app-min-scale"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "0"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_07" {
  name        = "app-name"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "web-app"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_08" {
  name        = "app-port"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "3000"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_09" {
  name        = "app-visibility"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "public"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_10" {
  name        = "build-size"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "large"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_11" {
  name        = "build-strategy"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "dockerfile"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_12" {
  name        = "build-timeout"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "1200"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_13" {
  name        = "build-use-native-docker"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "true"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_14" {
  name        = "code-engine-project"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = var.code_engine_project_name
  locked      = true
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_15" {
  name        = "resource-group"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = var.resource_group_name
  locked      = true
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_16" {
  name        = "region"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = var.ibm_region
  locked      = true
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_17" {
  name        = "deployment-type"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "application"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_18" {
  name        = "cpu"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "0.25"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_19" {
  name        = "memory"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "0.5G"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_20" {
  name        = "ephemeral-storage"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "0.4G"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_21" {
  name        = "env-from-configmaps"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = ""
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_22" {
  name        = "env-from-secrets"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = var.create_postgresql ? module.postgresql[0].secret_name : null
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_23" {
  name        = "git-token"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = ""
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_24" {
  name        = "ibmcloud-api"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "https://cloud.ibm.com"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_25" {
  name        = "path-to-context"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "."
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_26" {
  name        = "path-to-dockerfile"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "."
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_27" {
  name        = "registry-namespace"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = ibm_cr_namespace.icr_namespace.name
  locked      = true
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_28" {
  name        = "registry-region"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = var.ibm_region
  locked      = true
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_29" {
  name        = "image-name"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "web-app"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_30" {
  name        = "pipeline-debug"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "0"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_31" {
  name        = "remove-unspecified-references-to-configuration-resources"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "false"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_32" {
  name        = "suffix-for-cd-auto-managed-configuration-resources"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_33" {
  name        = "toolchain-apikey"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "secure"
  value       = var.ibm_cloud_api_key
}
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_34" {
  name        = "wait-timeout"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = "1300"
}

# --------------------------------------------------------------------
# --------------------------------------------------------------------

module "cd_service" {
  source = "./modules/cd-service"

  region            = var.ibm_region
  resource_group_id = ibm_resource_group.group.id
}
