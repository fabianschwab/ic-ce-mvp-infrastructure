resource "ibm_resource_instance" "appid" {
  name              = var.name
  service           = "appid"
  plan              = "graduated-tier"
  location          = var.region
  resource_group_id = var.resource_group_id
}

resource "ibm_appid_application" "app" {
  tenant_id = ibm_resource_instance.appid.guid
  name      = "terraform-generated-oauth2proxy"
  type      = "regularwebapp"
}

resource "ibm_appid_idp_cloud_directory" "cd" {
  tenant_id = ibm_resource_instance.appid.guid
  is_active = true
  identity_confirm_methods = [
    "email"
  ]
  identity_field                      = "email"
  self_service_enabled                = false
  signup_enabled                      = false
  welcome_enabled                     = false
  reset_password_enabled              = false
  reset_password_notification_enabled = false
}

resource "ibm_appid_idp_facebook" "fb" {
  tenant_id = ibm_resource_instance.appid.guid
  is_active = false
}
resource "ibm_appid_idp_google" "gg" {
  tenant_id = ibm_resource_instance.appid.guid
  is_active = false
}
resource "ibm_appid_idp_saml" "saml" {
  tenant_id = ibm_resource_instance.appid.guid
  is_active = false
}
resource "ibm_appid_idp_custom" "idp" {
  tenant_id = ibm_resource_instance.appid.guid
  is_active = false
}
