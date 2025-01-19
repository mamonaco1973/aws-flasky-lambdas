# Execute check_env.ps1 and capture its return code
./check_env.ps1
$returnCode = $LASTEXITCODE

# Check if the return code indicates failure
if ($returnCode -ne 0) {
    Write-Host "ERROR: check_env.ps1 failed with exit code $returnCode. Stopping the script." -ForegroundColor Red
    exit $returnCode
}

# Navigate to the 01-lambdas directory
Set-Location -Path "01-lambdas"
Write-Host "NOTE: Zipping lambda code into lambda.zip"

# Navigate to the code directory and create the zip file
Set-Location -Path "code"
Remove-Item -Path "lambdas.zip" -Force -ErrorAction SilentlyContinue
Compress-Archive -Path *.py -DestinationPath "lambdas.zip" -Force
Set-Location -Path ..

# Initialize and apply Terraform configuration
Write-Host "NOTE: Building API Gateway and Lambdas"
terraform init
terraform apply -auto-approve

# Return to the parent directory
Set-Location -Path ..

./validate.ps1