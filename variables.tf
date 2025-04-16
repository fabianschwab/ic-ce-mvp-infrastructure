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
  description = "Container registry namespace name which holds the images. To be unique, the name has a random character suffix to avoid name collisions."
  default     = "mvp-images"
}

variable "create_postgresql" {
  type        = bool
  description = "Boolean flag to control if PostgreSQL database should be created"
  default     = true
}

variable "pg_database_name" {
  type        = string
  description = "Name of the PostgreSQL database service"
  default     = "mvp-database"
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

variable "use_oauth2proxy" {
  type        = bool
  description = "Boolean flag to control if project is behind oauth2proxy."
  default     = true
}

variable "toolchain" {
  type        = string
  description = "Name of the automation Toolchain"
  default     = "code-engine-deployment"
}

variable "code_repositories" {
  type = list(object({
    provider    = string
    url         = string
    token       = string
    root_folder = string
    name        = string
    visibility  = string
  }))
  validation {
    condition     = alltrue([for repo in var.code_repositories : contains(["github", "gitlab", "other"])])
    error_message = "Invalid provider value. Valid values are 'github', 'gitlab' and 'other'."
  }
  validation {
    condition     = alltrue([for repo in var.code_repositories : contains(["public", "private", "project"], repo.visibility)])
    error_message = "Invalid visibility value. Valid values are 'public', 'private' and 'project'."
  }
  validation {
    condition     = alltrue([for repo in var.code_repositories : repo.provider != "other" || (repo.provider == "other" && repo.token != null && repo.token != "")])
    error_message = "Token is required when provider is set to 'other'."
  }

  description = "List of services to deploy. Consolidate the `Readme.md` for structure of the list and containing object if unsure."
}

variable "repository_pipeline" {
  type = object({
    provider = string
    url      = string
    token    = string
  })
  default = { provider = "github", url = "https://github.com/fabianschwab/ic-ce-tekton-pipeline.git", token = "" }

  validation {
    condition     = contains(["github", "gitlab", "other"], var.repository_pipeline.provider)
    error_message = "Invalid provider value. Valid values are 'github', 'gitlab' and 'other'."
  }

  validation {
    condition     = (var.repository_pipeline.provider == "other" && var.repository_pipeline.token != null && var.repository_pipeline.token != "") || var.repository_pipeline.provider != "other"
    error_message = "Token is required when provider is set to 'other'."
  }

  description = "URL of the code repository the pipeline should build. See `Readme.md` for object info."
}

variable "repository_pipeline_catalog" {
  type = object({
    provider = string
    url      = string
    token    = string
  })
  default = { provider = "github", url = "https://github.com/fabianschwab/ic-ce-tekton-pipeline-catalog.git", token = "" }

  validation {
    condition     = contains(["github", "gitlab", "other"], var.repository_pipeline_catalog.provider)
    error_message = "Invalid provider value. Valid values are 'github', 'gitlab' and 'other'."
  }

  validation {
    condition     = (var.repository_pipeline_catalog.provider == "other" && var.repository_pipeline.token != null && var.repository_pipeline.token != "") || var.repository_pipeline_catalog.provider != "other"
    error_message = "Token is required when provider is set to 'other'."
  }

  description = "URL of the code repository the pipeline should build. See `Readme.md` for object info."
}
