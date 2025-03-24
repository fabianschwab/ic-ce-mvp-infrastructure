resource "ibm_resource_instance" "cd_service_instance" {
  name              = "cd-service-worker"
  service           = "continuous-delivery"
  plan              = "lite"
  location          = var.region
  resource_group_id = var.resource_group_id
}