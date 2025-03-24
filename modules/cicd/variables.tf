variable "toolchain" {
  type        = string
  description = "Name of the toolchain"
}

variable "resource_group_id" {
  type        = string
  description = "ID of the resource group"
}

variable "repository_url_pipeline" {
  type        = string
  description = "URL of the pipeline repository"
}

variable "repository_url_pipeline_catalog" {
  type        = string
  description = "URL of the pipeline catalog repository"
}

variable "code_repository_url" {
  type        = string
  description = "URL of the code repository"
}

variable "ibm_cloud_api_key" {
  type        = string
  description = "IBM Cloud API Key"
  sensitive   = true
}

variable "code_engine_project_name" {
  type        = string
  description = "Name of the Code Engine project"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "ibm_region" {
  type        = string
  description = "IBM Cloud region"
}

variable "container_registry_namespace" {
  type        = string
  description = "Container registry namespace"
}

variable "code_engine_secrets_name" {
  type        = string
  description = "Name of the generated secret"
  default     = ""
}
