resource "ibm_code_engine_secret" "nginx_proxy_config" {
  project_id = var.project_id
  name       = "nginx-proxy-config"
  format     = "generic"

  data = {
    NGINX_CONFIG = templatefile("${path.module}/nginx.conf.tpl", {
      upstream_domains = var.upstream_domains
    })
  }
}

resource "ibm_code_engine_app" "nginx_proxy" {
  project_id      = var.project_id
  name            = var.proxy_name
  image_reference = "docker.io/library/nginx:1.27.4-alpine"
  image_port      = 80

  scale_max_instances = var.max_scale
  scale_min_instances = var.min_scale

  scale_cpu_limit    = var.cpu_limit
  scale_memory_limit = var.memory_limit

  probe_liveness {
    type = "http"
    path = "/health"
    port = 80
  }

  probe_readiness {
    type = "http"
    path = "/health"
    port = 80
  }

  run_env_variables {
    type      = "secret_full_reference"
    reference = ibm_code_engine_secret.nginx_proxy_config.name
  }
}
