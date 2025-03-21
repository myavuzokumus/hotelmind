import json
import time
import hmac
import hashlib
import boto3
from botocore.exceptions import ClientError

# DynamoDB tablosu
dynamodb = boto3.resource('dynamodb')
sessions_table = dynamodb.Table('QrSessions')

def handler(event, context):
    try:
        # JSON body'den veriyi al
        body = json.loads(event['body'])
        qr_data = body.get('qrCode', '')

        # QR veriyi ayrıştır
        qr_json = json.loads(qr_data)

        room_id = qr_json.get('roomId')
        timestamp = qr_json.get('timestamp')
        expiry = qr_json.get('expiry')
        session_id = qr_json.get('sessionId')
        signature = qr_json.get('signature')

        # Gerekli tüm alanları kontrol et
        if not all([room_id, timestamp, expiry, session_id, signature]):
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'isValid': False,
                    'message': 'Missing required fields in QR data'
                })
            }

        # Süre kontrolü
        current_time = int(time.time())
        if current_time > expiry:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'isValid': False,
                    'message': 'QR code has expired'
                })
            }

        # İmza doğrulama
        secret_key = get_secret_key(room_id)
        if not verify_signature(room_id, timestamp, expiry, session_id, signature, secret_key):
            return {
                'statusCode': 401,
                'body': json.dumps({
                    'isValid': False,
                    'message': 'Invalid signature'
                })
            }

        # Daha önce kullanılmış mı kontrol et
        if is_session_used(session_id):
            return {
                'statusCode': 401,
                'body': json.dumps({
                    'isValid': False,
                    'message': 'QR code already used'
                })
            }

        # Oturumu kullanılmış olarak işaretle
        mark_session_used(session_id, room_id, expiry)

        # Erişim yetkisi ver
        return {
            'statusCode': 200,
            'body': json.dumps({
                'isValid': True,
                'message': 'Access granted',
                'roomId': room_id,
                'expiryTime': expiry
            })
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'isValid': False,
                'message': 'Internal server error'
            })
        }

def get_secret_key(room_id):
    """Oda için gizli anahtar alır (Secret Manager veya başka bir kaynaktan)."""
    # Bu örnek için sabit bir anahtar kullanılıyor
    # Gerçek uygulamada AWS Secrets Manager kullanılabilir
    return "a69836475cdbb13d9e3fb15d6d2a547ee11f0d6d52d7c1b43bc9b0e965502357"

def verify_signature(room_id, timestamp, expiry, session_id, signature, secret_key):
    """İmzayı doğrular."""
    data_string = f"{room_id}:{timestamp}:{expiry}:{session_id}"
    key = bytes.fromhex(secret_key)
    message = data_string.encode('utf-8')
    expected_signature = hmac.new(key, message, hashlib.sha256).hexdigest()
    return hmac.compare_digest(signature, expected_signature)

def is_session_used(session_id):
    """Oturumun daha önce kullanılıp kullanılmadığını kontrol eder."""
    try:
        response = sessions_table.get_item(
            Key={
                'sessionId': session_id
            }
        )
        return 'Item' in response
    except ClientError as e:
        print(f"Error checking session: {e}")
        # Hata durumunda güvenlik için kullanılmış gibi davran
        return True

def mark_session_used(session_id, room_id, expiry):
    """Oturumu kullanılmış olarak işaretle."""
    try:
        current_time = int(time.time())
        sessions_table.put_item(
            Item={
                'sessionId': session_id,
                'roomId': room_id,
                'usedAt': current_time,
                'expiry': expiry
            }
        )
        return True
    except ClientError as e:
        print(f"Error marking session: {e}")
        return False