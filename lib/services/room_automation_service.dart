import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/SensorData.dart';

class RoomAutomationService {
  // Oda olayları için stream controller
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  // Stream getter
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  // Singleton pattern
  static final RoomAutomationService _instance = RoomAutomationService._internal();

  factory RoomAutomationService() {
    return _instance;
  }

  RoomAutomationService._internal() {
    // İlk açılışta olayları dinlemeye başla
    _subscribeToEvents();
  }

  // Abonelik
  StreamSubscription? _subscription;

  void _subscribeToEvents() {
    try {
      // Amplify v2 GraphQL subscription
            const String subscriptionDocument = '''
        subscription OnRoomEvent(\$roomId: String!) {
          onRoomEvent(roomId: \$roomId) {
            roomId
            eventType
            timestamp
            details
          }
        }
      ''';

      // Varsayılan oda ID'si
      const variables = {
        'roomId': 'room_001'
      };

      final operation = Amplify.API.subscribe(
        GraphQLRequest<String>(
          document: subscriptionDocument,
          variables: variables,
        ),
        onEstablished: () => print('Oda olayları aboneliği kuruldu'),
      );

      _subscription = operation.listen(
            (event) {
          if (event.data != null) {
            try {
              // JSON yanıtı ayrıştır
              final data = json.decode(event.data!);
              if (data.containsKey('onRoomEvent') && data['onRoomEvent'] != null) {
                // Event stream'e gönder
                _eventController.add(data['onRoomEvent']);
              }
            } catch (e) {
              print("Olay verisi ayrıştırma hatası: $e");
            }
          }
        },
        onError: (error) {
          print("Olay aboneliği hatası: $error");
        },
      );
    } catch (e) {
      print("Olay aboneliği oluşturma hatası: $e");
    }
  }

  // Oda modu ayarlama
  Future<bool> setRoomMode(String roomId, String mode) async {
    try {
      // Amplify v2 GraphQL mutation
      const String mutationDocument = '''
  mutation SetRoomMode(\$roomId: String!, \$mode: String!) {
    setRoomMode(roomId: \$roomId, mode: \$mode) {
      success
      message
    }
  }
''';

      final variables = {
        'roomId': roomId,
        'mode': mode
      };

      final request = GraphQLRequest<String>(
        document: mutationDocument,
        variables: variables,
      );

      final operation = Amplify.API.mutate(request: request);
      final response = await operation.response;

      if (response.data != null) {
        final data = json.decode(response.data!);
        return data['setRoomMode']['success'] ?? false;
      }

      return false;
    } catch (e) {
      print("Oda modu ayarlama hatası: $e");
      return false;
    }
  }

  // Sesli özet oluşturma
  Future<String?> generateVoiceSummary(String roomId) async {
    try {
      // Amplify v2 REST API
      final restOperation = Amplify.API.post(
          '/voice-summary',
          body: HttpPayload.json({
            'roomId': roomId
          })
      );

      final response = await restOperation.response;

      // Sesli özet oluşturma fonksiyonunda düzeltme
      if (response.statusCode == 200) {
        final bodyBytes = await response.body.toList().then((chunks) =>
            chunks.expand((chunk) => chunk).toList());
        final data = json.decode(utf8.decode(bodyBytes));
        return data['audioUrl'];
      }

      return null;
    } catch (e) {
      print("Sesli özet oluşturma hatası: $e");
      return null;
    }
  }

  // Sensör geçmişi getir
  Future<List<Map<String, dynamic>>?> getSensorHistory(String roomId) async {
    try {
      // Amplify v2 DataStore sorgu
      final sensorData = await Amplify.DataStore.query(
          SensorData.classType,
          where: SensorData.DEVICEID.eq(roomId).and(
              SensorData.TIMESTAMP.gt(DateTime.now().millisecondsSinceEpoch - 86400000)), // Son 24 saat
          sortBy: [SensorData.TIMESTAMP.descending()]
      );

      // Verileri dönüştür
      return sensorData.map((data) => {
        'timestamp': data.timestamp,
        'temperature': data.temperature,
        'humidity': data.humidity,
        'gasLevel': data.gasLevel,
        'distance': data.distance,
        'occupied': data.occupied
      }).toList();

    } catch (e) {
      print("Sensör geçmişi getirme hatası: $e");
      return null;
    }
  }

  // Olay geçmişi getir
  Future<List<Map<String, dynamic>>?> getEventHistory(String roomId) async {
    try {
      // Amplify v2 REST API
      final restOperation = Amplify.API.get(
          '/room-events',
          queryParameters: {
            'roomId': roomId,
            'limit': '50'
          }
      );

      final response = await restOperation.response;

      if (response.statusCode == 200) {
        final bodyBytes = await response.body.toList().then((chunks) =>
            chunks.expand((chunk) => chunk).toList());
        final data = json.decode(utf8.decode(bodyBytes));
        return List<Map<String, dynamic>>.from(data['events']);
      }

      return [];
    } catch (e) {
      print("Olay geçmişi getirme hatası: $e");
      return [];
    }
  }

  // Kullanıcı tercihlerini kaydet
  Future<bool> saveUserPreferences(String roomId, Map<String, dynamic> preferences) async {
    try {
      // Amplify v2 REST API
      final restOperation = Amplify.API.put(
          '/user-preferences',
          body: HttpPayload.json({
            'roomId': roomId,
            'preferences': preferences
          })
      );

      final response = await restOperation.response;
      return response.statusCode == 200;
    } catch (e) {
      print("Kullanıcı tercihleri kaydetme hatası: $e");
      return false;
    }
  }

  // Kullanıcı tercihlerini getir
  Future<Map<String, dynamic>?> getUserPreferences(String roomId) async {
    try {
      // Amplify v2 REST API
      final restOperation = Amplify.API.get(
          '/user-preferences',
          queryParameters: {
            'roomId': roomId
          }
      );

      final response = await restOperation.response;

      if (response.statusCode == 200) {
        final bodyBytes = await response.body.toList().then((chunks) =>
            chunks.expand((chunk) => chunk).toList());
        final data = json.decode(utf8.decode(bodyBytes));
        return data['preferences'];
      }

      return {};
    } catch (e) {
      print("Kullanıcı tercihleri getirme hatası: $e");
      return {};
    }
  }

  // Kaynak temizleme
  void dispose() {
    _subscription?.cancel();
    _eventController.close();
  }
}