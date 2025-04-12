import logging
import random


class GasSensor:
    """MQ-2 gaz sensörü için sınıf"""

    def __init__(self, config):
        """
        Gaz sensörünü başlatır

        Args:
            config: Sistem konfigürasyonu
        """
        self.logger = logging.getLogger("SmartRoom.GasSensor")
        self.config = config
        self.has_hardware = config.has_hardware
        self.pin = config.gpio["GAS_SENSOR_PIN"]
        self.gpio = None

    def setup(self):
        """Sensörü yapılandırır"""
        if not self.has_hardware:
            self.logger.info("Simülasyon: Gaz sensörü simülasyon modunda")
            return True

        try:
            import RPi.GPIO as GPIO
            self.gpio = GPIO

            # Gaz sensörü (MQ-2)
            self.gpio.setup(self.pin, self.gpio.IN)
            self.logger.info("Gaz sensörü başarıyla yapılandırıldı")
            return True

        except Exception as e:
            self.logger.error(f"Gaz sensörü başlatma hatası: {e}")
            return False

    def read_sensor(self):
        """MQ-2'den gaz seviyesini okur"""
        if not self.has_hardware:
            # 10 üzerinden gaz seviyesi simüle et (çoğunlukla düşük, bazen yüksek)
            if random.randint(1, 100) > 95:  # %5 ihtimalle yüksek gaz seviyesi
                return random.randint(6, 10)
            else:
                return random.randint(0, 2)

        try:
            # MQ-2 sensörü lojik olarak tersine çevrilmiş olabilir:
            # 0: Gaz algılandı, 1: Gaz algılanmadı
            gas_detected = not self.gpio.input(self.pin)

            # Dijital değeri 0-10 arası bir değere dönüştür
            if gas_detected:
                # Algılanan gazın şiddetini simüle et
                return random.randint(6, 10)
            else:
                return random.randint(0, 2)

        except Exception as e:
            self.logger.error(f"MQ-2 sensör okuma hatası: {e}")
            return 0

    def is_gas_detected(self):
        """Gaz algılanıp algılanmadığını döndürür (boolean)"""
        return self.read_sensor() > 5