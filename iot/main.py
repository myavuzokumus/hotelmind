import argparse
import logging
import sys
import time
import tkinter as tk
from pathlib import Path

# Proje kök dizinini Python yoluna ekle
sys.path.append(str(Path(__file__).parent.parent))

# Kendi modüllerimizi içe aktar
from utils.config import Config
from utils.logger import setup_logger, setup_aws_iot_logger
from sensors.sensor_manager import SensorManager
from actuators.actuator_manager import ActuatorManager
from cloud.iot_client import IoTClient
from cloud.preference import PreferenceManager
from utils.qrcode_generator import QRCodeGenerator

# Global değişkenler
running = True
logger = None
qr_generator = None


def parse_args():
    parser = argparse.ArgumentParser(description="Akıllı Oda Kontrol Sistemi")
    parser.add_argument("-m", "--mock", action="store_true", dest="mock_sensors",
                        help="Sensörleri simüle et (Raspberry Pi donanımı olmadığında)")
    parser.add_argument("-v", "--verbose", action="store_true", dest="verbose",
                        help="Detaylı log çıktısı")
    parser.add_argument("-q", "--qrcode", action="store_true", dest="show_qrcode",
                        help="Başlangıçta QR kod üretecini göster")
    return parser.parse_args()


def command_handler(topic, message):
    """AWS'den gelen komutları işler"""
    global preference_manager, actuator_manager, qr_generator, iot_client

    try:
        logger.info(f"Komut alındı: {message}")

        # RoomControl model değişikliklerini kontrol et
        if topic.endswith('/control/response') and "roomControl" in message:
            control_type = message["roomControl"].get("controlType")
            control_name = message["roomControl"].get("controlName")
            status = message["roomControl"].get("status", False)

            logger.info(f"Oda kontrolü alındı: {control_type} - {control_name} - {status}")

            # Cihaz kontrolü ise IR kontrolcüsünü kullan
            if control_type == "device" and control_name in ["tv", "ac"]:
                actuator_manager.ir_controller.control_device(control_name, "power", status)

                # Cihaz durumlarını AWS IoT'ye raporla
                if iot_client:
                    device_statuses = actuator_manager.ir_controller.get_device_status()
                    iot_client.publish_device_status(device_statuses)

            # Işık kontrolü ise (gelecekte eklenebilir)
            elif control_type == "light":
                # Sadece LED'leri kontrol et, IR cihaz kontrolünü kullanma
                led_name = control_name.upper() if control_name == "main" else control_name
                actuator_manager.ir_controller.set_led_status(led_name, status)
                logger.info(f"Işık kontrolü: {control_name} - {'açık' if status else 'kapalı'}")

                # Işık durumlarını AWS IoT'ye raporla
                if iot_client:
                    device_statuses = {}
                    device_statuses[control_name] = status
                    iot_client.publish_device_status(device_statuses)

        # Eylem komutları
        if "actions" in message:
            actuator_manager.process_actions(message["actions"])

        # Kullanıcı tercihleri yanıtı
        if "userPreference" in message:
            preference_manager.update_preferences(message["userPreference"])

        # QR kod güvenlik anahtarı yanıtı
        if topic.endswith('/secret/response') and "secretKey" in message:
            if qr_generator:
                qr_generator.handle_secret_response(message)

        # Sensör geçmişi yanıtı
        if topic.endswith('/sensors/history/response') and "payload" in message:
            logger.info("Sensör geçmişi alındı")
            if isinstance(message["payload"], list) and iot_client:
                iot_client.sensor_history = message["payload"]

        # Olay geçmişi yanıtı
        if topic.endswith('/events/history/response') and "payload" in message:
            logger.info("Olay geçmişi alındı")
            if isinstance(message["payload"], list) and iot_client:
                iot_client.event_history = message["payload"]

    except Exception as e:
        logger.error(f"Komut işleme hatası: {e}")


def check_dangerous_conditions(sensor_data, iot_client):
    """Tehlikeli durumları kontrol eder ve gerekirse olay kaydeder"""

    # Gaz seviyesi kontrolü
    if sensor_data["gasLevel"] > 5:
        logger.warning("Yüksek gaz seviyesi tespit edildi!")
        actuator_manager.alert.play_warning_sound()

    # Hareket/mevcudiyet kontrolü
    if sensor_data["distance"] < 50 and not sensor_data["occupied"]:
        iot_client.publish_room_event("SECURITY_WARNING", "Şüpheli hareket tespit edildi")


def apply_preferences(sensor_data, preferences, actuator_manager):
    """Kullanıcı tercihlerini uygular"""

    # Climate controller'a preference'ları aktar
    actuator_manager.climate.update_preferences(preferences.user_preferences)

    # Sıcaklık kontrolü
    if preferences.user_preferences.get("autoClimate", True):
        current_temp = sensor_data["temperature"]
        actuator_manager.climate.adjust_for_temperature(current_temp)

    # Nem kontrolü - artık gerçek fonksiyon çağrısı
    if preferences.user_preferences.get("autoClimate", True):
        current_humidity = sensor_data["humidity"]
        actuator_manager.climate.adjust_for_humidity(current_humidity)

def sensor_callback(data):
    """Sensör verilerini işler"""
    global iot_client, preference_manager, actuator_manager

    # Sensör verilerini yazdır
    print("\n" + "=" * 50)
    print(f"Sıcaklık: {data['temperature']:.1f}°C, Nem: {data['humidity']:.1f}%")
    print(f"Basınç: {data['pressure']:.2f} hPa")  # Basınç verisi eklendi
    print(f"Mevcudiyet: {'Dolu' if data['occupied'] else 'Boş'}, Mesafe: {data['distance']:.1f} cm")
    print(f"Gaz Seviyesi: {data['gasLevel']}/10, Kart: {'Takılı' if data['cardInserted'] else 'Takılı Değil'}")
    print("=" * 50)

    # Verileri buluta gönder
    iot_client.publish_sensor_data(data)

    # Tehlikeli durumları kontrol et
    check_dangerous_conditions(data, iot_client)

    # Kullanıcı tercihlerini güncelle ve uygula
    #preferences = preference_manager.fetch_preferences()
    apply_preferences(data, preference_manager, actuator_manager)


