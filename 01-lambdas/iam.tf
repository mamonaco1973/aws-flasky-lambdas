# Conditional creation of IAM user for invoking the function
resource "aws_iam_user" "flasky_user" {
  count = var.authorization_type == "AWS_IAM" ? 1 : 0  # Create only if authorization_type equals "AWS_IAM"
  name  = "flasky-api-user"  # The name assigned to the IAM user.
}

# Conditional creation of IAM policy for API Gateway access
resource "aws_iam_policy" "flasky_policy" {
  count       = var.authorization_type == "AWS_IAM" ? 1 : 0  # Create only if authorization_type equals "AWS_IAM"
  name        = "FlaskyAPIAccessPolicy"  # The name of the policy for identification.
  description = "Policy granting permissions to invoke API Gateway"  # Description of the policy's purpose.

  # Define the policy JSON to allow invoking API Gateway
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "execute-api:Invoke"
        Resource = "${aws_apigatewayv2_api.flask_api.execution_arn}/*" # Targets the specific API Gateway execution ARN.
      }
    ]
  })
}

# Conditional attachment of policy to the IAM user
resource "aws_iam_user_policy_attachment" "flasky_user_policy" {
  count      = var.authorization_type == "AWS_IAM" ? 1 : 0  # Attach policy only if authorization_type equals "AWS_IAM"
  user       = aws_iam_user.flasky_user[0].name  # Reference the first instance of the IAM user.
  policy_arn = aws_iam_policy.flasky_policy[0].arn  # Reference the first instance of the policy.
}

# Conditional creation of access key for programmatic access
resource "aws_iam_access_key" "flasky_access_key" {
  count = var.authorization_type == "AWS_IAM" ? 1 : 0  # Create access key only if authorization_type equals "AWS_IAM"
  user  = aws_iam_user.flasky_user[0].name  # Reference the first instance of the IAM user.
}

# Output the access key ID conditionally
output "access_key_id" {
  value       = var.authorization_type == "AWS_IAM" && length(aws_iam_access_key.flasky_access_key) > 0 ? aws_iam_access_key.flasky_access_key[0].id : null
  sensitive   = true  # Mark the output as sensitive to hide it in logs.
  description = "Access key ID for programmatic use"  # Description of the output.
}

# Output the secret access key conditionally
output "secret_access_key" {
  value       = var.authorization_type == "AWS_IAM" && length(aws_iam_access_key.flasky_access_key) > 0 ? aws_iam_access_key.flasky_access_key[0].secret : null
  sensitive   = true  # Mark the output as sensitive to hide it in logs.
  description = "Secret access key for programmatic use"  # Description of the output.
}
