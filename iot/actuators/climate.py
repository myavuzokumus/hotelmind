import logging


class ClimateController:
    """İklimlendirme kontrolü"""

    def __init__(self, config):
        """
        İklimlendirme kontrolörünü başlatır

        Args:
            config: Sistem konfigürasyonu
        """
        self.logger = logging.getLogger("SmartRoom.ClimateController")
        self.config = config
        self.has_hardware = config.has_hardware
        self.iot_client = None

        # İklimlendirme durumu
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
        """IoT istemcisini ayarlar"""
        self.iot_client = iot_client

    def setup(self):
        """İklimlendirme donanımını yapılandırır"""
        if not self.has_hardware:
            self.logger.info("Simülasyon: İklimlendirme kontrolörü simülasyon modunda")
            return True

        try:
            # Gerçek donanım kontrolü burada yapılabilir
            # GPIO pinleri, röleler vb. yapılandırılabilir

            self.logger.info("İklimlendirme kontrolörü başarıyla yapılandırıldı")
            return True

        except Exception as e:
            self.logger.error(f"İklimlendirme kontrolörü başlatma hatası: {e}")
            return False

    def update_preferences(self, preferences):
        """
        Kullanıcı tercihlerine göre hedef değerleri günceller

        Args:
            preferences: Kullanıcı tercihleri
        """
        try:
            old_temp = self.state["target_temp"]
            old_humidity = self.state["target_humidity"]

            # Tercihlerdeki değerleri al
            if "preferredTemperature" in preferences:
                self.state["target_temp"] = float(preferences["preferredTemperature"])

            if "preferredHumidity" in preferences:
                self.state["target_humidity"] = float(preferences["preferredHumidity"])

            # Değerler değiştiyse log yaz
            if old_temp != self.state["target_temp"]:
                self.logger.info(f"Hedef sıcaklık güncellendi: {old_temp}°C -> {self.state['target_temp']}°C")

            if old_humidity != self.state["target_humidity"]:
                self.logger.info(f"Hedef nem güncellendi: {old_humidity}% -> {self.state['target_humidity']}%")

            # Güncellenen tercihlere göre olay yayınla
            if self.iot_client and (
                    old_temp != self.state["target_temp"] or old_humidity != self.state["target_humidity"]):
                self.iot_client.publish_room_event("PREFERENCE_UPDATE",
                                                   f"İklimlendirme hedefleri güncellendi - Sıcaklık: {self.state['target_temp']}°C, Nem: {self.state['target_humidity']}%")

        except Exception as e:
            self.logger.error(f"Tercih güncelleme hatası: {e}")

    def apply_settings(self, settings):
        """
        İklimlendirme ayarlarını uygular

        Args:
            settings: Uygulanacak ayarlar (hedef sıcaklık, nem, mod vs.)
        """
        try:
            # Ayarları güncelle
            if "targetTemperature" in settings:
                self.state["target_temp"] = float(settings["targetTemperature"])

            if "targetHumidity" in settings:
                self.state["target_humidity"] = float(settings["targetHumidity"])

            if "mode" in settings:
                mode = settings["mode"]
                self._apply_climate_mode(mode)

            self.logger.info(f"İklimlendirme ayarları güncellendi: {self.state}")
            return True

        except Exception as e:
            self.logger.error(f"İklimlendirme ayarlarını uygulama hatası: {e}")
            return False

    def _apply_climate_mode(self, mode):
        """
        İklimlendirme modunu uygular

        Args:
            mode: Mod ('heat', 'cool', 'auto', 'off')
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
            # Otomatik mod - sensör verisine göre ısıtma/soğutma yapar
            # Bu fonksiyona mevcut sıcaklık da parametre olarak gelmeli
            pass

        # Durum değiştiyse olay yayınla
        if (old_heating != self.state["heating"] or old_cooling != self.state["cooling"]) and self.iot_client:
            current_mode = "kapalı"
            if self.state["heating"]:
                current_mode = "ısıtma"
            elif self.state["cooling"]:
                current_mode = "soğutma"

            event_type = "CLIMATE_ACTION"
            description = f"Klima modu değişti: {current_mode}"
            self.iot_client.publish_room_event(event_type, description)

    def adjust_for_temperature(self, current_temp):
        """
        Mevcut sıcaklığa göre iklimlendirmeyi ayarlar

        Args:
            current_temp: Mevcut sıcaklık değeri
        """
        target_temp = self.state["target_temp"]

        if current_temp < target_temp - 1.5:
            # Isıtma gerekiyor
            if not self.state["heating"]:
                self._heat()
            self.logger.info(f"Isıtma aktif: Mevcut {current_temp}°C, Hedef {target_temp}°C")
        elif current_temp > target_temp + 1.5:
            # Soğutma gerekiyor
            if not self.state["cooling"]:
                self._cool()
            self.logger.info(f"Soğutma aktif: Mevcut {current_temp}°C, Hedef {target_temp}°C")
        else:
            # Hedef sıcaklık aralığındayız, bir şey yapma
            if self.state["heating"] or self.state["cooling"]:
                self.logger.info(f"İklimlendirme devre dışı: Mevcut {current_temp}°C, Hedef {target_temp}°C")
                self._turn_off()

    def adjust_for_humidity(self, current_humidity):
        """
        Mevcut nem oranına göre nemlendirme/nem alma işlemi yapar

        Args:
            current_humidity: Mevcut nem oranı
        """
        target_humidity = self.state["target_humidity"]

        if current_humidity < target_humidity - 5:
            # Nemlendirme gerekiyor
            if not self.state["humidifier"]:
                self._humidify()
            self.logger.info(f"Nemlendirme aktif: Mevcut {current_humidity}%, Hedef {target_humidity}%")
        elif current_humidity > target_humidity + 5:
            # Nem alma gerekiyor
            if not self.state["dehumidifier"]:
                self._dehumidify()
            self.logger.info(f"Nem alma aktif: Mevcut {current_humidity}%, Hedef {target_humidity}%")
        else:
            # Hedef nem aralığındayız, nem kontrol cihazlarını kapat
            if self.state["humidifier"] or self.state["dehumidifier"]:
                self.logger.info(f"Nem kontrolü devre dışı: Mevcut {current_humidity}%, Hedef {target_humidity}%")
                self._turn_off_humidity_control()

    def _heat(self):
        """Isıtma fonksiyonu"""
        if not self.has_hardware:
            self.logger.info("SİMÜLASYON: Isıtma açıldı")
        else:
            try:
                # Isıtıcı kontrolü burada
                pass
            except Exception as e:
                self.logger.error(f"Isıtıcı kontrolü hatası: {e}")

        self.state["heating"] = True
        self.state["cooling"] = False

    def _cool(self):
        """Soğutma fonksiyonu"""
        if not self.has_hardware:
            self.logger.info("SİMÜLASYON: Soğutma açıldı")
        else:
            try:
                # Soğutucu kontrolü burada
                pass
            except Exception as e:
                self.logger.error(f"Soğutucu kontrolü hatası: {e}")

        self.state["cooling"] = True
        self.state["heating"] = False

    def _humidify(self):
        """Nemlendirme fonksiyonu"""
        if not self.has_hardware:
            self.logger.info("SİMÜLASYON: Nemlendirici açıldı")
        else:
            try:
                # Nemlendirici kontrolü burada
                pass
            except Exception as e:
                self.logger.error(f"Nemlendirici kontrolü hatası: {e}")

        self.state["humidifier"] = True
        self.state["dehumidifier"] = False

        # Olay yayınla
        if self.iot_client:
            self.iot_client.publish_room_event("HUMIDITY_ACTION", "Nemlendirici açıldı")

    def _dehumidify(self):
        """Nem alma fonksiyonu"""
        if not self.has_hardware:
            self.logger.info("SİMÜLASYON: Nem alıcı açıldı")
        else:
            try:
                # Nem alıcı kontrolü burada
                pass
            except Exception as e:
                self.logger.error(f"Nem alıcı kontrolü hatası: {e}")

        self.state["dehumidifier"] = True
        self.state["humidifier"] = False

        # Olay yayınla
        if self.iot_client:
            self.iot_client.publish_room_event("HUMIDITY_ACTION", "Nem alıcı açıldı")

    def _turn_off_humidity_control(self):
        """Nem kontrol cihazlarını kapatır"""
        if not self.has_hardware:
            self.logger.info("SİMÜLASYON: Nem kontrolü kapatıldı")
        else:
            try:
                # Nem kontrol cihazlarını kapat
                pass
            except Exception as e:
                self.logger.error(f"Nem kontrol kapatma hatası: {e}")

        self.state["humidifier"] = False
        self.state["dehumidifier"] = False

    def _turn_off(self):
        """İklimlendirmeyi kapatır"""
        if not self.has_hardware:
            self.logger.info("SİMÜLASYON: İklimlendirme kapatıldı")
        else:
            try:
                # İklimlendirme cihazlarını kapat
                pass
            except Exception as e:
                self.logger.error(f"İklimlendirme kapatma hatası: {e}")

        self.state["cooling"] = False
        self.state["heating"] = False