import json
import logging
import time
import os


class IRController:
    """Kızılötesi cihaz kontrol sınıfı"""

    def __init__(self, config):
        """
        IR kontrol cihazını başlatır

        Args:
            config: Sistem konfigürasyonu
        """
        self.logger = logging.getLogger("SmartRoom.IRController")
        self.config = config
        self.has_hardware = config.has_hardware
        self.ir_pin = config.gpio["IR_TRANSMITTER_PIN"]
        self.gpio = None
        self.device_codes_file = os.path.join(os.path.dirname(__file__), "ir_codes.json")
        self.device_codes = self._load_device_codes()
        self.device_status = {}
        self.iot_client = None

    def set_iot_client(self, iot_client):
        """IoT istemcisini ayarlar"""
        self.iot_client = iot_client

    def _load_device_codes(self):
        """IR cihaz kodları dosyasını yükler"""
        try:
            if os.path.exists(self.device_codes_file):
                with open(self.device_codes_file, 'r') as file:
                    return json.load(file)
            else:
                # Varsayılan kodları oluştur
                default_codes = {
                    "tv": {
                        "power": [9000, 4500, 560, 560, 560, 560, 560, 1690, 560, 560, 560, 560, 560, 560, 560, 560,
                                  560, 1690],
                        "volumeUp": [9000, 4500, 560, 560, 560, 1690, 560, 560, 560, 560, 560, 560, 560, 560, 560, 560,
                                     560, 1690],
                        "volumeDown": [9000, 4500, 560, 1690, 560, 560, 560, 560, 560, 560, 560, 560, 560, 560, 560,
                                       560, 560, 1690]
                    },
                    "ac": {
                        "power": [9000, 4500, 560, 560, 560, 560, 560, 1690, 560, 1690, 560, 560, 560, 560, 560, 560,
                                  560, 1690],
                        "tempUp": [9000, 4500, 560, 560, 560, 560, 560, 560, 560, 1690, 560, 560, 560, 1690, 560, 560,
                                   560, 1690],
                        "tempDown": [9000, 4500, 560, 560, 560, 560, 560, 560, 560, 560, 560, 1690, 560, 1690, 560, 560,
                                     560, 1690]
                    }
                }
                with open(self.device_codes_file, 'w') as file:
                    json.dump(default_codes, file, indent=4)
                return default_codes
        except Exception as e:
            self.logger.error(f"IR kodları yükleme hatası: {e}")
            return {}

    def setup(self):
        """IR vericisini yapılandırır"""
        if not self.has_hardware:
            self.logger.info("Simülasyon modu: IR verici simüle ediliyor")
            return True

        try:
            import RPi.GPIO as GPIO
            self.gpio = GPIO
            self.gpio.setup(self.ir_pin, self.gpio.OUT)
            self.logger.info("IR verici başarıyla yapılandırıldı")
            return True
        except Exception as e:
            self.logger.error(f"IR verici başlatma hatası: {e}")
            return False

    def send_ir_signal(self, code):
        """
        IR sinyali gönderir

        Args:
            code: IR sinyal kodu (mikrosaniyelik aralıklar listesi)
        """
        if not self.has_hardware:
            self.logger.debug(f"Simülasyon modu: IR sinyal gönderiliyor: {code[:5]}...")
            return True

        try:
            # Normalde burada pigpio veya LIRC gibi kütüphaneleri kullanmak daha doğru olacaktır
            # Bu basitleştirilmiş bir implementasyondur
            for i, pulse in enumerate(code):
                if i % 2 == 0:  # Çift indeks: sinyal açık
                    self.gpio.output(self.ir_pin, True)
                else:  # Tek indeks: sinyal kapalı
                    self.gpio.output(self.ir_pin, False)

                # Mikrosaniye cinsinden bekle
                time.sleep(pulse / 1000000.0)

            # Son durumda pini kapatalım
            self.gpio.output(self.ir_pin, False)
            return True
        except Exception as e:
            self.logger.error(f"IR sinyal gönderme hatası: {e}")
            return False

    def control_device(self, device_type, command, status=None):
        """
        Cihazı kontrol eder

        Args:
            device_type: Cihaz tipi (tv, ac, vb.)
            command: Komut (power, volumeUp, vb.)
            status: İstenen durum (True/False) - sadece power komutunda kullanılır

        Returns:
            bool: İşlem başarılı oldu mu
        """
        if device_type not in self.device_codes:
            self.logger.error(f"Bilinmeyen cihaz tipi: {device_type}")
            return False

        if command not in self.device_codes[device_type]:
            self.logger.error(f"Bilinmeyen komut: {command}")
            return False

        # Cihaz durumunu güncelle
        device_key = f"{device_type}"
        old_status = self.device_status.get(device_key, False)

        if command == "power":
            # Durum belirtilmediyse, mevcut durumu tersine çevir
            if status is None:
                self.device_status[device_key] = not old_status
            else:
                self.device_status[device_key] = status

        # IR sinyali gönder
        code = self.device_codes[device_type][command]
        result = self.send_ir_signal(code)

        if result:
            self.logger.info(f"{device_type} için {command} komutu gönderildi")

            if command == "power":
                new_status = self.device_status.get(device_key, False)
                self.logger.info(
                    f"{device_type} durumu: {'açık' if new_status else 'kapalı'}")

                # Durum değiştiyse olay yayınla
                if old_status != new_status and self.iot_client:
                    event_type = "MODE_CHANGE"
                    description = f"{device_type.upper()} {'açıldı' if new_status else 'kapatıldı'}"
                    self.iot_client.publish_room_event(event_type, description)

            elif self.iot_client:
                # Diğer komutlar için de olay yayınla (ses ayarı, sıcaklık ayarı vb.)
                event_type = "MODE_CHANGE"
                description = f"{device_type.upper()} için {command} komutu uygulandı"
                self.iot_client.publish_room_event(event_type, description)

            # RoomControl güncellemelerini mevcut kodla bırakın
            try:
                # RoomControl model güncellemesi için mesaj hazırla
                from cloud.iot_client import IoTClient
                import time
                import json

                self.logger.debug(f"RoomControl için durum güncellemesi hazırlanıyor: {device_type} - {status}")
            except Exception as e:
                self.logger.error(f"RoomControl güncelleme hatası: {e}")

        return result

    def _update_amplify_room_control(self, device_name, status):
        """
        AWS Amplify'daki RoomControl modelini günceller

        Args:
            device_name: Cihaz adı
            status: Açık/kapalı durumu
        """
        try:
            # RoomControl model güncellemesi için mesaj hazırla
            from cloud.iot_client import IoTClient
            import time
            import json

            # Global IoTClient'a direkt erişimimiz olmadığından
            # main.py içindeki güncellemelere güveniyoruz

            self.logger.debug(f"RoomControl için durum güncellemesi hazırlanıyor: {device_name} - {status}")
        except Exception as e:
            self.logger.error(f"RoomControl güncelleme hatası: {e}")

    def get_device_status(self, device_type=None):
        """
        Cihaz durumunu döndürür

        Args:
            device_type: Belirtilirse sadece o cihazın durumu, None ise tüm durumlar

        Returns:
            dict: Cihaz durumları
        """
        if device_type:
            return {device_type: self.device_status.get(device_type, False)}
        return self.device_status