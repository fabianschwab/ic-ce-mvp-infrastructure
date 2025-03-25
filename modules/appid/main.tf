resource "ibm_resource_instance" "appid" {
  name              = var.name
  service           = "appid"
  plan              = "graduated-tier"
  location          = var.region
  resource_group_id = var.resource_group_id
}

resource "ibm_resource_key" "appid_credentials" {
  name                 = "appid-service-credentials"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.appid.id
}
