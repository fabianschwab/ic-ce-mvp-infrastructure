# -----------------------------------------------------------
# ------------------------ Toolchain ------------------------
# -----------------------------------------------------------
resource "ibm_cd_toolchain" "ci_cd_toolchain" {
  name              = "code-engine-deployment"
  resource_group_id = var.resource_group_id
}

# Repository: Connect git repositories to the toolchain which define the ci-cd pipeline and tasks
resource "ibm_cd_toolchain_tool_githubconsolidated" "tekton_repository" {

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    type     = "link"
    repo_url = var.repository_url_pipeline
  }
  parameters {
    repo_url = var.repository_url_pipeline
  }
}
resource "ibm_cd_toolchain_tool_githubconsolidated" "tekton_catalog" {

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    type     = "link"
    repo_url = var.repository_url_pipeline_catalog
  }
  parameters {
    repo_url = var.repository_url_pipeline_catalog
  }
}
