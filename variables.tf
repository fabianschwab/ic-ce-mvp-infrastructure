##########
# General
##########

variable "ibm_cloud_api_key" {
  type        = string
  description = "IAM API Key"
  sensitive   = true
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

variable "container_registry_name" {
  type        = string
  description = "Name for the CodeEngine project which holds the applications"
  default     = "mvp-images"
}

variable "pg_database_name" {
  type        = string
  description = "Name of the PostgreSQL database service"
  default     = "mvp-database"
}

variable "pg_admin_password" {
  type        = string
  description = "Admin password for the PostgreSQL database"
  sensitive   = true
}

variable "pg_database_endpoint" {
  description = "Specify the visibility of the database endpoint. Allowed values: 'private', 'public', 'public-and-private'."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public", "public-and-private"], var.pg_database_endpoint)
    error_message = "Invalid value! Allowed values: 'private', 'public', 'public-and-private'."
  }
}

variable "toolchain" {
  type        = string
  description = "Name of the automation Toolchain"
  default     = "code-engine-deployment"
}

variable "tekton_repo" {
  type        = string
  description = "URL of the Tekton pipeline repository"
}
