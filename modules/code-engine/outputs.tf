output "project_id" {
  description = "The ID of the Code Engine project"
  value       = ibm_code_engine_project.code_engine_project.id
}

output "project_name" {
  description = "The name of the Code Engine project"
  value       = ibm_code_engine_project.code_engine_project.name
}

output "code_engine_namespace" {
  description = "The namespace of the Code Engine project"
  value       = local.response_body.Shortenednamespace
}

output "code_engine_secrets_name" {
  value = ibm_code_engine_secret.project_secret.name
}
