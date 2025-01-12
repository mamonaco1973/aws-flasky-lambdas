# Navigate to the 01-lambdas directory
Set-Location -Path "01-lambdas"

# Initialize and apply Terraform configuration
Write-Host "NOTE: Destroying API Gateway and Lambdas"
terraform init
terraform destroy -auto-approve

# Return to the parent directory
Set-Location -Path ..
