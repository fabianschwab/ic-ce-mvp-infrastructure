output "toolchain_id" {
  description = "The ID of the created toolchain"
  value       = ibm_cd_toolchain.ci_cd_toolchain.id
}

output "pipeline_id" {
  description = "The ID of the created pipeline"
  value       = ibm_cd_tekton_pipeline.tekton_pipeline.id
}