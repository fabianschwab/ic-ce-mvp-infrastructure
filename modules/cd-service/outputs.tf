output "cd_service_instance_id" {
  description = "The ID of the Continuous Delivery service instance"
  value       = ibm_resource_instance.cd_service_instance.id
}

output "cd_service_instance_guid" {
  description = "The GUID of the Continuous Delivery service instance"
  value       = ibm_resource_instance.cd_service_instance.guid
}