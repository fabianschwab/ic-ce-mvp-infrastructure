output "endpoint" {
  description = "The endpoint URL of the Nginx proxy application"
  value       = ibm_code_engine_app.nginx_proxy.endpoint
}

output "config_secret_name" {
  description = "The name of the created Nginx config secret"
  value       = ibm_code_engine_secret.nginx_proxy_config.name
}