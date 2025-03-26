resource "ibm_code_engine_project" "code_engine_project" {
  name              = var.project_name
  resource_group_id = var.resource_group_id
}

resource "ibm_code_engine_secret" "project_secret" {
  project_id = ibm_code_engine_project.code_engine_project.id
  name       = "terraform-generated-secrets-db"
  format     = "generic"

  data = {
    POSTGRESQL = var.postgresql_connection_string
  }
}
