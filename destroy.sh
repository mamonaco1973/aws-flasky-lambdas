export AWS_DEFAULT_REGION=us-east-2

# Navigate to the 01-lambdas directory
cd "01-lambdas"

# Initialize and apply Terraform configuration
echo "NOTE: Destroying API Gateway and Lambdas"
terraform init
terraform destroy -auto-approve

# Return to the parent directory
cd ..

