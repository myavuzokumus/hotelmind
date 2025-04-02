#!/usr/bin/env python3

import qrcode
import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import json
import time
import uuid
import hmac
import hashlib
import datetime
import boto3

def get_secret():
    try:
        # Systems Manager (SSM) istemcisi oluştur
        ssm_client = boto3.client('ssm')

        # Parameter Store'dan değeri al
        response = ssm_client.get_parameter(
            Name='/qr-generator/secret-key',  # Parametre yolu
            WithDecryption=True               # Şifreli parametre ise çöz
        )

        return response['Parameter']['Value']
    except Exception as e:
        print(f"Anahtar alınırken hata: {e}")
        return None

# Yapılandırma
CONFIG = {
    "room_id": "room_001",
    "secret_key": get_secret(),
    "qr_expiry_seconds": 300,  # 5 dakika geçerlilik - hata ayıklama için uzattık
    "qr_refresh_seconds": 240,  # 4 dakika yenileme - hata ayıklama için uzattık
    "display_width": 400,
    "display_height": 500
}


class QRCodeGenerator:
    def __init__(self):
        self.current_qr = None
        self.current_data = None
        self.current_expiry = None

    def generate_signature(self, data_string):
        """Veri için HMAC-SHA256 imzası oluşturur."""
        key = bytes.fromhex(CONFIG["secret_key"])
        print(f"İmza oluşturulurken kullanılan anahtar: {CONFIG['secret_key']}")
        message = data_string.encode('utf-8')
        signature = hmac.new(key, message, hashlib.sha256).hexdigest()
        return signature

    def generate_qr_data(self):
        """QR kodunda kullanılacak veriyi oluşturur."""
        timestamp = int(time.time())
        expiry = timestamp + CONFIG["qr_expiry_seconds"]
        session_id = str(uuid.uuid4())

        data = {
            "roomId": CONFIG["room_id"],
            "timestamp": timestamp,
            "expiry": expiry,
            "sessionId": session_id
        }

        # İmza oluştur
        data_string = f"{data['roomId']}:{data['timestamp']}:{data['expiry']}:{data['sessionId']}"
        signature = self.generate_signature(data_string)

        data["signature"] = signature
        self.current_data = data
        self.current_expiry = expiry

        # Debug bilgisi yazdır
        print(f"Yeni QR kodu oluşturuldu: {json.dumps(data)}")
        print(f"Geçerlilik: {datetime.datetime.fromtimestamp(timestamp)} - {datetime.datetime.fromtimestamp(expiry)}")
        print(f"İmzalamada kullanılan metin: {data_string}")

        return data

    def generate_qr_code(self):
        """QR kod resmi oluşturur."""
        if CONFIG["secret_key"] is None:
            print("QR kodu oluşturulamıyor: Güvenlik anahtarı mevcut değil")
            return None

        data = self.generate_qr_data()

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


