variable "resource_group_name" {
  description = "Azure Resource Group containing the existing VM."
  type        = string
}

variable "vm_name" {
  description = "Name of the existing Azure VM that will run the app."
  type        = string
}

variable "container_name" {
  description = "Docker container name that will run on the VM."
  type        = string
  default     = "flask-devops-app"
}

variable "docker_image" {
  description = "Docker image to deploy on the VM."
  type        = string
  default     = "benharbfarah/ci_cd_pipeline:latest"
}

variable "host_port" {
  description = "Port exposed on the Azure VM."
  type        = number
  default     = 80
}

variable "app_port" {
  description = "Port exposed by the Flask app inside the container."
  type        = number
  default     = 5000
}

variable "script_name" {
  description = "Name of the generated script file inside the VM extension."
  type        = string
  default     = "deploy_flask_app.sh"
}

variable "compose_project_name" {
  description = "Docker Compose project name used for the observability stack."
  type        = string
  default     = "flask-observability"
}

variable "grafana_admin_user" {
  description = "Grafana admin username created by Docker Compose."
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password for the demo stack."
  type        = string
  default     = "ChangeMe123!"
}
