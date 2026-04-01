import boto3
import json
import uuid

iot_client = boto3.client('iot-data')

def handler(event, context):

    request_id = event.get('requestId')
    room_id = event.get('roomId')

    try:

        # Get secret key from Parameter Store
        ssm_client = boto3.client('ssm')
        response = ssm_client.get_parameter(
            Name=f'/qr-generator/secret-key', #/qr-generator/{room_id}/secret-key
            WithDecryption=True
        )
        secret_key = response['Parameter']['Value']

        # Send response
        iot_client.publish(
            topic=f'room/{room_id}/secret/response',
            qos=1,
            payload=json.dumps({
                'requestId': request_id,
                'secretKey': secret_key,
                'status': 'success'
            })
        )

        return {
            'statusCode': 200,
            'body': json.dumps('Secret key sent')
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        # Send response in case of error too
        if room_id:
            try:
                iot_client.publish(
                    topic=f'room/{room_id}/secret/response',
                    qos=1,
                    payload=json.dumps({
                        'requestId': request_id,
                        'status': 'error',
                        'error': str(e)
                    })
                )
            except Exception as publish_error:
                print(f"IoT publish error: {str(publish_error)}")

        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }