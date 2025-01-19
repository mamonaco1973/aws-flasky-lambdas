#!/bin/bash

# Configuration

API_ID=$(aws apigatewayv2 get-apis --query "Items[?Name=='flasky-api'].{id:ApiId}" --output text)        

# Check if API_ID is empty or undefined
if [ -z "$API_ID" ]; then
  echo "ERROR: API_ID is not defined. Please ensure the API Gateway with the name 'flask-api' exists and AWS CLI is configured properly."
  exit 1
fi


SERVICE_URL="https://${API_ID}.execute-api.us-east-2.amazonaws.com"

cd ./01-lambdas
echo "NOTE: Testing the API Gateway Solution."
echo "NOTE: URL for API Solution is $SERVICE_URL/gtg?details=true"
./test_candidates.py $SERVICE_URL 

cd ..
