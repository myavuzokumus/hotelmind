import boto3
import json
import os
from boto3.dynamodb.conditions import Key
from datetime import datetime, timedelta
from decimal import Decimal

# DynamoDB tablosu adı
table_name = os.environ.get('DATA_TABLE', 'RoomEvent-23zg6kw7jvc7vd6hacyznny2w4-NONE')

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

iot_client = boto3.client('iot-data')

def handler(event, context):
    try:
        print(f"Olay geçmişi isteği: {json.dumps(event)}")

        # İstek parametrelerini al
        room_id = event.get('roomId')
        request_id = event.get('requestId', 'unknown')

        if not room_id:
            return {'error': 'roomId gereklidir'}

        # Son verileri al
        response = table.get_item(
            Key={
                'roomId': room_id
            }
        )

        # Yalnızca payload alanını al
        item = response.get('Item', None)

        # MQTT üzerinden yanıt gönder
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
            'message': f"Yanıt {response_topic} konusuna gönderildi"
        }

    except Exception as e:
        print(f"Hata: {str(e)}")
        return {'error': str(e)}


# JSON için özel encoder - Decimal değerlerini float'a dönüştürür
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)