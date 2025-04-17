
variable "resource_group_id" {
  type        = string
  description = "ID of the resource group"
}

variable "repository_pipeline" {
  type = object({
    provider = string
    token    = string
    url      = string
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
    token    = string
    url      = string
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
