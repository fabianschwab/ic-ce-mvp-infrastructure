# -----------------------------------------------------------
# ------------------------ Toolchain ------------------------
# -----------------------------------------------------------
resource "ibm_cd_toolchain" "ci_cd_toolchain" {
  name              = var.toolchain
  resource_group_id = var.resource_group_id
}

# Repository: Connect a git repository to the toolchain
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

resource "ibm_cd_toolchain_tool_githubconsolidated" "code_repository" {
  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
  initialization {
    git_id   = "integrated"
    repo_url = var.code_repository_url
    type     = "link"
  }
  parameters {
    git_id   = "integrated"
    repo_url = var.code_repository_url
    type     = "link"
  }
}

# Delivery: Pipeline
resource "ibm_cd_toolchain_tool_pipeline" "ci_cd_pipeline" {
  parameters {
    name = "ci_cd_pipeline"
  }
  toolchain_id = ibm_cd_toolchain.ci_cd_toolchain.id
}

# -----------------------------------------------------------------
# ------------------------ Tekton Pipeline ------------------------
resource "ibm_cd_tekton_pipeline" "tekton_pipeline" {
  worker {
    id = "public"
  }
  pipeline_id = ibm_cd_toolchain_tool_pipeline.ci_cd_pipeline.tool_id
}

# ------------------------ Tekton Definition ------------------------
resource "ibm_cd_tekton_pipeline_definition" "cd_tekton_pipeline_definition_instance_tasks" {
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  source {
    type = "git"
    properties {
      url    = var.repository_url_pipeline
      branch = "main"
      path   = "./tekton/tasks"
    }
  }
}

# ... [Include all other pipeline definitions] ...

# ------------------------ Tekton Trigger ------------------------
resource "ibm_cd_tekton_pipeline_trigger" "cd_tekton_pipeline_trigger_manual" {
  event_listener      = "manual-run"
  max_concurrent_runs = 1
  name                = "Manual Trigger"
  pipeline_id         = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type                = "manual"
}

resource "ibm_cd_tekton_pipeline_trigger" "cd_tekton_pipeline_trigger_commit" {
  event_listener      = "github-commit"
  max_concurrent_runs = 1
  name                = "Git Commit Trigger"
  pipeline_id         = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type                = "scm"
  events              = ["push"]
  source {
    type = "git"
    properties {
      url    = var.code_repository_url
      branch = "main"
    }
  }
}

# ------------------------ Tekton Properties ------------------------
resource "ibm_cd_tekton_pipeline_property" "cd_tekton_pipeline_property_00" {
  name        = "repository"
  pipeline_id = ibm_cd_tekton_pipeline.tekton_pipeline.id
  type        = "text"
  value       = var.code_repository_url
}

# ... [Include all other pipeline properties] ...