part of 'dashboard_screen.dart';

mixin _DashboardMixin on ConsumerState<DashboardScreen> {

  final RoomAutomationService _roomService = RoomAutomationService();

  final ValueNotifier<bool> _isLoggingOut = ValueNotifier<bool>(false);
  bool _isLoading = true;
  bool _aiAssistantEnabled = false;

  late final String _roomId;
  late final String _currentSessionId;

  late final SensorService _sensorService;
  final String _userName = 'Guest';

  // Sensor data lists
  final List<double> _temperatureHistory = [];
  final List<double> _humidityHistory = [];
  final List<int> _gasHistory = [];
  final List<Map<String, dynamic>> _eventHistory = [];

  // Current values
  double _currentTemperature = 22.0;
  double _currentHumidity = 50.0;
  int _currentGasLevel = 0;
  bool _isRoomOccupied = false;
  bool _isCardInserted = false;
  String _roomMode = "Normal";

  // NEW: Lighting and device statuses
  bool _mainLightOn = false;
  bool _deskLightOn = false;
  bool _bedLightOn = false;
  bool _bathroomLightOn = false;
  bool _tvOn = false;
  bool _acOn = false;

  // Subscriptions
  late StreamSubscription _temperatureSub;
  late StreamSubscription _humiditySub;
  late StreamSubscription _gasSub;
  late StreamSubscription _distanceSub;
  late StreamSubscription _cardSub;
  late StreamSubscription _eventSub;
  late StreamSubscription _sessionTerminationSub;

  @override
  void initState() {

    // Get roomId and sessionId from widget
    _roomId = widget.roomId;
    _currentSessionId = widget.sessionId;

    _initialize();

    // Listen for session termination events
    _sessionTerminationSub = EventBus().onSessionTerminated.listen((terminatedSessionId) {
      // If the terminated session belongs to this device, redirect to home page
      if (_currentSessionId == terminatedSessionId) {
        // Redirect to home page with NavigationService
        ref.read(navigationServiceProvider).navigateToHome();

        // Show notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your session has been terminated'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    super.initState();

  }

  Future<void> _initialize() async {
    try {
      // Initialize room service
      _roomService.initialize(roomId: _roomId);

      // Initialize sensor services
      _sensorService = SensorService();
      _sensorService.initialize(roomId: _roomId);

      // Subscribe to sensor data
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
          _isRoomOccupied = value < 150; // Assume occupied if distance is under 150cm
        });
      });

      _cardSub = _sensorService.cardStatusStream.listen((value) {
        setState(() {
          _isCardInserted = value;
        });
      });

      // Subscribe to room events
      _eventSub = _roomService.eventStream.listen((event) {
        setState(() {
          _eventHistory.add(event);
          if (_eventHistory.length > 100) _eventHistory.removeAt(0);

          // Update room mode
          if (event['type'] == 'MODE_CHANGE') {
            _roomMode = event['mode'];
          }
        });
      });

      // Load room history
      _loadRoomHistory();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log("Initialization error: $e");
    }
  }

  Future<void> _loadRoomHistory() async {
    try {
      // Get latest sensor data from database
      final sensorData = await _roomService.getSensorHistory(_roomId);
      log("Sensor data: $sensorData");
      // Get latest events from database
      final eventData = await _roomService.getEventHistory(_roomId);
      log("Event data: $eventData");

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
      log("Error loading room history: $e");
    }
  }

  // NEW: Lighting control methods
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

      // Send info to service
      await _roomService.setRoomControl(_roomId, {
        'type': 'light',
        'lightType': type,
        'status': value
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getLightName(type)} ${value ? 'turned on' : 'turned off'}'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      log('Lighting control error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during the operation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // NEW: Device controls
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

      // Send info to service
      await _roomService.setRoomControl(_roomId, {
        'type': 'device',
        'deviceType': type,
        'status': value
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getDeviceName(type)} ${value ? 'turned on' : 'turned off'}'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      log('Device control error: $e');
    }
  }

  // add to dashboard_mixin.dart
  void _toggleAI(bool value) {
    setState(() {
      _aiAssistantEnabled = value;
    });

    // If activated, start animation, otherwise stop it
    if (_aiAssistantEnabled) {
      _aiButtonAnimController.repeat();
    } else {
      _aiButtonAnimController.stop();
    }

    // Publish event via EventBus
    //ref.read(eventBusProvider).publish(
    //  'AI Assistant ${_aiAssistantEnabled ? "activated" : "deactivated"}',
    //);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_aiAssistantEnabled
            ? 'AI Assistant activated'
            : 'AI Assistant deactivated'),
        backgroundColor: _aiAssistantEnabled ? Colors.green : Colors.grey,
      ),
    );
  }

  // NEW: Helper methods
  String _getLightName(String type) {
    switch (type) {
      case 'main': return 'Main lighting';
      case 'desk': return 'Desk light';
      case 'bed': return 'Bed light';
      case 'bathroom': return 'Bathroom light';
      default: return 'Light';
    }
  }

  String _getDeviceName(String type) {
    switch (type) {
      case 'tv': return 'Television';
      case 'ac': return 'AC';
      default: return 'Device';
    }
  }

  // Get active session info from QrSession table
  Future<List<QrSession?>> _getActiveUsersForRoom(String roomId) async {
    try {

      // Query QrSession data with ModelQueries.list
      final request = ModelQueries.list(
        QrSession.classType,
        where: QrSession.ROOMID.eq(roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

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
      log("Error getting active users: $e");
      rethrow;
    }
  }

  // Terminate user session
  Future<void> _terminateUserSession(String sessionId) async {
    try {
      // First get current session
      final getRequest = ModelQueries.get(
        QrSession.classType,
        QrSessionModelIdentifier(sessionId: sessionId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final getResponse = await Amplify.API.query(request: getRequest).response;

      if (getResponse.errors.isNotEmpty) {
        throw Exception("Could not get session info: ${getResponse.errors.first.message}");
      }

      if (getResponse.data == null) {
        throw Exception("Session not found");
      }

      // Delete session
      final deleteRequest = ModelMutations.delete(getResponse.data!,
          authorizationMode: APIAuthorizationType.apiKey);

      final deleteResponse = await Amplify.API.mutate(request: deleteRequest).response;

      if (deleteResponse.errors.isNotEmpty) {
        throw Exception(deleteResponse.errors.first.message);
      }

      // If successful, show notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User session terminated'),
          backgroundColor: Colors.green,
        ),
      );

      // Publish session termination event
      EventBus().terminateSession(sessionId);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not terminate session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Determine sensor color
  Color _getSensorColor(double value, double min, double max) {
    if (value < min) return Colors.blue;
    if (value > max) return Colors.red;
    return Colors.green;
  }

  // Determine gas level color
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
    _sensorService.dispose();
    _aiButtonAnimController.dispose();
    super.dispose();
  }

  // add AnimationController to dashboard_mixin.dart
  late AnimationController _aiButtonAnimController;
  late Animation<Color?> _aiButtonColorAnimation;
  final List<Color> _aiButtonColors = [
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.teal,
    Colors.indigo,
  ];

  // Separate animation controller initialization process
  void initAIAnimation(TickerProvider vsync) {
    _aiButtonAnimController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: vsync, // using vsync from State
    )..repeat();

    _aiButtonColorAnimation = _aiButtonAnimController
        .drive(
        ColorTween(begin: _aiButtonColors.first, end: _aiButtonColors.last)
            .chain(CurveTween(curve: Curves.easeInOut))
    );
  }


}