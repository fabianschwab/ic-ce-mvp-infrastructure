variable "pg_database_name" {
  type        = string
  description = "Name of the PostgreSQL database service"
}

variable "resource_group_id" {
  type        = string
  description = "ID of the resource group"
}

variable "region" {
  type        = string
  description = "Region where to deploy the database"
}

variable "pg_database_endpoint" {
  description = "Specify the visibility of the database endpoint. Allowed values: 'private', 'public', 'public-and-private'."
  type        = string
  validation {
    condition     = contains(["private", "public", "public-and-private"], var.pg_database_endpoint)
    error_message = "Invalid value! Allowed values: 'private', 'public', 'public-and-private'."
  }
}

variable "code_engine_project_id" {
  type        = string
  description = "ID of the Code Engine project where to create the secrets"
}