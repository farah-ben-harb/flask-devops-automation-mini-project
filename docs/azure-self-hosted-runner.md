# Azure self-hosted runner on `myVM`

This guide sets up option 2: a GitHub Actions self-hosted runner on your existing Azure VM.

## Why this option works

- no Microsoft Entra app registration required
- GitHub Actions runs directly on the VM
- Terraform uses the VM managed identity through `az login --identity`

## 1) Enable the VM managed identity

In Azure Portal:

1. Open `myVM`
2. Go to `Identity`
3. Turn `System assigned` to `On`
4. Save

## 2) Give the identity access to the Resource Group

In Azure Portal:

1. Open `myResourceGroupTerraform`
2. Go to `Access control (IAM)`
3. Add role assignment
4. Choose `Contributor`
5. Assign it to the VM managed identity

If you want a more restrictive setup later, you can try `Virtual Machine Contributor`, but `Contributor` is simpler for learning.

## 3) Create the GitHub self-hosted runner

In GitHub:

1. Open your repository
2. Go to `Settings`
3. Click `Actions`
4. Click `Runners`
5. Click `New self-hosted runner`
6. Choose `Linux` and `x64`

GitHub will show you a registration token and the exact commands to run.

## 4) Install the runner on the VM

SSH into the VM:

```bash
ssh -i /home/farah/newkey.pem azureuser@4.223.128.175
```

Then run the commands GitHub shows you. The flow is usually:

```bash
mkdir actions-runner && cd actions-runner
curl -o actions-runner.tar.gz -L <github-runner-download-url>
tar xzf actions-runner.tar.gz
./config.sh --url https://github.com/farah-ben-harb/flask-devops-automation-mini-project --token <RUNNER_TOKEN> --labels azure-vm --unattended
sudo ./svc.sh install
sudo ./svc.sh start
```

## 5) Verify the runner

Back in GitHub:

- the runner should appear as `Idle`
- the label should include `azure-vm`

## 6) Verify Azure auth on the VM

On the VM:

```bash
az login --identity
az account set --subscription acec6a34-0f38-4da1-9e5b-6335ff6efc80
az account show
```

If this fails, the VM identity is not enabled or does not have the right role.

## 7) Test the pipeline

1. Push code to `main`
2. GitHub Actions should run tests and build the Docker image
3. The Terraform deploy job should run on the self-hosted runner
4. Terraform should update the VM extension and restart the stack if needed

## Troubleshooting

- `Runner offline`: the service is not started or the token expired
- `az login --identity` fails: enable the VM identity and reassign the role
- `terraform plan` fails with `403`: the VM identity needs access to the Resource Group
- workflow never reaches deploy: check that the runner label in the workflow matches `azure-vm`
