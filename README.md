# Flask DevOps Automation Mini Project

A practical Flask project that demonstrates a complete CI/CD workflow with GitHub Actions, Docker, Pytest, Docker Hub, Terraform-based infrastructure as code on Azure, and a real observability stack with Prometheus and Grafana.

## Overview

This repository is a hands-on DevOps learning project. It shows how to:

- build a small Flask application
- test it automatically with Pytest
- package it with Docker
- run CI on every push and pull request
- publish a Docker image to Docker Hub from GitHub Actions
- deploy the Docker image onto an existing Azure Linux VM with Terraform
- observe the app and VM with Prometheus, Grafana, Alertmanager, node_exporter, cAdvisor, and blackbox exporter

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

## Project Structure

```text
flask-devops-automation-mini-project/
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
│           ├── outputs.tf
│           ├── scripts/
│           │   └── deploy_observability.sh.tftpl
│           ├── locals.tf
│           ├── monitoring/
│           │   ├── alertmanager/
│           │   │   └── alertmanager.yml
│           │   ├── blackbox/
│           │   │   └── blackbox.yml
│           │   ├── docker-compose.yml
│           │   ├── grafana/
│           │   │   ├── dashboards/
│           │   │   │   └── flask-observability.json
│           │   │   └── provisioning/
│           │   │       ├── dashboards/
│           │   │       │   └── dashboards.yml
│           │   │       └── datasources/
│           │   │           └── datasource.yml
│           │   └── prometheus/
│           │       ├── prometheus.yml
│           │       └── rules.yml
│           ├── terraform.tfvars.example
│           ├── variables.tf
│           └── versions.tf
├── docs/
│   ├── architecture.md
│   ├── azure-local-deploy.md
│   ├── cv-description.md
│   └── linkedin-description.md
└── README.md
```

## Application Features

- `GET /` returns a JSON welcome message
- `GET /health` returns a simple health check response
- `GET /metrics` exposes Prometheus metrics for request count and latency

## Concepts Covered

- **CI**: automatically validate code on every change
- **CD**: automatically deliver or deploy code after validation
- **Pipeline**: a chain of automated stages
- **Workflow**: the GitHub Actions YAML file that defines the pipeline
- **Job**: a group of related steps executed on a runner
- **Step**: one action inside a job
- **Runner**: the machine that executes the workflow
- **Docker Image**: the packaged application artifact
- **Docker Container**: a running instance of the image
- **Docker Registry**: a service that stores Docker images
- **Docker Hub**: the registry used in this project
- **GitHub Secrets**: secure storage for sensitive values
- **Environment Variables**: runtime configuration outside the code
- **Automated Tests**: repeatable checks that protect the application
- **Build**: create the Docker image
- **Deploy**: run the application on a target environment
- **Terraform**: infrastructure as code for Azure resources
- **Prometheus**: collects metrics by scraping HTTP endpoints
- **Grafana**: visualizes metrics and dashboards
- **Alertmanager**: routes alerts to email
- **node_exporter**: exposes VM-level metrics
- **cAdvisor**: exposes container metrics
- **blackbox exporter**: probes the app like an external user

## Local Setup

### 1. Create a virtual environment

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### 2. Install dependencies

```powershell
pip install -r requirements.txt
```

### 3. Run the tests

```powershell
pytest -q
```

### 4. Start the application

```powershell
python app.py
```

Open:

- `http://127.0.0.1:5000/`
- `http://127.0.0.1:5000/health`
- `http://127.0.0.1:5000/metrics`

## Run with Docker

```powershell
docker build -t benharbfarah/ci_cd_pipeline .
docker run -p 5000:5000 benharbfarah/ci_cd_pipeline
```

## CI/CD Workflow

The GitHub Actions workflow does the following:

- runs Pytest on every `push` and `pull_request`
- builds the Docker image on every `push`
- pushes the Docker image to Docker Hub on `main` when `DOCKERHUB_TOKEN` is configured

This project now has two GitHub Actions workflows:

