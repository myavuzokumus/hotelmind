import logging
import time
from warnings import deprecated


class PreferenceManager:
    """Kullanıcı tercihleri yönetimi"""

    def __init__(self, iot_client, default_preferences=None):
        """
        Tercih yöneticisini başlatır

        Args:
            iot_client: IoT bağlantı istemcisi
            default_preferences: Varsayılan tercihler
        """
        self.logger = logging.getLogger("SmartRoom.PreferenceManager")
        self.iot_client = iot_client

        # Varsayılan tercihler
        self.default_preferences = {
            "preferredTemperature": 22.0,
            "preferredHumidity": 50.0,
            "autoClimate": True,
            "automaticLights": True,
            "voiceReports": False,
            "roomMode": "comfort"
        }

        # Varsayılan değerleri güncelle
        if default_preferences:
            self.default_preferences.update(default_preferences)

        # Aktif tercihler (başlangıçta varsayılan değerleri kullan)
        self.user_preferences = self.default_preferences.copy()

        # Son tercih alma zamanı
        self.last_fetch_time = 0

    def update_preferences(self, new_preferences):
        """
        Kullanıcı tercihlerini günceller

        Args:
            new_preferences: Yeni tercih değerleri
        """
        if new_preferences:
            self.user_preferences.update(new_preferences)
            self.logger.info(f"Kullanıcı tercihleri güncellendi: {self.user_preferences}")

    def get_preference(self, key, default=None):
        """
        Belirli bir tercihin değerini döndürür

        Args:
            key: İstenen tercih anahtarı
            default: Tercih bulunamazsa döndürülecek varsayılan değer

        Returns:
            Tercih değeri veya varsayılan değer
        """
        return self.user_preferences.get(key, default)

    @deprecated("Yeni veri geldiğinde sistem otomatik olarak çekmekte, kullanıma gerek kalmadı.")
    def fetch_preferences(self, force=False):
        """
        Bulut'tan kullanıcı tercihlerini alır

        Args:
            force: True ise zamanlama kontrolünü atlar ve zorla istek yapar

        Returns:
            dict: Güncel kullanıcı tercihleri
        """
        current_time = int(time.time())

        # 5 dakikada bir tercihleri güncelle (çok sık istek göndermemek için)
        # veya force=True ise hemen güncelle
        if force or (current_time - self.last_fetch_time >= 300):
            self.iot_client.request_user_preferences()
            self.last_fetch_time = current_time

        return self.user_preferences