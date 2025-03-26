output "appid_instance_id" {
  description = "The ID of the App ID instance"
  value       = ibm_resource_instance.appid.id
}

output "appid_oauth_app_client_id" {
  description = "The OAuth app client id"
  value       = ibm_appid_application.app.client_id
}

output "appid_oauth_app_client_secret" {
  description = "The OAuth app client secret"
  value       = ibm_appid_application.app.secret
  sensitive   = true
}

output "appid_oauth_app_issuer" {
  description = "The OAuth app oauth server url"
  value       = ibm_appid_application.app.oauth_server_url
}