- `.github/workflows/ci-cd.yml` for application CI/CD and monitoring validation
- `.github/workflows/terraform-azure.yml` for manual Terraform plan/apply fallback

On a push to `main`, `.github/workflows/ci-cd.yml` now:

1. runs the tests
2. validates the monitoring stack
3. builds and pushes the Docker image to Docker Hub
4. runs Terraform automatically to redeploy the Azure VM extension and refresh the stack

Because GitHub runners are ephemeral and this project does not use a remote Terraform backend yet, the workflow first imports the existing VM extension into the runner state before planning and applying.

## GitHub Configuration

Add this secret in your GitHub repository:

- `DOCKERHUB_TOKEN`

## Docker Hub Configuration

1. Make sure the Docker Hub repository `benharbfarah/ci_cd_pipeline` exists
2. Generate a Docker Hub access token
3. Add that token to GitHub Secrets as `DOCKERHUB_TOKEN`

## Infrastructure as Code with Terraform

Terraform adds an Azure deployment layer to this project. It does not create a new VM here; instead, it manages a **VM extension** on your existing Azure Linux VM so the app can be deployed automatically and repeatedly.

### What Terraform manages

- the existing VM reference
- a Custom Script extension
- Docker installation on the VM
- the Flask container on port `80`
- the Prometheus monitoring stack
- Grafana on `127.0.0.1:3000`
- Alertmanager, node_exporter, cAdvisor, and blackbox exporter

### Terraform workflow

The workflow in `.github/workflows/terraform-azure.yml`:

1. checks out the repository
2. installs Terraform
3. runs on a self-hosted runner hosted on your Azure VM
4. logs into Azure with the VM managed identity
5. runs `terraform fmt`
6. runs `terraform init`
7. runs `terraform validate`
8. runs `terraform plan`
9. uploads the generated plan as an artifact
10. optionally runs `terraform apply` by reusing that saved plan

If you do not have Microsoft Entra access, this self-hosted runner path is the one to use.

### GitHub secrets and variables

Create these repository secrets:

- `AZURE_SUBSCRIPTION_ID`

Create these repository variables:

- `AZURE_RESOURCE_GROUP`
- `AZURE_VM_NAME`

The self-hosted runner itself must be registered in GitHub and labeled `azure-vm`.

### Azure setup

You need:

- an Azure VM running Linux
- the VM system-assigned managed identity enabled
- a Contributor role assignment for that identity on `myResourceGroupTerraform`
- an inbound rule that allows TCP port `80` to the VM if you want browser access
- no public port for Grafana; use an SSH tunnel to `localhost:3000`

See `docs/azure-self-hosted-runner.md` for the full runner setup on `myVM`.

If you still cannot configure the managed identity or the role assignment, use the local deployment path in `docs/azure-local-deploy.md` as a fallback.

### Local Terraform commands

```powershell
cd infra/terraform/azure
copy terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
```

The local commands work after you run `az login` in the same terminal session.

To apply the extension:

```powershell
terraform apply -var-file=terraform.tfvars
```

### Common Terraform issues

- `Resource group not found`: verify `AZURE_RESOURCE_GROUP`
- `VM not found`: verify `AZURE_VM_NAME`
- `Unauthorized` or `403`: the Azure role assignment or federated credentials are incomplete
- `Terraform auth fails locally`: run `az login` and `az account set --subscription acec6a34-0f38-4da1-9e5b-6335ff6efc80`
- `CustomScript` fails: check the VM extension status in Azure and the VM’s serial console / boot diagnostics
- `Port 80 already in use`: stop the old container on the VM before reapplying Terraform
- `Image pull failed`: confirm the Docker Hub image exists and is public or that the VM has access to it
- `App not reachable in browser`: verify the Network Security Group and the OS firewall allow port `80`
- `Grafana not reachable`: create an SSH tunnel to `127.0.0.1:3000` from the VM

## Observability Stack

The observability layer runs on the same Azure VM as the Flask app.

### Components

