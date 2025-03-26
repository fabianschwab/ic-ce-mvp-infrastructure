variable "name" {
  type        = string
  description = "Name of the App ID instance"
}

variable "region" {
  type        = string
  description = "Region where to create the App ID instance"
}

variable "resource_group_id" {
  type        = string
  description = "ID of the resource group"
}

variable "redirect_urls" {
  type        = list(string)
  description = "List of allowed redirect URLs for App ID"
  default     = ["http://localhost:3000/"]
}
