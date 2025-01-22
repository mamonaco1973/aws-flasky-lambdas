import json  # Importing the `json` module to handle JSON serialization and deserialization.
import os    # Importing the `os` module to access environment variables and system-level information.

def lambda_handler(event, context):
    """
    AWS Lambda entry point. Handles incoming API Gateway requests and returns appropriate responses.
    
    Args:
        event (dict): The event payload from the invoking service (e.g., API Gateway).
        context (LambdaContext): Runtime information about the Lambda function (not used here).

    Returns:
        dict: HTTP response with status code, headers, and body.
    """

    # Attempt to extract query parameters from the event payload.
    # If no query parameters are provided, default to an empty dictionary.
    query_params = event.get('queryStringParameters', {})

    # Try to retrieve the "details" parameter from the query parameters, if it exists.
    # If the parameter is absent, `details` will be None.
    details = query_params.get("details", None) if query_params else None

    # Retrieve the instance ID or hostname of the current Lambda execution environment.
    # This uses the `os.uname().nodename` method to fetch system-level information.
    # Note: `os.uname()` is platform-dependent and may not always work in AWS Lambda.
    instance_id = os.uname().nodename

    # Conditional logic: Check if the "details" query parameter is provided.
    
    if details:
        # If "details" exists, return a JSON response with connection details.
        return {
            "statusCode": 200,  # HTTP 200 status indicates success.
            "headers": {
                "Content-Type": "application/json"  # Specify that the response body is in JSON format.
            },
            "body": json.dumps({                    # Convert the response dictionary to a JSON-formatted string.
                "connected": "true",                # Indicate that the Lambda function is connected.
                "hostname": instance_id             # Include the instance ID (or hostname) of the Lambda environment.
            })
        }
    else:
        # If "details" is not provided, return a minimal JSON response with an empty body.
        return {
            "statusCode": 200,                      # HTTP 200 status indicates success.
            "headers": {
                "Content-Type": "application/json"  # Specify that the response body is in JSON format.
            },
            "body": "{}"                            # An empty JSON object as the response body.
        }
