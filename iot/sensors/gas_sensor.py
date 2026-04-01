import logging
import random


class GasSensor:
    """Class for MQ-2 gas sensor"""

    def __init__(self, config):
        """
        Initializes the gas sensor

        Args:
            config: System configuration
        """
        self.logger = logging.getLogger("SmartRoom.GasSensor")
        self.config = config
        self.has_hardware = config.has_hardware
        self.pin = config.gpio["GAS_SENSOR_PIN"]
        self.gpio = None

    def setup(self):
        """Configures the sensor"""
        if not self.has_hardware:
            self.logger.info("Simulation: Gas sensor in simulation mode")
            return True

        try:
            import RPi.GPIO as GPIO
            self.gpio = GPIO

            # Gas sensor (MQ-2)
            self.gpio.setup(self.pin, self.gpio.IN)
            self.logger.info("Gas sensor configured successfully")
            return True

        except Exception as e:
            self.logger.error(f"Gas sensor initialization error: {e}")
            return False

    def read_sensor(self):
        """Reads gas level from MQ-2"""
        if not self.has_hardware:
            # Simulate gas level out of 10 (mostly low, sometimes high)
            if random.randint(1, 100) > 95:  # 5% chance of high gas level
                return random.randint(6, 10)
            else:
                return random.randint(0, 2)

        try:
            # MQ-2 sensor logic might be inverted:
            # 0: Gas detected, 1: Gas not detected
            gas_detected = not self.gpio.input(self.pin)

            # Convert digital value to a value between 0-10
            if gas_detected:
                # Simulate the intensity of the detected gas
                return random.randint(6, 10)
            else:
                return random.randint(0, 2)

        except Exception as e:
            self.logger.error(f"MQ-2 sensor read error: {e}")
            return 0

    def is_gas_detected(self):
        """Returns whether gas is detected (boolean)"""
        return self.read_sensor() > 5