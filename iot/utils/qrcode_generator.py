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
    """Modern QR Code Generator - Designed to be used within the main application"""

    def __init__(self, config, iot_client):
        """
        Initializes the QR Code generator

        Args:
            config: System configuration
            iot_client: Client for IoT connection
        """
        self.logger = logging.getLogger("SmartRoom.QRGenerator")
        self.config = config
        self.iot_client = iot_client

        # QR Code configuration
        self.qr_config = {
            "roomId": config["roomId"],
            "secret_key": None,  # To be received via MQTT
            "qr_expiry_seconds": 10800,  # 3 hours validity
            "qr_refresh_seconds": 240,  # 4 minutes refresh
        }

        # QR code information
        self.current_qr = None
        self.current_data = None
        self.current_expiry = None

        # UI components
        self.root = None
        self.qr_image = None
        self.time_label = None
        self.status_label = None
        self.debug_text = None
        self.debug_frame = None

        # State variables
        self.is_secret_requested = False
        self.is_secret_received = False
        self.is_debug_visible = False

    def request_secret_key(self):
        """Sends request via MQTT to request secret key"""
        if not self.iot_client.mqtt_connection:
            self.update_status("No MQTT connection!", "error")
            return False

        try:
            self.update_status("Requesting security key...", "connecting")
            self.is_secret_requested = True

            # Requesting secret key via MQTT
            request_id = str(uuid.uuid4())
            request_topic = f"room/{self.config['roomId']}/secret/request"
            request_payload = json.dumps({
                "requestId": request_id,
                "roomId": self.config['roomId'],
                "clientId": f"{self.config['clientId']}_qr_generator"
            })

            # Send request
            self.iot_client.mqtt_connection.publish(
                topic=request_topic,
                payload=request_payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.info(f"Secret key requested, request ID: {request_id}")
            return True

        except Exception as e:
            self.logger.error(f"Secret key request error: {e}")
            self.update_status(f"Secret key request error: {str(e)}", "error")
            return False

    def handle_secret_response(self, message):
        """Processes secret key response"""
        try:
            if "secretKey" in message:
                self.qr_config["secret_key"] = message["secretKey"]
                self.is_secret_received = True
                self.update_status("Security key received", "success")
                self.update_qr_code()
            else:
                self.update_status("Security key not found!", "error")

        except Exception as e:
            self.logger.error(f"Secret key processing error: {e}")
            self.update_status(f"Secret key processing error: {str(e)}", "error")

    def generate_signature(self, data_string):
        """Generates HMAC-SHA256 signature for data."""
        if not self.qr_config["secret_key"]:
            self.logger.error("Cannot generate signature: Security key not available")
            return None

        key = bytes.fromhex(self.qr_config["secret_key"])
        message = data_string.encode('utf-8')
        signature = hmac.new(key, message, hashlib.sha256).hexdigest()
        return signature

    def generate_qr_data(self):
        """Generates data to be used in QR code."""
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

        # Generate signature
        data_string = f"{data['roomId']}:{data['timestamp']}:{data['expiry']}:{data['sessionId']}"
        signature = self.generate_signature(data_string)

        if not signature:
            return None

        data["signature"] = signature
        self.current_data = data
        self.current_expiry = refresh

        # Debug information
        self.logger.debug(f"New QR code generated: {json.dumps(data)}")
        self.logger.debug(
            f"Validity: {datetime.datetime.fromtimestamp(timestamp)} - {datetime.datetime.fromtimestamp(expiry)}")

        return data

    def generate_qr_code(self):
        """Generates QR code image."""
        if not self.qr_config["secret_key"]:
            return None

        data = self.generate_qr_data()
        if not data:
            return None

        # Convert JSON data to QR code
        json_data = json.dumps(data)
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_H,  # Higher error correction
            box_size=10,
            border=4,
        )
        qr.add_data(json_data)
        qr.make(fit=True)

        img = qr.make_image(fill_color="black", back_color="white")
        self.current_qr = img
        return img

    def is_qr_expired(self):
        """Checks if QR code is expired."""
        if self.current_expiry is None:
            return True

        return time.time() > self.current_expiry

    def create_ui(self):
        """Creates Modern UI interface"""
        self.root = tk.Toplevel()
        self.root.title(f"Smart Room Access - {self.qr_config['roomId']}")
        self.root.geometry("480x720")
        self.root.minsize(400, 600)
        self.root.configure(bg="#ffffff")
        self.root.protocol("WM_DELETE_WINDOW", self._on_close)

        # Theme and color scheme
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

        # Create UI components
        self._create_ui_components()

        # Initial update
        self.update_status("Initializing...", "connecting")

        # Request secret key
        threading.Thread(target=self.request_secret_key, daemon=True).start()

        # Start timer
        self.update_timer()

    def _create_ui_components(self):
        """Creates UI components"""
        # Main frame
        main_frame = tk.Frame(self.root, bg=self.colors["bg"])
        main_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)

        # Header frame
        header_frame = tk.Frame(main_frame, bg=self.colors["bg"])
        header_frame.pack(fill=tk.X, pady=(0, 20))

        title = tk.Label(
            header_frame,
            text="Smart Room Access",
            font=("Segoe UI", 24, "bold"),
            fg=self.colors["primary"],
            bg=self.colors["bg"]
        )
        title.pack(pady=(0, 5))

        subtitle = tk.Label(
            header_frame,
            text=f"Room ID: {self.qr_config['roomId']}",
            font=("Segoe UI", 14),
            fg=self.colors["text_light"],
            bg=self.colors["bg"]
        )
        subtitle.pack()

        # Status frame
        status_frame = tk.Frame(main_frame, bg=self.colors["bg"])
        status_frame.pack(fill=tk.X, pady=(0, 10))

        self.status_label = tk.Label(
            status_frame,
            text="Preparing...",
            font=("Segoe UI", 12),
            fg=self.colors["text_light"],
            bg=self.colors["bg"],
            wraplength=400
        )
        self.status_label.pack()

        # QR Code frame - Card design
        qr_card_frame = tk.Frame(
            main_frame,
            bg=self.colors["bg_light"],
            highlightbackground=self.colors["text_light"],
            highlightthickness=1,
            bd=0
        )
        qr_card_frame.pack(fill=tk.BOTH, expand=True, pady=15)

        # QR code label - business card style
        self.qr_label = tk.Label(
            qr_card_frame,
            bg=self.colors["bg"],
            bd=0
        )
        self.qr_label.pack(fill=tk.BOTH, expand=True, padx=30, pady=30)

        # Timer information
        timer_frame = tk.Frame(main_frame, bg=self.colors["bg"])
        timer_frame.pack(fill=tk.X, pady=10)

        self.time_label = tk.Label(
            timer_frame,
            text="QR Code Timer: -- sec",
            font=("Segoe UI", 12),
            fg=self.colors["primary"],
            bg=self.colors["bg"]
        )
        self.time_label.pack()

        # Bottom frame for buttons
        button_frame = tk.Frame(main_frame, bg=self.colors["bg"])
        button_frame.pack(fill=tk.X, pady=20)

        # Modern flat buttons
        refresh_button = tk.Button(
            button_frame,
            text="Refresh QR Code",
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
            text="Show Details",
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

        # Instruction label
        instruction_label = tk.Label(
            main_frame,
            text="Open mobile app and scan the QR code above",
            font=("Segoe UI", 11),
            fg=self.colors["text_light"],
            bg=self.colors["bg"],
            wraplength=400
        )
        instruction_label.pack(pady=15)

        # Debug info frame (initially hidden)
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
        self.debug_text.insert(tk.END, "QR code content will appear here...")

        # React to window size changes
        self.root.bind("<Configure>", self._on_resize)

    def _on_resize(self, event=None):
        """Updates the QR code when window is resized"""
        if event and event.widget == self.root:
            if hasattr(self, '_resize_timer'):
                self.root.after_cancel(self._resize_timer)

            self._resize_timer = self.root.after(200, self.update_qr_code)

    def _on_close(self):
        """Called when the window is closed"""
        self.logger.info("QR code window closed")
        if self.root:
            self.root.destroy()
            self.root = None

    def update_status(self, message, status_type="info"):
        """Updates the status label"""
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
        """Updates the QR code and places it on UI"""
        if not self.root or not self.qr_label:
            return

        if not self.qr_config["secret_key"]:
            # No secret key, show warning message instead of QR code
            self.qr_label.config(image="")
            self.qr_label.config(
                text="Waiting for security key...\nPlease wait.",
                font=("Segoe UI", 12),
                fg=self.colors["warning"]
            )
            return

        # Generate QR code
        img = self.generate_qr_code()
        if not img:
            self.logger.error("QR code could not be created")
            return

        try:
            # Get current frame size
            width = self.qr_label.winfo_width()
            height = self.qr_label.winfo_height()

            # Initial size might be zero, start with a reasonable value
            if width < 50 or height < 50:
                width = height = 300

            # Resize QR code while maintaining aspect ratio
            size = min(width, height) - 20
            img = img.resize((size, size), Image.LANCZOS)

            # Convert PIL image to Tkinter PhotoImage
            tk_img = ImageTk.PhotoImage(img)

            # Show QR code
            self.qr_label.config(image=tk_img)
            self.qr_label.image = tk_img  # Keep the reference
            self.qr_label.config(text="")  # Clear text

            # Update debug text
            if self.debug_text and self.current_data:
                self.debug_text.delete(1.0, tk.END)
                self.debug_text.insert(tk.END, json.dumps(self.current_data, indent=2))

        except Exception as e:
            self.logger.error(f"QR code update error: {e}")

    def update_timer(self):
        """Updates timer label and checks QR code validity"""
        if not self.root or not self.time_label:
            return

        if self.current_expiry:
            remaining = max(0, int(self.current_expiry - time.time()))
            self.time_label.config(text=f"QR Code Timer: {remaining} seconds")

            # Refresh QR code if expired
            if remaining == 0 or self.is_qr_expired():
                self.update_qr_code()

        # Call itself again every second
        if self.root:
            self.root.after(1000, self.update_timer)

    def force_refresh_qr(self):
        """Forces QR code refresh"""
        if not self.qr_config["secret_key"]:
            self.request_secret_key()
            return

        self.update_qr_code()
        self.update_status("QR code refreshed", "success")

    def toggle_debug_info(self):
        """Shows/hides debug information"""
        if self.is_debug_visible:
            self.debug_frame.pack_forget()
            self.is_debug_visible = False
        else:
            self.debug_frame.pack(fill=tk.X, expand=True)
            self.is_debug_visible = True

    def show(self):
        """Shows the QR code generator"""
        if self.root:
            self.root.lift()
            self.root.focus_force()
        else:
            self.create_ui()