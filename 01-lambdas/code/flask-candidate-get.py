import json                                # Import the `json` module for handling JSON serialization and deserialization.
import boto3                               # Import the `boto3` library to interact with AWS services, particularly DynamoDB.
import os                                  # Import the `os` module for environment variable and system-level interactions.
from boto3.dynamodb.conditions import Key  # Import `Key` for constructing DynamoDB query conditions.

# Initialize the DynamoDB table
dynamo_table_name = 'Candidates'                                    # Name of the DynamoDB table being accessed.
dyndb_client = boto3.resource('dynamodb', region_name='us-east-2')  # Create a DynamoDB resource in the specified AWS region.
dyndb_table = dyndb_client.Table(dynamo_table_name)                 # Access the DynamoDB table using its name.

def lambda_handler(event, context):
    """
    AWS Lambda function to fetch candidate details from a DynamoDB table based on the candidate name.
    
    Args:
        event (dict): Input payload containing API Gateway request data, including `pathParameters`.
        context (LambdaContext): Provides runtime information about the Lambda function.

    Returns:
        dict: HTTP response containing status code, headers, and body.
    """
    try:
        # Extract the candidate name from the event's `pathParameters`.
        # `pathParameters` contain dynamic URL segments provided by API Gateway.
        name = event['pathParameters'].get('name')
        
        # If the candidate name is not provided, return a 400 Bad Request response.
        if not name:
            return {
                "statusCode": 400,                           # HTTP status code for a client error (Bad Request).
                "headers": {
                    "Content-Type": "application/json"       # Specify the response body format as JSON.
                },
                "body": json.dumps(
                    {"error": "Candidate name is required"})  # Inform the client of the missing name.
            }

        # Query the DynamoDB table to retrieve records where the 'CandidateName' matches the provided name.
        response = dyndb_table.query(
            KeyConditionExpression=Key('CandidateName').eq(name)  # Filter based on the candidate name.
        )

        # Extract the 'Items' field from the query response, which contains the matching records.
        items = response.get('Items', [])
        
        # If no matching items are found, return a 404 Not Found response.
        if not items:
            return {
                "statusCode": 404,                      # HTTP status code for resource not found.
                "headers": {
                    "Content-Type": "application/json"  # Specify the response body format as JSON.
                },
                "body": json.dumps(
                    {"error": "Candidate not found"})   # Inform the client that no match was found.
            }

        # If matching items are found, return them in the response with a 200 OK status.
        return {
            "statusCode": 200,                      # HTTP status code for a successful response.
            "body": json.dumps(items),              # Serialize the list of items into a JSON string.
            "headers": {
                "Content-Type": "application/json"  # Specify the response body format as JSON.
            }
        }

    except Exception as e:
        # Catch any unexpected errors that occur during execution.
        return {
            "statusCode": 500,                      # HTTP status code for an internal server error.
            "headers": {
                "Content-Type": "application/json"  # Specify the response body format as JSON.
            },
            "body": json.dumps({                    # Serialize error details into a JSON string.
                "error": "An error occurred",       # General error message.
                "details": str(e)                   # Include the exception details for debugging purposes.
            })
        }
