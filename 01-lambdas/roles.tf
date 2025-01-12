
# IAM Role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name               = "flask-gtg-role" # Name of the IAM Role
  assume_role_policy = jsonencode({     # Trust policy allowing Lambda service to assume this role
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",               # Allow Lambda service to assume the role
        Principal = {
          Service = "lambda.amazonaws.com" # Specify Lambda as the trusted entity
        },
        Action = "sts:AssumeRole"       # Action to assume the role
      }
    ]
  })
}

# IAM Role Policy to grant permissions for the Lambda function
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "flask-gtg-policy"                 # Name of the policy
  role   = aws_iam_role.lambda_role.id       # Attach the policy to the IAM role
  policy = jsonencode({                      # Define the policy document in JSON format
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [                         # List of actions allowed on the DynamoDB table
          "dynamodb:Query",                  # Allow querying the table
          "dynamodb:PutItem",                # Allow adding items to the table
          "dynamodb:Scan"                    # Allow scanning the table
        ],
        Effect   = "Allow",                  # Grant the specified permissions
        Resource = "${aws_dynamodb_table.candidate-table.arn}" # Reference the table's ARN
      }
    ]
  })
}
