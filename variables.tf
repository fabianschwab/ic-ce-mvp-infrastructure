##########
# General
##########

variable "ibm_cloud_api_key" {
  type        = string
  description = "IAM API Key"
}

variable "ibm_region" {
  type        = string
  description = "Region and zone the resources should be created in."
  default     = "eu-de"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group to provision resources."
  default     = "development"
}

variable "code_engine_project_name" {
  type        = string
  description = "Name for the CodeEngine project which holds the applications"
  default     = "mvp-development"
}
