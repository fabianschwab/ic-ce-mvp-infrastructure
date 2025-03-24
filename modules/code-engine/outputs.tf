output "project_id" {
  description = "The ID of the Code Engine project"
  value       = ibm_code_engine_project.code_engine_project.id
}

output "project_name" {
  description = "The name of the Code Engine project"
  value       = ibm_code_engine_project.code_engine_project.name
}