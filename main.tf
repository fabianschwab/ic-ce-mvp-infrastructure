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

resource "ibm_cr_namespace" "icr_namespace" {
  name              = var.container_registry_name
  resource_group_id = ibm_resource_group.group.id
}

resource "ibm_cr_retention_policy" "cr_retention_policy" {
  namespace       = ibm_cr_namespace.icr_namespace.name
  images_per_repo = 10
  retain_untagged = false
}

resource "ibm_database" "pg_database" {
  name          = var.pg_database_name
  service       = "databases-for-postgresql"
  plan          = "standard"
  adminpassword = var.pg_admin_password

  resource_group_id = ibm_resource_group.group.id
  location          = var.ibm_region

  service_endpoints = var.pg_database_endpoint

  group {
    group_id = "member"
    host_flavor {
      id = "multitenant"
    }
    disk {
      allocation_mb = 5120
    }
  }
}

resource "ibm_resource_key" "pg_credentials" {
  name                 = "pg-service-credentials"
  resource_instance_id = ibm_database.pg_database.id
}

# -----------------------------------------------------------
# ------------------------ Toolchain ------------------------

resource "ibm_cd_toolchain" "ci_cd_toolchain" {
  name              = var.toolchain
  resource_group_id = ibm_resource_group.group.id
}

# Repository: Connect a git repository to the toolchain
resource "ibm_cd_toolchain_tool_githubconsolidated" "tekton_repository" {

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    type     = "link"
    repo_url = var.git_repository_url
  }
  parameters {
    repo_url = var.git_repository_url
  }
}

# Delivery: Pipeline
resource "ibm_cd_toolchain_tool_pipeline" "ci_cd_pipeline" {
  parameters {
    name = "ci_cd_pipeline"
  }
  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
}

# Pipeline type Tekton inside the pipeline
resource "ibm_cd_tekton_pipeline" "tekton_pipeline" {
  worker {
    id = "public"
  }
  pipeline_id = ibm_cd_toolchain_tool_pipeline.ci_cd_pipeline.tool_id
}

# Pipeline definition, this holds the Tekton files of the build pipeline
resource "ibm_cd_tekton_pipeline_definition" "cd_tekton_pipeline_definition_instance_tasks" {
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  source {
    type = "git"
    properties {
      url    = "https://github.com/fabianschwab/ic-ce-tekton-pipeline"
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
      url    = "https://github.com/fabianschwab/ic-ce-tekton-pipeline.git"
      branch = "main"
      path   = "./tekton/cicd"
    }
  }
}

# Tekton runner instance for Tekton pipelines (shared)
resource "ibm_resource_instance" "cd_service_instance" {
  name              = "cd-service-worker"
  service           = "continuous-delivery"
  plan              = "lite"
  location          = var.ibm_region
  resource_group_id = ibm_resource_group.group.id
}
