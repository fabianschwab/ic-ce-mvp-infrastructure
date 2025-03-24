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

module "code_engine" {
  source = "./modules/code-engine"

  project_name      = var.code_engine_project_name
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
  code_engine_project_id = module.code_engine.project_id
}

module "cicd" {
  source = "./modules/cicd"

  toolchain                       = var.toolchain
  resource_group_id               = ibm_resource_group.group.id
  repository_url_pipeline         = var.repository_url_pipeline
  repository_url_pipeline_catalog = var.repository_url_pipeline_catalog
  code_repository_url             = var.code_repository_url
  ibm_cloud_api_key               = var.ibm_cloud_api_key
  code_engine_project_name        = var.code_engine_project_name
  resource_group_name             = var.resource_group_name
  ibm_region                      = var.ibm_region
  container_registry_namespace    = module.container_registry.namespace_name
  postgresql_secret_name          = var.create_postgresql ? module.postgresql[0].secret_name : ""
}

module "cd_service" {
  source = "./modules/cd-service"

  region            = var.ibm_region
  resource_group_id = ibm_resource_group.group.id
}

module "appid" {
  source = "./modules/appid"

  name              = "auth-provider"
  region            = var.ibm_region
  resource_group_id = ibm_resource_group.group.id
}
