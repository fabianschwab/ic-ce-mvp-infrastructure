output "namespace_name" {
  description = "The name of the container registry namespace"
  value       = ibm_cr_namespace.icr_namespace.name
}
