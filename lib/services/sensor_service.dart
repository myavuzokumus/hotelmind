import 'dart:async';
import 'dart:math';

import 'package:amplify_flutter/amplify_flutter.dart';

import '../models/SensorData.dart';

class SensorService {
  // Simülasyon için değişkenler
  bool _isMocked = true;
  Timer? _mockDataTimer;

  // Sensör değerleri
  double _temperature = 22.0;
  double _humidity = 50.0;
  int _gasLevel = 0;
  double _distance = 300.0;
  bool _isCardInserted = false;

  // Stream controllers
  final _temperatureController = StreamController<double>.broadcast();
  final _humidityController = StreamController<double>.broadcast();
  final _gasLevelController = StreamController<int>.broadcast();
  final _distanceController = StreamController<double>.broadcast();
  final _cardStatusController = StreamController<bool>.broadcast();

  // Streams
  Stream<double> get temperatureStream => _temperatureController.stream;
  Stream<double> get humidityStream => _humidityController.stream;
  Stream<int> get gasLevelStream => _gasLevelController.stream;
  Stream<double> get distanceStream => _distanceController.stream;
  Stream<bool> get cardStatusStream => _cardStatusController.stream;

  // Getters
  double get temperature => _temperature;
  double get humidity => _humidity;
  int get gasLevel => _gasLevel;
  double get distance => _distance;
  bool get isCardInserted => _isCardInserted;

  // Singleton pattern
  static final SensorService _instance = SensorService._internal();

  factory SensorService() {
    return _instance;
  }

  SensorService._internal();

  // Initialize sensor service
  void initialize() {
    if (_isMocked) {
      _startMockDataGeneration();
    } else {
      _connectToRealSensors();
    }
  }

  // Mock data generation for testing
  void _startMockDataGeneration() {
    _mockDataTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Simulate temperature changes
      _temperature += (Random().nextDouble() * 0.5) - 0.25;
      if (_temperature < 18) _temperature = 18;
      if (_temperature > 30) _temperature = 30;

      // Simulate humidity changes
      _humidity += (Random().nextDouble() * 2) - 1;
      if (_humidity < 30) _humidity = 30;
      if (_humidity > 70) _humidity = 70;

      // Simulate gas level changes
      if (Random().nextInt(100) > 95) {
        _gasLevel = Random().nextInt(10);
      }

      // Simulate distance changes
      if (Random().nextInt(100) > 80) {
        _distance = 100 + Random().nextDouble() * 400;
      }

      // Simulate card status changes
      if (Random().nextInt(100) > 95) {
        _isCardInserted = !_isCardInserted;
      }

      // Update streams
      _temperatureController.add(_temperature);
      _humidityController.add(_humidity);
      _gasLevelController.add(_gasLevel);
      _distanceController.add(_distance);
      _cardStatusController.add(_isCardInserted);

      // Send data to AWS
      _sendDataToAWS();
    });
  }

  // Connect to real sensors (this would integrate with actual IoT devices)
  void _connectToRealSensors() {
    // This would be replaced with actual IoT device code
    print("Connecting to real sensors...");
  }

  // Send data to AWS IoT and DynamoDB
  Future<void> _sendDataToAWS() async {
    try {
      // Amplify v2 DataStore
      final sensorData = SensorData(
          deviceId: 'room_001',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          temperature: _temperature,
          humidity: _humidity,
          gasLevel: _gasLevel,
          distance: _distance,
          occupied: _isPersonDetected(),
          cardInserted: _isCardInserted
      );

      // Save to DataStore which syncs with AppSync/DynamoDB
      await Amplify.DataStore.save(sensorData);

      // Optionally send real-time data via REST API
      final restOperation = Amplify.API.post(
          '/sensor-data',
          body: HttpPayload.json({
            'deviceId': 'room_001',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'temperature': _temperature,
            'humidity': _humidity,
            'gasLevel': _gasLevel,
            'distance': _distance,
            'occupied': _isPersonDetected(),
            'cardInserted': _isCardInserted
          })
      );

      await restOperation.response;

    } catch (e) {
      print("Error sending data to AWS: $e");
    }
  }

  // Determine if a person is detected based on distance sensor
  bool _isPersonDetected() {
    // If distance is less than 150cm, assume a person is detected
    return _distance < 150;
  }

  // Clean up
  void dispose() {
    _mockDataTimer?.cancel();
    _temperatureController.close();
    _humidityController.close();
    _gasLevelController.close();
    _distanceController.close();
    _cardStatusController.close();
  }
}