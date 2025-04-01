terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.75.1"
    }
  }
}

locals {
  oauth2proxy_name = "oauth2proxy"
  proxy_url        = "https://${local.oauth2proxy_name}.${module.code_engine.code_engine_namespace}.${var.ibm_region}.codeengine.appdomain.cloud"
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

  project_name                 = var.code_engine_project_name
  resource_group_id            = ibm_resource_group.group.id
  postgresql_connection_string = var.create_postgresql ? module.postgresql[0].connection_string : ""
  ibm_region                   = var.ibm_region
}

module "oauth_proxy" {
  count  = var.use_oauth2proxy ? 1 : 0
  source = "./modules/oauth-proxy"

  proxy_name            = local.oauth2proxy_name
  project_id            = module.code_engine.project_id
  cookie_domain         = local.proxy_url
  client_id             = module.appid.appid_oauth_app_client_id
  client_secret         = module.appid.appid_oauth_app_client_secret
  oidc_issuer_url       = module.appid.appid_oauth_app_issuer
  redirect_url          = local.proxy_url
  code_engine_namespace = module.code_engine.code_engine_namespace
  ibm_region            = var.ibm_region
}

module "container_registry" {
  source = "./modules/container-registry"

  container_registry_name = var.container_registry_name
  resource_group_id       = ibm_resource_group.group.id
}

module "postgresql" {
  count  = var.create_postgresql ? 1 : 0
  source = "./modules/postgresql"

  pg_database_name     = var.pg_database_name
  resource_group_id    = ibm_resource_group.group.id
  region               = var.ibm_region
  pg_database_endpoint = var.pg_database_endpoint
}

module "toolchain" {
  source = "./modules/toolchain"

  resource_group_id               = ibm_resource_group.group.id
  repository_url_pipeline         = var.repository_url_pipeline
  repository_url_pipeline_catalog = var.repository_url_pipeline_catalog
}

module "cicd" {
  source   = "./modules/cicd"
  for_each = { for repo in var.code_repositories : "${repo.name}-${repo.url}" => repo }

  code_repository_url             = each.value.url
  root_folder                     = each.value.root_folder
  name                            = each.value.name
  visibility                      = each.value.visibility
  ci_cd_toolchain_id              = module.toolchain.toolchain_id
  resource_group_id               = ibm_resource_group.group.id
  repository_url_pipeline         = var.repository_url_pipeline
  repository_url_pipeline_catalog = var.repository_url_pipeline_catalog
  ibm_cloud_api_key               = var.ibm_cloud_api_key
  code_engine_project_name        = var.code_engine_project_name
  resource_group_name             = var.resource_group_name
  ibm_region                      = var.ibm_region
  container_registry_namespace    = module.container_registry.namespace_name
  code_engine_secrets_name        = module.code_engine.code_engine_secrets_name
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
  redirect_urls     = var.use_oauth2proxy ? ["${local.proxy_url}/oauth2/callback"] : []
}
