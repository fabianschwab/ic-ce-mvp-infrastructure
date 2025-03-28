output "pipeline_id" {
  description = "The ID of the created pipeline"
  value       = ibm_cd_tekton_pipeline.tekton_pipeline.id
}
