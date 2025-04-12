from datetime import datetime, timezone
import json
import logging
import time

import uuid
from awscrt import io, mqtt
from awsiot import mqtt_connection_builder


class IoTClient:
    """AWS IoT bağlantı ve iletişim yönetimi"""

    def __init__(self, config):
        """
        IoT Client'ı başlatır

        Args:
            config: Sistem konfigürasyonu
        """
        self.sensor_history = []
        self.event_history = []
        self.max_history_size = 99  # Maksimum saklanacak veri sayısı
        self.logger = logging.getLogger("SmartRoom.IoTClient")
        self.config = config
        self.mqtt_connection = None
        self.command_handler = None

    def connect(self):
        """AWS IoT'ye bağlanır"""
        try:
            # Sertifikaların varlığını kontrol et
            if not self.config.check_certificates():
                self.logger.error("Sertifika dosyaları bulunamadı")
                return False

            # AWS IoT SDK v2 ile bağlantı kurma
            event_loop_group = io.EventLoopGroup(1)
            host_resolver = io.DefaultHostResolver(event_loop_group)
            client_bootstrap = io.ClientBootstrap(event_loop_group, host_resolver)

            self.mqtt_connection = mqtt_connection_builder.mtls_from_path(
                endpoint=self.config["endpoint"],
                cert_filepath=self.config["certificatePath"],
                pri_key_filepath=self.config["privateKeyPath"],
                client_bootstrap=client_bootstrap,
                ca_filepath=self.config["rootCAPath"],
                client_id=self.config["clientId"],
                clean_session=False,
                keep_alive_secs=30
            )

            connect_future = self.mqtt_connection.connect()
            connect_future.result()  # Bağlantı tamamlanana kadar bekle

            self.logger.info("AWS IoT'ye bağlantı başarılı")

            # Bağlantı başarılıysa geçmiş verileri iste
            self.request_sensor_history()
            self.request_event_history()

            # Oda kontrol durumlarını iste
            self.request_room_control(control_type="device", control_name="tv")
            self.request_room_control(control_type="device", control_name="ac")
            self.request_room_control(control_type="light", control_name="main")
            self.request_room_control(control_type="light", control_name="desk")
            self.request_room_control(control_type="light", control_name="bed")
            self.request_room_control(control_type="light", control_name="bathroom")

            # Kullanıcı tercihlerini iste
            self.request_user_preferences()

            return True

        except Exception as e:
            self.logger.error(f"AWS IoT bağlantı hatası: {str(e)}")
            return False

    def disconnect(self):
        """AWS IoT bağlantısını kapatır"""
        if self.mqtt_connection:
            try:
                disconnect_future = self.mqtt_connection.disconnect()
                disconnect_future.result()
                self.logger.info("AWS IoT bağlantısı kapatıldı")
            except Exception as e:
                self.logger.error(f"Bağlantı kesme hatası: {e}")

    def set_command_handler(self, handler):
        """
        Komut işleyicisini ayarlar

        Args:
            handler: AWS IoT'den gelen komutları işleyen fonksiyon
        """
        self.command_handler = handler

    def subscribe_to_commands(self):
        """Komut ve tercih konularına abone olur"""
        if not self.mqtt_connection:
            self.logger.error("MQTT bağlantısı bulunamadı. Önce connect() çağrılmalıdır.")
            return False

        try:
            # Komut almak için abone ol
            command_topic = f"room/{self.config['thingName']}/commands"
            self.mqtt_connection.subscribe(
                topic=command_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Komut konusuna abone olundu: {command_topic}")

            # Kullanıcı tercihleri yanıtlarını almak için abone ol
            preference_topic = f"room/{self.config['thingName']}/preference/response"
            self.mqtt_connection.subscribe(
                topic=preference_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Tercih yanıt konusuna abone olundu: {preference_topic}")

            # QR kod secret yanıtları
            qr_topic = f"room/{self.config['roomId']}/secret/response"
            self.mqtt_connection.subscribe(
                topic=qr_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Secret yanıt konusuna abone olundu: {qr_topic}")

            # Sensör geçmişi yanıtları için abone ol
            sensor_history_topic = f"room/{self.config['thingName']}/sensors/history/response"
            self.mqtt_connection.subscribe(
                topic=sensor_history_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Sensör geçmişi yanıt konusuna abone olundu: {sensor_history_topic}")

            # Olay geçmişi yanıtları için abone ol
            event_history_topic = f"room/{self.config['thingName']}/events/history/response"
            self.mqtt_connection.subscribe(
                topic=event_history_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Olay geçmişi yanıt konusuna abone olundu: {event_history_topic}")

            # RoomControl güncellemeleri için abone ol
            room_control_topic = f"room/{self.config['roomId']}/control/response"
            self.mqtt_connection.subscribe(
                topic=room_control_topic,
                qos=mqtt.QoS.AT_LEAST_ONCE,
                callback=self._process_incoming_message
            )
            self.logger.info(f"Oda kontrol konusuna abone olundu: {room_control_topic}")

            return True

        except Exception as e:
            self.logger.error(f"Konulara abone olma hatası: {e}")
            return False

    def _process_incoming_message(self, topic, payload, **kwargs):
        """AWS'den gelen mesajları işler ve uygun işleyiciye yönlendirir"""
        try:
            message = json.loads(payload.decode())
            self.logger.info(f"Konu: {topic}, Mesaj alındı: {message}")

            # Kullanıcının tanımladığı işleyici varsa çağır
            if self.command_handler:
                self.command_handler(topic, message)

        except Exception as e:
            self.logger.error(f"Mesaj işleme hatası: {e}")

    def publish_sensor_data(self, data):
        """Sensör verilerini AWS IoT'ye gönderir"""
        if not self.mqtt_connection:
            self.logger.error("MQTT bağlantısı bulunamadı. Önce connect() çağrılmalıdır.")
            return False

        try:

            self.sensor_history.append(data.copy())

            # Geçmiş boyutunu kontrol et
            if len(self.sensor_history) > self.max_history_size:
                self.sensor_history.pop(0)  # En eski veriyi çıkar

            # Veriyi JSON olarak serileştir
            #payload = json.dumps(data)
            timestamp = int(time.time())
            iso_time = datetime.fromtimestamp(timestamp, timezone.utc).isoformat()

            payload =  json.dumps({
                "roomId": self.config['thingName'],
                "payload": self.sensor_history,
                "updatedAt": iso_time,
                "createdAt": iso_time
            })

            # AWS IoT'ye veri gönder
            topic = f"room/{self.config['thingName']}/sensors"
            self.mqtt_connection.publish(
                topic=topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.debug(f"Sensör verisi gönderildi: {payload}")
            return True

        except Exception as e:
            self.logger.error(f"Veri gönderme hatası: {e}")
            return False

    def publish_room_event(self, event_type, description):
        """Oda olaylarını AWS IoT'ye gönderir"""
        if not self.mqtt_connection:
            self.logger.error("MQTT bağlantısı bulunamadı. Önce connect() çağrılmalıdır.")
            return False

        try:

            self.logger.info(f"Olay türü: {event_type}, Açıklama: {description}")

            event_data = {
                "eventType": event_type,  # ALERT, SECURITY_WARNING, INFO vb.
                "timestamp": int(time.time()),
                "description": description,
                "resolved": False
            }

            self.event_history.append(event_data.copy())

            # Geçmiş boyutunu kontrol et
            if len(self.event_history) > self.max_history_size:
                self.event_history.pop(0)  # En eski veriyi çıkar

            # Veriyi JSON olarak serileştir
            timestamp = int(time.time())
            iso_time = datetime.fromtimestamp(timestamp, timezone.utc).isoformat()
            payload =  json.dumps({
                "roomId": self.config['thingName'],
                "payload": self.event_history,
                "updatedAt": iso_time,
                "createdAt": iso_time
            })

            # Olay verisini yayınla
            event_topic = f"room/{self.config['thingName']}/events"
            self.mqtt_connection.publish(
                topic=event_topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.info(f"Oda olayı kaydedildi: {event_type} - {description}")
            return True

        except Exception as e:
            self.logger.error(f"Olay kaydetme hatası: {e}")
            return False

    def publish_device_status(self, device_statuses):
        """Cihaz durumlarını AWS IoT'ye gönderir"""
        if not self.mqtt_connection:
            self.logger.error("MQTT bağlantısı bulunamadı. Önce connect() çağrılmalıdır.")
            return False

        try:
            # Veriyi JSON olarak serileştir
            payload = json.dumps({
                "roomId": self.config['thingName'],
                "devices": device_statuses,
                "timestamp": int(time.time()),
                "updatedAt": int(time.time()),
                "createdAt": int(time.time())
            })

            # AWS IoT'ye veri gönder
            topic = f"room/{self.config['thingName']}/devices"
            self.mqtt_connection.publish(
                topic=topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.debug(f"Cihaz durumları gönderildi: {payload}")
            return True

        except Exception as e:
            self.logger.error(f"Cihaz durumu gönderme hatası: {e}")
            return False

    def request_user_preferences(self):
        """Kullanıcı tercihlerini API Gateway üzerinden ister"""
        if not self.mqtt_connection:
            self.logger.error("MQTT bağlantısı bulunamadı. Önce connect() çağrılmalıdır.")
            return False

        try:
            # MQTT üzerinden tercih sorgusu yayınla
            request_id = str(uuid.uuid4())
            request_topic = f"room/{self.config['thingName']}/preference/request"
            request_payload = json.dumps({
                "requestId": request_id,
                "roomId": self.config['thingName']
            })

            # İstek gönder
            self.mqtt_connection.publish(
                topic=request_topic,
                payload=request_payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.info(f"Kullanıcı tercihleri istendi, istek ID: {request_id}")
            return True

        except Exception as e:
            self.logger.error(f"Kullanıcı tercihleri isteme hatası: {e}")
            return False

    def request_sensor_history(self):
        """Sensör geçmişini MQTT üzerinden ister"""
        try:
            # Sensör geçmişi isteği için JSON hazırla
            request_id = str(uuid.uuid4())
            payload = json.dumps({
                "requestId": request_id,
                "roomId": self.config['thingName'],
                "limit": self.max_history_size
            })

            # İstek konusu
            request_topic = f"room/{self.config['thingName']}/sensors/history/request"

            # İsteği yayınla
            self.mqtt_connection.publish(
                topic=request_topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )
            self.logger.info(f"Sensör geçmişi istendi, istek ID: {request_id}")
            return True

        except Exception as e:
            self.logger.error(f"Sensör geçmişi isteme hatası: {e}")
            return False

    def request_event_history(self):
        """Olay geçmişini MQTT üzerinden ister"""
        try:
            # Olay geçmişi isteği için JSON hazırla
            request_id = str(uuid.uuid4())
            payload = json.dumps({
                "requestId": request_id,
                "roomId": self.config['thingName'],
                "limit": self.max_history_size
            })

            # İstek konusu
            request_topic = f"room/{self.config['thingName']}/events/history/request"

            # İsteği yayınla
            self.mqtt_connection.publish(
                topic=request_topic,
                payload=payload,
                qos=mqtt.QoS.AT_LEAST_ONCE
            )
            self.logger.info(f"Olay geçmişi istendi, istek ID: {request_id}")
            return True

        except Exception as e:
            self.logger.error(f"Olay geçmişi isteme hatası: {e}")
            return False

    def request_room_control(self, control_type=None, control_name=None):
        """
        AWS Amplify'dan RoomControl durumlarını ister

        Args:
            control_type: İsteğe bağlı, belirli bir kontrol tipi (light, device) için filtreleme
            control_name: İsteğe bağlı, belirli bir cihaz adı (tv, ac) için filtreleme
        """
        if not self.mqtt_connection:
            self.logger.error("MQTT bağlantısı bulunamadı. Önce connect() çağrılmalıdır.")
            return False

        try:
            # MQTT üzerinden RoomControl sorgusu yayınla
            request_id = str(uuid.uuid4())
            request_topic = f"room/{self.config['roomId']}/control/request"

            # İstek payload'ını hazırla
            request_payload = {
                "requestId": request_id,
                "roomId": self.config['roomId']
            }

            # Opsiyonel filtreler ekle
            if control_type:
                request_payload["controlType"] = control_type

            if control_name:
                request_payload["controlName"] = control_name

            # İstek gönder
            self.mqtt_connection.publish(
                topic=request_topic,
                payload=json.dumps(request_payload),
                qos=mqtt.QoS.AT_LEAST_ONCE
            )

            self.logger.info(f"RoomControl durumları istendi: {request_payload}")
            return True

        except Exception as e:
            self.logger.error(f"RoomControl durumları isteme hatası: {e}")
            return False

    def test_network_connection(self):
        """AWS IoT endpoint'ine basit bir ağ bağlantı testi yapar"""
        import socket

        try:
            # Basit ping testi
            host = self.config["endpoint"]
            self.logger.info(f"AWS IoT endpoint'e bağlantı deneniyor: {host}")

            # Normal soket bağlantısı
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)

            self.logger.info("1. Soket oluşturuldu, bağlantı kuruluyor...")
            sock.connect((host, 8883))
            self.logger.info("2. TCP bağlantısı kuruldu")

            # SSL/TLS bağlantısı olmadan kapatıyoruz
            sock.close()
            self.logger.info("3. Temel soket bağlantısı başarılı")

            return True
        except socket.timeout:
            self.logger.error("Bağlantı zaman aşımına uğradı. Firewall veya internet bağlantınızı kontrol edin.")
            return False
        except socket.gaierror as e:
            self.logger.error(f"DNS çözümlemesi hatası. Endpoint adresini kontrol edin: {e}")
            return False
        except Exception as e:
            self.logger.error(f"Ağ bağlantı hatası: {str(e)}")
            return False