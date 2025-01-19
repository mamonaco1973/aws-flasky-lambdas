# Define the API Gateway resource for the Flask-based API
resource "aws_apigatewayv2_api" "flask_api" {
  name          = "flasky-api"     # Name of the API Gateway
  description   = "Flask(y) like APIs deployed with Lambda"
                                   # API Gateway Description
  protocol_type = "HTTP"           # Protocol type (HTTP or WEBSOCKET)
}

# Define the default deployment stage for the API Gateway
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.flask_api.id # Reference the API ID
  name        = "$default"                        # Use the default stage name
  auto_deploy = true                              # Automatically deploy changes
}

# Define routes for the API Gateway

# POST route for creating a candidate
resource "aws_apigatewayv2_route" "candidate_post" {
  api_id    = aws_apigatewayv2_api.flask_api.id                    # Reference the API ID
  route_key = "POST /candidate/{name}"                             # Define the route key
  target    = "integrations/${aws_apigatewayv2_integration.candidate_post_integration.id}" # Target integration
  authorization_type = var.authorization_type
}

# GET route for fetching a specific candidate
resource "aws_apigatewayv2_route" "candidate_get" {
  api_id    = aws_apigatewayv2_api.flask_api.id                    # Reference the API ID
  route_key = "GET /candidate/{name}"                              # Define the route key
  target    = "integrations/${aws_apigatewayv2_integration.candidate_get_integration.id}" # Target integration
  authorization_type = var.authorization_type
}

# GET route for fetching all candidates
resource "aws_apigatewayv2_route" "candidates_get" {
  api_id    = aws_apigatewayv2_api.flask_api.id                    # Reference the API ID
  route_key = "GET /candidates"                                    # Define the route key
  target    = "integrations/${aws_apigatewayv2_integration.candidates_get_integration.id}" # Target integration
  authorization_type = var.authorization_type
}

# GET route for the Good-to-Go (GTG) health check
resource "aws_apigatewayv2_route" "gtg_get" {
  api_id    = aws_apigatewayv2_api.flask_api.id                    # Reference the API ID
  route_key = "GET /gtg"                                           # Define the route key
  target    = "integrations/${aws_apigatewayv2_integration.gtg_get_integration.id}" # Target integration
  authorization_type = var.authorization_type
}

# Define integrations for each route

# Integration for POST /candidate/{name}
resource "aws_apigatewayv2_integration" "candidate_post_integration" {
  api_id                 = aws_apigatewayv2_api.flask_api.id # Reference the API ID
  integration_type       = "AWS_PROXY"                      # Use AWS_PROXY for Lambda integration
  integration_uri        = aws_lambda_function.flask_candidate_post.arn # Lambda function ARN
  payload_format_version = "2.0"                            # Payload format version
  request_parameters = {
    "overwrite:path" = "$request.path.name"                # Map the "name" path parameter
  }
}

# Integration for GET /candidate/{name}
resource "aws_apigatewayv2_integration" "candidate_get_integration" {
  api_id                 = aws_apigatewayv2_api.flask_api.id # Reference the API ID
  integration_type       = "AWS_PROXY"                       # Use AWS_PROXY for Lambda integration
  integration_uri        = aws_lambda_function.flask_candidate_get.arn # Lambda function ARN
  payload_format_version = "2.0"                             # Payload format version
  request_parameters = {
    "overwrite:path" = "$request.path.name"                  # Map the "name" path parameter
  }
}

# Integration for GET /candidates
resource "aws_apigatewayv2_integration" "candidates_get_integration" {
  api_id           = aws_apigatewayv2_api.flask_api.id     # Reference the API ID
  integration_type = "AWS_PROXY"                           # Use AWS_PROXY for Lambda integration
  integration_uri  = aws_lambda_function.flask_candidates_get.arn # Lambda function ARN
}

# Integration for GET /gtg
resource "aws_apigatewayv2_integration" "gtg_get_integration" {
  api_id                 = aws_apigatewayv2_api.flask_api.id # Reference the API ID
  integration_type       = "AWS_PROXY"                       # Use AWS_PROXY for Lambda integration
  integration_uri        = aws_lambda_function.flask_gtg.arn # Lambda function ARN
  payload_format_version = "2.0"                             # Payload format version
  request_parameters = {
    "overwrite:querystring.details" = "$request.querystring.details" # Map the "details" query string parameter
  }
}

# Define Lambda permissions to allow API Gateway to invoke the functions

# Permission for GTG Lambda function
resource "aws_lambda_permission" "flask_gtg_permission" {
  statement_id  = "AllowAPIGatewayInvoke"                      # Unique statement ID
  action        = "lambda:InvokeFunction"                     # Allow function invocation
  function_name = aws_lambda_function.flask_gtg.arn            # Reference the Lambda function ARN
  principal     = "apigateway.amazonaws.com"                  # Allow API Gateway
  source_arn    = "${aws_apigatewayv2_api.flask_api.execution_arn}/*" # Restrict to this API Gateway
}

# Permission for GET /candidate/{name} Lambda function
resource "aws_lambda_permission" "flask_get_candidate_permission" {
  statement_id  = "AllowAPIGatewayInvoke"                      # Unique statement ID
  action        = "lambda:InvokeFunction"                     # Allow function invocation
  function_name = aws_lambda_function.flask_candidate_get.arn  # Reference the Lambda function ARN
  principal     = "apigateway.amazonaws.com"                  # Allow API Gateway
  source_arn    = "${aws_apigatewayv2_api.flask_api.execution_arn}/*" # Restrict to this API Gateway
}

# Permission for GET /candidates Lambda function
resource "aws_lambda_permission" "flask_get_candidates_permission" {
  statement_id  = "AllowAPIGatewayInvoke"                      # Unique statement ID
  action        = "lambda:InvokeFunction"                     # Allow function invocation
  function_name = aws_lambda_function.flask_candidates_get.arn # Reference the Lambda function ARN
  principal     = "apigateway.amazonaws.com"                  # Allow API Gateway
  source_arn    = "${aws_apigatewayv2_api.flask_api.execution_arn}/*" # Restrict to this API Gateway
}

# Permission for POST /candidate/{name} Lambda function
resource "aws_lambda_permission" "flask_post_candidate_permission" {
  statement_id  = "AllowAPIGatewayInvoke"                      # Unique statement ID
  action        = "lambda:InvokeFunction"                     # Allow function invocation
  function_name = aws_lambda_function.flask_candidate_post.arn # Reference the Lambda function ARN
  principal     = "apigateway.amazonaws.com"                  # Allow API Gateway
  source_arn    = "${aws_apigatewayv2_api.flask_api.execution_arn}/*" # Restrict to this API Gateway
}