- **Flask app** exposes `/metrics` and `/health`
- **Prometheus** scrapes the app, VM, containers, and health probe
- **Grafana** visualizes app and VM metrics
- **Alertmanager** routes alert notifications by email
- **node_exporter** exposes VM CPU, RAM, and disk metrics
- **cAdvisor** exposes container usage metrics
- **blackbox exporter** checks the `/health` endpoint like a real user

### Ports

- `80`: Flask app
- `3000`: Grafana, bound to `127.0.0.1` for SSH-tunnel access
- `9090`: Prometheus, not published publicly
- `9093`: Alertmanager, not published publicly

### Grafana access

From your computer:

```powershell
ssh -L 3000:127.0.0.1:3000 azureuser@<vm-public-ip>
```

Then open:

- `http://localhost:3000`

### Alerts

The default Alertmanager config includes an email receiver template.
Replace the SMTP placeholders in `infra/terraform/azure/monitoring/alertmanager/alertmanager.yml` with your real provider details when you want actual emails.

## How to Test the Pipeline

### Test 1: Validate CI without Docker Hub publishing

1. Push a small change to any branch.
2. Open the GitHub repository.
3. Go to the `Actions` tab.
4. Confirm that the `Run tests` job passes.
5. Confirm that the `Build and push Docker image` job builds successfully.

### Test 2: Test pull request validation

1. Create a new branch.
2. Make a small code change.
3. Open a pull request to `main`.
4. Check that the workflow runs automatically.
5. Confirm the tests pass before merge.

### Test 3: Test Docker Hub publishing

After adding `DOCKERHUB_TOKEN`:

1. Push a commit directly to `main`.
2. Open the `Actions` tab in GitHub.
3. Wait for the workflow to finish successfully.
4. Open Docker Hub.
5. Confirm that the image `benharbfarah/ci_cd_pipeline` appears with tags like:
   - `latest`
   - the commit SHA

### Test 4: Test Terraform plan

1. Open GitHub Actions.
2. Make sure the self-hosted runner is online.
3. Run the `Terraform Azure VM` workflow.
4. Choose `plan`.
5. Confirm `terraform fmt`, `terraform init`, `terraform validate`, and `terraform plan` succeed.

### Test 5: Test Terraform apply

1. Set `AZURE_SUBSCRIPTION_ID`, `AZURE_RESOURCE_GROUP`, and `AZURE_VM_NAME`.
2. Run the `Terraform Azure VM` workflow.
3. Choose `apply`.
4. Wait for the workflow to finish.
5. Open the VM public IP in your browser on port `80` and verify the Flask app is reachable.

### Test 6: Test monitoring

1. Apply the Terraform deployment locally or through GitHub Actions.
2. Open the app on port `80`.
3. Visit `http://<vm-public-ip>/health`.
4. SSH tunnel to Grafana and open `http://localhost:3000`.
5. Confirm the dashboard shows request rate, latency, and VM CPU usage.
6. Stop the Flask container on the VM and confirm the `FlaskAppDown` and `FlaskHealthCheckFailed` alerts fire.

## Expected Result

When the pipeline is healthy:

- tests pass
- the Docker image is built
- the image is pushed to Docker Hub on `main`
- Terraform can plan and apply the Azure VM extension
- the Flask app is reachable from the Azure VM public IP
- Grafana shows the observability dashboard
- Alertmanager is ready to send email alerts

## Common Issues

- `ModuleNotFoundError: No module named 'app'`: make sure the workflow sets `PYTHONPATH`
- `pytest` not found: install dependencies in the virtual environment
- Docker login failure: verify `DOCKERHUB_TOKEN`
- Image not pushed: confirm the commit was made on `main`
- Workflow not triggered: verify the file is in `.github/workflows/`
- Azure deployment not running: verify the VM is Linux and the Custom Script extension succeeded
- Grafana dashboard empty: wait one scrape interval and confirm Prometheus targets are `UP`

## Next Improvements

- add linting with `ruff`
- add integration tests
- add rollback support
- add image vulnerability scanning
- move Terraform state to an S3 backend
- add a load balancer and autoscaling
- move Grafana behind authentication and a private network
- add Slack or Teams notifications in Alertmanager
