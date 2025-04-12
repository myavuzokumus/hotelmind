import logging
import time


class AlertController:
    """Uyarı sistemi kontrolü"""

    def __init__(self, config):
        """
        Uyarı kontrolörünü başlatır

        Args:
            config: Sistem konfigürasyonu
        """
        self.logger = logging.getLogger("SmartRoom.AlertController")
        self.config = config
        self.has_hardware = config.has_hardware
        self.speaker_pin = config.gpio["SPEAKER_PIN"]
        self.gpio = None
        self.iot_client = None

    def set_iot_client(self, iot_client):
        """IoT istemcisini ayarlar"""
        self.iot_client = iot_client

    def setup(self):
        """Uyarı sistemini yapılandırır"""
        if not self.has_hardware:
            self.logger.info("Simülasyon: Uyarı sistemi simülasyon modunda")
            return True

        try:
            import RPi.GPIO as GPIO
            self.gpio = GPIO

            # Hoparlör pini
            self.gpio.setup(self.speaker_pin, self.gpio.OUT)

            self.logger.info("Uyarı sistemi başarıyla yapılandırıldı")
            return True

        except Exception as e:
            self.logger.error(f"Uyarı sistemi başlatma hatası: {e}")
            return False

    def play_warning_sound(self):
        """Uyarı sesi çalar"""
        if not self.has_hardware:
            self.logger.info("SİMÜLASYON: Uyarı sesi çalınıyor...")

            # Olay geçmişine ekle
            if self.iot_client:
                event_type = "SECURITY_WARNING"
                description = "Uyarı sesi çalındı (simülasyon)"
                self.iot_client.publish_room_event(event_type, description)

            return True

        try:
            self.logger.info("Uyarı sesi çalınıyor...")
            self.gpio.setup(self.speaker_pin, self.gpio.OUT)
            pwm = self.gpio.PWM(self.speaker_pin, 1000)  # 1 kHz frekans
            pwm.start(50)  # %50 görev döngüsü

            # Uyarı sesi çal
            for _ in range(5):  # 5 bip
                pwm.ChangeFrequency(1000)  # 1 kHz
                time.sleep(0.2)
                pwm.ChangeFrequency(500)  # 500 Hz
                time.sleep(0.2)

            pwm.stop()

            # Olay geçmişine ekle
            if self.iot_client:
                event_type = "ALERT_TRIGGERED"
                description = "Uyarı sesi çalındı"
                self.iot_client.publish_room_event(event_type, description)

            return True

        except Exception as e:
            self.logger.error(f"Uyarı sesi çalma hatası: {e}")
            return False

    def show_notification(self, message):
        """Ekran/LED üzerinde bir bildirim gösterir"""
        self.logger.info(f"Bildirim: {message}")
        # LED veya ekran ile bildirim gösterme fonksiyonu burada