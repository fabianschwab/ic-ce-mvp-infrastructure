# -----------------------------------------------------------
# ------------------------ Toolchain ------------------------
# -----------------------------------------------------------
locals {
  # Determines the git provider ID based on the repository URL
  # This is needed to create different resources due to IBM cloud provider specific treatments of git platforms
  # For this only github.com, ibm.github.com, gitlab.com and git.cloud.ibm.com are supported.
  # Others are possible but not implemented because this would increase complexity and is not used ce projects

  pipeline_id = (
    can(regex("^https://github\\.com/", var.repository_pipeline.url)) ? "github" :
    can(regex("^https://github\\.ibm\\.com/", var.repository_pipeline.url)) ? "integrated" :
    can(regex("^https://gitlab\\.com/", var.repository_pipeline.url)) ? "gitlab" :
    can(regex("^https://[^/]+\\.git\\.cloud\\.ibm\\.com/", var.repository_pipeline.url)) ? "hostedgit" : ""
  )

  catalog_id = (
    can(regex("^https://github\\.com/", var.repository_pipeline_catalog.url)) ? "github" :
    can(regex("^https://github\\.ibm\\.com/", var.repository_pipeline_catalog.url)) ? "integrated" :
    can(regex("^https://gitlab\\.com/", var.repository_pipeline_catalog.url)) ? "gitlab" :
    can(regex("^https://[^/]+\\.git\\.cloud\\.ibm\\.com/", var.repository_pipeline_catalog.url)) ? "hostedgit" : ""
  )
}

resource "ibm_cd_toolchain" "ci_cd_toolchain" {
  name              = "code-engine-deployment"
  resource_group_id = var.resource_group_id
}

# Repository: Connect git repositories to the toolchain which define the ci-cd pipeline and tasks

# ---------- Pipeline ------------
# For pipeline on github.com or github.ibm.com
resource "ibm_cd_toolchain_tool_githubconsolidated" "tekton_repository" {

  count = local.pipeline_id == "github" || local.pipeline_id == "integrated" ? 1 : 0

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    git_id   = local.pipeline_id
    type     = "link"
    repo_url = var.repository_pipeline.url
  }
  parameters {
    git_id   = local.pipeline_id
    repo_url = var.repository_pipeline.url
  }
}

# For pipeline on gitlab.com
resource "ibm_cd_toolchain_tool_gitlab" "tekton_repository" {

  count = local.pipeline_id == "gitlab" ? 1 : 0

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    git_id   = local.pipeline_id
    type     = "link"
    repo_url = var.repository_pipeline.url
  }
  parameters {
    git_id   = local.pipeline_id
    repo_url = var.repository_pipeline.url
  }
}

# For pipeline on git.cloud.ibm.com
resource "ibm_cd_toolchain_tool_hostedgit" "tekton_repository" {

  count = local.pipeline_id == "hostedgit" ? 1 : 0

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    git_id   = local.pipeline_id
    type     = "link"
    repo_url = var.repository_pipeline.url
  }
  parameters {
    git_id   = local.pipeline_id
    type     = "link"
    repo_url = var.repository_pipeline.url
  }
}

# ---------- Catalog ------------
# For catalog on github.com or github.ibm.com
resource "ibm_cd_toolchain_tool_githubconsolidated" "tekton_catalog" {

  count = local.catalog_id == "github" || local.catalog_id == "integrated" ? 1 : 0

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    git_id   = local.catalog_id
    type     = "link"
    repo_url = var.repository_pipeline_catalog.url
  }
  parameters {
    git_id   = local.catalog_id
    repo_url = var.repository_pipeline_catalog.url
  }
}

# For catalog on gitlab.com
resource "ibm_cd_toolchain_tool_gitlab" "tekton_catalog" {

  count = local.catalog_id == "gitlab" ? 1 : 0

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    git_id   = local.catalog_id
    type     = "link"
    repo_url = var.repository_pipeline_catalog.url
  }
  parameters {
    git_id   = local.catalog_id
    repo_url = var.repository_pipeline_catalog.url
  }
}

# For pipeline on git.cloud.ibm.com
resource "ibm_cd_toolchain_tool_hostedgit" "tekton_catalog" {

  count = local.catalog_id == "hostedgit" ? 1 : 0

  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    git_id   = local.catalog_id
    type     = "link"
    repo_url = var.repository_pipeline_catalog.url
  }
  parameters {
    git_id   = local.catalog_id
    type     = "link"
    repo_url = var.repository_pipeline_catalog.url
  }
}
