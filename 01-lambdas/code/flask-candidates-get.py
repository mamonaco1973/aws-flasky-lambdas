import json   # Import the `json` module for serializing and deserializing JSON data.
import boto3  # Import the `boto3` library to interact with AWS services, specifically DynamoDB.
import os     # Import the `os` module for environment variables and system-level operations.

# Initialize the DynamoDB table
dynamo_table_name = 'Candidates'                                    # Define the name of the DynamoDB table to interact with.
dyndb_client = boto3.resource('dynamodb', region_name='us-east-2')  # Create a DynamoDB resource for the specified AWS region.
dyndb_table = dyndb_client.Table(dynamo_table_name)                 # Get a reference to the DynamoDB table.

def lambda_handler(event, context):
    """
    AWS Lambda function to retrieve all items (candidates) from a DynamoDB table.

    Args:
        event (dict): Input payload containing API Gateway request data (not used here).
        context (LambdaContext): Provides runtime information about the Lambda function (not used here).

    Returns:
        dict: HTTP response containing status code, headers, and body.
    """
    try:
        # Scan the DynamoDB table to retrieve all items (entire contents of the table).
        # Note: Scanning reads every item in the table, which can be inefficient for large datasets.
        response = dyndb_table.scan()  # Perform a scan operation to fetch all records.

        # Extract the list of items (candidates) from the scan response.
        # The 'Items' key contains the actual data retrieved from the DynamoDB table.
        items = response.get('Items', [])  # Default to an empty list if 'Items' is not present.

        # Check if no items were found in the table.
        if not items:
            # If the table is empty, return a 404 Not Found response with an appropriate error message.
            return {
                "statusCode": 404,                      # HTTP 404 indicates the resource (candidates) was not found.
                "headers": {
                    "Content-Type": "application/json"  # Specify JSON format for the response body.
                },
                "body": json.dumps(
                    {"error": "No candidates found"})   # Inform the client that no data was found.
            }

        # If items are found, return them as part of a 200 OK response.
        return {
            "statusCode": 200,                      # HTTP 200 indicates a successful operation.
            "headers": {
                "Content-Type": "application/json"  # Specify JSON format for the response body.
            },
            "body": json.dumps(items)               # Serialize the list of candidates into a JSON string.
        }

    except Exception as e:
        # Catch any unexpected errors that occur during the scan or response generation.
        # This includes issues like missing permissions, DynamoDB service outages, or invalid table configurations.
        return {
            "statusCode": 500,                      # HTTP 500 indicates a server-side error (Internal Server Error).
            "headers": {
                "Content-Type": "application/json"  # Specify JSON format for the response body.
            },
            "body": json.dumps({                    # Include detailed error information for debugging purposes.
                "error": "An error occurred",  
                "details": str(e)  
            })
        }
