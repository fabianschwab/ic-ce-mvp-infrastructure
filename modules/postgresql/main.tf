resource "ibm_database" "pg_database" {
  name    = var.pg_database_name
  service = "databases-for-postgresql"
  plan    = "standard"

  resource_group_id = var.resource_group_id
  location          = var.region

  service_endpoints = var.pg_database_endpoint

  group {
    group_id = "member"
    host_flavor {
      id = "multitenant"
    }
    disk {
      allocation_mb = 5120
    }
  }
}

resource "ibm_resource_key" "pg_credentials" {
  name                 = "pg-service-credentials"
  resource_instance_id = ibm_database.pg_database.id
}

resource "ibm_code_engine_secret" "code_engine_secrets" {
  project_id = var.code_engine_project_id
  name       = "terraform-generated-secrets"
  format     = "generic"

  data = {
    POSTGRESQL = jsondecode(ibm_resource_key.pg_credentials.credentials_json).connection.postgres.composed[0]
  }
}
