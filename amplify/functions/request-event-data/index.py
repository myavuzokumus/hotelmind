import boto3
import json
import os
from boto3.dynamodb.conditions import Key
from datetime import datetime, timedelta
from decimal import Decimal

# DynamoDB table name
table_name = os.environ.get('DATA_TABLE', 'RoomEvent-23zg6kw7jvc7vd6hacyznny2w4-NONE')

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

iot_client = boto3.client('iot-data')

def handler(event, context):
    try:
        print(f"Event history request: {json.dumps(event)}")

        # Get request parameters
        room_id = event.get('roomId')
        request_id = event.get('requestId', 'unknown')

        if not room_id:
            return {'error': 'roomId is required'}

        # Get the latest data
        response = table.get_item(
            Key={
                'roomId': room_id
            }
        )

        # Get only the payload field
        item = response.get('Item', None)

        # Send response via MQTT
        response_topic = f"room/{room_id}/events/history/response"
        message = {
            'requestId': request_id,
            'timestamp': int(datetime.now().timestamp()),
            'payload': item['payload'] if item else []
        }

        iot_client.publish(
            topic=response_topic,
            qos=1,
            payload=json.dumps(message, cls=DecimalEncoder)
        )

        return {
            'statusCode': 200,
            'message': f"Response sent to {response_topic} topic"
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {'error': str(e)}


# Custom encoder for JSON - converts Decimal values to float
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)