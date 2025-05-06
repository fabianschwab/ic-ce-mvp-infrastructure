
variable "resource_group_id" {
  type        = string
  description = "ID of the resource group"
}

variable "repository_pipeline" {
  type = object({
    token = string
    url   = string
  })
  default = { url = "https://github.com/fabianschwab/ic-ce-tekton-pipeline.git", token = "" }

  description = "URL of the pipeline repository. See `Readme.md` for object info."
}

variable "repository_pipeline_catalog" {
  type = object({
    token = string
    url   = string
  })
  default = { url = "https://github.com/fabianschwab/ic-ce-tekton-pipeline-catalog.git", token = "" }

  description = "URL of the pipeline tasks repository. See `Readme.md` for object info."
}
