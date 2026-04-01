import boto3
import decimal
import json
import os
import time
from boto3.dynamodb.conditions import Key

# DynamoDB table name
table_name = os.environ.get('DATA_TABLE', 'RoomControl-23zg6kw7jvc7vd6hacyznny2w4-NONE')

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

iot_client = boto3.client('iot-data')

def handler(event, context):
    print(f"Incoming request: {json.dumps(event)}")  # Log incoming request

    try:
        # Extract parameters from different request formats
        request_id = event.get('requestId')

        # 1. Directly inside event or 2. parameter inside arguments in Amplify format
        room_id = event.get('roomId')
        control_type = event.get('controlType')  # 'light' or 'device'
        control_name = event.get('controlName')  # 'main', 'desk', 'tv', 'ac' etc.
        status = event.get('status')

        # Amplify format check (parameters inside arguments)
        if room_id is None and 'arguments' in event:
            args = event.get('arguments', {})
            room_id = args.get('roomId')
            control_type = args.get('controlType')
            control_name = args.get('controlName')
            status = args.get('status')

        # Ensure roomId is string
        if room_id is not None and not isinstance(room_id, str):
            room_id = str(room_id)
            print(f"roomId converted to string: {room_id}")

        # Check required parameters
        if not room_id:
            print("Invalid roomId: Empty or None value")
            return {"statusCode": 400, "error": "Room ID is required"}

        # Create timestamp
        current_time = int(time.time())

        # If status update is to be made
        if control_name and status is not None:
            # Update or create control
            update_response = table.update_item(
                Key={
                    'roomId': room_id,
                    'controlName': control_name
                },
                UpdateExpression="set #status = :status, controlType = :control_type, #lastUpdated = :time",
                ExpressionAttributeNames={
                    '#status': 'status',
                    '#lastUpdated': 'lastUpdated'
                },
                ExpressionAttributeValues={
                    ':status': status,
                    ':control_type': control_type,
                    ':time': current_time
                },
                ReturnValues="ALL_NEW"
            )

            updated_item = update_response.get('Attributes', {})
            response_data = {
                "controlType": updated_item.get('controlType', control_type),
                "controlName": control_name,
                "status": updated_item.get('status', status),
                "lastUpdated": updated_item.get('lastUpdated', current_time)
            }

            # Prepare and send IoT MQTT message
            payload = json.dumps({
                "requestId": request_id,
                "roomControl": response_data
            }, cls=DecimalEncoder)

            iot_client.publish(
                topic=f"room/{room_id}/control/response",
                payload=payload
            )

        # To query a specific control
        elif control_name:
            response = table.get_item(
                Key={
                    'roomId': room_id,
                    'controlName': control_name
                }
            )
            item = response.get('Item', {})
            response_data = {
                "controlType": item.get('controlType', control_type),
                "controlName": item.get('controlName', control_name),
                "status": item.get('status', False),
                "lastUpdated": item.get('lastUpdated', current_time)
            }

            # Prepare and send IoT MQTT message
            payload = json.dumps({
                "requestId": request_id,
                "roomControl": response_data
            }, cls=DecimalEncoder)

            iot_client.publish(
                topic=f"room/{room_id}/control/response",
                payload=payload
            )

        # To query all controls
        else:
            response = table.query(
                KeyConditionExpression=Key('roomId').eq(room_id)
            )
            items = response.get('Items', [])
            all_controls = []

            for item in items:
                device_data = {
                    'controlType': item.get('controlType'),
                    'controlName': item.get('controlName'),
                    'status': item.get('status', False),
                    'lastUpdated': item.get('lastUpdated', current_time)
                }
                all_controls.append(device_data)

                # Send a separate IoT message for each device
                individual_payload = json.dumps({
                    "requestId": request_id,
                    "roomControl": device_data
                }, cls=DecimalEncoder)

                iot_client.publish(
                    topic=f"room/{room_id}/control/response",
                    payload=individual_payload
                )

        # Return JSON response for Amplify/HTTP requests
        return {
            "statusCode": 200,
            "body": "Room control processed successfully"
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