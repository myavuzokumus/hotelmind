import boto3
import decimal
import json
import os
import time
from boto3.dynamodb.conditions import Key

# DynamoDB tablosu adı
table_name = os.environ.get('DATA_TABLE', 'RoomControl-23zg6kw7jvc7vd6hacyznny2w4-NONE')

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

iot_client = boto3.client('iot-data')

def handler(event, context):
    print(f"Gelen istek: {json.dumps(event)}")  # Gelen isteği logla

    try:
        # Farklı istek formatlarından parametreleri çıkar
        request_id = event.get('requestId')

        # 1. Doğrudan event içindeki veya 2. Amplify formatındaki arguments içindeki parametre
        room_id = event.get('roomId')
        control_type = event.get('controlType')  # 'light' veya 'device'
        control_name = event.get('controlName')  # 'main', 'desk', 'tv', 'ac' vb.
        status = event.get('status')

        # Amplify formatı kontrolü (arguments içinde parametreler)
        if room_id is None and 'arguments' in event:
            args = event.get('arguments', {})
            room_id = args.get('roomId')
            control_type = args.get('controlType')
            control_name = args.get('controlName')
            status = args.get('status')

        # roomId'nin string olduğundan emin olalım
        if room_id is not None and not isinstance(room_id, str):
            room_id = str(room_id)
            print(f"roomId string'e dönüştürüldü: {room_id}")

        # Zorunlu parametrelerin kontrolü
        if not room_id:
            print("Geçersiz roomId: Boş veya None değeri")
            return {"statusCode": 400, "error": "Oda ID gereklidir"}

        # Zaman damgası oluştur
        current_time = int(time.time())

        # Durum güncellemesi yapılacaksa
        if control_name and status is not None:
            # Kontrolü güncelle veya oluştur
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

            # IoT MQTT mesajı hazırla ve gönder
            payload = json.dumps({
                "requestId": request_id,
                "roomControl": response_data
            }, cls=DecimalEncoder)

            iot_client.publish(
                topic=f"room/{room_id}/control/response",
                payload=payload
            )

        # Belirli bir kontrolü sorgulamak için
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

            # IoT MQTT mesajı hazırla ve gönder
            payload = json.dumps({
                "requestId": request_id,
                "roomControl": response_data
            }, cls=DecimalEncoder)

            iot_client.publish(
                topic=f"room/{room_id}/control/response",
                payload=payload
            )

        # Tüm kontrolleri sorgulamak için
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

                # Her cihaz için ayrı IoT mesajı gönder
                individual_payload = json.dumps({
                    "requestId": request_id,
                    "roomControl": device_data
                }, cls=DecimalEncoder)

                iot_client.publish(
                    topic=f"room/{room_id}/control/response",
                    payload=individual_payload
                )

        # Amplify/HTTP istekleri için JSON yanıtı döndür
        return {
            "statusCode": 200,
            "body": "Oda kontrolü başarıyla işlendi"
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