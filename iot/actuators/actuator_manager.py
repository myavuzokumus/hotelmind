import logging


class ActuatorManager:
    """Tüm çıktı cihazlarını yöneten ana sınıf"""

    def __init__(self, config):
        """
        Çıktı cihazlarını yönetecek sınıfı başlatır

        Args:
            config: Sistem konfigürasyonu
        """
        self.logger = logging.getLogger("SmartRoom.ActuatorManager")
        self.config = config
        self.has_hardware = config.has_hardware
        self.iot_client = None  # IoT istemci referansı

        # Alt kontrol birimleri
        from .climate import ClimateController
        from .alert import AlertController
        from .ir_controller import IRController

        self.climate = ClimateController(config)
        self.alert = AlertController(config)
        self.ir_controller = IRController(config)

    def setup(self):
        """Tüm çıktı cihazlarını yapılandırır"""
        try:
            # Alt birimleri yapılandır
            climate_ok = self.climate.setup()
            alert_ok = self.alert.setup()
            ir_ok = self.ir_controller.setup()

            if self.has_hardware and not all([climate_ok, alert_ok, ir_ok]):
                self.logger.warning("Bazı çıktı cihazları başlatılamadı")
                return False

            self.logger.info("Tüm çıktı cihazları başarıyla yapılandırıldı")
            return True

        except Exception as e:
            self.logger.error(f"Çıktı cihazları yapılandırma hatası: {e}")
            return False

    def set_iot_client(self, iot_client):
        """
        IoT istemcisini ayarlar

        Args:
            iot_client: AWS IoT istemcisi
        """
        self.iot_client = iot_client
        # Alt kontrol birimlerine de IoT istemcisini geçir
        self.climate.set_iot_client(iot_client)
        self.ir_controller.set_iot_client(iot_client)
        self.alert.set_iot_client(iot_client)

    def process_actions(self, actions):
        """AI Agent'tan gelen eylemleri işler"""
        try:
            if "climate" in actions:
                climate = actions["climate"]
                self.logger.info(f"İklimlendirme ayarları: {climate}")
                self.climate.apply_settings(climate)

            if "security" in actions:
                security = actions["security"]
                self.logger.info(f"Güvenlik eylemleri: {security}")
                if security.get("warningActive", False):
                    self.alert.play_warning_sound()

            if "devices" in actions:
                devices = actions["devices"]
                self.logger.info(f"Cihaz kontrolleri: {devices}")
                for device_type, commands in devices.items():
                    for command, value in commands.items():
                        self.ir_controller.control_device(device_type, command, value)

        except Exception as e:
            self.logger.error(f"Eylem işleme hatası: {e}")