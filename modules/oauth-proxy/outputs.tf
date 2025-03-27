output "endpoint" {
  description = "The endpoint URL of the OAuth proxy application"
  value       = ibm_code_engine_app.oauth_proxy.endpoint
}

output "secret_name" {
  description = "The name of the created OAuth proxy secret"
  value       = ibm_code_engine_secret.oauth_proxy_secret.name
}

output "cookie_secret" {
  description = "The generated cookie secret"
  value       = random_password.cookie_secret.result
  sensitive   = true
}

output "oauth2proxy_url" {
  description = "The public facing URL"
  value       = ibm_code_engine_app.oauth_proxy.endpoint
}
