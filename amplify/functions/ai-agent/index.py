import json
import boto3
import datetime
import numpy as np
from decimal import Decimal

# AWS servisleri
dynamodb = boto3.resource('dynamodb')
iot = boto3.client('iot-data')
polly = boto3.client('polly')
sns = boto3.client('sns')

# DynamoDB tabloları
sensor_table = dynamodb.Table('SensorData')
events_table = dynamodb.Table('RoomEvents')
preferences_table = dynamodb.Table('UserPreferences')

# Ayarlar
ROOM_EMPTY_THRESHOLD = 150  # cm (mesafe sensörü için)
TEMPERATURE_COMFORT = 22.0  # Celsius
HUMIDITY_COMFORT = 50.0     # %
GAS_ALERT_THRESHOLD = 5     # 0-10 arası gaz seviyesi
NOTIFICATION_TOPIC = "arn:aws:sns:region:account:RoomAlertTopic"

# JSON serileştirme yardımcısı
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, Decimal):
            return float(o)
        return super(DecimalEncoder, self).default(o)

def lambda_handler(event, context):
    """
    Bu Lambda fonksiyonu, sensör verilerini alır, durumu analiz eder ve
    gerekli kararları verir.
    """
    try:
        # Gelen verileri analiz et
        room_id = event['deviceId']
        temperature = float(event.get('temperature', 22.0))
        humidity = float(event.get('humidity', 50.0))
        gas_level = int(event.get('gasLevel', 0))
        distance = float(event.get('distance', 300.0))
        card_inserted = bool(event.get('cardInserted', False))
        timestamp = event.get('timestamp', int(datetime.datetime.now().timestamp() * 1000))

        # Kişi tespiti
        person_detected = distance < ROOM_EMPTY_THRESHOLD

        # Durum değerlendirmesi
        room_state = analyze_room_state(room_id, temperature, humidity, gas_level, distance, card_inserted, person_detected)

        # AI karar mekanizması
        actions = make_decisions(room_id, room_state)

        # Kararları uygula
        apply_decisions(room_id, actions)

        # Durumu kaydet
        save_room_state(room_id, room_state, timestamp)

        # Güvenlik kontrolü
        security_check(room_id, person_detected, card_inserted)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'roomId': room_id,
                'state': room_state,
                'actions': actions
            }, cls=DecimalEncoder)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def analyze_room_state(room_id, temperature, humidity, gas_level, distance, card_inserted, person_detected):
    """
    Oda durumunu analiz eder ve bir durum raporu oluşturur
    """
    # Kullanıcı tercihlerini al
    user_prefs = get_user_preferences(room_id)

    # Sıcaklık değerlendirmesi
    temp_pref = user_prefs.get('preferredTemperature', TEMPERATURE_COMFORT)
    temp_diff = abs(temperature - temp_pref)
    temp_status = "optimal" if temp_diff < 1.5 else "suboptimal"

    # Nem değerlendirmesi
    humidity_status = "optimal" if 40 <= humidity <= 60 else "suboptimal"

    # Gaz seviyesi değerlendirmesi
    gas_status = "normal"
    if gas_level > GAS_ALERT_THRESHOLD:
        gas_status = "alert"
        create_alert(room_id, f"Yüksek gaz seviyesi tespit edildi: {gas_level}/10")

    # Durum raporu
    room_state = {
        'occupied': person_detected,
        'cardInserted': card_inserted,
        'temperature': {
            'value': temperature,
            'status': temp_status,
            'targetValue': temp_pref
        },
        'humidity': {
            'value': humidity,
            'status': humidity_status
        },
        'gasLevel': {
            'value': gas_level,
            'status': gas_status
        },
        'securityStatus': "normal" if (not person_detected or card_inserted) else "warning"
    }

    return room_state

def make_decisions(room_id, room_state):
    """
    Oda durumuna göre AI kararları alır
    """
    actions = {}

    # Kişi odada mı?
    occupied = room_state['occupied']
    card_inserted = room_state['cardInserted']

    # İklimlendirme kararları
    if occupied:
        # Kişi odadaysa konfor moduna geç
        target_temp = room_state['temperature']['targetValue']
        actions['climate'] = {
            'mode': 'comfort',
            'targetTemperature': target_temp,
            'fanSpeed': 'auto'
        }
    else:
        # Kişi odada değilse enerji tasarruf moduna geç
        actions['climate'] = {
            'mode': 'eco',
            'targetTemperature': 26.0 if room_state['temperature']['value'] < 30 else 24.0,
            'fanSpeed': 'low'
        }

    # Güvenlik kararları
    if room_state['securityStatus'] == "warning":
        actions['security'] = {
            'warningActive': True,
            'notifyReception': False  # 15 saniyelik süre dolmadı henüz
        }

    # Gaz algılama kararları
    if room_state['gasLevel']['status'] == "alert":
        actions['ventilation'] = {
            'mode': 'high',
            'windowsOpen': True
        }

    return actions

