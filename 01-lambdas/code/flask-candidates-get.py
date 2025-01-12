import json
import boto3
import os

# Initialize DynamoDB
dynamo_table_name = 'Candidates'
dyndb_client = boto3.resource('dynamodb', region_name='us-east-2')
dyndb_table = dyndb_client.Table(dynamo_table_name)

def lambda_handler(event, context):
    try:
        # Scan the DynamoDB table to retrieve all candidates
        response = dyndb_table.scan()
        items = response.get('Items', [])
        
        # If no items found, return 404
        if not items:
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "No candidates found"})
            }
        
        # Return the list of candidates
        return {
            "statusCode": 200,
            "body": json.dumps(items)
        }

    except Exception as e:
        # Handle unexpected errors
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "An error occurred", "details": str(e)})
        }
