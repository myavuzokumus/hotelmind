import logging
import random
import time


class DistanceSensor:
    """Class for HC-SR04 distance sensor"""

    def __init__(self, config):
        """
        Initializes the distance sensor

        Args:
            config: System configuration
        """
        self.logger = logging.getLogger("SmartRoom.DistanceSensor")
        self.config = config
        self.has_hardware = config.has_hardware
        self.trig_pin = config.gpio["DISTANCE_TRIG_PIN"]
        self.echo_pin = config.gpio["DISTANCE_ECHO_PIN"]
        self.gpio = None

    def setup(self):
        """Configures the sensor"""
        if not self.has_hardware:
            self.logger.info("Simulation: Distance sensor in simulation mode")
            return True

        try:
            import RPi.GPIO as GPIO
            self.gpio = GPIO

            # Distance sensor (HC-SR04)
            self.gpio.setup(self.trig_pin, self.gpio.OUT)
            self.gpio.setup(self.echo_pin, self.gpio.IN)
            self.gpio.output(self.trig_pin, False)
            time.sleep(0.1)  # Short wait for sensor stabilization

            self.logger.info("Distance sensor configured successfully")
            return True

        except Exception as e:
            self.logger.error(f"Distance sensor initialization error: {e}")
            return False

    def read_sensor(self):
        """Measures distance from HC-SR04 (in cm)"""
        if not self.has_hardware:
            # Simulate distance - 80% chance far, 20% chance close
            if random.randint(1, 100) > 80:
                return random.uniform(10.0, 150.0)  # Close distance (presence)
            else:
                return random.uniform(200.0, 400.0)  # Far distance (no presence)

        try:
            # Measure distance with HC-SR04
            self.gpio.output(self.trig_pin, False)
            time.sleep(0.01)  # 10ms wait

            # Send 10 microsecond pulse
            self.gpio.output(self.trig_pin, True)
            time.sleep(0.00001)  # 10 microseconds
            self.gpio.output(self.trig_pin, False)

            # Wait for Echo pin to go high
            start_time = time.time()
            timeout_start = start_time
            while self.gpio.input(self.echo_pin) == 0:
                start_time = time.time()
                if start_time - timeout_start > 0.1:  # 100ms timeout
                    self.logger.warning("Distance sensor start signal not received (timeout)")
                    return 400.0

            # Wait for Echo pin to go low
            stop_time = time.time()
            timeout_start = stop_time
            while self.gpio.input(self.echo_pin) == 1:
                stop_time = time.time()
                if stop_time - timeout_start > 0.1:  # 100ms timeout
                    self.logger.warning("Distance sensor end signal not received (timeout)")
                    return 400.0

            # Calculate distance (speed of sound: 343m/s = 34300cm/s)
            pulse_duration = stop_time - start_time
            distance = (pulse_duration * 34300) / 2  # target distance in cm

            # Validity check
            if distance < 2 or distance > 400:  # HC-SR04 range: 2cm-400cm
                self.logger.warning(f"Invalid distance measurement: {distance:.1f} cm")
                return 400.0 if distance > 400 else 2.0

            return distance

        except Exception as e:
            self.logger.error(f"HC-SR04 sensor read error: {e}")
            return 400.0  # Maximum value on error