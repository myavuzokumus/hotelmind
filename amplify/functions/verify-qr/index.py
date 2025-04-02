import boto3
import hashlib
import hmac
import json
import os
import time
import uuid
from botocore.exceptions import ClientError

# DynamoDB tablosu - Ortam değişkeninden tablonun adını al
session_table_name = os.environ.get('QR_SESSIONS_TABLE', 'QrSession-23zg6kw7jvc7vd6hacyznny2w4-NONE')
rate_limit_table_name = os.environ.get('QR_RATE_LIMIT_TABLE', 'QrRateLimit-23zg6kw7jvc7vd6hacyznny2w4-NONE')

dynamodb = boto3.resource('dynamodb')
sessions_table = dynamodb.Table(session_table_name)
rate_limit_table = dynamodb.Table(rate_limit_table_name)

# QR Kod doğrulama Lambda fonksiyonu
def handler(event, context):
    try:
        # Kaynak IP'yi al (API Gateway proxy entegrasyonundan)
        source_ip = event.get('requestContext', {}).get('identity', {}).get('sourceIp', 'unknown')

        # Rate limit kontrolü
        if not check_rate_limit(source_ip):
            return create_response(429, {
                "isValid": False,
                "message": "Çok fazla istek gönderdiniz. Lütfen biraz bekleyin."
            })

        # API Gateway ve GraphQL tarafından gönderilen veriyi al
        qr_data = event.get('arguments', {}).get('name', '')

        if not qr_data:
            return create_response(400, {
                "isValid": False,
                "message": "QR kodu veri içermiyor"
            })

        # QR kod verisi JSON formatında olmalı
        try:
            qr_json = json.loads(qr_data)
        except json.JSONDecodeError:
            return create_response(400, {
                "isValid": False,
                "message": "QR kodu geçerli bir JSON formatında değil"
            })

        # Gerekli alanların varlığını kontrol et
        required_fields = ['roomId', 'timestamp', 'expiry', 'sessionId', 'signature']
        if not all(field in qr_json for field in required_fields):
            return create_response(400, {
                "isValid": False,
                "message": "QR kodu eksik bilgiler içeriyor"
            })

        # Süre kontrolü yap
        current_time = int(time.time())
        if current_time > qr_json['expiry']:
            return create_response(400, {
                "isValid": False,
                "message": "QR kodun süresi dolmuş"
            })

        # İmza doğrulaması yap
        if not verify_signature(qr_json):
            return create_response(400, {
                "isValid": False,
                "message": "QR kod imzası doğrulanamadı"
            })

        # Session ID
        session_id = qr_json['sessionId']
        room_id = qr_json['roomId']
        expiry = qr_json['expiry']

        # QR kodu daha önce kullanılmış mı kontrol et
        if is_session_used(session_id):
            return create_response(400, {
                "isValid": False,
                "message": "Bu QR kod daha önce kullanılmış"
            })

        active_sessions = count_active_sessions(room_id)
        if active_sessions > 3:
            return create_response(400, {
                "isValid": False,
                "message": "Bu odada maksimum kullanıcı sayısına (3) ulaşıldı"
            })

        # Yeni session kaydı oluştur
        if mark_session_used(session_id, room_id, expiry):
            # Başarılı yanıt döndür
            return create_response(200, {
                "isValid": True,
                "message": "QR kod doğrulandı",
                "roomId": room_id,
                "sessionId": session_id
            })
        else:
            return create_response(500, {
                "isValid": False,
                "message": "Session kaydı oluşturulamadı"
            })

    except Exception as e:
        print(f"Beklenmeyen hata: {str(e)}")
        return create_response(500, {
            "isValid": False,
            "message": "Internal server error"
        })

