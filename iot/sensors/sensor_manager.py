import time
import logging
import threading
from .temperature import TemperatureSensor
from .gas_sensor import GasSensor
from .distance import DistanceSensor
from .card_reader import CardReader


class SensorManager:
    """Tüm sensörleri yöneten ana sınıf"""

    def __init__(self, config):
        """
        Sensör yöneticisini başlatır

        Args:
            config: Sistem konfigürasyonu
        """
        self.logger = logging.getLogger("SmartRoom.SensorManager")
        self.config = config
        self.has_hardware = config.has_hardware

        # Sensör durumları
        self.sensor_data = {
            "timestamp": 0,
            "temperature": 22.0,
            "pressure": 1013.25,  # Basınç değeri eklendi
            "humidity": 50.0,  # Not: Şimdilik nem sensörü yok, simüle ediyoruz
            "gasLevel": 0,
            "distance": 300.0,
            "occupied": True,  # IR sensör durumu (True=dolu, False=boş)
            "cardInserted": False,
        }

        # Sensörleri başlat
        self.temperature_sensor = TemperatureSensor(config)
        self.gas_sensor = GasSensor(config)
        self.distance_sensor = DistanceSensor(config)
        self.card_reader = CardReader(config)

        self.logger.info("Sensör yöneticisi başlatıldı")

    def setup_sensors(self):
        """Tüm sensörleri yapılandırır"""
        try:
            # Tüm sensörleri başlat
            temperature_ok = self.temperature_sensor.setup()
            gas_ok = self.gas_sensor.setup()
            distance_ok = self.distance_sensor.setup()
            card_ok = self.card_reader.setup()

            if self.has_hardware and not all([temperature_ok, gas_ok, distance_ok, card_ok]):
                self.logger.warning("Bazı sensörler başlatılamadı")
                return False

            self.logger.info("Tüm sensörler başarıyla yapılandırıldı")
            return True

        except Exception as e:
            self.logger.error(f"Sensör yapılandırma hatası: {e}")
            return False

    def read_all_sensors(self):
        """Tüm sensörlerden veri okur ve sensor_data sözlüğünü günceller"""
        # Sıcaklık sensörü
        temp, pressure = self.temperature_sensor.read_sensor()
        if temp is not None:
            self.sensor_data["temperature"] = round(temp, 1)
        if pressure is not None:
            self.sensor_data["pressure"] = round(pressure, 1)

        # Nem değeri - gerçek sensör olmadığından simüle edilir
        # Daha gerçekçi bir nem değeri için sıcaklığa bağlı simulasyon
        self.sensor_data["humidity"] = max(30, min(70, 50 + (temp - 22.0) * 2)) if temp else 50.0

        # MQ-2 gaz sensörü
        gas_level = self.gas_sensor.read_sensor()
        self.sensor_data["gasLevel"] = gas_level

        # HC-SR04 mesafe sensörü
        distance = self.distance_sensor.read_sensor()
        self.sensor_data["distance"] = round(distance, 1)
        # Engel var mı?
        self.sensor_data["occupied"] = round(distance, 1) < 150  # 150 < engel var / dolu

        # Kart durumu
        card_inserted = self.card_reader.read_sensor()
        self.sensor_data["cardInserted"] = card_inserted

        # Zaman damgası
        self.sensor_data["timestamp"] = int(time.time())

        return self.sensor_data

    def start_monitoring(self, callback, interval=10):
        """
        Sensör izlemeyi başlatan yardımcı metod

        Args:
            callback: Her sensör okumasından sonra çağrılacak fonksiyon
            interval: Okumalar arası saniye cinsinden bekleme süresi
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