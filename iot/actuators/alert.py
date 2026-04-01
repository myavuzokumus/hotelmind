import logging
import time


class AlertController:
    """Alert system control"""

    def __init__(self, config):
        """
        Initializes the alert controller

        Args:
            config: System configuration
        """
        self.logger = logging.getLogger("SmartRoom.AlertController")
        self.config = config
        self.has_hardware = config.has_hardware
        self.speaker_pin = config.gpio["SPEAKER_PIN"]
        self.gpio = None
        self.iot_client = None
        self.preferences = None

    def set_iot_client(self, iot_client, preferences):
        """Sets the IoT client"""
        self.iot_client = iot_client
        self.preferences = preferences

    def setup(self):
        """Configures the alert system"""
        if not self.has_hardware:
            self.logger.info("Simulation: Alert system in simulation mode")
            return True

        try:
            import RPi.GPIO as GPIO
            self.gpio = GPIO

            # Speaker pin
            self.gpio.setup(self.speaker_pin, self.gpio.OUT)

            self.logger.info("Alert system configured successfully")
            return True

        except Exception as e:
            self.logger.error(f"Alert system initialization error: {e}")
            return False

    def play_warning_sound(self):
        """Plays warning sound"""
        if not self.has_hardware:
            self.logger.info("SIMULATION: Playing warning sound...")

            # Add to event history
            if self.iot_client:
                event_type = "SECURITY_WARNING"
                description = "Warning sound played (simulation)"
                self.iot_client.publish_room_event(event_type, description)

            return True

        try:
            if self.preferences and self.preferences.user_preferences.get("voiceReports", False):
                self.logger.info("Playing warning sound...")
                self.gpio.setup(self.speaker_pin, self.gpio.OUT)
                pwm = self.gpio.PWM(self.speaker_pin, 1000)  # 1 kHz frequency
                pwm.start(50)  # 50% duty cycle

                # Play warning sound
                for _ in range(5):  # 5 beeps
                    pwm.ChangeFrequency(1000)  # 1 kHz
                    time.sleep(0.2)
                    pwm.ChangeFrequency(500)  # 500 Hz
                    time.sleep(0.2)

                pwm.stop()

            # Add to event history
            if self.iot_client:
                event_type = "ALERT"
                description = "Dangerous gas level detected."
                self.iot_client.publish_room_event(event_type, description)

            return True

        except Exception as e:
            self.logger.error(f"Warning sound play error: {e}")
            return False

    def show_notification(self, message):
        """Shows a notification on Screen/LED"""
        self.logger.info(f"Notification: {message}")
        # Function to show notification with LED or screen here