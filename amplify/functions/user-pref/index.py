import boto3
import decimal
import json
import os
from boto3.dynamodb.conditions import Key

# DynamoDB table - Get table name from environment variable
table_name = os.environ.get('PREFERENCE_TABLE', 'UserPreference-23zg6kw7jvc7vd6hacyznny2w4-NONE')

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

iot_client = boto3.client('iot-data')

def handler(event, context):
    print(f"Incoming request: {json.dumps(event)}")  # Log request

    request_id = event.get('requestId')

    # Process two different request formats:
    # 1. MQTT requests with roomId directly in event
    # 2. Amplify v2 requests with roomId in arguments
    room_id = event.get('roomId')
    if room_id is None and 'arguments' in event:
        # For Amplify format requests
        room_id = event.get('arguments', {}).get('roomId')

    # Ensure roomId is a string
    if room_id is not None and not isinstance(room_id, str):
        room_id = str(room_id)
        print(f"roomId converted to string: {room_id}")

    if not room_id:
        print("Invalid roomId: Empty or None value")
        return {"statusCode": 400, "error": "Invalid roomId"}

    try:
        print(f"Querying DynamoDB: roomId={room_id}")

        # Fetch preference data by room ID
        response = table.query(
            KeyConditionExpression=Key('roomId').eq(room_id)
        )

        print(f"DynamoDB response: {json.dumps(response, cls=DecimalEncoder)}")

        # Get preference data or use default values
        if response['Items']:
            preference = response['Items'][0]
        else:
            # Use empty dictionary if no data, default values will be assigned with get() method
            preference = {}

        # Prepare response
        result = {
            "requestId": request_id,
            "userPreference": {
                "preferredTemperature": preference.get('preferredTemperature', 22.0),
                "preferredHumidity": preference.get('preferredHumidity', 50.0),
                "autoClimate": preference.get('autoClimate', True),
                "automaticLights": preference.get('automaticLights', True),
                "voiceReports": preference.get('voiceReports', False),
                "roomMode": preference.get('roomMode', 'comfort')
            }
        }

        # Send response to topic for MQTT requests
        payload = json.dumps(result, cls=DecimalEncoder)
        iot_client.publish(
            topic=f"room/{room_id}/preference/response",
            payload=payload
        )

        # Return JSON response for Amplify/HTTP requests
        return {
            "statusCode": 200,
            "body": result
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {"statusCode": 500, "error": str(e)}

# Custom encoder that can convert Decimal types to JSON
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)