class QRCodeDisplay(tk.Tk):
    def __init__(self, generator):
        super().__init__()

        self.generator = generator
        self.title(f"Oda Erişimi - {CONFIG['room_id']}")
        self.geometry(f"{CONFIG['display_width']}x{CONFIG['display_height']}")
        self.configure(bg="#f5f5f5")  # Açık gri arka plan

        # Özel stil oluştur
        self.style = ttk.Style()
        self.style.theme_use('clam')  # Daha modern tema

        # Düğme stilleri
        self.style.configure('TButton', font=('Segoe UI', 10), borderwidth=1)
        self.style.configure('Accent.TButton', background='#007bff', foreground='white')
        self.style.map('Accent.TButton', background=[('active', '#0069d9')])

        # Etiket stilleri
        self.style.configure('TLabel', background='#f5f5f5', font=('Segoe UI', 10))
        self.style.configure('Header.TLabel', font=('Segoe UI', 18, 'bold'))
        self.style.configure('SubHeader.TLabel', font=('Segoe UI', 12))
        self.style.configure('Error.TLabel', foreground='#dc3545', font=('Segoe UI', 11, 'bold'))
        self.style.configure('Info.TLabel', foreground='#17a2b8', font=('Segoe UI', 11))

        # Çerçeve stilleri
        self.style.configure('TFrame', background='#f5f5f5')
        self.style.configure('Card.TFrame', background='white', relief='raised')

        # Ana çerçeve
        self.main_frame = ttk.Frame(self, style='TFrame')
        self.main_frame.pack(padx=20, pady=20, fill=tk.BOTH, expand=True)

        # Başlık ve bilgi bölümü
        self.header_frame = ttk.Frame(self.main_frame, style='Card.TFrame')
        self.header_frame.pack(padx=0, pady=(0, 15), fill=tk.X)

        self.title_label = ttk.Label(
            self.header_frame,
            text="Akıllı Oda Erişimi",
            style='Header.TLabel'
        )
        self.title_label.pack(pady=(15, 5), padx=15)

        self.room_label = ttk.Label(
            self.header_frame,
            text=f"Oda ID: {CONFIG['room_id']}",
            style='SubHeader.TLabel'
        )
        self.room_label.pack(pady=(0, 15), padx=15)

        # Hata mesajı çerçevesi
        self.error_frame = ttk.Frame(self.main_frame, style='TFrame')
        self.error_frame.pack(fill=tk.X, pady=10)

        self.error_label = ttk.Label(
            self.error_frame,
            text="Güvenlik anahtarı alınamadı!",
            style='Error.TLabel'
        )

        self.retry_button = ttk.Button(
            self.error_frame,
            text="Yeniden Dene",
            command=self.retry_get_secret,
            style='Accent.TButton'
        )

        # QR kod alanı (kart gibi)
        self.qr_frame = ttk.Frame(self.main_frame, style='Card.TFrame')
        self.qr_frame.pack(padx=0, pady=10, fill=tk.BOTH, expand=True)

        # QR kodunu ortalamak için bir iç çerçeve kullan
        self.qr_center_frame = ttk.Frame(self.qr_frame, style='Card.TFrame')
        self.qr_center_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)

        self.qr_label = ttk.Label(self.qr_center_frame, background='white')
        self.qr_label.pack(anchor="center", expand=True)

        # Kalan süre bilgisi
        self.time_frame = ttk.Frame(self.qr_frame, style='TFrame')
        self.time_frame.pack(fill=tk.X, pady=0)

        self.time_label = ttk.Label(
            self.time_frame,
            text=f"QR Kod Süresi: {CONFIG['qr_expiry_seconds']} sn",
            style='Info.TLabel'
        )
        self.time_label.pack(pady=(0, 15))

        # Pencere boyutlandırma olayını dinle
        self.bind("<Configure>", self.on_resize)

        # Butonlar bölümü
        self.button_frame = ttk.Frame(self.main_frame, style='TFrame')
        self.button_frame.pack(fill=tk.X, pady=15)

        # Yenile butonu
        self.refresh_button = ttk.Button(
            self.button_frame,
            text="QR Kodu Yenile",
            command=self.force_refresh_qr,
            style='Accent.TButton'
        )
        self.refresh_button.pack(side=tk.LEFT, padx=(0, 5), expand=True, fill=tk.X)

        # Debug butonu
        self.debug_button = ttk.Button(
            self.button_frame,
            text="QR İçeriğini Göster/Gizle",
            command=self.toggle_debug_info
        )
        self.debug_button.pack(side=tk.RIGHT, padx=(5, 0), expand=True, fill=tk.X)

        # Talimat
        self.instruction_label = ttk.Label(
            self.main_frame,
            text="Uygulamayı açın ve QR kodu taratın",
            style='Info.TLabel'
        )
        self.instruction_label.pack(pady=10)

        # Debug bilgisi bölümü
        self.debug_frame = ttk.Frame(self.main_frame, style='Card.TFrame')
        self.debug_frame.pack(fill=tk.X, pady=10, padx=0)

        self.debug_text = tk.Text(self.debug_frame, height=5, width=40,
                                  font=("Consolas", 9), bg="#f8f9fa", relief="flat",
                                  borderwidth=0, highlightthickness=0)
        self.debug_text.pack(fill=tk.X, expand=True, padx=10, pady=10)
        self.debug_text.insert(tk.END, "QR içeriği burada görünecek...")
        self.debug_frame.pack_forget()  # Başlangıçta gizli

        # İlk QR kodu oluştur
        self.update_qr_code()

        # Periyodik güncelleme için
        self.update_timer()

    def on_resize(self, event):
        """Pencere boyutu değiştiğinde QR kodunu yeniden boyutlandır."""
        # Sadece ana pencere boyutlandırıldığında tepki ver
        if event.widget == self:
            # Yeniden boyutlandırma sırasında çok fazla güncellemeden kaçınmak için
            # Önceki zamanlayıcıyı iptal et (varsa)
            if hasattr(self, '_resize_timer'):
                self.after_cancel(self._resize_timer)

            # Yeni bir zamanlayıcı başlat
            self._resize_timer = self.after(200, self.update_qr_code)

    def retry_get_secret(self):
        """AWS'den güvenlik anahtarını tekrar almayı dener."""
        CONFIG["secret_key"] = get_secret()
        if CONFIG["secret_key"] is not None:
            # Anahtar başarıyla alındı, hata mesajını gizle ve QR kodu güncelle
            self.error_label.pack_forget()
            self.retry_button.pack_forget()
            self.update_qr_code()
        else:
            # Hata devam ediyor, mesajın görünür olduğundan emin ol
            self.error_label.pack(pady=5)
            self.retry_button.pack(pady=5)

    def update_qr_code(self):
        """QR kodu yeniler ve çerçeveye sığdırır."""
        if CONFIG["secret_key"] is None:
            # Güvenlik anahtarı yok, hata mesajını göster
            self.error_label.pack(pady=5)
            self.retry_button.pack(pady=5)
            self.qr_label.config(image="")
            return

        # Anahtar var, QR kodu oluştur
        img = self.generator.generate_qr_code()
        if img is None:
            return

        # QR kod görüntüsünü çerçeveye sığacak şekilde yeniden boyutlandır
        # Mevcut çerçeve boyutunu al
        qr_frame_width = self.qr_center_frame.winfo_width()
        qr_frame_height = self.qr_center_frame.winfo_height()

        # Çerçeve boyutu henüz belli değilse varsayılan değerler kullan
        if qr_frame_width <= 10 or qr_frame_width >= 500:
            qr_frame_width = CONFIG["display_width"]

        # QR kodunu yeniden boyutlandır (en-boy oranını koru, küçük olanı seç)
        max_size = min(qr_frame_width, qr_frame_height)
        print(max_size)
        img = img.resize((max_size, max_size), Image.LANCZOS)

        # PIL resmini Tkinter'ın anlayacağı formata dönüştür
        tk_img = ImageTk.PhotoImage(img)

        # QR kodu güncelle
        self.qr_label.config(image=tk_img)
        self.qr_label.image = tk_img  # Referansı tut, GC tarafından silinmemesi için

        # Debug metnini güncelle
        self.debug_text.delete(1.0, tk.END)
        self.debug_text.insert(tk.END, json.dumps(self.generator.current_data, indent=2))

        print(f"QR kodu güncellendi: {json.dumps(self.generator.current_data)}")

    def update_timer(self):
        """Zamanlayıcıyı ve QR kodun kalan süresini günceller."""
        if self.generator.current_expiry:
            remaining = max(0, int(self.generator.current_expiry - time.time()))
            self.time_label.config(text=f"QR Kod Süresi: {remaining} sn")

            # Süre dolmak üzereyse veya dolmuşsa yeni QR kod oluştur
            if remaining <= CONFIG["qr_expiry_seconds"] - CONFIG["qr_refresh_seconds"]:
                self.update_qr_code()

        # Kendini tekrar çağır
        self.after(1000, self.update_timer)

    def force_refresh_qr(self):
        """Kullanıcı isteği ile QR kodu hemen yeniler."""
        self.update_qr_code()

    def toggle_debug_info(self):
        """Debug bilgisini göster/gizle."""
        if self.debug_frame.winfo_ismapped():
            self.debug_frame.pack_forget()
        else:
            self.debug_frame.pack(fill=tk.X, pady=5, padx=5)


def main():
    generator = QRCodeGenerator()
    app = QRCodeDisplay(generator)
    app.mainloop()


if __name__ == "__main__":
    main()