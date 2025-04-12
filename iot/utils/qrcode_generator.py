import datetime
import hashlib
import hmac
import json
import logging
import threading
import time
import tkinter as tk

import qrcode
import uuid
from PIL import Image, ImageTk
from awscrt import mqtt


class QRCodeGenerator:
    """Modern QR Kod Üreteci - Ana uygulama içinde kullanılmak üzere tasarlandı"""

    def __init__(self, config, iot_client):
        """
        QR Kod üretecini başlatır

        Args:
            config: Sistem konfigürasyonu
            iot_client: IoT bağlantısı için istemci
        """
        self.logger = logging.getLogger("SmartRoom.QRGenerator")
        self.config = config
        self.iot_client = iot_client

        # QR Kod yapılandırması
        self.qr_config = {
            "roomId": config["roomId"],
            "secret_key": None,  # MQTT ile alınacak
            "qr_expiry_seconds": 10800,  # 3 saat geçerlilik
            "qr_refresh_seconds": 240,  # 4 dakika yenileme
        }

        # QR kod bilgileri
        self.current_qr = None
        self.current_data = None
        self.current_expiry = None

        # UI bileşenleri
        self.root = None
        self.qr_image = None
        self.time_label = None
        self.status_label = None
        self.debug_text = None
        self.debug_frame = None

        # Durum değişkenleri
        self.is_secret_requested = False
        self.is_secret_received = False
        self.is_debug_visible = False

    def request_secret_key(self):
        """Secret key istemek için MQTT üzerinden istek gönderir"""
        if not self.iot_client.mqtt_connection:
            self.update_status("MQTT bağlantısı yok!", "error")
            return False

        try:
            self.update_status("Güvenlik anahtarı isteniyor...", "connecting")
            self.is_secret_requested = True

            # MQTT üzerinden secret key isteme
            request_id = str(uuid.uuid4())
            request_topic = f"room/{self.config['roomId']}/secret/request"
            request_payload = json.dumps({
                "requestId": request_id,
                "roomId": self.config['roomId'],
                "clientId": f"{self.config['clientId']}_qr_generator"
            })

            # İstek gönder
            self.iot_client.mqtt_connection.publish(
                topic=request_topic,
                payload=request_payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.info(f"Secret key istendi, istek ID: {request_id}")
            return True

        except Exception as e:
            self.logger.error(f"Secret key isteme hatası: {e}")
            self.update_status(f"Secret key isteme hatası: {str(e)}", "error")
            return False

    def handle_secret_response(self, message):
        """Secret key yanıtını işler"""
        try:
            if "secretKey" in message:
                self.qr_config["secret_key"] = message["secretKey"]
                self.is_secret_received = True
                self.update_status("Güvenlik anahtarı alındı", "success")
                self.update_qr_code()
            else:
                self.update_status("Güvenlik anahtarı bulunamadı!", "error")

        except Exception as e:
            self.logger.error(f"Secret key işleme hatası: {e}")
            self.update_status(f"Secret key işleme hatası: {str(e)}", "error")

    def generate_signature(self, data_string):
        """Veri için HMAC-SHA256 imzası oluşturur."""
        if not self.qr_config["secret_key"]:
            self.logger.error("İmza oluşturulamıyor: Güvenlik anahtarı mevcut değil")
            return None

        key = bytes.fromhex(self.qr_config["secret_key"])
        message = data_string.encode('utf-8')
        signature = hmac.new(key, message, hashlib.sha256).hexdigest()
        return signature

    def generate_qr_data(self):
        """QR kodunda kullanılacak veriyi oluşturur."""
        if not self.qr_config["secret_key"]:
            return None

        timestamp = int(time.time())
        expiry = timestamp + self.qr_config["qr_expiry_seconds"]
        refresh = timestamp + self.qr_config["qr_refresh_seconds"]
        session_id = str(uuid.uuid4())

        data = {
            "roomId": self.qr_config["roomId"],
            "timestamp": timestamp,
            "expiry": expiry,
            "sessionId": session_id
        }

        # İmza oluştur
        data_string = f"{data['roomId']}:{data['timestamp']}:{data['expiry']}:{data['sessionId']}"
        signature = self.generate_signature(data_string)

        if not signature:
            return None

        data["signature"] = signature
        self.current_data = data
        self.current_expiry = refresh

        # Debug bilgisi
        self.logger.debug(f"Yeni QR kodu oluşturuldu: {json.dumps(data)}")
        self.logger.debug(
            f"Geçerlilik: {datetime.datetime.fromtimestamp(timestamp)} - {datetime.datetime.fromtimestamp(expiry)}")

        return data

    def generate_qr_code(self):
        """QR kod resmi oluşturur."""
        if not self.qr_config["secret_key"]:
            return None

        data = self.generate_qr_data()
        if not data:
            return None

        # JSON verisini QR koda dönüştür
        json_data = json.dumps(data)
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_H,  # Daha yüksek hata düzeltme
            box_size=10,
            border=4,
        )
        qr.add_data(json_data)
        qr.make(fit=True)

        img = qr.make_image(fill_color="black", back_color="white")
        self.current_qr = img
        return img

    def is_qr_expired(self):
        """QR kodun süresi dolmuş mu kontrol eder."""
        if self.current_expiry is None:
            return True

        return time.time() > self.current_expiry

    def create_ui(self):
        """Modern UI arayüzünü oluşturur"""
        self.root = tk.Toplevel()
        self.root.title(f"Akıllı Oda Erişimi - {self.qr_config['roomId']}")
        self.root.geometry("480x720")
        self.root.minsize(400, 600)
        self.root.configure(bg="#ffffff")
        self.root.protocol("WM_DELETE_WINDOW", self._on_close)

        # Tema ve renk şeması
        self.colors = {
            "primary": "#4361ee",
            "primary_dark": "#3a56d4",
            "success": "#4cc9f0",
            "warning": "#fca311",
            "error": "#e63946",
            "text": "#212529",
            "text_light": "#6c757d",
            "bg_light": "#f8f9fa",
            "bg": "#ffffff",
            "accent": "#7209b7",
        }

        # UI bileşenlerini oluştur
        self._create_ui_components()

        # İlk güncelleme
        self.update_status("Başlatılıyor...", "connecting")

        # Secret key iste
        threading.Thread(target=self.request_secret_key, daemon=True).start()

        # Timer başlat
        self.update_timer()

    def _create_ui_components(self):
        """UI bileşenlerini oluşturur"""
        # Ana çerçeve
        main_frame = tk.Frame(self.root, bg=self.colors["bg"])
        main_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)

        # Başlık çerçevesi
        header_frame = tk.Frame(main_frame, bg=self.colors["bg"])
        header_frame.pack(fill=tk.X, pady=(0, 20))

        title = tk.Label(
            header_frame,
            text="Akıllı Oda Erişimi",
            font=("Segoe UI", 24, "bold"),
            fg=self.colors["primary"],
            bg=self.colors["bg"]
        )
        title.pack(pady=(0, 5))

        subtitle = tk.Label(
            header_frame,
            text=f"Oda Kimliği: {self.qr_config['roomId']}",
            font=("Segoe UI", 14),
            fg=self.colors["text_light"],
            bg=self.colors["bg"]
        )
        subtitle.pack()

        # Durum çerçevesi
        status_frame = tk.Frame(main_frame, bg=self.colors["bg"])
        status_frame.pack(fill=tk.X, pady=(0, 10))

        self.status_label = tk.Label(
            status_frame,
            text="Hazırlanıyor...",
            font=("Segoe UI", 12),
            fg=self.colors["text_light"],
            bg=self.colors["bg"],
            wraplength=400
        )
        self.status_label.pack()

        # QR Kod çerçevesi - Kartlı tasarım
        qr_card_frame = tk.Frame(
            main_frame,
            bg=self.colors["bg_light"],
            highlightbackground=self.colors["text_light"],
            highlightthickness=1,
            bd=0
        )
        qr_card_frame.pack(fill=tk.BOTH, expand=True, pady=15)

        # QR kod etiketi - kartvizit stili şeklinde
        self.qr_label = tk.Label(
            qr_card_frame,
            bg=self.colors["bg"],
            bd=0
        )
        self.qr_label.pack(fill=tk.BOTH, expand=True, padx=30, pady=30)

        # Süre bilgisi
        timer_frame = tk.Frame(main_frame, bg=self.colors["bg"])
        timer_frame.pack(fill=tk.X, pady=10)

        self.time_label = tk.Label(
            timer_frame,
            text="QR Kod Süresi: -- sn",
            font=("Segoe UI", 12),
            fg=self.colors["primary"],
            bg=self.colors["bg"]
        )
        self.time_label.pack()

        # Butonlar için alt çerçeve
        button_frame = tk.Frame(main_frame, bg=self.colors["bg"])
        button_frame.pack(fill=tk.X, pady=20)

        # Modern düz butonlar
        refresh_button = tk.Button(
            button_frame,
            text="QR Kodu Yenile",
            font=("Segoe UI", 12, "bold"),
            fg="#ffffff",
            bg=self.colors["primary"],
            activebackground=self.colors["primary_dark"],
            activeforeground="#ffffff",
            bd=0,
            relief="flat",
            padx=15,
            pady=8,
            command=self.force_refresh_qr
        )
        refresh_button.pack(side=tk.LEFT, expand=True, fill=tk.X, padx=(0, 5))

        debug_button = tk.Button(
            button_frame,
            text="Detayları Göster",
            font=("Segoe UI", 12),
            fg="#ffffff",
            bg=self.colors["accent"],
            activebackground="#5a0891",
            activeforeground="#ffffff",
            bd=0,
            relief="flat",
            padx=15,
            pady=8,
            command=self.toggle_debug_info
        )
        debug_button.pack(side=tk.RIGHT, expand=True, fill=tk.X, padx=(5, 0))

        # Talimat etiketi
        instruction_label = tk.Label(
            main_frame,
            text="Mobil uygulamayı açın ve yukarıdaki QR kodu taratın",
            font=("Segoe UI", 11),
            fg=self.colors["text_light"],
            bg=self.colors["bg"],
            wraplength=400
        )
        instruction_label.pack(pady=15)

        # Debug bilgisi çerçevesi (başlangıçta gizli)
        self.debug_frame = tk.Frame(main_frame, bg=self.colors["bg"])

        self.debug_text = tk.Text(
            self.debug_frame,
            height=8,
            wrap=tk.WORD,
            font=("Consolas", 10),
            bg=self.colors["bg_light"],
            fg=self.colors["text"],
            bd=1,
            relief="flat"
        )
        self.debug_text.pack(fill=tk.BOTH, expand=True, padx=0, pady=10)
        self.debug_text.insert(tk.END, "QR kod içeriği burada görünecek...")

        # Pencere boyut değişimine tepki ver
        self.root.bind("<Configure>", self._on_resize)

    def _on_resize(self, event=None):
        """Pencere yeniden boyutlandırıldığında QR kodu günceller"""
        if event and event.widget == self.root:
            if hasattr(self, '_resize_timer'):
                self.root.after_cancel(self._resize_timer)

            self._resize_timer = self.root.after(200, self.update_qr_code)

    def _on_close(self):
        """Pencere kapatıldığında çağrılır"""
        self.logger.info("QR kod penceresi kapatıldı")
        if self.root:
            self.root.destroy()
            self.root = None

    def update_status(self, message, status_type="info"):
        """Durum etiketini günceller"""
        if not hasattr(self, 'status_label') or not self.status_label:
            return

        colors = {
            "info": self.colors["text_light"],
            "success": self.colors["success"],
            "error": self.colors["error"],
            "warning": self.colors["warning"],
            "connecting": self.colors["primary"]
        }

        if self.root and self.status_label:
            self.status_label.config(
                text=message,
                fg=colors.get(status_type, self.colors["text_light"])
            )

    def update_qr_code(self):
        """QR kodunu günceller ve UI'a yerleştirir"""
        if not self.root or not self.qr_label:
            return

        if not self.qr_config["secret_key"]:
            # Güvenlik anahtarı yok, QR kodu yerine uyarı mesajı göster
            self.qr_label.config(image="")
            self.qr_label.config(
                text="Güvenlik anahtarı bekleniyor...\nLütfen bekleyin.",
                font=("Segoe UI", 12),
                fg=self.colors["warning"]
            )
            return

        # QR kodu oluştur
        img = self.generate_qr_code()
        if not img:
            self.logger.error("QR kodu oluşturulamadı")
            return

        try:
            # Mevcut çerçeve boyutunu al
            width = self.qr_label.winfo_width()
            height = self.qr_label.winfo_height()

            # Başlangıçta boyut sıfır olabilir, makul bir değerle başla
            if width < 50 or height < 50:
                width = height = 300

            # QR kodunu en-boy oranını koruyarak yeniden boyutlandır
            size = min(width, height) - 20
            img = img.resize((size, size), Image.LANCZOS)

            # PIL görüntüsünü Tkinter PhotoImage'a dönüştür
            tk_img = ImageTk.PhotoImage(img)

            # QR kodu göster
            self.qr_label.config(image=tk_img)
            self.qr_label.image = tk_img  # Referansı koru
            self.qr_label.config(text="")  # Metni temizle

            # Debug metni güncelle
            if self.debug_text and self.current_data:
                self.debug_text.delete(1.0, tk.END)
                self.debug_text.insert(tk.END, json.dumps(self.current_data, indent=2))

        except Exception as e:
            self.logger.error(f"QR kod güncelleme hatası: {e}")

    def update_timer(self):
        """Zamanlayıcı etiketini günceller ve QR kodun geçerliliğini kontrol eder"""
        if not self.root or not self.time_label:
            return

        if self.current_expiry:
            remaining = max(0, int(self.current_expiry - time.time()))
            self.time_label.config(text=f"QR Kod Süresi: {remaining} saniye")

            # Süre dolmuşsa QR kodu yenile
            if remaining == 0 or self.is_qr_expired():
                self.update_qr_code()

        # Her saniye kendini yeniden çağır
        if self.root:
            self.root.after(1000, self.update_timer)

    def force_refresh_qr(self):
        """QR kodunu zorla yeniler"""
        if not self.qr_config["secret_key"]:
            self.request_secret_key()
            return

        self.update_qr_code()
        self.update_status("QR kodu yenilendi", "success")

    def toggle_debug_info(self):
        """Debug bilgilerini göster/gizle"""
        if self.is_debug_visible:
            self.debug_frame.pack_forget()
            self.is_debug_visible = False
        else:
            self.debug_frame.pack(fill=tk.X, expand=True)
            self.is_debug_visible = True

    def show(self):
        """QR kod üretecini gösterir"""
        if self.root:
            self.root.lift()
            self.root.focus_force()
        else:
            self.create_ui()