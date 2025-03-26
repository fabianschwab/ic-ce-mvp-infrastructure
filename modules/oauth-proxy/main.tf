resource "random_password" "cookie_secret" {
  length  = 32
  special = true
}

resource "ibm_code_engine_secret" "oauth_proxy_secret" {
  project_id = var.project_id
  name       = "terraform-generated-secrets-auth"
  format     = "generic"

  data = {
    OAUTH2_PROXY_COOKIE_DOMAIN   = var.cookie_domain
    OAUTH2_PROXY_COOKIE_SECRET   = random_password.cookie_secret.result
    OAUTH2_PROXY_CLIENT_ID       = var.client_id
    OAUTH2_PROXY_CLIENT_SECRET   = var.client_secret
    OAUTH2_PROXY_OIDC_ISSUER_URL = var.oidc_issuer_url
    OAUTH2_PROXY_REDIRECT_URL    = var.redirect_url
  }
}

resource "ibm_code_engine_app" "oauth_proxy" {
  project_id      = var.project_id
  name            = var.proxy_name
  image_reference = "quay.io/oauth2-proxy/oauth2-proxy:latest"
  image_port      = 4180

  scale_max_instances = 1
  scale_min_instances = 1

  scale_cpu_limit    = "0.5"
  scale_memory_limit = "1G"

  probe_liveness {
    type = "http"
    path = "/ping"
    port = 4180
  }

  probe_readiness {
    type = "http"
    path = "/ping"
    port = 4180
  }

  run_arguments = [
    "--provider=oidc",
    "--email-domain=ibm.com",
    "--email-domain=de.ibm.com",
    "--http-address=:4180",
    "--pass-authorization-header=true",
    "--insecure-oidc-allow-unverified-email=true",
    "--pass-host-header=false",
    "--skip-provider-button=true",
    "--upstream-timeout=300s",
    "--upstream=http://*.${var.code_engine_namespace}.svc.cluster.local/",
    "--whitelist_domains=*.${var.code_engine_namespace}.svc.cluster.local"
  ]

  run_env_variables {
    type      = "secret_full_reference"
    reference = ibm_code_engine_secret.oauth_proxy_secret.name
  }
}
