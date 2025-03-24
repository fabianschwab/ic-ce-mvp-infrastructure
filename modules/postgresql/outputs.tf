output "database_id" {
  description = "The ID of the PostgreSQL database instance"
  value       = ibm_database.pg_database.id
}

output "credentials_key_id" {
  description = "The ID of the resource key containing database credentials"
  value       = ibm_resource_key.pg_credentials.id
}

output "connection_string" {
  description = "PostgreSQL connection string"
  value       = jsondecode(ibm_resource_key.pg_credentials.credentials_json).connection.postgres.composed[0]
  sensitive   = true
}
