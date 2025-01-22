import json
import boto3
import os
from boto3.dynamodb.conditions import Key

# Initialize DynamoDB table
dynamo_table_name = 'Candidates'
dyndb_client = boto3.resource('dynamodb', region_name='us-east-2')
dyndb_table = dyndb_client.Table(dynamo_table_name)

def lambda_handler(event, context):
    try:
        # Extract the candidate name from the pathParameters
        name = event['pathParameters'].get('name')
        
        if not name:
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps({"error": "Candidate name is required"})
            }

        # Query the DynamoDB table for the candidate name
        response = dyndb_table.query(
            KeyConditionExpression=Key('CandidateName').eq(name)
        )

        # Check if items were returned
        items = response.get('Items', [])
        if not items:
            return {
                "statusCode": 404,
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps({"error": "Candidate not found"})
            }

        # Return the retrieved candidate(s)
        return {
            "statusCode": 200,
            "body": json.dumps(items),
            "headers": {
                "Content-Type": "application/json"
            }
        }

    except Exception as e:
        # Handle unexpected errors
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"error": "An error occurred", "details": str(e)})
        }
