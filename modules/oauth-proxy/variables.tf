variable "project_id" {
  type        = string
  description = "The ID of the Code Engine project"
}

variable "proxy_name" {
  type        = string
  description = "OAuth2Proxy application name"
}

variable "cookie_domain" {
  type        = string
  description = "The domain for the OAuth proxy cookie"
}

variable "client_id" {
  type        = string
  description = "The OAuth client ID"
}

variable "client_secret" {
  type        = string
  description = "The OAuth client secret"
  sensitive   = true
}

variable "oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL"
}

variable "redirect_url" {
  type        = string
  description = "The OAuth redirect URL"
}

variable "code_engine_namespace" {
  type        = string
  description = "The namespace for generating service URLs"
}

variable "ibm_region" {
  type        = string
  description = "Region and zone the resources should be created in."
  default     = "eu-de"
}
