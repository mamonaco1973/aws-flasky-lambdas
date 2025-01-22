import json   # Import the `json` module to handle JSON serialization and deserialization.
import boto3  # Import the `boto3` library to interact with AWS services, specifically DynamoDB.
import os     # Import the `os` module for environment variable and system-level interactions.

# Initialize the DynamoDB table
dynamo_table_name = 'Candidates'                                    # Define the name of the DynamoDB table.
dyndb_client = boto3.resource('dynamodb', region_name='us-east-2')  # Create a DynamoDB resource for the specified AWS region.
dyndb_table = dyndb_client.Table(dynamo_table_name)                 # Get a reference to the DynamoDB table.

def lambda_handler(event, context):
    """
    AWS Lambda function to add a new candidate to the DynamoDB table.

    Args:
        event (dict): Input payload containing API Gateway request data (e.g., pathParameters).
        context (LambdaContext): Provides runtime information about the Lambda function.

    Returns:
        dict: HTTP response with status code, headers, and body.
    """
    try:
        # Attempt to extract the 'name' parameter from the event's `pathParameters`.
        # `pathParameters` are dynamic segments from the API Gateway URL.
        name = event['pathParameters'].get('name')
        
        # Validate that the 'name' parameter is provided.
        if not name:
            # If 'name' is missing, return a 400 Bad Request response with an error message.
            return {
                "statusCode": 400,                            # HTTP 400 indicates a client-side error (Bad Request).
                "headers": {
                    "Content-Type": "application/json"        # Specify JSON format for the response body.
                },
                "body": json.dumps(
                    {"error": "Candidate name is required"})  # Inform the client about the missing parameter.
            }

        # Insert a new item into the DynamoDB table with the provided candidate name.
        # The `put_item` method adds or replaces an item with the specified primary key.
        response = dyndb_table.put_item(Item={"CandidateName": name})

        # If the insertion is successful, return a 200 OK response with the candidate name.
        return {
            "statusCode": 200,                           # HTTP 200 indicates a successful operation.
            "headers": {
                "Content-Type": "application/json"       # Specify JSON format for the response body.
            },
            "body": json.dumps({"CandidateName": name})  # Respond with the newly added candidate's name.
        }

    except Exception as e:
        # Catch any unexpected errors that occur during execution.
        # This includes DynamoDB access errors, missing permissions, or AWS SDK issues.
        return {
            "statusCode": 500,                      # HTTP 500 indicates a server-side error (Internal Server Error).
            "headers": {
                "Content-Type": "application/json"  # Specify JSON format for the response body.
            },
            "body": json.dumps({                    # Include detailed error information for debugging purposes.
                "error": "Unable to update candidate",  
                "details": str(e)                        
            })
        }