def cleanup_resources():
    """Kaynakları temizler"""
    global running, logger, iot_client, qr_generator

    logger.info("Kaynaklar temizleniyor...")
    running = False

    # AWS IoT bağlantısını kapat
    if iot_client:
        iot_client.disconnect()

    # QR kod üreteci penceresi varsa kapat
    if qr_generator and qr_generator.root:
        qr_generator.root.destroy()

    # GPIO kaynakları temizleme (RPi.GPIO bir Python modülü)
    try:
        import RPi.GPIO as GPIO
        GPIO.cleanup()
        logger.info("GPIO kaynakları temizlendi")
    except:
        pass

    logger.info("Tüm kaynaklar temizlendi")


def show_qr_code():
    """QR kod üretecini gösterir"""
    global qr_generator
    if qr_generator:
        qr_generator.show()


def create_control_ui():
    """Ana kontrol arayüzünü oluşturur"""
    global qr_generator

    # Basit kontrol arayüzü
    root = tk.Tk()
    root.title("Akıllı Oda Kontrol")
    root.geometry("300x200")
    root.configure(bg="#f8f9fa")

    # Ana çerçeve
    frame = tk.Frame(root, bg="#f8f9fa", padx=20, pady=20)
    frame.pack(fill=tk.BOTH, expand=True)

    # Başlık
    title = tk.Label(
        frame,
        text="Akıllı Oda Kontrol",
        font=("Segoe UI", 16, "bold"),
        fg="#4361ee",
        bg="#f8f9fa"
    )
    title.pack(pady=(0, 20))

    # QR Kod butonu
    qr_button = tk.Button(
        frame,
        text="QR Kod Oluştur",
        font=("Segoe UI", 12),
        bg="#4361ee",
        fg="white",
        activebackground="#3a56d4",
        activeforeground="white",
        relief="flat",
        padx=10,
        pady=8,
        command=show_qr_code
    )
    qr_button.pack(fill=tk.X, pady=10)

    # Çıkış butonu
    exit_button = tk.Button(
        frame,
        text="Programı Sonlandır",
        font=("Segoe UI", 12),
        bg="#e63946",
        fg="white",
        activebackground="#c62f39",
        activeforeground="white",
        relief="flat",
        padx=10,
        pady=8,
        command=lambda: (root.destroy(), cleanup_resources(), sys.exit(0))
    )
    exit_button.pack(fill=tk.X, pady=10)

    return root


def main():
    global running, logger, iot_client, preference_manager, actuator_manager, qr_generator

    try:
        # Komut satırı argümanlarını al
        args = parse_args()

        # Logger'ı yapılandır
        log_level = logging.DEBUG if args.verbose else logging.INFO
        logger = setup_logger(level=log_level)
        #aws_logger = setup_aws_iot_logger()

        # Konfigürasyon yükle
        config = Config()

        # Simülasyon modunu ayarla
        if args.mock_sensors:
            config.has_hardware = False

        # Sertifika dosyalarını kontrol et
        if not config.check_certificates():
            print(f"HATA: Sertifika dosyaları bulunamadı. Lütfen certs/ klasörünü kontrol edin.")
            return 1

        # IoT istemcisi oluştur ve bağlan
        iot_client = IoTClient(config)
        if not iot_client.connect():
            logger.error("AWS IoT bağlantısı kurulamadı. Çıkılıyor.")
            return 1

        # Komut işleyiciyi ayarla ve gerekli konulara abone ol
        iot_client.set_command_handler(command_handler)
        iot_client.subscribe_to_commands()

        # Kullanıcı tercihleri yöneticisi
        preference_manager = PreferenceManager(iot_client)

        # Sensör yöneticisi
        sensor_manager = SensorManager(config)
        if not sensor_manager.setup_sensors():
            logger.error("Sensör yapılandırması başarısız oldu. Çıkılıyor.")
            cleanup_resources()
            return 1

        # Çıktı cihazları yöneticisi
        actuator_manager = ActuatorManager(config)
        if not actuator_manager.setup():
            logger.error("Çıktı cihazları yapılandırması başarısız oldu. Çıkılıyor.")
            cleanup_resources()
            return 1

        actuator_manager.set_iot_client(iot_client, preference_manager)

        #Cooldown süresi
        time.sleep(5)

        # QR kod üreteci
        qr_generator = QRCodeGenerator(config, iot_client)

        # Sensör izlemeyi başlat (10 saniyelik aralıklarla)
        #monitor_thread = sensor_manager.start_monitoring(sensor_callback, interval=10)

        # İlk kullanıcı tercihlerini al
        #preference_manager.fetch_preferences(force=True)

        # Başlangıçta QR kod göster seçeneği aktifse
        if args.show_qrcode:
            qr_generator.show()

        # Kontrol arayüzünü oluştur ve başlat
        root = create_control_ui()
        root.mainloop()

        return 0

    except KeyboardInterrupt:
        logger.info("Kullanıcı tarafından sonlandırıldı.")
    except Exception as e:
        logger.error(f"Beklenmeyen hata: {e}", exc_info=True)
        return 1
    finally:
        cleanup_resources()
        return 0


if __name__ == "__main__":
    sys.exit(main())
