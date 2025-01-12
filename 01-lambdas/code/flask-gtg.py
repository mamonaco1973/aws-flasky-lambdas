import json
import os

def lambda_handler(event, context):
    # Parse query parameters
    query_params = event.get('queryStringParameters', {})
    details = query_params.get("details", None) if query_params else None
    instance_id = os.uname().nodename
    
    # Response logic
    if details:
        return {
            "statusCode": 200,
            "body": json.dumps({
                "connected": "true",
                "hostname": instance_id
            })
        }
    else:
        return {
            "statusCode": 200,
            "body": ""
        }
