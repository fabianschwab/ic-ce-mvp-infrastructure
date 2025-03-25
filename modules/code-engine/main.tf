resource "ibm_code_engine_project" "code_engine_project" {
  name              = var.project_name
  resource_group_id = var.resource_group_id
}

resource "ibm_code_engine_secret" "project_secret" {
  project_id = ibm_code_engine_project.code_engine_project.id
  name       = "terraform-generated-secrets"
  format     = "generic"

  data = {
    POSTGRESQL = var.postgresql_connection_string
    MYENV      = "MyValue"
  }
}

resource "ibm_code_engine_app" "oauth_proxy" {
  project_id      = ibm_code_engine_project.code_engine_project.id
  name            = "oauth2proxy"
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
    "--upstream=http://web-app.1tej7v4z4ykt.svc.cluster.local"
  ]

  run_env_variables {
    type      = "secret_full_reference"
    reference = "terraform-generated-secrets-auth"
  }

  depends_on = [ibm_code_engine_secret.oauth-proxy-secret]
}

resource "ibm_code_engine_secret" "oauth-proxy-secret" {
  project_id = ibm_code_engine_project.code_engine_project.id
  name       = "terraform-generated-secrets-auth"
  format     = "generic"

  data = {
    OAUTH2_PROXY_COOKIE_DOMAIN   = "https://oauth2proxy.1tej7v4z4ykt.eu-de.codeengine.appdomain.cloud"
    OAUTH2_PROXY_COOKIE_SECRET   = random_password.cookie_secret.result
    OAUTH2_PROXY_CLIENT_ID       = "1a412199-d4d0-4186-95a3-2624de09f46f"
    OAUTH2_PROXY_CLIENT_SECRET   = "YjExZjUwNWMtOTZmMi00ZGJmLWJhZWEtNGMzYWE4NzdlMGQ5"
    OAUTH2_PROXY_OIDC_ISSUER_URL = "https://eu-de.appid.cloud.ibm.com/oauth/v4/30cd2cab-aeeb-4d33-a377-52aa1cb365d0"
    OAUTH2_PROXY_REDIRECT_URL    = "https://oauth2proxy.1tej7v4z4ykt.eu-de.codeengine.appdomain.cloud"
  }
}

resource "random_password" "cookie_secret" {
  length  = 32
  special = true
}

#  ibmcloud ce application create \
#     --name oauth-proxy \✅
#     --image quay.io/oauth2-proxy/oauth2-proxy:latest \✅
#     --port http1:4180 \✅
#     --probe-live type=http --probe-live path=/ping --probe-live port=4180 \✅
#     --probe-ready type=http --probe-ready path=/ping --probe-ready port=4180 \✅
#     --cpu 0.5 \✅
#     --memory 1G \✅
#     --max-scale 1 \✅
#     --min-scale 1 \✅
#     --env-from-secret oauth-proxy-secret \‼️
#     --argument '--provider=oidc' \✅
#     --argument '--email-domain=ibm.com' \✅
#     --argument '--email-domain=de.ibm.com' \✅
#     --argument '--http-address=:4180' \✅
#     --argument '--pass-authorization-header=true' \✅
#     --argument '--insecure-oidc-allow-unverified-email=true' \✅
#     --argument '--pass-host-header=false' \✅
#     --argument '--skip-provider-button=true' \✅
#     --argument '--upstream-timeout=300s' \✅
#     --argument '--upstream=http://<upstream-service-name>.<code-engine-namespace>.svc.cluster.local'✅ ⚠️
