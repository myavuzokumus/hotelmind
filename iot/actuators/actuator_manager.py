import logging


class ActuatorManager:
    """Main class to manage all output devices"""

    def __init__(self, config):
        """
        Initializes the class to manage output devices

        Args:
            config: System configuration
        """
        self.logger = logging.getLogger("SmartRoom.ActuatorManager")
        self.config = config
        self.has_hardware = config.has_hardware
        self.iot_client = None  # IoT client reference
        self.preferences = None

        # Sub-controllers
        from .climate import ClimateController
        from .alert import AlertController
        from .ir_controller import IRController

        self.climate = ClimateController(config)
        self.alert = AlertController(config)
        self.ir_controller = IRController(config)

    def setup(self):
        """Configures all output devices"""
        try:
            # Configure sub-units
            climate_ok = self.climate.setup()
            alert_ok = self.alert.setup()
            ir_ok = self.ir_controller.setup()

            if self.has_hardware and not all([climate_ok, alert_ok, ir_ok]):
                self.logger.warning("Some output devices could not be initialized")
                return False

            self.logger.info("All output devices configured successfully")
            return True

        except Exception as e:
            self.logger.error(f"Output devices configuration error: {e}")
            return False

    def set_iot_client(self, iot_client, preferences):
        """
        Sets the IoT client

        Args:
            iot_client: AWS IoT client
        """
        self.iot_client = iot_client
        # Pass IoT client to sub-controllers too
        self.climate.set_iot_client(iot_client)
        self.ir_controller.set_iot_client(iot_client)
        self.alert.set_iot_client(iot_client, preferences)

    def process_actions(self, actions):
        """Processes actions coming from AI Agent"""
        try:
            if "climate" in actions:
                climate = actions["climate"]
                self.logger.info(f"Climate settings: {climate}")
                self.climate.apply_settings(climate)

            if "security" in actions:
                security = actions["security"]
                self.logger.info(f"Security actions: {security}")
                if security.get("warningActive", False):
                    self.alert.play_warning_sound()

            if "devices" in actions:
                devices = actions["devices"]
                self.logger.info(f"Device controls: {devices}")
                for device_type, commands in devices.items():
                    for command, value in commands.items():
                        self.ir_controller.control_device(device_type, command, value)

        except Exception as e:
            self.logger.error(f"Action processing error: {e}")