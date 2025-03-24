output "appid_instance_id" {
  description = "The ID of the App ID instance"
  value       = ibm_resource_instance.appid.id
}

output "appid_instance_guid" {
  description = "The GUID of the App ID instance"
  value       = ibm_resource_instance.appid.guid
}