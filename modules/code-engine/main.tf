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

data "ibm_iam_auth_token" "token_data" {}

provider "curl" {
  token = replace(data.ibm_iam_auth_token.token_data.iam_access_token, "Bearer ", "")
}

data "curl_request" "my_project" {
  uri         = "https://api.${var.ibm_region}.codeengine.cloud.ibm.com/api/v1/project/${ibm_code_engine_project.code_engine_project.id}/info"
  http_method = "GET"
  headers = {
    "Refresh-Token" = data.ibm_iam_auth_token.token_data.iam_refresh_token
    "Accept"        = "application/json"
  }

  depends_on = [ibm_code_engine_project.code_engine_project]
}

locals {
  response_body = jsondecode(data.curl_request.my_project.response_body)
}
