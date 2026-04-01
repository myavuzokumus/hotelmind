import boto3
import hashlib
import hmac
import json
import os
import time
import uuid
from botocore.exceptions import ClientError
from datetime import datetime, timezone

# DynamoDB table - Get table name from environment variable
session_table_name = os.environ.get('QR_SESSIONS_TABLE', 'QrSession-23zg6kw7jvc7vd6hacyznny2w4-NONE')
rate_limit_table_name = os.environ.get('QR_RATE_LIMIT_TABLE', 'QrRateLimit-23zg6kw7jvc7vd6hacyznny2w4-NONE')

dynamodb = boto3.resource('dynamodb')
sessions_table = dynamodb.Table(session_table_name)
rate_limit_table = dynamodb.Table(rate_limit_table_name)

# QR Code verification Lambda function
def handler(event, context):
    try:
        # Get source IP (from API Gateway proxy integration)
        source_ip = event.get('requestContext', {}).get('identity', {}).get('sourceIp', 'unknown')

        # Rate limit check
        if not check_rate_limit(source_ip):
            return create_response(429, {
                "isValid": False,
                "message": "Too many requests. Please wait."
            })

        # Get data sent by API Gateway and GraphQL
        qr_data = event.get('arguments', {}).get('name', '')

        if not qr_data:
            return create_response(400, {
                "isValid": False,
                "message": "QR code contains no data"
            })

        # QR code data must be in JSON format
        try:
            qr_json = json.loads(qr_data)
        except json.JSONDecodeError:
            return create_response(400, {
                "isValid": False,
                "message": "QR code is not in a valid JSON format"
            })

        # Check required fields
        required_fields = ['roomId', 'timestamp', 'expiry', 'sessionId', 'signature']
        if not all(field in qr_json for field in required_fields):
            return create_response(400, {
                "isValid": False,
                "message": "QR code is missing information"
            })

        # Check expiration time
        current_time = int(time.time())
        if current_time > qr_json['expiry']:
            return create_response(400, {
                "isValid": False,
                "message": "QR code has expired"
            })

        # Verify signature
        if not verify_signature(qr_json):
            return create_response(400, {
                "isValid": False,
                "message": "QR code signature could not be verified"
            })

        # Session ID
        session_id = qr_json['sessionId']
        room_id = qr_json['roomId']
        expiry = qr_json['expiry']

        # Check if QR code has been used before
        if is_session_used(session_id):
            return create_response(400, {
                "isValid": False,
                "message": "This QR code has already been used"
            })

        active_sessions = count_active_sessions(room_id)
        if active_sessions > 3:
            return create_response(400, {
                "isValid": False,
                "message": "Maximum number of users (3) reached in this room"
            })

        # Create new session record
        if mark_session_used(session_id, room_id, expiry):
            # Return successful response
            return create_response(200, {
                "isValid": True,
                "message": "QR code verified",
                "roomId": room_id,
                "sessionId": session_id
            })
        else:
            return create_response(500, {
                "isValid": False,
                "message": "Session record could not be created"
            })

    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return create_response(500, {
            "isValid": False,
            "message": "Internal server error"
        })

# Signature verification function
def verify_signature(qr_data):
    try:
        # Create payload for signature verification
        payload = f"{qr_data['roomId']}:{qr_data['timestamp']}:{qr_data['expiry']}:{qr_data['sessionId']}"

        # Use the same key format as the QR generator
        # TODO: Replace the fallback key with your own. Generate with: openssl rand -hex 32
        SECRET_KEY = os.environ.get('QR_SECRET_KEY', "a69836475cdbb13d9e3fb15d6d2a547ee11f0d6d52d7c1b43bc9b0e965502357")
        key = bytes.fromhex(SECRET_KEY)  # use hexadecimal format

        # Create signature with HMAC-SHA256
        calculated_signature = hmac.new(
            key,
            msg=bytes(payload, 'utf-8'),
            digestmod=hashlib.sha256
        ).hexdigest()

        # Compare incoming signature with calculated one
        return calculated_signature == qr_data['signature']
    except Exception as e:
        print(f"Signature verification error: {e}")
        return False

# Create HTTP response
def create_response(status_code, body):
    return {
        "statusCode": status_code,
        "body": json.dumps(body)
    }

def is_session_used(session_id):
    """Checks whether the session has been used before."""
    try:
        response = sessions_table.get_item(
            Key={
                'sessionId': session_id
            }
        )
        return 'Item' in response
    except ClientError as e:
        print(f"Session check error: {e}")
        # In case of error, act as if used for security
        return True

def mark_session_used(session_id, room_id, expiry):
    """Mark session as used."""
    try:

        timestamp = int(time.time())
        iso_time = datetime.fromtimestamp(timestamp, timezone.utc).isoformat()

        sessions_table.put_item(
            Item={
                'sessionId': session_id,
                'roomId': room_id,
                'createdAt': iso_time,
                'updatedAt': iso_time,
                'expiry': expiry
            }
        )
        return True
    except ClientError as e:
        print(f"Session marking error: {e}")
        return False

# New functions for rate limiting

def check_rate_limit(source_ip):
    """
    Checks the rate limit for the source IP
    """
    try:
        # Get limit settings from environment variables
        max_requests = int(os.environ.get('RATE_LIMIT_COUNT', '10'))
        window_seconds = int(os.environ.get('RATE_LIMIT_WINDOW', '60'))

        current_time = int(time.time())
        iso_time = datetime.fromtimestamp(current_time, timezone.utc).isoformat()
        window_start_time = current_time - window_seconds

        # Query the recent requests of the source IP
        response = rate_limit_table.query(
            IndexName="qrRateLimitsBySourceIpAndTimestamp",  # Specify the secondary index name
            KeyConditionExpression=boto3.dynamodb.conditions.Key('sourceIp').eq(source_ip) &
                                   boto3.dynamodb.conditions.Key('timestamp').gt(window_start_time)
        )

        # Check request count within the time window
        request_count = len(response.get('Items', []))

        if request_count >= max_requests:
            return False  # Rate limit exceeded

        # Add new request record
        rate_limit_table.put_item(
            Item={
                'id': str(uuid.uuid4()),
                'sourceIp': source_ip,
                'createdAt': iso_time,
                'updatedAt': iso_time,
                'timestamp': current_time,
                'ttl': current_time + (window_seconds * 2)  # 2x time window for TTL
            }
        )
        return True  # Rate limit not exceeded

    except Exception as e:
        print(f"Error during rate limit check: {e}")
        # Do not reject requests in case of error
        return False

def count_active_sessions(room_id):
    """Returns the active session count for a given room and deletes expired sessions if necessary."""
    try:
        current_time = int(time.time())

        # Fetch all sessions for the same room
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

        # Identify expired sessions
        active_sessions = [item for item in items if item['expiry'] >= current_time]
        expired_sessions = [item for item in items if item['expiry'] < current_time]

        # Delete expired sessions if active session count is greater than 3
        for session in expired_sessions:
            sessions_table.delete_item(
                Key={
                    'sessionId': session['sessionId']
                }
            )
            print(f"Expired session deleted: {session['sessionId']}")

        # Return the number of active sessions
        return len(active_sessions)

    except Exception as e:
        print(f"Session count check error: {e}")
        return 0