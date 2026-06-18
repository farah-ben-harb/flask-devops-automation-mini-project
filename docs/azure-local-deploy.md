# Azure local deployment path

If you do not have access to Microsoft Entra ID, you can still learn Terraform and deploy the app to your existing Azure VM from your own machine.

## Why this path is simpler

- no app registration
- no federated credential
- no GitHub OIDC setup
- no extra Azure identity permissions to configure

Terraform supports Azure authentication through the Azure CLI, so you can use your normal `az login` session locally.

## Steps

1. Sign in to Azure from your machine.

```powershell
az login
az account set --subscription acec6a34-0f38-4da1-9e5b-6335ff6efc80
az account show
```

2. Open the Terraform folder.

```powershell
cd "D:\Documents\Mini projects\automated ci-cd pipeline\infra\terraform\azure"
```

3. Create your Terraform variables file.

```powershell
copy terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and make sure it contains:

```hcl
resource_group_name = "myResourceGroupTerraform"
vm_name             = "myVM"
container_name      = "flask-devops-app"
docker_image        = "benharbfarah/ci_cd_pipeline:latest"
host_port           = 80
app_port            = 5000
compose_project_name = "flask-observability"
grafana_admin_user   = "admin"
grafana_admin_password = "ChangeMe123!"
```

4. Initialize Terraform.

```powershell
terraform init
```

5. Format and validate.

```powershell
terraform fmt -recursive
terraform validate
```

6. Preview the changes.

```powershell
terraform plan -var-file=terraform.tfvars
```

7. Apply the changes.

```powershell
terraform apply -var-file=terraform.tfvars
```

8. Verify the app.

- Open the VM public IP in your browser on port `80`
- Check the VM extension status in Azure Portal if the container does not start
- Open `http://<vm-public-ip>/health`
- Create an SSH tunnel to Grafana with `ssh -L 3000:127.0.0.1:3000 azureuser@<vm-public-ip>` and open `http://localhost:3000`

## What Terraform does

- finds the existing VM
- installs the Custom Script Extension
- installs Docker on the VM
- pulls the Docker Hub image
- runs the Flask container and the monitoring stack with Docker Compose
- writes Prometheus, Grafana, Alertmanager, node_exporter, cAdvisor, and blackbox exporter configs

## Common problems

- `az login` fails: use the Azure account that already has access to the subscription
- `Resource group not found`: confirm the resource group name
- `VM not found`: confirm the VM name
- app not reachable: open port `80` in the VM NSG
- extension failed: inspect the Custom Script Extension status in Azure Portal
- Grafana does not open in a browser: use the SSH tunnel, because it only listens on `127.0.0.1:3000`
- alerts do not send email: replace the SMTP placeholders in `infra/terraform/azure/monitoring/alertmanager/alertmanager.yml`
