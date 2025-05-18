#!/bin/bash

export AWS_DEFAULT_REGION=us-east-2

./check_env.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi


# Navigate to the 01-lambdas directory
cd "01-lambdas" 
echo "NOTE: Zipping lambda code into lambda.zip"

# Navigate to the code directory and create the zip file
cd "code" 
rm -f "lambdas.zip"  # Remove existing zip file if it exists
zip "lambdas.zip" *.py  # Create a zip file with all .py files
cd .. 

# Initialize and apply Terraform configuration
echo "NOTE: Building API Gateway and Lambdas"
terraform init
terraform apply -auto-approve

# Return to the parent directory
cd .. 

# Execute the validation script
./validate.sh


