output "namespace_name" {
  description = "The name of the container registry namespace"
  value       = ibm_cr_namespace.icr_namespace.name
}

output "registry_url" {
  description = "The URL of the container registry"
  value       = ibm_cr_namespace.icr_namespace.registry_url
}