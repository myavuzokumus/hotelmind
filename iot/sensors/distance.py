import logging
import random
import time


class DistanceSensor:
    """HC-SR04 mesafe sensörü için sınıf"""

    def __init__(self, config):
        """
        Mesafe sensörünü başlatır

        Args:
            config: Sistem konfigürasyonu
        """
        self.logger = logging.getLogger("SmartRoom.DistanceSensor")
        self.config = config
        self.has_hardware = config.has_hardware
        self.trig_pin = config.gpio["DISTANCE_TRIG_PIN"]
        self.echo_pin = config.gpio["DISTANCE_ECHO_PIN"]
        self.gpio = None

    def setup(self):
        """Sensörü yapılandırır"""
        if not self.has_hardware:
            self.logger.info("Simülasyon: Mesafe sensörü simülasyon modunda")
            return True

        try:
            import RPi.GPIO as GPIO
            self.gpio = GPIO

            # Mesafe sensörü (HC-SR04)
            self.gpio.setup(self.trig_pin, self.gpio.OUT)
            self.gpio.setup(self.echo_pin, self.gpio.IN)
            self.gpio.output(self.trig_pin, False)
            time.sleep(0.1)  # Sensörün stabil olması için kısa bekleme

            self.logger.info("Mesafe sensörü başarıyla yapılandırıldı")
            return True

        except Exception as e:
            self.logger.error(f"Mesafe sensörü başlatma hatası: {e}")
            return False

    def read_sensor(self):
        """HC-SR04'ten mesafe ölçümü yapar (cm cinsinden)"""
        if not self.has_hardware:
            # Mesafeyi simüle et - %80 ihtimalle uzak, %20 ihtimalle yakın
            if random.randint(1, 100) > 80:
                return random.uniform(10.0, 150.0)  # Yakın mesafe (kişi var)
            else:
                return random.uniform(200.0, 400.0)  # Uzak mesafe (kişi yok)

        try:
            # HC-SR04 ile mesafe ölçümü
            self.gpio.output(self.trig_pin, False)
            time.sleep(0.01)  # 10ms bekleme

            # 10 mikrosaniyelik pulse gönder
            self.gpio.output(self.trig_pin, True)
            time.sleep(0.00001)  # 10 mikrosaniye
            self.gpio.output(self.trig_pin, False)

            # Echo pininin yükselmesini bekle
            start_time = time.time()
            timeout_start = start_time
            while self.gpio.input(self.echo_pin) == 0:
                start_time = time.time()
                if start_time - timeout_start > 0.1:  # 100ms timeout
                    self.logger.warning("Mesafe sensörü başlangıç sinyali alınamadı (timeout)")
                    return 400.0

            # Echo pininin düşmesini bekle
            stop_time = time.time()
            timeout_start = stop_time
            while self.gpio.input(self.echo_pin) == 1:
                stop_time = time.time()
                if stop_time - timeout_start > 0.1:  # 100ms timeout
                    self.logger.warning("Mesafe sensörü bitiş sinyali alınamadı (timeout)")
                    return 400.0

            # Mesafeyi hesapla (ses hızı: 343m/s = 34300cm/s)
            pulse_duration = stop_time - start_time
            distance = (pulse_duration * 34300) / 2  # cm cinsinden mesafe

            # Geçerlilik kontrolü
            if distance < 2 or distance > 400:  # HC-SR04'ün aralığı: 2cm-400cm
                self.logger.warning(f"Geçersiz mesafe ölçümü: {distance:.1f} cm")
                return 400.0 if distance > 400 else 2.0

            return distance

        except Exception as e:
            self.logger.error(f"HC-SR04 sensör okuma hatası: {e}")
            return 400.0  # Hata durumunda maksimum değer