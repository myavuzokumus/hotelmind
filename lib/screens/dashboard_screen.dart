import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:async';
import '../services/sensor_service.dart';
import '../services/room_automation_service.dart';
import '../widgets/room_status_card.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/event_list.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SensorService _sensorService = SensorService();
  final RoomAutomationService _roomService = RoomAutomationService();

  bool _isLoading = true;
  String _roomId = 'room_001';
  String _userName = 'Misafir';

  // Sensör verileri listeleri
  final List<double> _temperatureHistory = [];
  final List<double> _humidityHistory = [];
  final List<int> _gasHistory = [];
  final List<Map<String, dynamic>> _eventHistory = [];

  // Mevcut değerler
  double _currentTemperature = 22.0;
  double _currentHumidity = 50.0;
  int _currentGasLevel = 0;
  bool _isRoomOccupied = false;
  bool _isCardInserted = false;
  String _roomMode = "Normal";

  // YENİ: Aydınlatma ve cihaz durumları
  bool _mainLightOn = false;
  bool _deskLightOn = false;
  bool _bedLightOn = false;
  bool _bathroomLightOn = false;
  bool _tvOn = false;
  bool _acOn = false;

  // Abonelikler
  late StreamSubscription _temperatureSub;
  late StreamSubscription _humiditySub;
  late StreamSubscription _gasSub;
  late StreamSubscription _distanceSub;
  late StreamSubscription _cardSub;
  late StreamSubscription _eventSub;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Sensör servisleri başlat
      _sensorService.initialize();

      // Kullanıcı verisini al
      final authSession = await Amplify.Auth.fetchAuthSession();
      if (authSession.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        setState(() {
          _userName = user.username;
        });
      }

      // Sensör verilerine abone ol
      _temperatureSub = _sensorService.temperatureStream.listen((value) {
        setState(() {
          _currentTemperature = value;
          _temperatureHistory.add(value);
          if (_temperatureHistory.length > 50) _temperatureHistory.removeAt(0);
        });
      });

      _humiditySub = _sensorService.humidityStream.listen((value) {
        setState(() {
          _currentHumidity = value;
          _humidityHistory.add(value);
          if (_humidityHistory.length > 50) _humidityHistory.removeAt(0);
        });
      });

      _gasSub = _sensorService.gasLevelStream.listen((value) {
        setState(() {
          _currentGasLevel = value;
          _gasHistory.add(value);
          if (_gasHistory.length > 50) _gasHistory.removeAt(0);
        });
      });

      _distanceSub = _sensorService.distanceStream.listen((value) {
        setState(() {
          _isRoomOccupied = value < 150; // 150cm altında kişi var kabul et
        });
      });

      _cardSub = _sensorService.cardStatusStream.listen((value) {
        setState(() {
          _isCardInserted = value;
        });
      });

      // Oda olaylarına abone ol
      _eventSub = _roomService.eventStream.listen((event) {
        setState(() {
          _eventHistory.add(event);
          if (_eventHistory.length > 100) _eventHistory.removeAt(0);

          // Oda modunu güncelle
          if (event['type'] == 'MODE_CHANGE') {
            _roomMode = event['mode'];
          }
        });
      });

      // Oda geçmişini yükle
      _loadRoomHistory();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Initialization error: $e");
    }
  }

  Future<void> _loadRoomHistory() async {
    try {
      // Veritabanından son sensör verilerini al
      final sensorData = await _roomService.getSensorHistory(_roomId);
      // Veritabanından son olayları al
      final eventData = await _roomService.getEventHistory(_roomId);

      setState(() {
        if (sensorData != null) {
          _temperatureHistory.clear();
          _humidityHistory.clear();
          _gasHistory.clear();

          for (var data in sensorData) {
            _temperatureHistory.add(data['temperature']);
            _humidityHistory.add(data['humidity']);
            _gasHistory.add(data['gasLevel']);
          }
        }

        if (eventData != null) {
          _eventHistory.clear();
          _eventHistory.addAll(eventData);
        }
      });
    } catch (e) {
      print("Error loading room history: $e");
    }
  }

  // YENİ: Aydınlatma kontrol metodları
  Future<void> _toggleLight(String type, bool value) async {
    try {
      setState(() {
        switch (type) {
          case 'main':
            _mainLightOn = value;
            break;
          case 'desk':
            _deskLightOn = value;
            break;
          case 'bed':
            _bedLightOn = value;
            break;
          case 'bathroom':
            _bathroomLightOn = value;
            break;
        }
      });

      // Servise bilgiyi gönder
      // await _roomService.setRoomControl(_roomId, {
      //   'type': 'light',
      //   'lightType': type,
      //   'status': value
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getLightName(type)} ${value ? 'açıldı' : 'kapatıldı'}'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Aydınlatma kontrolü hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem sırasında bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // YENİ: Cihaz kontrolleri
  Future<void> _toggleDevice(String type, bool value) async {
    try {
      setState(() {
        switch (type) {
          case 'tv':
            _tvOn = value;
            break;
          case 'ac':
            _acOn = value;
            break;
        }
      });

      // Servise bilgiyi gönder
      // await _roomService.setRoomControl(_roomId, {
      //   'type': 'device',
      //   'deviceType': type,
      //   'status': value
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getDeviceName(type)} ${value ? 'açıldı' : 'kapatıldı'}'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Cihaz kontrolü hatası: $e');
    }
  }

  // YENİ: Temizlik talebi
  Future<void> _showCleaningRequestDialog() async {
    String note = '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Temizlik Talebi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Temizlik ekibine iletilecek talebiniz var mı?'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ekstra havlu, ekstra çarşaf, vb.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                note = value;
              },
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                //await _roomService.sendCleaningRequest(_roomId, note);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Temizlik talebiniz iletildi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Talep gönderilirken hata oluştu'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Talep Gönder'),
          ),
        ],
      ),
    );
  }

  // YENİ: Resepsiyona mesaj gönder
  Future<void> _showReceptionMessageDialog() async {
    String message = '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resepsiyona Mesaj'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mesajınızı yazın:'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Mesajınızı buraya yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              onChanged: (value) {
                message = value;
              },
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (message.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lütfen bir mesaj yazın'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              try {
                //await _roomService.sendMessageToReception(_roomId, message);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mesajınız resepsiyona iletildi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mesaj gönderilirken hata oluştu'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Gönder'),
          ),
        ],
      ),
    );
  }

  // YENİ: Yardımcı metotlar
  String _getLightName(String type) {
    switch (type) {
      case 'main': return 'Ana aydınlatma';
      case 'desk': return 'Masa ışığı';
      case 'bed': return 'Yatak ışığı';
      case 'bathroom': return 'Banyo ışığı';
      default: return 'Işık';
    }
  }

  String _getDeviceName(String type) {
    switch (type) {
      case 'tv': return 'Televizyon';
      case 'ac': return 'Klima';
      default: return 'Cihaz';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Oda Yönetim Paneli')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Oda Yönetim Paneli'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRoomHistory,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRoomHistory,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Karşılama mesajı
                Text(
                  'Hoş geldiniz, $_userName',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Oda Durumu: ${_isRoomOccupied ? "Dolu" : "Boş"} | Mod: $_roomMode',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),

                // Canlı sensör verileri
                Row(
                  children: [
                    Expanded(
                      child: RoomStatusCard(
                        title: 'Sıcaklık',
                        value: '${_currentTemperature.toStringAsFixed(1)}°C',
                        icon: Icons.thermostat,
                        color: _getSensorColor(_currentTemperature, 18, 25),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: RoomStatusCard(
                        title: 'Nem',
                        value: '${_currentHumidity.toStringAsFixed(1)}%',
                        icon: Icons.water_drop,
                        color: _getSensorColor(_currentHumidity, 40, 60),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RoomStatusCard(
                        title: 'Gaz Seviyesi',
                        value: '$_currentGasLevel/10',
                        icon: Icons.cloud,
                        color: _getGasColor(_currentGasLevel),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: RoomStatusCard(
                        title: 'Kart Durumu',
                        value: _isCardInserted ? 'Takılı' : 'Takılı Değil',
                        icon: Icons.credit_card,
                        color: _isCardInserted ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // YENİ: Oda Kontrol Bölümü
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oda Kontrolleri',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),

                        // Aydınlatma Kontrolleri
                        Text('Aydınlatma', style: TextStyle(fontWeight: FontWeight.bold)),
                        SwitchListTile(
                          title: Text('Ana Aydınlatma'),
                          value: _mainLightOn,
                          secondary: Icon(Icons.lightbulb, color: _mainLightOn ? Colors.yellow : Colors.grey),
                          onChanged: (value) => _toggleLight('main', value),
                        ),
                        SwitchListTile(
                          title: Text('Masa Işığı'),
                          value: _deskLightOn,
                          secondary: Icon(Icons.desk, color: _deskLightOn ? Colors.yellow : Colors.grey),
                          onChanged: (value) => _toggleLight('desk', value),
                        ),
                        SwitchListTile(
                          title: Text('Yatak Işığı'),
                          value: _bedLightOn,
                          secondary: Icon(Icons.bed, color: _bedLightOn ? Colors.yellow : Colors.grey),
                          onChanged: (value) => _toggleLight('bed', value),
                        ),
                        SwitchListTile(
                          title: Text('Banyo Işığı'),
                          value: _bathroomLightOn,
                          secondary: Icon(Icons.bathroom, color: _bathroomLightOn ? Colors.yellow : Colors.grey),
                          onChanged: (value) => _toggleLight('bathroom', value),
                        ),

                        Divider(height: 32),

                        // Cihaz Kontrolleri
                        Text('Cihazlar', style: TextStyle(fontWeight: FontWeight.bold)),
                        SwitchListTile(
                          title: Text('Televizyon'),
                          value: _tvOn,
                          secondary: Icon(Icons.tv, color: _tvOn ? Colors.blue : Colors.grey),
                          onChanged: (value) => _toggleDevice('tv', value),
                        ),
                        SwitchListTile(
                          title: Text('Klima'),
                          value: _acOn,
                          secondary: Icon(Icons.ac_unit, color: _acOn ? Colors.blue : Colors.grey),
                          onChanged: (value) => _toggleDevice('ac', value),
                        ),

                        Divider(height: 32),

                        // Hizmet Butonları
                        Text('Hizmetler', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showCleaningRequestDialog,
                              icon: Icon(Icons.cleaning_services),
                              label: Text('Temizlik\nTalep Et'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showReceptionMessageDialog,
                              icon: Icon(Icons.message),
                              label: Text('Resepsiyona\nMesaj Gönder'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Sensör grafikleri
                Text(
                  'Sıcaklık Grafiği',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  child: SensorChart(
                    data: _temperatureHistory,
                    color: Colors.orange,
                    label: 'Sıcaklık (°C)',
                  ),
                ),
                SizedBox(height: 24),

                Text(
                  'Nem Grafiği',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  child: SensorChart(
                    data: _humidityHistory,
                    color: Colors.blue,
                    label: 'Nem (%)',
                  ),
                ),
                SizedBox(height: 24),

                // Son olaylar
                Text(
                  'Son Olaylar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                EventList(events: _eventHistory),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQRCodeDialog();
        },
        icon: Icon(Icons.qr_code),
        label: Text('Yetkilendir'),
      ),
    );
  }

  // Sensör rengi belirle
  Color _getSensorColor(double value, double min, double max) {
    if (value < min) return Colors.blue;
    if (value > max) return Colors.red;
    return Colors.green;
  }

  // Gaz seviyesi rengi belirle
  Color _getGasColor(int value) {
    if (value <= 2) return Colors.green;
    if (value <= 5) return Colors.orange;
    return Colors.red;
  }

  // QR Kod diyalogu göster
  void _showQRCodeDialog() {
    // QR kod gösterme diyalogu - gerçek uygulamada QR kod oluşturma eklenecek
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yetkilendirme QR Kodu'),
        content: Container(
          height: 300,
          width: 300,
          child: Center(
            child: Image.network(
              'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(_roomId)}',
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _temperatureSub.cancel();
    _humiditySub.cancel();
    _gasSub.cancel();
    _distanceSub.cancel();
    _cardSub.cancel();
    _eventSub.cancel();
    super.dispose();
  }
}