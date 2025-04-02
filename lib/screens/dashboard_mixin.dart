part of 'dashboard_screen.dart';

mixin _DashboardMixin on ConsumerState<DashboardScreen> {

  late final SensorService _sensorService;
  final RoomAutomationService _roomService = RoomAutomationService();

  final ValueNotifier<bool> _isLoggingOut = ValueNotifier<bool>(false);
  bool _isLoading = true;
  late String _roomId;
  late String _currentSessionId;
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
  late StreamSubscription _sessionTerminationSub;

  @override
  void initState() {

    _initialize();

    // Widget'tan gelen roomId ve sessionId değerlerini al
    _roomId = widget.roomId;
    _currentSessionId = widget.sessionId;

    // Oturum sonlandırma olaylarını dinle
    _sessionTerminationSub = EventBus().onSessionTerminated.listen((terminatedSessionId) {
      // Eğer sonlandırılan oturum bu cihazınkiyse ana sayfaya yönlendir
      if (_currentSessionId == terminatedSessionId) {
        // NavigationService ile ana sayfaya yönlendir
        ref.read(navigationServiceProvider).navigateToHome();

        // Bildirim göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oturumunuz sonlandırıldı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    super.initState();

  }

  Future<void> _initialize() async {
    try {
      // Sensör servisleri başlat
      _sensorService = SensorService();
      _sensorService.initialize();

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
      //_loadRoomHistory();

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

  // QrSession tablosundan aktif oturum bilgilerini getir
  Future<List<QrSession?>> _getActiveUsersForRoom(String roomId) async {
    try {

      // ModelQueries.list ile QrSession verilerini sorgula
      final request = ModelQueries.list(
        QrSession.classType,
        where: QrSession.ROOMID.eq(roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      safePrint(response.errors);
      safePrint("Ham yanıt: ${response.data!.items.toString()}");

      if (response.data != null) {
        return response.data!.items;
        // return response.data!.items
        //     .whereType<QrSession>()
        //     .where((session) =>
        // session.sessionId != _currentSessionId)
        //     .toList();
      }

      return <QrSession>[];
    } catch (e) {
      safePrint("Aktif kullanıcıları alma hatası: $e");
      rethrow;
    }
  }

  // Kullanıcı oturumunu sonlandır
  Future<void> _terminateUserSession(String sessionId) async {
    try {
      // Önce mevcut oturumu getir
      final getRequest = ModelQueries.get(
        QrSession.classType,
        QrSessionModelIdentifier(sessionId: sessionId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final getResponse = await Amplify.API.query(request: getRequest).response;

      if (getResponse.errors.isNotEmpty) {
        throw Exception("Oturum bilgisi alınamadı: ${getResponse.errors.first.message}");
      }

      if (getResponse.data == null) {
        throw Exception("Oturum bulunamadı");
      }

      // Oturumu sil
      final deleteRequest = ModelMutations.delete(getResponse.data!,
          authorizationMode: APIAuthorizationType.apiKey);

      final deleteResponse = await Amplify.API.mutate(request: deleteRequest).response;

      if (deleteResponse.errors.isNotEmpty) {
        throw Exception(deleteResponse.errors.first.message);
      }

      // Başarılı olursa bildirim göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı oturumu sonlandırıldı'),
          backgroundColor: Colors.green,
        ),
      );

      // Oturum sonlandırma olayını yayınla
      EventBus().terminateSession(sessionId);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oturum sonlandırılamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  @override
  void dispose() {
    _sessionTerminationSub.cancel();
    _temperatureSub.cancel();
    _humiditySub.cancel();
    _gasSub.cancel();
    _distanceSub.cancel();
    _cardSub.cancel();
    _eventSub.cancel();
    _isLoggingOut.dispose();
    super.dispose();
  }



}