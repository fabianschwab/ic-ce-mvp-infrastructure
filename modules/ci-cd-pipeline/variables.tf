variable "ci_cd_toolchain_id" {
  type        = string
  description = "The ID of the toolchain the pipelines are added to"
}
variable "name" {
  type        = string
  description = "Name of the delivery pipeline"
}

variable "resource_group_id" {
  type        = string
  description = "ID of the resource group"
}

variable "repository_url_pipeline" {
  type        = string
  description = "URL of the pipeline repository"
}

# variable "repository_provider_pipeline" {
#   type        = string
#   description = "Provider of the pipeline repository"

#   validation {
#     condition     = contains(["github", "gitlab", "other"], var.repository_provider_pipeline)
#     error_message = "Invalid provider value. Valid values are 'github', 'gitlab' and 'other'."
#   }

# }

variable "repository_url_pipeline_catalog" {
  type        = string
  description = "URL of the pipeline catalog repository"
}

# variable "repository_provider_pipeline_catalog" {
#   type        = string
#   description = "Provider of the pipeline catalog repository"

#   validation {
#     condition     = contains(["github", "gitlab", "other"], var.repository_provider_pipeline_catalog)
#     error_message = "Invalid provider value. Valid values are 'github', 'gitlab' and 'other'."
#   }

# }

variable "code_repository_url" {
  type        = string
  description = "URL of the code repository"
}

variable "code_repository_provider" {
  type        = string
  description = "Provider of the code repository"

  validation {
    condition     = contains(["github", "gitlab", "other"], var.code_repository_provider)
    error_message = "Invalid provider value. Valid values are 'github', 'gitlab' and 'other'."
  }
}

variable "root_folder" {
  type        = string
  description = "Root folder of the source code and Dockerfile"
  default     = "/"
  validation {
    condition     = can(regex("^/", var.root_folder))
    error_message = "The root_folder value must start with a forward slash (/)."
  }
}
variable "visibility" {
  type        = string
  description = "Visibility of the code engine application. Allowed values are: 'public', 'private' and 'project'."
  default     = "private"
  validation {
    condition     = contains(["public", "private", "project"], var.visibility)
    error_message = "Invalid visibility value. Valid values are 'public', 'private' and 'project'."
  }
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
