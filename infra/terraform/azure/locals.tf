locals {
  observability_stack_root = "/opt/flask-observability"

  docker_compose_content = file("${path.module}/monitoring/docker-compose.yml")
  prometheus_config      = file("${path.module}/monitoring/prometheus/prometheus.yml")
  prometheus_rules       = file("${path.module}/monitoring/prometheus/rules.yml")
  alertmanager_config    = file("${path.module}/monitoring/alertmanager/alertmanager.yml")
  blackbox_config        = file("${path.module}/monitoring/blackbox/blackbox.yml")
  grafana_datasource     = file("${path.module}/monitoring/grafana/provisioning/datasources/datasource.yml")
  grafana_dashboards     = file("${path.module}/monitoring/grafana/provisioning/dashboards/dashboards.yml")
  grafana_dashboard      = file("${path.module}/monitoring/grafana/dashboards/flask-observability.json")

  observability_env = join("\n", [
    "APP_IMAGE=${var.docker_image}",
    "GRAFANA_ADMIN_USER=${var.grafana_admin_user}",
    "GRAFANA_ADMIN_PASSWORD=${var.grafana_admin_password}",
    ""
  ])

  deploy_observability_script = templatefile("${path.module}/scripts/deploy_observability.sh.tftpl", {
    stack_root           = local.observability_stack_root
    compose_project_name = var.compose_project_name
    env_file             = local.observability_env
    docker_compose       = local.docker_compose_content
    prometheus_config    = local.prometheus_config
    prometheus_rules     = local.prometheus_rules
    alertmanager_config  = local.alertmanager_config
    blackbox_config      = local.blackbox_config
    grafana_datasource   = local.grafana_datasource
    grafana_dashboards   = local.grafana_dashboards
    grafana_dashboard    = local.grafana_dashboard
  })
}
