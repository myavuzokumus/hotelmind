import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:hotelmind/models/SensorData.dart';

import 'debug_log_provider.dart';

class SensorService {

  // Sensor values
  double _temperature = 22.0;
  double _humidity = 50.0;
  int _gasLevel = 3;
  double _distance = 300.0;
  bool _isCardInserted = false;

  String roomId = "room_001";

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

  // Subscription variable
  StreamSubscription<GraphQLResponse<SensorData>>? _sensorSubscription;

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
  void initialize({String? roomId}) {
    if (roomId != null) {
      this.roomId = roomId;
    }
    _connectToSensors();
  }

  void _connectToSensors() {
    log("Connecting to sensors...");

    // Initial data fetch
    _fetchLatestSensorData();

    // Periodically refresh data
    Timer.periodic(Duration(seconds: 10), (_) {
      _fetchLatestSensorData();
    });
  }

  Future<void> _fetchLatestSensorData() async {
    try {
      final request = ModelQueries.get(
        SensorData.classType,
        SensorDataModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null && response.data!.payload!.isNotEmpty) {
        final latestSensor = response.data!.payload!.last;

        // Update data and pass to streams
        _temperature = latestSensor.temperature ?? 22.0;
        _humidity = latestSensor.humidity ?? 50.0;
        _gasLevel = latestSensor.gasLevel ?? 3;
        _distance = latestSensor.distance ?? 300.0;
        _isCardInserted = latestSensor.cardInserted ?? false;

        // Send notification to streams
        _temperatureController.add(_temperature);
        _humidityController.add(_humidity);
        _gasLevelController.add(_gasLevel);
        _distanceController.add(_distance);
        _cardStatusController.add(_isCardInserted);

        log("Sensor data updated: T:$_temperature, H:$_humidity");
      }
    } catch (e) {
      log("Error fetching sensor data: $e");
    }
  }

// // Connect to sensors and listen to real-time updates
//   void _connectToSensors() {
//     log("Connecting to sensors...");
//
//     try {
//       // Create subscription for SensorData model
//       final subscriptionRequest = ModelSubscriptions.onUpdate(
//         SensorData.classType,
//         authorizationMode: APIAuthorizationType.apiKey,
//         where: SensorData.ROOMID.eq("room_001"), // Specify Sensor ID here
//       );
//
//       // Create stream
//       final subscription = Amplify.API.subscribe(
//         subscriptionRequest,
//         onEstablished: () => log("Subscription to sensor data established successfully"),
//       );
//
//       // Subscribe to stream
//       _sensorSubscription = subscription.listen(
//             (event) {
//           final sensorData = event.data;
//           log("Sensor data updated: $sensorData");
//           if (sensorData != null && sensorData.payload!.isNotEmpty) {
//             // Get the last sensor data in the array
//             log("Sensor data received: ${sensorData.payload}");
//
//             final latestSensor = sensorData.payload!.last;
//
//             // Update data and pass to streams
//             _temperature = latestSensor.temperature ?? 22.0;
//             _humidity = latestSensor.humidity ?? 50.0;
//             _gasLevel = latestSensor.gasLevel ?? 3;
//             _distance = latestSensor.distance ?? 300.0;
//             _isCardInserted = latestSensor.cardInserted ?? false;
//
//             // Send notification to streams
//             _temperatureController.add(_temperature);
//             _humidityController.add(_humidity);
//             _gasLevelController.add(_gasLevel);
//             _distanceController.add(_distance);
//             _cardStatusController.add(_isCardInserted);
//
//             log("New sensor data received: T:$_temperature, H:$_humidity, G:$_gasLevel");
//           }
//         },
//         onError: (error) {
//           log("Error in sensor data subscription: $error");
//         },
//       );
//     } catch (e) {
//       log("Could not connect to sensors: $e");
//     }
//   }

  // Clean up
  void dispose() {
    _sensorSubscription?.cancel();
    _temperatureController.close();
    _humidityController.close();
    _gasLevelController.close();
    _distanceController.close();
    _cardStatusController.close();
  }
}