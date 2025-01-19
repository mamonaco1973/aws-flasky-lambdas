# Create an IAM user for invoking the function
resource "aws_iam_user" "flasky_user" {
  name = "flasky-api-user"  # The name assigned to the IAM user. This user will be used specifically for invoking API Gateway.
}

# Create an IAM policy that allows the user to invoke API Gateway
resource "aws_iam_policy" "flasky_policy" {
  name        = "FlaskyAPIAccessPolicy" # The name of the policy for clear identification.
  description = "Policy granting permissions to invoke API Gateway" # A description to document the purpose of this policy.

  # The policy is defined using JSON. It allows invoking API Gateway endpoints.
  policy      = jsonencode({
    Version = "2012-10-17" # Specifies the version of the IAM policy language. This is the standard version.
    Statement = [          # List of permissions or actions the policy grants.
      {
        Effect   = "Allow" # Specifies that the action is allowed.
        Action   = "execute-api:Invoke" # Grants the ability to invoke API Gateway endpoints.
        Resource = "${aws_apigatewayv2_api.flask_api.execution_arn}/*" # Targets the specific API Gateway resource (execution ARN) and all its stages/methods.
      }
    ]
  })
}

# Attach the previously created policy to the IAM user
resource "aws_iam_user_policy_attachment" "flasky_user_policy" {
  user       = aws_iam_user.flasky_user.name # The IAM user to whom the policy will be attached.
  policy_arn = aws_iam_policy.flasky_policy.arn # The ARN (Amazon Resource Name) of the policy being attached.
}

# (Optional) Create an access key for the IAM user to enable programmatic access
resource "aws_iam_access_key" "flasky_access_key" {
  user = aws_iam_user.flasky_user.name # Specifies the IAM user for whom the access key will be generated.
}

# Output the access key ID (use with caution in production to avoid accidental exposure)
output "access_key_id" {
  value       = aws_iam_access_key.flasky_access_key.id # Outputs the generated access key ID for programmatic use.
  sensitive   = true  # Marks the output as sensitive, ensuring it does not appear in plain text in Terraform logs or output.
}

# Output the secret access key (use securely and never expose publicly)
output "secret_access_key" {
  value       = aws_iam_access_key.flasky_access_key.secret # Outputs the secret access key, which must be securely stored.
  sensitive   = true  # Marks the output as sensitive to avoid accidental exposure in logs or output.
}
