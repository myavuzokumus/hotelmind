import json
import boto3
import datetime
from decimal import Decimal
import os

# Get AWS region from environment variable
AWS_REGION = os.environ.get('AWS_REGION', 'eu-central-1')

# Initialize AWS services specifying region
dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
iot = boto3.client('iot-data', region_name=AWS_REGION)
polly = boto3.client('polly', region_name=AWS_REGION)
sns = boto3.client('sns', region_name=AWS_REGION)

# DynamoDB tables
sensor_table = dynamodb.Table('SensorData')
events_table = dynamodb.Table('RoomEvents')
preferences_table = dynamodb.Table('UserPreferences')

# Settings
ROOM_EMPTY_THRESHOLD = 150  # cm (for distance sensor)
TEMPERATURE_COMFORT = 22.0  # Celsius
HUMIDITY_COMFORT = 50.0     # %
GAS_ALERT_THRESHOLD = 5     # gas level between 0-10

# Get resources from environment variables
NOTIFICATION_TOPIC = os.environ.get('NOTIFICATION_TOPIC', 'arn:aws:sns:eu-central-1:471112835770:smart-room-system-alerts-dev')
ASSETS_BUCKET = os.environ.get('ASSETS_BUCKET_NAME', 'smart-room-system-assets-dev')

# JSON serialization helper
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, Decimal):
            return float(o)
        return super(DecimalEncoder, self).default(o)

def handler(event, context):
    """
    This Lambda function receives sensor data, analyzes the state, and
    makes necessary decisions.
    """
    try:
        # Analyze incoming data
        room_id = event['deviceId']
        temperature = float(event.get('temperature', 22.0))
        humidity = float(event.get('humidity', 50.0))
        gas_level = int(event.get('gasLevel', 0))
        distance = float(event.get('distance', 300.0))
        card_inserted = bool(event.get('cardInserted', False))
        timestamp = event.get('timestamp', int(datetime.datetime.now().timestamp() * 1000))

        # Person detection
        person_detected = distance < ROOM_EMPTY_THRESHOLD

        # State assessment
        room_state = analyze_room_state(room_id, temperature, humidity, gas_level, distance, card_inserted, person_detected)

        # AI decision mechanism
        actions = make_decisions(room_id, room_state)

        # Apply decisions
        apply_decisions(room_id, actions)

        # Save state
        save_room_state(room_id, room_state, timestamp)

        # Security check
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
    Analyzes room state and creates a state report
    """
    # Get user preferences
    user_prefs = get_user_preferences(room_id)

    # Temperature assessment
    temp_pref = user_prefs.get('preferredTemperature', TEMPERATURE_COMFORT)
    temp_diff = abs(temperature - temp_pref)
    temp_status = "optimal" if temp_diff < 1.5 else "suboptimal"

    # Humidity assessment
    humidity_status = "optimal" if 40 <= humidity <= 60 else "suboptimal"

    # Gas level assessment
    gas_status = "normal"
    if gas_level > GAS_ALERT_THRESHOLD:
        gas_status = "alert"
        create_alert(room_id, f"High gas level detected: {gas_level}/10")

    # State report
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
    Makes AI decisions based on room state
    """
    actions = {}

    # Is person in the room?
    occupied = room_state['occupied']
    card_inserted = room_state['cardInserted']

    # Climate control decisions
    if occupied:
        # Switch to comfort mode if person is in room
        target_temp = room_state['temperature']['targetValue']
        actions['climate'] = {
            'mode': 'comfort',
            'targetTemperature': target_temp,
            'fanSpeed': 'auto'
        }
    else:
        # Switch to energy saving mode if person is not in room
        actions['climate'] = {
            'mode': 'eco',
            'targetTemperature': 26.0 if room_state['temperature']['value'] < 30 else 24.0,
            'fanSpeed': 'low'
        }

    # Security decisions
    if room_state['securityStatus'] == "warning":
        actions['security'] = {
            'warningActive': True,
            'notifyReception': False  # 15 seconds period hasn't expired yet
        }

    # Gas detection decisions
    if room_state['gasLevel']['status'] == "alert":
        actions['ventilation'] = {
            'mode': 'high',
            'windowsOpen': True
        }

    return actions

def apply_decisions(room_id, actions):
    """
    Applies AI decisions
    """
    # Send command to IoT devices
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
    Saves room state to DynamoDB
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
    Checks security status
    """
    if person_detected and not card_inserted:
        # Person in room but card not inserted - start warning
        event_data = {
            'roomId': room_id,
            'eventType': 'SECURITY_WARNING',
            'timestamp': int(datetime.datetime.now().timestamp() * 1000),
            'description': 'Person detected in room without card inserted',
            'resolved': False
        }

        events_table.put_item(Item=event_data)

        # Schedule an event to check after 15 seconds
        # In a real application, Step Functions could be used

def create_alert(room_id, message):
    """
    Creates an alert and sends a notification
    """
    # Event record
    event_data = {
        'roomId': room_id,
        'eventType': 'ALERT',
        'timestamp': int(datetime.datetime.now().timestamp() * 1000),
        'description': message,
        'resolved': False
    }

    events_table.put_item(Item=event_data)

    # Send SMS/Email notification
    sns.publish(
        TopicArn=NOTIFICATION_TOPIC,
        Message=f"Alert from Room {room_id}: {message}",
        Subject=f"Room Alert - {room_id}"
    )

def get_user_preferences(room_id):
    """
    Retrieves user preferences from database
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
    Generates a voice summary report for the user
    """
    # Summarize recent events
    summary_text = "Welcome. "

    # Temperature and humidity info
    try:
        # Get last read sensor data
        response = sensor_table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('roomId').eq(room_id),
            Limit=1,
            ScanIndexForward=False  # sort from newest to oldest
        )

        if response['Items']:
            last_reading = response['Items'][0]
            state = last_reading.get('state', {})

            temp = state.get('temperature', {}).get('value')
            humidity = state.get('humidity', {}).get('value')

            if temp and humidity:
                summary_text += f"Current room temperature is {temp:.1f} degrees, humidity is {humidity:.1f} percent. "
    except Exception as e:
        print(f"Error retrieving sensor data: {str(e)}")

    # Summarize actions taken in your absence
    if events:
        summary_text += "In your absence, "

        climate_actions = [e for e in events if e.get('eventType') == 'CLIMATE_ACTION']
        if climate_actions:
            summary_text += f"room temperature was adjusted {len(climate_actions)} times. "

        alerts = [e for e in events if e.get('eventType') == 'ALERT']
        if alerts:
            summary_text += f"{len(alerts)} alerts occurred. "

            # Detail important alerts
            gas_alerts = [a for a in alerts if 'gaz' in a.get('description', '').lower()]
            if gas_alerts:
                summary_text += f"Of these, {len(gas_alerts)} were related to high gas level. "
    else:
        summary_text += "no events occurred in your absence. "

    summary_text += "Have a good day."

    # Convert text to speech
    response = polly.synthesize_speech(
        Text=summary_text,
        OutputFormat='mp3',
        VoiceId='Joanna'  # English female voice
    )

    # Save MP3 file to S3
    if 'AudioStream' in response:
        s3 = boto3.client('s3')
        audio_file_key = f"voice_summaries/{room_id}/{int(datetime.datetime.now().timestamp())}.mp3"

        s3.upload_fileobj(
            response['AudioStream'],
            'smart-room-assets-bucket',  # S3 bucket name
            audio_file_key
        )

        return {
            's3Key': audio_file_key,
            'text': summary_text
        }

    return None