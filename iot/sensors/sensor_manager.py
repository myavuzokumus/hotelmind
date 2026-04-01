import time
import logging
import threading
from .temperature import TemperatureSensor
from .gas_sensor import GasSensor
from .distance import DistanceSensor
from .card_reader import CardReader


class SensorManager:
    """Main class managing all sensors"""

    def __init__(self, config):
        """
        Initializes the sensor manager

        Args:
            config: System configuration
        """
        self.logger = logging.getLogger("SmartRoom.SensorManager")
        self.config = config
        self.has_hardware = config.has_hardware

        # Sensor states
        self.sensor_data = {
            "timestamp": 0,
            "temperature": 22.0,
            "pressure": 1013.25,  # Pressure value added
            "humidity": 50.0,  # Note: No humidity sensor for now, simulating
            "gasLevel": 0,
            "distance": 300.0,
            "occupied": True,  # IR sensor status (True=occupied, False=empty)
            "cardInserted": False,
        }

        # Initialize sensors
        self.temperature_sensor = TemperatureSensor(config)
        self.gas_sensor = GasSensor(config)
        self.distance_sensor = DistanceSensor(config)
        self.card_reader = CardReader(config)

        self.logger.info("Sensor manager initialized")

    def setup_sensors(self):
        """Configures all sensors"""
        try:
            # Initialize all sensors
            temperature_ok = self.temperature_sensor.setup()
            gas_ok = self.gas_sensor.setup()
            distance_ok = self.distance_sensor.setup()
            card_ok = self.card_reader.setup()

            if self.has_hardware and not all([temperature_ok, gas_ok, distance_ok, card_ok]):
                self.logger.warning("Some sensors could not be initialized")
                return False

            self.logger.info("All sensors configured successfully")
            return True

        except Exception as e:
            self.logger.error(f"Sensor configuration error: {e}")
            return False

    def read_all_sensors(self):
        """Reads data from all sensors and updates sensor_data dictionary"""
        # Temperature sensor
        temp, pressure = self.temperature_sensor.read_sensor()
        if temp is not None:
            self.sensor_data["temperature"] = round(temp, 1)
        if pressure is not None:
            self.sensor_data["pressure"] = round(pressure, 1)

        # Humidity value - simulated since there is no real sensor
        # Temperature-dependent simulation for a more realistic humidity value
        self.sensor_data["humidity"] = max(30, min(70, 50 + (temp - 22.0) * 2)) if temp else 50.0

        # MQ-2 gas sensor
        gas_level = self.gas_sensor.read_sensor()
        self.sensor_data["gasLevel"] = gas_level

        # HC-SR04 distance sensor
        distance = self.distance_sensor.read_sensor()
        self.sensor_data["distance"] = round(distance, 1)
        # Is there an obstacle?
        self.sensor_data["occupied"] = round(distance, 1) < 150  # < 150 obstacle present / occupied

        # Card status
        card_inserted = self.card_reader.read_sensor()
        self.sensor_data["cardInserted"] = card_inserted

        # Timestamp
        self.sensor_data["timestamp"] = int(time.time())

        return self.sensor_data

    def start_monitoring(self, callback, interval=10):
        """
        Helper method to start sensor monitoring

        Args:
            callback: Function to be called after each sensor reading
            interval: Waiting time in seconds between readings
        """

        def monitor_thread():
            while True:
                data = self.read_all_sensors()
                if callback:
                    callback(data)
                time.sleep(interval)

        thread = threading.Thread(target=monitor_thread)
        thread.daemon = True
        thread.start()
        return thread