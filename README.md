# Flask Azure DevOps Pipeline

Automated Flask application deployment on Azure with GitHub Actions, Docker, Terraform, and a full observability stack.

## Summary

This project demonstrates a realistic Cloud & DevOps workflow:

- develop a Flask application
- validate it with Pytest
- package it as a Docker image
- publish the image to Docker Hub
- deploy automatically to an existing Azure Linux VM
- monitor the app and host with Prometheus and Grafana

It is designed as a portfolio project for CI/CD, Infrastructure as Code, and observability practice.

## Core Features

- Flask app with `/`, `/health`, and `/metrics`
- automated tests with Pytest
- Docker image build and Docker Hub push
- GitHub Actions CI/CD pipeline
- Terraform-based Azure deployment
- Prometheus, Grafana, Alertmanager, node_exporter, cAdvisor, and blackbox exporter

## Tech Stack

- Python 3.10
- Flask
- Pytest
- Docker
- GitHub Actions
- Docker Hub
- Terraform
- Azure VM
- Prometheus
- Grafana
- Alertmanager
- node_exporter
- cAdvisor
- blackbox exporter

## Repository Layout

```text
flask-azure-devops-pipeline/
├── app.py
├── requirements.txt
├── Dockerfile
├── tests/
│   └── test_app.py
├── .github/
│   └── workflows/
│       ├── ci-cd.yml
│       └── terraform-azure.yml
├── infra/
│   └── terraform/
│       └── azure/
│           ├── main.tf
│           ├── locals.tf
│           ├── outputs.tf
│           ├── variables.tf
│           ├── versions.tf
│           ├── terraform.tfvars.example
│           ├── scripts/
│           │   └── deploy_observability.sh.tftpl
│           └── monitoring/
│               ├── docker-compose.yml
│               ├── prometheus/
│               ├── alertmanager/
│               ├── blackbox/
│               └── grafana/
└── docs/
```

## CI/CD Flow

The main workflow in `.github/workflows/ci-cd.yml` runs on every push and pull request:

1. run Pytest
2. validate the monitoring configuration
3. build the Docker image
4. push the image to Docker Hub on `main`
5. redeploy the Azure VM via Terraform on the self-hosted runner

## Terraform Flow

The Terraform workflow in `.github/workflows/terraform-azure.yml`:

1. runs on the self-hosted runner installed on `myVM`
2. authenticates with the VM managed identity
3. formats, initializes, validates, plans, and applies Terraform
4. updates the VM extension that deploys the stack

## Observability

The observability stack runs on the same VM as the Flask app.

- Prometheus scrapes `/metrics`, `node_exporter`, `cAdvisor`, and `/health`
- Grafana visualizes request rate, latency, and VM metrics
- Alertmanager is prepared to forward alerts by email

## Quick Start

### Local development

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
pytest -q
python app.py
```

Open:

- `http://127.0.0.1:5000/`
- `http://127.0.0.1:5000/health`
- `http://127.0.0.1:5000/metrics`

### Docker

```powershell
docker build -t benharbfarah/ci_cd_pipeline .
docker run -p 5000:5000 benharbfarah/ci_cd_pipeline
```

## Azure Access

- app host: `http://<vm-public-ip>/`
- health check: `http://<vm-public-ip>/health`
- Grafana: SSH tunnel to `localhost:3000`
- Prometheus: SSH tunnel to `localhost:9090`

Grafana login:

- user: `admin`
- password: `ChangeMe123!`

## Required GitHub Secrets and Variables

Secrets:

- `DOCKERHUB_TOKEN`
- `AZURE_SUBSCRIPTION_ID`

Variables:

- `AZURE_RESOURCE_GROUP`
- `AZURE_VM_NAME`

## Azure Notes

- the VM must be Linux
- the VM must have a system-assigned managed identity
- that identity must have `Contributor` on `myResourceGroupTerraform`
- Grafana stays private and is accessed through SSH tunneling

## Testing the Pipeline

1. push a change to a feature branch
2. verify tests run in GitHub Actions
3. open a pull request and confirm validation passes
4. push to `main` and confirm Docker Hub gets a new image
5. confirm Terraform redeploys the VM extension
6. open the app in the browser and verify `/health`
7. open Grafana and verify dashboards update after a few requests

## Common Issues

- `publickey` SSH error: check the SSH key path and permissions
- `node` missing on the runner: install Node.js on `myVM`
- `docker compose` missing: install the Compose v2 plugin
- `404 /metrics`: the VM is still running an older image
- `Connection refused` on port 80: the Flask container is not running
- Terraform `403`: the VM identity does not have the correct RBAC role

## Project Goal

This repository is a practical example of a modern Cloud & DevOps delivery pipeline:

- source control with GitHub
- automated CI with GitHub Actions
- containerization with Docker
- infrastructure as code with Terraform
- deployment on Azure
- monitoring with Prometheus and Grafana
