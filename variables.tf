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
  description = "Container registry namespace name which holds the images for the applications. The name has a random 4 character suffix to avoid name collisions."
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

variable "code_repository_url" {
  type        = string
  description = "URL of the code repository to build"
}

variable "repository_url_pipeline" {
  type        = string
  description = "URL of the code repository the pipeline should build"
  default     = "https://github.com/fabianschwab/ic-ce-tekton-pipeline.git"
}
variable "repository_url_pipeline_catalog" {
  type        = string
  description = "URL of the code repository the pipeline should build"
  default     = "https://github.com/fabianschwab/ic-ce-tekton-pipeline-catalog.git"
}
