from datetime import datetime, timezone
import json
import logging
import time

import uuid
from awscrt import io, mqtt
from awsiot import mqtt_connection_builder


class IoTClient:
    """AWS IoT connection and communication management"""

    def __init__(self, config):
        """
        Initializes the IoT Client

        Args:
            config: System configuration
        """
        self.sensor_history = []
        self.event_history = []
        self.max_history_size = 99  # Maximum number of data to be stored
        self.logger = logging.getLogger("SmartRoom.IoTClient")
        self.config = config
        self.mqtt_connection = None
        self.command_handler = None

    def connect(self):
        """Connects to AWS IoT"""
        try:
            # Check the existence of certificates
            if not self.config.check_certificates():
                self.logger.error("Certificate files not found")
                return False

            # Establish connection with AWS IoT SDK v2
            event_loop_group = io.EventLoopGroup(1)
            host_resolver = io.DefaultHostResolver(event_loop_group)
            client_bootstrap = io.ClientBootstrap(event_loop_group, host_resolver)

            self.mqtt_connection = mqtt_connection_builder.mtls_from_path(
                endpoint=self.config["endpoint"],
                cert_filepath=self.config["certificatePath"],
                pri_key_filepath=self.config["privateKeyPath"],
                client_bootstrap=client_bootstrap,
                ca_filepath=self.config["rootCAPath"],
                client_id=self.config["clientId"],
                clean_session=False,
                keep_alive_secs=30
            )

            connect_future = self.mqtt_connection.connect()
            connect_future.result()  # Wait until connection is complete

            self.logger.info("Connection to AWS IoT successful")

            # Request historical data if connection is successful
            self.request_sensor_history()
            self.request_event_history()

            # Request room control statuses
            self.request_room_control(control_type="device", control_name="tv")
            self.request_room_control(control_type="device", control_name="ac")
            self.request_room_control(control_type="light", control_name="main")
            self.request_room_control(control_type="light", control_name="desk")
            self.request_room_control(control_type="light", control_name="bed")
            self.request_room_control(control_type="light", control_name="bathroom")

            # Request user preferences
            self.request_user_preferences()

            return True

        except Exception as e:
            self.logger.error(f"AWS IoT connection error: {str(e)}")
            return False

    def disconnect(self):
        """Closes the AWS IoT connection"""
        if self.mqtt_connection:
            try:
                disconnect_future = self.mqtt_connection.disconnect()
                disconnect_future.result()
                self.logger.info("AWS IoT connection closed")
            except Exception as e:
                self.logger.error(f"Disconnection error: {e}")

    def set_command_handler(self, handler):
        """
        Sets the command handler

        Args:
            handler: Function that handles incoming commands from AWS IoT
        """
        self.command_handler = handler

    def subscribe_to_commands(self):
        """Subscribes to command and preference topics"""
        if not self.mqtt_connection:
            self.logger.error("MQTT connection not found. connect() must be called first.")
            return False

        try:
            # Subscribe to receive commands
            command_topic = f"room/{self.config['thingName']}/commands"
            self.mqtt_connection.subscribe(
                topic=command_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Subscribed to command topic: {command_topic}")

            # Subscribe to receive user preference responses
            preference_topic = f"room/{self.config['thingName']}/preference/response"
            self.mqtt_connection.subscribe(
                topic=preference_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Subscribed to preference response topic: {preference_topic}")

            # QR code secret responses
            qr_topic = f"room/{self.config['roomId']}/secret/response"
            self.mqtt_connection.subscribe(
                topic=qr_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Subscribed to secret response topic: {qr_topic}")

            # Subscribe for sensor history responses
            sensor_history_topic = f"room/{self.config['thingName']}/sensors/history/response"
            self.mqtt_connection.subscribe(
                topic=sensor_history_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Subscribed to sensor history response topic: {sensor_history_topic}")

            # Subscribe for event history responses
            event_history_topic = f"room/{self.config['thingName']}/events/history/response"
            self.mqtt_connection.subscribe(
                topic=event_history_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Subscribed to event history response topic: {event_history_topic}")

            # Subscribe for RoomControl updates
            room_control_topic = f"room/{self.config['roomId']}/control/response"
            self.mqtt_connection.subscribe(
                topic=room_control_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Subscribed to room control topic: {room_control_topic}")

            return True

        except Exception as e:
            self.logger.error(f"Topic subscription error: {e}")
            return False

    def _process_incoming_message(self, topic, payload, **kwargs):
        """Processes incoming messages from AWS and routes to appropriate handler"""
        try:
            message = json.loads(payload.decode())
            self.logger.info(f"Topic: {topic}, Message received: {message}")

            # Call the user-defined handler if available
            if self.command_handler:
                self.command_handler(topic, message)

        except Exception as e:
            self.logger.error(f"Message processing error: {e}")

    def publish_sensor_data(self, data):
        """Publishes sensor data to AWS IoT"""
        if not self.mqtt_connection:
            self.logger.error("MQTT connection not found. connect() must be called first.")
            return False

        try:

            self.sensor_history.append(data.copy())

            # Check history size
            if len(self.sensor_history) > self.max_history_size:
                self.sensor_history.pop(0)  # Remove the oldest data

            # Serialize data to JSON
            #payload = json.dumps(data)
            timestamp = int(time.time())
            iso_time = datetime.fromtimestamp(timestamp, timezone.utc).isoformat()

            payload =  json.dumps({
                "roomId": self.config['thingName'],
                "payload": self.sensor_history,
                "updatedAt": iso_time,
                "createdAt": iso_time
            })

            # Send data to AWS IoT
            topic = f"room/{self.config['thingName']}/sensors"
            self.mqtt_connection.publish(
                topic=topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.debug(f"Sensor data sent: {payload}")
            return True

        except Exception as e:
            self.logger.error(f"Data transmission error: {e}")
            return False

    def publish_room_event(self, event_type, description):
        """Publishes room events to AWS IoT"""
        if not self.mqtt_connection:
            self.logger.error("MQTT connection not found. connect() must be called first.")
            return False

        try:

            self.logger.info(f"Event type: {event_type}, Description: {description}")

            event_data = {
                "eventType": event_type,  # ALERT, SECURITY_WARNING, INFO etc.
                "timestamp": int(time.time()),
                "description": description,
                "resolved": False
            }

            self.event_history.append(event_data.copy())

            # Check history size
            if len(self.event_history) > self.max_history_size:
                self.event_history.pop(0)  # Remove the oldest data

            # Serialize data to JSON
            timestamp = int(time.time())
            iso_time = datetime.fromtimestamp(timestamp, timezone.utc).isoformat()
            payload =  json.dumps({
                "roomId": self.config['thingName'],
                "payload": self.event_history,
                "updatedAt": iso_time,
                "createdAt": iso_time
            })

            # Publish event data
            event_topic = f"room/{self.config['thingName']}/events"
            self.mqtt_connection.publish(
                topic=event_topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.info(f"Room event registered: {event_type} - {description}")
            return True

        except Exception as e:
            self.logger.error(f"Event logging error: {e}")
            return False

    def publish_device_status(self, device_statuses):
        """Publishes device statuses to AWS IoT"""
        if not self.mqtt_connection:
            self.logger.error("MQTT connection not found. connect() must be called first.")
            return False

        try:
            # Serialize data to JSON
            payload = json.dumps({
                "roomId": self.config['thingName'],
                "devices": device_statuses,
                "timestamp": int(time.time()),
                "updatedAt": int(time.time()),
                "createdAt": int(time.time())
            })

            # Send data to AWS IoT
            topic = f"room/{self.config['thingName']}/devices"
            self.mqtt_connection.publish(
                topic=topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.debug(f"Device statuses sent: {payload}")
            return True

        except Exception as e:
            self.logger.error(f"Device status publish error: {e}")
            return False

    def request_user_preferences(self):
        """Requests user preferences via API Gateway"""
        if not self.mqtt_connection:
            self.logger.error("MQTT connection not found. connect() must be called first.")
            return False

        try:
            # Publish preference query over MQTT
            request_id = str(uuid.uuid4())
            request_topic = f"room/{self.config['thingName']}/preference/request"
            request_payload = json.dumps({
                "requestId": request_id,
                "roomId": self.config['thingName']
            })

            # Send request
            self.mqtt_connection.publish(
                topic=request_topic,
                payload=request_payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.info(f"User preferences requested, request ID: {request_id}")
            return True

        except Exception as e:
            self.logger.error(f"User preferences request error: {e}")
            return False

    def request_sensor_history(self):
        """Requests sensor history over MQTT"""
        try:
            # Prepare JSON for sensor history request
            request_id = str(uuid.uuid4())
            payload = json.dumps({
                "requestId": request_id,
                "roomId": self.config['thingName'],
                "limit": self.max_history_size
            })

            # Request topic
            request_topic = f"room/{self.config['thingName']}/sensors/history/request"

            # Publish request
            self.mqtt_connection.publish(
                topic=request_topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )
            self.logger.info(f"Sensor history requested, request ID: {request_id}")
            return True

        except Exception as e:
            self.logger.error(f"Sensor history request error: {e}")
            return False

    def request_event_history(self):
        """Requests event history over MQTT"""
        try:
            # Prepare JSON for event history request
            request_id = str(uuid.uuid4())
            payload = json.dumps({
                "requestId": request_id,
                "roomId": self.config['thingName'],
                "limit": self.max_history_size
            })

            # Request topic
            request_topic = f"room/{self.config['thingName']}/events/history/request"

            # Publish request
            self.mqtt_connection.publish(
                topic=request_topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )
            self.logger.info(f"Event history requested, request ID: {request_id}")
            return True

        except Exception as e:
            self.logger.error(f"Event history request error: {e}")
            return False

    def request_room_control(self, control_type=None, control_name=None):
        """
        Requests RoomControl statuses from AWS Amplify

        Args:
            control_type: Optional, filter by specific control type (light, device)
            control_name: Optional, filter by specific device name (tv, ac)
        """
        if not self.mqtt_connection:
            self.logger.error("MQTT connection not found. connect() must be called first.")
            return False

        try:
            # Publish RoomControl query over MQTT
            request_id = str(uuid.uuid4())
            request_topic = f"room/{self.config['roomId']}/control/request"

            # Prepare request payload
            request_payload = {
                "requestId": request_id,
                "roomId": self.config['roomId']
            }

            # Add optional filters
            if control_type:
                request_payload["controlType"] = control_type

            if control_name:
                request_payload["controlName"] = control_name

            # Send request
            self.mqtt_connection.publish(
                topic=request_topic,
                payload=json.dumps(request_payload),
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.info(f"RoomControl statuses requested: {request_payload}")
            return True

        except Exception as e:
            self.logger.error(f"RoomControl statuses request error: {e}")
            return False

    def test_network_connection(self):
        """Performs a simple network connection test to AWS IoT endpoint"""
        import socket

        try:
            # Simple ping test
            host = self.config["endpoint"]
            self.logger.info(f"Attempting connection to AWS IoT endpoint: {host}")

            # Normal socket connection
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)

            self.logger.info("1. Socket created, establishing connection...")
            sock.connect((host, 8883))
            self.logger.info("2. TCP connection established")

            # Closing without SSL/TLS connection
            sock.close()
            self.logger.info("3. Basic socket connection successful")

            return True
        except socket.timeout:
            self.logger.error("Connection timed out. Check your firewall or internet connection.")
            return False
        except socket.gaierror as e:
            self.logger.error(f"DNS resolution error. Check endpoint address: {e}")
            return False
        except Exception as e:
            self.logger.error(f"Network connection error: {str(e)}")
            return False