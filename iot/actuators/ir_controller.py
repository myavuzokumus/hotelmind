import json
import logging
import time
import os


class IRController:
    """Class for infrared device control"""

    def __init__(self, config):
        """
        Initializes the IR controller

        Args:
            config: System configuration
        """
        self.logger = logging.getLogger("SmartRoom.IRController")
        self.config = config
        self.has_hardware = config.has_hardware
        self.ir_pin = config.gpio["IR_TRANSMITTER_PIN"]

        # Define LED pins
        self.led_pins = {
            "MAIN": config.gpio.get("LED_MAIN_PIN", 24),
        }

        self.gpio = None
        self.device_codes_file = os.path.join(os.path.dirname(__file__), "ir_codes.json")
        self.device_codes = self._load_device_codes()
        self.device_status = {}
        self.iot_client = None

    def set_iot_client(self, iot_client):
        """Sets the IoT client"""
        self.iot_client = iot_client

    def _load_device_codes(self):
        """Loads the IR device codes file"""
        try:
            if os.path.exists(self.device_codes_file):
                with open(self.device_codes_file, 'r') as file:
                    return json.load(file)
            else:
                # Generate default codes
                default_codes = {
                    "tv": {
                        "power": [9000, 4500, 560, 560, 560, 560, 560, 1690, 560, 560, 560, 560, 560, 560, 560, 560,
                                  560, 1690],
                        "volumeUp": [9000, 4500, 560, 560, 560, 1690, 560, 560, 560, 560, 560, 560, 560, 560, 560, 560,
                                     560, 1690],
                        "volumeDown": [9000, 4500, 560, 1690, 560, 560, 560, 560, 560, 560, 560, 560, 560, 560, 560,
                                       560, 560, 1690]
                    },
                    "ac": {
                        "power": [9000, 4500, 560, 560, 560, 560, 560, 1690, 560, 1690, 560, 560, 560, 560, 560, 560,
                                  560, 1690],
                        "tempUp": [9000, 4500, 560, 560, 560, 560, 560, 560, 560, 1690, 560, 560, 560, 1690, 560, 560,
                                   560, 1690],
                        "tempDown": [9000, 4500, 560, 560, 560, 560, 560, 560, 560, 560, 560, 1690, 560, 1690, 560, 560,
                                     560, 1690]
                    }
                }
                with open(self.device_codes_file, 'w') as file:
                    json.dump(default_codes, file, indent=4)
                return default_codes
        except Exception as e:
            self.logger.error(f"IR codes load error: {e}")
            return {}

    def setup(self):
        """Configures the IR transmitter"""
        if not self.has_hardware:
            self.logger.info("Simulation mode: IR transmitter is simulated")
            return True

        try:
            import RPi.GPIO as GPIO
            self.gpio = GPIO
            self.gpio.setup(self.ir_pin, self.gpio.OUT)

            # LED pin configuration
            for device_type, pin in self.led_pins.items():
                if pin:
                    self.gpio.setup(pin, self.gpio.OUT)
                    self.logger.debug(f"LED pin {pin} configured for {device_type}")

            self.logger.info("IR transmitter configured successfully")
            return True
        except Exception as e:
            self.logger.error(f"IR transmitter initialization error: {e}")
            return False

    def set_led_status(self, device_type, status):
        """
        Turns the device LED on or off

        Args:
            device_type: Device type (tv, ac, etc.)
            status: LED status (True=on, False=off)
        """
        if not self.has_hardware:
            self.logger.debug(f"Simulation: {device_type} LED {'turned on' if status else 'turned off'}")
            return True

        try:
            if device_type in self.led_pins and self.led_pins[device_type]:
                self.gpio.output(self.led_pins[device_type], status)
                self.logger.debug(f"{device_type} LED {'turned on' if status else 'turned off'}")
                return True
            return False
        except Exception as e:
            self.logger.error(f"LED control error: {e}")
            return False

    def send_ir_signal(self, code):
        """
        Sends IR signal

        Args:
            code: IR signal code (list of intervals in microseconds)
        """
        if not self.has_hardware:
            self.logger.debug(f"Simulation mode: Sending IR signal: {code[:5]}...")
            return True

        try:
            # Normally it would be more accurate to use libraries like pigpio or LIRC here
            # This is a simplified implementation
            for i, pulse in enumerate(code):
                if i % 2 == 0:  # Even index: signal on
                    self.gpio.output(self.ir_pin, True)
                else:  # Odd index: signal off
                    self.gpio.output(self.ir_pin, False)

                # Wait in microseconds
                time.sleep(pulse / 1000000.0)

            # Finally, let's turn off the pin
            self.gpio.output(self.ir_pin, False)
            return True
        except Exception as e:
            self.logger.error(f"IR signal send error: {e}")
            return False

    def control_device(self, device_type, command, status=None):
        """
        Controls the device

        Args:
            device_type: Device type (tv, ac, etc.)
            command: Command (power, volumeUp, etc.)
            status: Desired status (True/False) - only used with power command

        Returns:
            bool: Was the operation successful
        """
        if device_type not in self.device_codes:
            self.logger.error(f"Unknown device type: {device_type}")
            return False

        if command not in self.device_codes[device_type]:
            self.logger.error(f"Unknown command: {command}")
            return False

        # Update device status
        device_key = f"{device_type}"
        old_status = self.device_status.get(device_key, False)

        if command == "power":
            # If status is not specified, toggle the current status
            if status is None:
                self.device_status[device_key] = not old_status
            else:
                self.device_status[device_key] = status

        # Send IR signal
        code = self.device_codes[device_type][command]
        result = self.send_ir_signal(code)

        if result:
            self.logger.info(f"Command {command} sent to {device_type}")

            if command == "power":
                new_status = self.device_status.get(device_key, False)

                # Update LED on power command too
                self.set_led_status(device_type, new_status)

                self.logger.info(
                    f"{device_type} status: {'on' if new_status else 'off'}")

                # Publish event if status changed
                if old_status != new_status and self.iot_client:
                    event_type = "MODE_CHANGE"
                    description = f"{device_type.upper()} {'turned on' if new_status else 'turned off'}"
                    self.iot_client.publish_room_event(event_type, description)

            elif self.iot_client:
                # Publish event for other commands too (volume, temp etc.)
                event_type = "MODE_CHANGE"
                description = f"Command {command} applied to {device_type.upper()}"
                self.iot_client.publish_room_event(event_type, description)

            # Keep RoomControl updates with existing code
            try:
                # Prepare message for RoomControl model update
                from cloud.iot_client import IoTClient
                import time
                import json

                self.logger.debug(f"Preparing status update for RoomControl: {device_type} - {status}")
            except Exception as e:
                self.logger.error(f"RoomControl update error: {e}")

        return result

    def _update_amplify_room_control(self, device_name, status):
        """
        Updates RoomControl model in AWS Amplify

        Args:
            device_name: Device name
            status: On/off status
        """
        try:
            # Prepare message for RoomControl model update
            from cloud.iot_client import IoTClient
            import time
            import json

            # Since we don't have direct access to global IoTClient
            # we rely on updates in main.py

            self.logger.debug(f"Preparing status update for RoomControl: {device_name} - {status}")
        except Exception as e:
            self.logger.error(f"RoomControl update error: {e}")

    def get_device_status(self, device_type=None):
        """
        Returns device status

        Args:
            device_type: If provided only that device's status, if None all statuses

        Returns:
            dict: Device statuses
        """
        if device_type:
            return {device_type: self.device_status.get(device_type, False)}
        return self.device_status