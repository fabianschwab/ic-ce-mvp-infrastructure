resource "ibm_resource_instance" "appid" {
  name              = var.name
  service           = "appid"
  plan              = "graduated-tier"
  location          = var.region
  resource_group_id = var.resource_group_id
}