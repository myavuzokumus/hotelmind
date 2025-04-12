import boto3
import decimal
import json
import os
from boto3.dynamodb.conditions import Key

# DynamoDB tablosu - Ortam değişkeninden tablonun adını al
table_name = os.environ.get('PREFERENCE_TABLE', 'UserPreference-23zg6kw7jvc7vd6hacyznny2w4-NONE')

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

iot_client = boto3.client('iot-data')

def handler(event, context):
    print(f"Gelen istek: {json.dumps(event)}")  # Log isteği

    request_id = event.get('requestId')

    # İki farklı istek formatını işle:
    # 1. Doğrudan event içinde roomId olan MQTT istekleri
    # 2. arguments içinde roomId olan Amplify v2 istekleri
    room_id = event.get('roomId')
    if room_id is None and 'arguments' in event:
        # Amplify formatındaki istekler için
        room_id = event.get('arguments', {}).get('roomId')

    # roomId'nin string olduğundan emin olalım
    if room_id is not None and not isinstance(room_id, str):
        room_id = str(room_id)
        print(f"roomId string'e dönüştürüldü: {room_id}")

    if not room_id:
        print("Geçersiz roomId: Boş veya None değeri")
        return {"statusCode": 400, "error": "Geçersiz roomId"}

    try:
        print(f"DynamoDB sorgulanıyor: roomId={room_id}")

        # Oda ID'sine göre tercih verilerini çek
        response = table.query(
            KeyConditionExpression=Key('roomId').eq(room_id)
        )

        print(f"DynamoDB yanıtı: {json.dumps(response, cls=DecimalEncoder)}")

        # Tercih verilerini al veya varsayılan değerleri kullan
        if response['Items']:
            preference = response['Items'][0]
        else:
            # Veri yoksa boş sözlük kullan, get() metoduyla varsayılan değerler atanacak
            preference = {}

        # Yanıtı hazırla
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

        # MQTT istekleri için topic'e yanıt gönder
        payload = json.dumps(result, cls=DecimalEncoder)
        iot_client.publish(
            topic=f"room/{room_id}/preference/response",
            payload=payload
        )

        # Amplify/HTTP istekleri için JSON yanıtı döndür
        return {
            "statusCode": 200,
            "body": result
        }

    except Exception as e:
        print(f"Hata: {str(e)}")
        return {"statusCode": 500, "error": str(e)}

# Decimal tiplerini JSON'a çevirebilen özel encoder
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)