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
