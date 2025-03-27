variable "ibm_region" {
  type        = string
  description = "Region and zone the resources should be created in."
  default     = "eu-de"
}

variable "project_name" {
  type        = string
  description = "Name of the Code Engine project"
}

variable "resource_group_id" {
  type        = string
  description = "ID of the resource group"
}

variable "postgresql_connection_string" {
  type        = string
  description = "PostgreSQL connection string to store in secrets"
  sensitive   = true
}
