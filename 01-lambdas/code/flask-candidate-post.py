import json
import boto3
import os

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
                "body": json.dumps({"error": "Candidate name is required"})
            }

        # Insert the candidate into the DynamoDB table
        response = dyndb_table.put_item(Item={"CandidateName": name})

        # Return a success response
        return {
            "statusCode": 200,
            "body": json.dumps({"CandidateName": name})
        }

    except Exception as e:
        # Handle unexpected errors
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Unable to update candidate", "details": str(e)})
        }
