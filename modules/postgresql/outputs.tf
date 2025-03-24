output "database_id" {
  description = "The ID of the PostgreSQL database instance"
  value       = ibm_database.pg_database.id
}

output "credentials_key_id" {
  description = "The ID of the resource key containing database credentials"
  value       = ibm_resource_key.pg_credentials.id
}

output "secret_name" {
  description = "The name of the Code Engine secret containing database credentials"
  value       = ibm_code_engine_secret.code_engine_secrets.name
}