def apply_decisions(room_id, actions):
    """
    AI kararlarını uygular
    """
    # IoT cihazlarına komut gönder
    payload = json.dumps({
        'roomId': room_id,
        'actions': actions
    })

    topic = f"room/{room_id}/commands"
    iot.publish(
        topic=topic,
        qos=1,
        payload=payload
    )

    return True

def save_room_state(room_id, room_state, timestamp):
    """
    Oda durumunu DynamoDB'ye kaydeder
    """
    sensor_table.put_item(
        Item={
            'roomId': room_id,
            'timestamp': timestamp,
            'state': room_state
        }
    )

def security_check(room_id, person_detected, card_inserted):
    """
    Güvenlik durumunu kontrol eder
    """
    if person_detected and not card_inserted:
        # Kişi odada ama kart takılı değil - uyarı başlat
        event_data = {
            'roomId': room_id,
            'eventType': 'SECURITY_WARNING',
            'timestamp': int(datetime.datetime.now().timestamp() * 1000),
            'description': 'Kart takılmadan odada kişi tespit edildi',
            'resolved': False
        }

        events_table.put_item(Item=event_data)

        # 15 saniye sonra kontrol etmek için bir event programla
        # Gerçek uygulamada Step Functions kullanılabilir

def create_alert(room_id, message):
    """
    Uyarı oluşturur ve bildirim gönderir
    """
    # Olay kaydı
    event_data = {
        'roomId': room_id,
        'eventType': 'ALERT',
        'timestamp': int(datetime.datetime.now().timestamp() * 1000),
        'description': message,
        'resolved': False
    }

    events_table.put_item(Item=event_data)

    # SMS/Email bildirimi gönder
    sns.publish(
        TopicArn=NOTIFICATION_TOPIC,
        Message=f"Alert from Room {room_id}: {message}",
        Subject=f"Room Alert - {room_id}"
    )

def get_user_preferences(room_id):
    """
    Kullanıcı tercihlerini veritabanından alır
    """
    try:
        response = preferences_table.get_item(
            Key={
                'roomId': room_id
            }
        )

        if 'Item' in response:
            return response['Item'].get('preferences', {})

        return {}

    except Exception as e:
        print(f"Error retrieving user preferences: {str(e)}")
        return {}

def generate_voice_summary(room_id, events):
    """
    Kullanıcı için sesli özet rapor oluşturur
    """
    # Son olayları özetle
    summary_text = "Hoş geldiniz. "

    # Sıcaklık ve nem bilgisi
    try:
        # Son okunan sensör verilerini al
        response = sensor_table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('roomId').eq(room_id),
            Limit=1,
            ScanIndexForward=False  # en yeniden en eskiye sırala
        )

        if response['Items']:
            last_reading = response['Items'][0]
            state = last_reading.get('state', {})

            temp = state.get('temperature', {}).get('value')
            humidity = state.get('humidity', {}).get('value')

            if temp and humidity:
                summary_text += f"Mevcut oda sıcaklığı {temp:.1f} derece, nem oranı yüzde {humidity:.1f}. "
    except Exception as e:
        print(f"Error retrieving sensor data: {str(e)}")

    # Yokluğunuzda yapılan işlemleri özetle
    if events:
        summary_text += "Yokluğunuzda, "

        climate_actions = [e for e in events if e.get('eventType') == 'CLIMATE_ACTION']
        if climate_actions:
            summary_text += f"oda sıcaklığı {len(climate_actions)} kez ayarlandı. "

        alerts = [e for e in events if e.get('eventType') == 'ALERT']
        if alerts:
            summary_text += f"{len(alerts)} adet uyarı oluştu. "

            # Önemli uyarıları detaylandır
            gas_alerts = [a for a in alerts if 'gaz' in a.get('description', '').lower()]
            if gas_alerts:
                summary_text += f"Bunlardan {len(gas_alerts)} tanesi yüksek gaz seviyesi ile ilgiliydi. "
    else:
        summary_text += "yokluğunuzda herhangi bir olay gerçekleşmedi. "

    summary_text += "İyi günler dilerim."

    # Metni sese çevir
    response = polly.synthesize_speech(
        Text=summary_text,
        OutputFormat='mp3',
        VoiceId='Filiz'  # Türkçe kadın sesi
    )

    # MP3 dosyasını S3'e kaydet
    if 'AudioStream' in response:
        s3 = boto3.client('s3')
        audio_file_key = f"voice_summaries/{room_id}/{int(datetime.datetime.now().timestamp())}.mp3"

        s3.upload_fileobj(
            response['AudioStream'],
            'smart-room-assets-bucket',  # S3 bucket adı
            audio_file_key
        )

        return {
            's3Key': audio_file_key,
            'text': summary_text
        }

    return None