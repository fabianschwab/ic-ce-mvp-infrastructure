variable "project_id" {
  type        = string
  description = "The ID of the Code Engine project"
}

variable "proxy_name" {
  type        = string
  description = "Nginx proxy application name"
  default     = "nginx-proxy"
}

variable "upstream_domains" {
  type        = list(string)
  description = "List of upstream domains to proxy"
}

variable "max_scale" {
  type        = number
  description = "Maximum number of instances to scale to"
  default     = 10
}

variable "min_scale" {
  type        = number
  description = "Minimum number of instances to scale to"
  default     = 1
}

variable "cpu_limit" {
  type        = string
  description = "CPU limit for each instance"
  default     = "0.5"
}

variable "memory_limit" {
  type        = string
  description = "Memory limit for each instance"
  default     = "1G"
}