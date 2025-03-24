resource "ibm_code_engine_project" "code_engine_project" {
  name              = var.project_name
  resource_group_id = var.resource_group_id
}