# İmza doğrulama fonksiyonu
def verify_signature(qr_data):
    try:
        # İmza doğrulama için payloadu oluştur
        payload = f"{qr_data['roomId']}:{qr_data['timestamp']}:{qr_data['expiry']}:{qr_data['sessionId']}"

        # QR üreticisiyle aynı formatta anahtar kullan
        SECRET_KEY = os.environ.get('QR_SECRET_KEY', "a69836475cdbb13d9e3fb15d6d2a547ee11f0d6d52d7c1b43bc9b0e965502357")
        key = bytes.fromhex(SECRET_KEY)  # hexadecimal formatı kullan

        # HMAC-SHA256 ile imza oluştur
        calculated_signature = hmac.new(
            key,
            msg=bytes(payload, 'utf-8'),
            digestmod=hashlib.sha256
        ).hexdigest()

        # Gelen imza ile hesaplananı karşılaştır
        return calculated_signature == qr_data['signature']
    except Exception as e:
        print(f"İmza doğrulama hatası: {e}")
        return False

# HTTP yanıtı oluştur
def create_response(status_code, body):
    return {
        "statusCode": status_code,
        "body": json.dumps(body)
    }

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
        print(f"Oturum kontrolü hatası: {e}")
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
        print(f"Oturum işaretleme hatası: {e}")
        return False

# Rate limiting için yeni fonksiyonlar

def check_rate_limit(source_ip):
    """
    Kaynak IP için hız sınırını kontrol eder
    """
    try:
        # Çevre değişkenlerinden limit ayarlarını al
        max_requests = int(os.environ.get('RATE_LIMIT_COUNT', '10'))
        window_seconds = int(os.environ.get('RATE_LIMIT_WINDOW', '60'))

        current_time = int(time.time())
        window_start_time = current_time - window_seconds

        # Kaynak IP'nin son isteklerini sorgula
        response = rate_limit_table.query(
            IndexName="qrRateLimitsBySourceIpAndTimestamp",  # İkincil indeksin adını belirtin
            KeyConditionExpression=boto3.dynamodb.conditions.Key('sourceIp').eq(source_ip) &
                                   boto3.dynamodb.conditions.Key('timestamp').gt(window_start_time)
        )

        # Zaman penceresi içindeki istek sayısını kontrol et
        request_count = len(response.get('Items', []))

        if request_count >= max_requests:
            return False  # Rate limit aşıldı

        # Yeni istek kaydı ekle
        rate_limit_table.put_item(
            Item={
                'id': str(uuid.uuid4()),
                'sourceIp': source_ip,
                'timestamp': current_time,
                'ttl': current_time + (window_seconds * 2)  # TTL için 2 kat zaman penceresi
            }
        )
        return True  # Rate limit aşılmadı

    except Exception as e:
        print(f"Rate limit kontrolü sırasında hata: {e}")
        # Hata durumunda istekleri reddetme
        return False

def count_active_sessions(room_id):
    """Belirli bir oda için aktif oturum sayısını döndürür ve gerekirse süresi dolmuş oturumları siler."""
    try:
        current_time = int(time.time())

        # Aynı odaya ait tüm oturumları çek
        response = sessions_table.scan(
            FilterExpression="roomId = :roomId",
            ExpressionAttributeValues={
                ":roomId": room_id
            }
        )

        items = response.get('Items', [])
        while 'LastEvaluatedKey' in response:
            response = sessions_table.scan(
                FilterExpression="roomId = :roomId",
                ExpressionAttributeValues={
                    ":roomId": room_id
                },
                ExclusiveStartKey=response['LastEvaluatedKey']
            )
            items.extend(response.get('Items', []))

        # Süresi dolmuş oturumları tespit et
        active_sessions = [item for item in items if item['expiry'] >= current_time]
        expired_sessions = [item for item in items if item['expiry'] < current_time]

        # Eğer aktif oturum sayısı 3'ten fazlaysa süresi dolmuş oturumları sil
        for session in expired_sessions:
            sessions_table.delete_item(
                Key={
                    'sessionId': session['sessionId']
                }
            )
            print(f"Süresi dolmuş oturum silindi: {session['sessionId']}")

        # Aktif oturum sayısını döndür
        return len(active_sessions)

    except Exception as e:
        print(f"Oturum sayısı kontrolü hatası: {e}")
        return 0