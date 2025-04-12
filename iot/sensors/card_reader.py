import logging
import random


class CardReader:
    """Kart okuyucu için sınıf"""

    def __init__(self, config):
        """
        Kart okuyucuyu başlatır

        Args:
            config: Sistem konfigürasyonu
        """
        self.logger = logging.getLogger("SmartRoom.CardReader")
        self.config = config
        self.has_hardware = config.has_hardware
        self.card_inserted = False

    def setup(self):
        """Kart okuyucuyu yapılandırır"""
        if not self.has_hardware:
            self.logger.info("Simülasyon: Kart okuyucu simülasyon modunda")
            return True

        try:
            # Gerçek kart okuyucu kodu buraya eklenebilir
            self.logger.info("Kart okuyucu başarıyla yapılandırıldı")
            return True

        except Exception as e:
            self.logger.error(f"Kart okuyucu başlatma hatası: {e}")
            return False

    def read_sensor(self):
        """Kart okuyucu durumunu okur"""
        if not self.has_hardware:
            # %10 ihtimalle durumu değiştir
            if random.randint(1, 100) > 90:
                self.card_inserted = not self.card_inserted
            return self.card_inserted

        try:
            # Gerçek RFID okuyucu kodu buraya eklenebilir
            # Bu örnek için rastgele değer döndürelim
            return self.card_inserted

        except Exception as e:
            self.logger.error(f"Kart okuyucu okuma hatası: {e}")
            return False