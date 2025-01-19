# Retrieve the API ID for the API Gateway with the name 'flask-api'
$API_ID = (aws apigatewayv2 get-apis --query "Items[?Name=='flasky-api'].{id:ApiId}" --output text)

# Check if API_ID is empty
if ([string]::IsNullOrWhiteSpace($API_ID)) {
    Write-Error "Error: API_ID is not set or could not be retrieved. Please ensure the API Gateway 'flask-api' exists."
    exit 1
}

# Construct the Service URL
$SERVICE_URL = "https://${API_ID}.execute-api.us-east-2.amazonaws.com"

# Output notes and test the API Gateway Solution
Write-Host "NOTE: Testing the API Gateway Solution."
Write-Host "NOTE: URL for API Solution is $SERVICE_URL/gtg?details=true"

# Execute the Python script with the Service URL
./01-lambdas/test_candidates.ps1 $SERVICE_URL
