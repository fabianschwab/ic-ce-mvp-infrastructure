resource "random_id" "unique_id" {
  byte_length = 4
}

resource "ibm_cr_namespace" "icr_namespace" {
  name              = "${var.container_registry_name}-${random_id.unique_id.hex}"
  resource_group_id = var.resource_group_id
}

resource "ibm_cr_retention_policy" "cr_retention_policy" {
  namespace       = ibm_cr_namespace.icr_namespace.name
  images_per_repo = 3
  retain_untagged = false
}
