# -----------------------------------------------------------
# ------------------------ Toolchain ------------------------
# -----------------------------------------------------------
locals {
  # Determines the git provider ID based on the repository URL and provider type
  # Logic:
  # 1. If provider is "github":
  #    - Returns "github" if URL matches github.com
  #    - Returns "integrated" if URL matches github.ibm.com
  #    - Returns "githubcustom" for any other URL
  # 2. If provider is "gitlab":
  #    - Returns "github" if URL matches gitlab.com
  #    - Returns "integrated" if URL matches any-region.git.cloud.ibm.com
  #    - Returns "gitlabcustom" for any other URL
  # 3. For any 'other' provider:
  #    - Returns "hostedgit" for any other URL
  pipeline_id = (
    var.repository_pipeline.provider == "github" ? (
      can(regex("^https://github\\.com/", var.repository_pipeline.url)) ? "github" :
      can(regex("^https://github\\.ibm\\.com/", var.repository_pipeline.url)) ? "integrated" :
      "githubcustom"
      ) : var.repository_pipeline.provider == "gitlab" ? (
      can(regex("^https://gitlab\\.com/", var.repository_pipeline.url)) ? "gitlab" :
      can(regex("^https://[^/]+\\.git\\.cloud\\.ibm\\.com/", var.repository_pipeline.url)) ? "integrated" :
      "gitlabcustom"
    ) : "hostedgit"
  )

  catalog_id = (
    var.repository_pipeline_catalog.provider == "github" ? (
      can(regex("^https://github\\.com/", var.repository_pipeline_catalog.url)) ? "github" :
      can(regex("^https://github\\.ibm\\.com/", var.repository_pipeline_catalog.url)) ? "integrated" :
      "githubcustom"
      ) : var.repository_pipeline_catalog.provider == "gitlab" ? (
      can(regex("^https://gitlab\\.com/", var.repository_pipeline_catalog.url)) ? "gitlab" :
      can(regex("^https://[^/]+\\.git\\.cloud\\.ibm\\.com/", var.repository_pipeline_catalog.url)) ? "integrated" :
      "gitlabcustom"
    ) : "hostedgit"
  )
}

resource "ibm_cd_toolchain" "ci_cd_toolchain" {
  name              = "code-engine-deployment"
  resource_group_id = var.resource_group_id
}

# Repository: Connect git repositories to the toolchain which define the ci-cd pipeline and tasks
resource "ibm_cd_toolchain_tool_githubconsolidated" "tekton_repository" {

  count = var.repository_pipeline_catalog.provider == "github" ? 1 : 0

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
resource "ibm_cd_toolchain_tool_githubconsolidated" "tekton_catalog" {

  count = var.repository_pipeline_catalog.provider == "github" ? 1 : 0

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

resource "ibm_cd_toolchain_tool_gitlab" "tekton_repository" {

  count = var.repository_pipeline_catalog.provider == "github" ? 1 : 0

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
resource "ibm_cd_toolchain_tool_gitlab" "tekton_catalog" {

  count = var.repository_pipeline_catalog.provider == "gitlab" ? 1 : 0

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

resource "ibm_cd_toolchain_tool_hostedgit" "tekton_repository" {

  count = var.repository_pipeline_catalog.provider == "gitlab" ? 1 : 0

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
resource "ibm_cd_toolchain_tool_hostedgit" "tekton_catalog" {

  count = var.repository_pipeline_catalog.provider == "github" ? 1 : 0

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
