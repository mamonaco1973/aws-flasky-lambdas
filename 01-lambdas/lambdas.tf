# AWS Lambda function definitions for Flask-based application
# Ensure your Python files are zipped and stored in the specified paths.

# Lambda Function: flask-gtg (Good-to-Go health check endpoint)
resource "aws_lambda_function" "flask_gtg" {
  filename         = "./code/lambdas.zip"              # Path to the zipped Lambda function code
  function_name    = "flask-gtg"                        # Name of the Lambda function
  role             = aws_iam_role.lambda_role.arn       # IAM role with necessary permissions
  handler          = "flask-gtg.lambda_handler"         # Entry point for the Lambda function
  runtime          = "python3.13"                       # Python runtime version
  source_code_hash = filebase64sha256("./code/lambdas.zip") # Detects changes in code.zip
}

# Test Event Example for flask-gtg:
# {
#   "queryStringParameters": {
#     "details": "true"
#   }
# }

# Lambda Function: flask-candidate-get (Fetch a candidate by ID)
resource "aws_lambda_function" "flask_candidate_get" {
  filename         = "./code/lambdas.zip"                # Path to the zipped Lambda function code
  function_name    = "flask-candidate-get"               # Name of the Lambda function
  role             = aws_iam_role.lambda_role.arn        # IAM role with necessary permissions
  handler          = "flask-candidate-get.lambda_handler" # Entry point for the Lambda function
  runtime          = "python3.13"                        # Python runtime version
  source_code_hash = filebase64sha256("./code/lambdas.zip") # Detects changes in code.zip
}

# Lambda Function: flask-candidate-post (Add a new candidate)
resource "aws_lambda_function" "flask_candidate_post" {
  filename         = "./code/lambdas.zip"                 # Path to the zipped Lambda function code
  function_name    = "flask-candidate-post"               # Name of the Lambda function
  role             = aws_iam_role.lambda_role.arn         # IAM role with necessary permissions
  handler          = "flask-candidate-post.lambda_handler" # Entry point for the Lambda function
  runtime          = "python3.13"                         # Python runtime version
  source_code_hash = filebase64sha256("./code/lambdas.zip") # Detects changes in code.zip
}

# Test Event Example for flask-candidate-post:
# {
#   "pathParameters": {
#     "name": "John Smith"
#   }
# }

# Lambda Function: flask-candidates-get (Fetch all candidates)
resource "aws_lambda_function" "flask_candidates_get" {
  filename         = "./code/lambdas.zip"                 # Path to the zipped Lambda function code
  function_name    = "flask-candidates-get"               # Name of the Lambda function
  role             = aws_iam_role.lambda_role.arn         # IAM role with necessary permissions
  handler          = "flask-candidates-get.lambda_handler" # Entry point for the Lambda function
  runtime          = "python3.13"                         # Python runtime version
  source_code_hash = filebase64sha256("./code/lambdas.zip") # Detects changes in code.zip
}

# General Notes:
# - Replace "aws_iam_role.lambda_role.arn" with the ARN of the IAM role you created for Lambda execution.
# - Ensure the `handler` value matches the entry point defined in your Python code.
# - Pre-zip your Python scripts and store them in the `./code/` directory.
