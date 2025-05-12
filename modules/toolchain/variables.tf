
variable "resource_group_id" {
  type        = string
  description = "ID of the resource group"
}

variable "repository_pipeline_url" {
  type        = string
  description = "URL of the pipeline repository."
  default     = "https://github.com/fabianschwab/ic-ce-tekton-pipeline.git"
}

variable "repository_pipeline_token" {
  type        = string
  description = "Access token for the pipeline repository."
  sensitive   = true
}

variable "repository_pipeline_catalog_url" {
  type        = string
  description = "URL of the tasks repository of the pipeline."
  default     = "https://github.com/fabianschwab/ic-ce-tekton-pipeline-catalog.git"
}

variable "repository_pipeline_catalog_token" {
  type        = string
  description = "Access token for the tasks repository."
  sensitive   = true
}
