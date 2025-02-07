terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.75.1"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibm_cloud_api_key
  region           = var.ibm_region
}

resource "ibm_resource_group" "group" {
  name     = var.resource_group_name
}
