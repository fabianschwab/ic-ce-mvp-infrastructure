variable "container_registry_name" {
  type        = string
  description = "Container registry namespace name which holds the images. To be unique, the name has a random character suffix to avoid name collisions."
}

variable "resource_group_id" {
  type        = string
  description = "ID of the resource group"
}