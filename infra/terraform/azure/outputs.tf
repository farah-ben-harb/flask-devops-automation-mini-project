output "resource_group_name" {
  description = "Resource group that contains the VM."
  value       = data.azurerm_resource_group.target.name
}

output "vm_id" {
  description = "ID of the target VM."
  value       = data.azurerm_virtual_machine.target.id
}

output "extension_id" {
  description = "ID of the VM extension that deploys the observability stack."
  value       = azurerm_virtual_machine_extension.deploy_app.id
}

output "next_steps" {
  description = "Reminder of what to check after apply."
  value       = "Open the Flask app on port 80, then create an SSH tunnel to localhost:3000 to reach Grafana."
}

output "grafana_access" {
  description = "Recommended way to access Grafana securely."
  value       = "ssh -L 3000:127.0.0.1:3000 azureuser@<vm-public-ip> then open http://localhost:3000"
}
