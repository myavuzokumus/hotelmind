import os
import logging
from pathlib import Path


class Config:
    """Tüm sistem konfigürasyonlarını yöneten sınıf"""

    # Varsayılan değerler
    DEFAULT_CONFIG = {
        "thingName": "room_001",
        "clientId": "room_001",
        "roomId": "room_001",
    }

    # GPIO pin tanımlamaları
    GPIO_CONFIG = {
        "GAS_SENSOR_PIN": 21,  # MQ-2 için GPIO21
        "IR_PIN": 18,  # IR sensör pini (algılama için)
        "IR_TRANSMITTER_PIN": 17,  # IR verici pini (kontrol için)
        "DISTANCE_TRIG_PIN": 16,  # HC-SR04 Trigger pin
        "DISTANCE_ECHO_PIN": 20,  # HC-SR04 Echo pin
        "SPEAKER_PIN": 23,  # Hoparlör için PWM pini
        "LED_MAIN_PIN": 13,  # LED için GPIO pini
        "LED_DESK_PIN": 26,  # Alarm LED'i için GPIO pini
    }

    # BMP280 tanımlamaları
    BMP280_CONFIG = {
        "ADDRESS": 0x76,  # BMP280 I2C adresi (0x76 veya 0x77 olabilir)
        "REG_DIG_T1": 0x88,
        "REG_DIG_T2": 0x8A,
        "REG_DIG_T3": 0x8C,
        "REG_DIG_P1": 0x8E,
        "REG_DIG_P2": 0x90,
        "REG_DIG_P3": 0x92,
        "REG_DIG_P4": 0x94,
        "REG_DIG_P5": 0x96,
        "REG_DIG_P6": 0x98,
        "REG_DIG_P7": 0x9A,
        "REG_DIG_P8": 0x9C,
        "REG_DIG_P9": 0x9E,
        "REG_CHIPID": 0xD0,
        "REG_CONTROL": 0xF4,
        "REG_CONFIG": 0xF5,
        "REG_TEMP_MSB": 0xFA,
        "REG_TEMP_LSB": 0xFB,
        "REG_TEMP_XLSB": 0xFC,
        "REG_PRESS_MSB": 0xF7,
        "REG_PRESS_LSB": 0xF8,
        "REG_PRESS_XLSB": 0xF9,
    }

    def __init__(self):
        self.script_dir = Path(__file__).parent.parent.absolute()
        self.certs_dir = self.script_dir / "certs"
        self.config = self.DEFAULT_CONFIG.copy()

        # Gizli konfigürasyonları git'ten bağımsız secrets.json dosyasından oku
        secrets_file = self.certs_dir / "secrets.json"
        if secrets_file.exists():
            import json
            try:
                with open(secrets_file, 'r') as f:
                    secrets = json.load(f)
                    self.config.update(secrets)
            except Exception as e:
                logging.error(f"secrets.json okunamadı: {e}")

        # Sertifika yollarını ayarla
        self.config.update({
            "rootCAPath": str(self.certs_dir / "root-CA.crt"),
            "certificatePath": str(self.certs_dir / f"{self.config['thingName']}.cert.pem"),
            "privateKeyPath": str(self.certs_dir / f"{self.config['thingName']}.private.key"),
        })

        # Donanım kontrolleri
        self.has_hardware = self._check_hardware()

    def _check_hardware(self):
        """Donanım kütüphanelerinin kullanılabilirliğini kontrol eder"""
        hardware_available = True

        # RPi.GPIO kütüphanesini kontrol et
        try:
            import RPi.GPIO as GPIO
            GPIO.setmode(GPIO.BCM)  # BCM mod için ayarlama ekle
        except ImportError as e:
            logging.warning(f"RPi.GPIO kütüphanesi bulunamadı: {e}")
            hardware_available = False

        # smbus2 kütüphanesini kontrol et
        try:
            import smbus2
        except ImportError as e:
            logging.warning(f"smbus2 kütüphanesi bulunamadı: {e}")
            hardware_available = False

        if not hardware_available:
            logging.warning("Donanım kütüphaneleri eksik. Simülasyon modu etkinleştiriliyor.")

        return hardware_available

    @property
    def gpio(self):
        """GPIO pin konfigürasyonlarına erişim sağlar"""
        return self.GPIO_CONFIG

    @property
    def bmp280(self):
        """BMP280 konfigürasyonlarına erişim sağlar"""
        return self.BMP280_CONFIG

    def check_certificates(self):
        """Sertifika dosyalarının varlığını kontrol eder"""
        cert_files = [
            self.config["rootCAPath"],
            self.config["certificatePath"],
            self.config["privateKeyPath"]
        ]

        missing_files = [f for f in cert_files if not os.path.exists(f)]

        if missing_files:
            for f in missing_files:
                logging.error(f"Sertifika dosyası bulunamadı: {f}")
            return False
        return True

    def get(self, key, default=None):
        """Belirli bir konfigürasyon değerini getirir"""
        return self.config.get(key, default)

    def __getitem__(self, key):
        """Dict-like erişim için"""
        return self.config[key]