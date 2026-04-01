import logging


class ClimateController:
    """Climate control"""

    def __init__(self, config):
        """
        Initializes the climate controller

        Args:
            config: System configuration
        """
        self.logger = logging.getLogger("SmartRoom.ClimateController")
        self.config = config
        self.has_hardware = config.has_hardware
        self.iot_client = None

        # Climate state
        self.state = {
            "heating": False,
            "cooling": False,
            "fan": False,
            "humidifier": False,
            "dehumidifier": False,
            "target_temp": 22.0,
            "target_humidity": 50.0
        }

    def set_iot_client(self, iot_client):
        """Sets the IoT client"""
        self.iot_client = iot_client

    def setup(self):
        """Configures the climate hardware"""
        if not self.has_hardware:
            self.logger.info("Simulation: Climate controller in simulation mode")
            return True

        try:
            # Real hardware control can be done here
            # GPIO pins, relays etc. can be configured

            self.logger.info("Climate controller configured successfully")
            return True

        except Exception as e:
            self.logger.error(f"Climate controller initialization error: {e}")
            return False

    def update_preferences(self, preferences):
        """
        Updates target values based on user preferences

        Args:
            preferences: User preferences
        """
        try:
            old_temp = self.state["target_temp"]
            old_humidity = self.state["target_humidity"]

            # Get values from preferences
            if "preferredTemperature" in preferences:
                self.state["target_temp"] = float(preferences["preferredTemperature"])

            if "preferredHumidity" in preferences:
                self.state["target_humidity"] = float(preferences["preferredHumidity"])

            # Log if values changed
            if old_temp != self.state["target_temp"]:
                self.logger.info(f"Target temperature updated: {old_temp}°C -> {self.state['target_temp']}°C")

            if old_humidity != self.state["target_humidity"]:
                self.logger.info(f"Target humidity updated: {old_humidity}% -> {self.state['target_humidity']}%")

            # Publish event based on updated preferences
            if self.iot_client and (
                    old_temp != self.state["target_temp"] or old_humidity != self.state["target_humidity"]):
                self.iot_client.publish_room_event("PREFERENCE_UPDATE",
                                                   f"Climate targets updated - Temperature: {self.state['target_temp']}°C, Humidity: {self.state['target_humidity']}%")

        except Exception as e:
            self.logger.error(f"Preference update error: {e}")

    def apply_settings(self, settings):
        """
        Applies climate settings

        Args:
            settings: Settings to apply (target temp, humidity, mode etc.)
        """
        try:
            # Update settings
            if "targetTemperature" in settings:
                self.state["target_temp"] = float(settings["targetTemperature"])

            if "targetHumidity" in settings:
                self.state["target_humidity"] = float(settings["targetHumidity"])

            if "mode" in settings:
                mode = settings["mode"]
                self._apply_climate_mode(mode)

            self.logger.info(f"Climate settings updated: {self.state}")
            return True

        except Exception as e:
            self.logger.error(f"Climate settings apply error: {e}")
            return False

    def _apply_climate_mode(self, mode):
        """
        Applies climate mode

        Args:
            mode: Mode ('heat', 'cool', 'auto', 'off')
        """
        old_heating = self.state["heating"]
        old_cooling = self.state["cooling"]

        if mode == "heat":
            self.state["heating"] = True
            self.state["cooling"] = False
            self._heat()
        elif mode == "cool":
            self.state["heating"] = False
            self.state["cooling"] = True
            self._cool()
        elif mode == "off":
            self.state["heating"] = False
            self.state["cooling"] = False
            self._turn_off()
        elif mode == "auto":
            # Auto mode - heats/cools based on sensor data
            # Current temperature should also be a parameter to this function
            pass

        # Publish event if state changed
        if (old_heating != self.state["heating"] or old_cooling != self.state["cooling"]) and self.iot_client:
            current_mode = "off"
            if self.state["heating"]:
                current_mode = "heating"
            elif self.state["cooling"]:
                current_mode = "cooling"

            event_type = "CLIMATE_ACTION"
            description = f"Climate mode changed: {current_mode}"
            self.iot_client.publish_room_event(event_type, description)

    def adjust_for_temperature(self, current_temp):
        """
        Adjusts climate based on current temperature

        Args:
            current_temp: Current temperature value
        """
        target_temp = self.state["target_temp"]

        if current_temp < target_temp - 1.5:
            # Heating needed
            if not self.state["heating"]:
                self._heat()
            self.logger.info(f"Heating active: Current {current_temp}°C, Target {target_temp}°C")
        elif current_temp > target_temp + 1.5:
            # Cooling needed
            if not self.state["cooling"]:
                self._cool()
            self.logger.info(f"Cooling active: Current {current_temp}°C, Target {target_temp}°C")
        else:
            # Within target temperature range, do nothing
            if self.state["heating"] or self.state["cooling"]:
                self.logger.info(f"Climate control disabled: Current {current_temp}°C, Target {target_temp}°C")
                self._turn_off()

    def adjust_for_humidity(self, current_humidity):
        """
        Performs humidification/dehumidification based on current humidity

        Args:
            current_humidity: Current humidity rate
        """
        target_humidity = self.state["target_humidity"]

        if current_humidity < target_humidity - 5:
            # Humidification needed
            if not self.state["humidifier"]:
                self._humidify()
            self.logger.info(f"Humidification active: Current {current_humidity}%, Target {target_humidity}%")
        elif current_humidity > target_humidity + 5:
            # Dehumidification needed
            if not self.state["dehumidifier"]:
                self._dehumidify()
            self.logger.info(f"Dehumidification active: Current {current_humidity}%, Target {target_humidity}%")
        else:
            # Within target humidity range, turn off humidity control devices
            if self.state["humidifier"] or self.state["dehumidifier"]:
                self.logger.info(f"Humidity control disabled: Current {current_humidity}%, Target {target_humidity}%")
                self._turn_off_humidity_control()

    def _heat(self):
        """Heating function"""
        if not self.has_hardware:
            self.logger.info("SIMULATION: Heating turned on")
        else:
            try:
                # Heater control here
                pass
            except Exception as e:
                self.logger.error(f"Heater control error: {e}")

        self.state["heating"] = True
        self.state["cooling"] = False

    def _cool(self):
        """Cooling function"""
        if not self.has_hardware:
            self.logger.info("SIMULATION: Cooling turned on")
        else:
            try:
                # Cooler control here
                pass
            except Exception as e:
                self.logger.error(f"Cooler control error: {e}")

        self.state["cooling"] = True
        self.state["heating"] = False

    def _humidify(self):
        """Humidification function"""
        if not self.has_hardware:
            self.logger.info("SIMULATION: Humidifier turned on")
        else:
            try:
                # Humidifier control here
                pass
            except Exception as e:
                self.logger.error(f"Humidifier control error: {e}")

        self.state["humidifier"] = True
        self.state["dehumidifier"] = False

        # Publish event
        if self.iot_client:
            self.iot_client.publish_room_event("HUMIDITY_ACTION", "Humidifier turned on")

    def _dehumidify(self):
        """Dehumidification function"""
        if not self.has_hardware:
            self.logger.info("SIMULATION: Dehumidifier turned on")
        else:
            try:
                # Dehumidifier control here
                pass
            except Exception as e:
                self.logger.error(f"Dehumidifier control error: {e}")

        self.state["dehumidifier"] = True
        self.state["humidifier"] = False

        # Publish event
        if self.iot_client:
            self.iot_client.publish_room_event("HUMIDITY_ACTION", "Dehumidifier turned on")

    def _turn_off_humidity_control(self):
        """Turns off humidity control devices"""
        if not self.has_hardware:
            self.logger.info("SIMULATION: Humidity control turned off")
        else:
            try:
                # Turn off humidity control devices
                pass
            except Exception as e:
                self.logger.error(f"Humidity control disable error: {e}")

        self.state["humidifier"] = False
        self.state["dehumidifier"] = False

    def _turn_off(self):
        """Turns off climate control"""
        if not self.has_hardware:
            self.logger.info("SIMULATION: Climate control turned off")
        else:
            try:
                # Turn off climate control devices
                pass
            except Exception as e:
                self.logger.error(f"Climate disable error: {e}")

        self.state["cooling"] = False
        self.state["heating"] = False