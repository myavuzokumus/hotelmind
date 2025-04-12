import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:hotelmind/models/RoomControl.dart';
import 'package:hotelmind/models/RoomControlControlType.dart';
import 'package:hotelmind/models/RoomEvent.dart';
import 'package:hotelmind/models/UserPreference.dart';
import 'package:hotelmind/models/UserPreferenceRoomMode.dart';

import '../models/SensorData.dart';
import 'debug_log_provider.dart';

class RoomAutomationService {
  // Oda olayları için stream controller
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  String roomId = "room_001";

  // Stream getter
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  // Singleton pattern
  static final RoomAutomationService _instance = RoomAutomationService._internal();

  factory RoomAutomationService() {
    return _instance;
  }

  RoomAutomationService._internal();

  // Initialize metodu ekliyoruz
  void initialize({String? roomId}) {
    if (roomId != null) {
      this.roomId = roomId;
    }
    // İlk açılışta olayları dinlemeye başla
    _subscribeToEvents();
  }

  // Abonelik
  StreamSubscription? _subscription;

  void _subscribeToEvents() {
    try {
      // Varolan subscription'ı iptal et (eğer varsa)
      _subscription?.cancel();

      // İlk veriyi hemen çek
      _fetchLatestEvents();

      // Periyodik olarak verileri çekecek bir Timer oluştur (her 10 saniyede bir)
      _subscription = Stream.periodic(Duration(seconds: 10)).listen((_) {
        _fetchLatestEvents();
      });

      log('Olay verilerini periyodik sorgulama başlatıldı');
    } catch (e) {
      log("Olay dinleme hatası: $e");
    }
  }

  Future<void> _fetchLatestEvents() async {
    try {
      // Tek bir kayıt getiren sorgu
      final request = ModelQueries.get(
        RoomEvent.classType,
        RoomEventModelIdentifier(roomId: roomId), // Varsayılan oda ID'si
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final eventData = response.data!;

        // Payload array'deki olayları döngüyle işle
        if (eventData.payload.isNotEmpty) {
          // En son olayı al ve stream'e gönder
          final lastEvent = eventData.payload.last;

          _eventController.add({
            'eventType': lastEvent.eventType,
            'timestamp': lastEvent.timestamp,
            'description': lastEvent.description,
            'resolved': lastEvent.resolved
          });

          log("Yeni olay verisi alındı: ${lastEvent.eventType} - ${lastEvent.description}");
        }
      }
    } catch (e) {
      log("Olay verisi çekilirken hata: $e");
    }
  }

  // void _subscribeToEvents() {
  //   try {
  //     // Model tabanlı abonelik
  //     final subscription = Amplify.API.subscribe(
  //       ModelSubscriptions.onUpdate(RoomEvent.classType,
  //           authorizationMode: APIAuthorizationType.apiKey),
  //       onEstablished: () => log('Oda olayları aboneliği kuruldu'),
  //     );
  //
  //     _subscription = subscription.listen(
  //           (event) {
  //         if (event.data != null && event.data is RoomEvent) {
  //           final roomEvent = event.data as RoomEvent;
  //
  //           // Yeni yapıda olaylar payload dizisinde
  //           if (roomEvent.payload.isNotEmpty) {
  //             // En son eklenen olayı al (dizinin son elemanı)
  //             final lastEvent = roomEvent.payload.last;
  //
  //             // Event stream'e gönder
  //             _eventController.add({
  //               'eventType': lastEvent.eventType,
  //               'timestamp': lastEvent.timestamp,
  //               'description': lastEvent.description,
  //               'resolved': lastEvent.resolved
  //             });
  //           }
  //         }
  //       },
  //       onError: (error) {
  //         log("Olay aboneliği hatası: $error");
  //       },
  //     );
  //   } catch (e) {
  //     log("Olay aboneliği oluşturma hatası: $e");
  //   }
  // }

  // Sensör geçmişi getir
// Sensör geçmişi getir
  Future<List<Map<String, dynamic>>?> getSensorHistory(String roomId) async {
    try {
      // Artık tek bir kayıt getiriyoruz, liste değil
      final request = ModelQueries.get(
        SensorData.classType,
        SensorDataModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        log("Sensör geçmişi sorgu hatası: ${response.errors}");
        return null;
      }

      // Veri yoksa boş liste döndür
      if (response.data == null) {
        return [];
      }

      // Artık payload içindeki array verisini alıyoruz
      final sensorData = response.data!;

      // payload içindeki verileri dönüştürüp bir liste olarak döndür
      return sensorData.payload!.map((item) => {
        'timestamp': item.timestamp,
        'temperature': item.temperature,
        'pressure': item.pressure,
        'humidity': item.humidity,
        'gasLevel': item.gasLevel,
        'distance': item.distance,
        'occupied': item.occupied,
        'cardInserted': item.cardInserted
      }).toList();

    } catch (e) {
      log("Sensör geçmişi getirme hatası: $e");
      return null;
    }
  }

  // Olay geçmişi getir
  Future<List<Map<String, dynamic>>?> getEventHistory(String roomId) async {
    try {
      // Tek bir kayıt getiriyoruz
      final request = ModelQueries.get(
        RoomEvent.classType,
        RoomEventModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        log("Olay geçmişi sorgu hatası: ${response.errors}");
        return [];
      }

      if (response.data == null) {
        return [];
      }

      // payload içindeki array verisini alıyoruz
      final eventData = response.data!;

      // Verileri dönüştür
      return eventData.payload.map((event) => {
        'eventType': event.eventType,
        'timestamp': event.timestamp,
        'description': event.description,
        'resolved': event.resolved
      }).toList();

    } catch (e) {
      log("Olay geçmişi getirme hatası: $e");
      return [];
    }
  }

  // Kullanıcı tercihlerini kaydet
  Future<bool> saveUserPreferences(String roomId, Map<String, dynamic> preferences) async {
    try {
      // Önce mevcut tercihleri sorgulayalım
      final getRequest = ModelQueries.get(
        UserPreference.classType,
        UserPreferenceModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final getResponse = await Amplify.API.query(request: getRequest).response;

      final response;

      if (getResponse.data != null) {
        // Mevcut tercihleri güncelle
        final updatedPreference = getResponse.data!.copyWith(
            preferredTemperature: preferences['preferredTemperature'],
            preferredHumidity: preferences['preferredHumidity'],
            autoClimate: preferences['autoClimate'],
            automaticLights: preferences['automaticLights'],
            voiceReports: preferences['voiceReports'],
            roomMode: preferences['roomMode'] != null
                ? UserPreferenceRoomMode.values.firstWhere(
                  (e) => e.toString().split('.').last == preferences['roomMode'],
              orElse: () => UserPreferenceRoomMode.comfort,
            ) : UserPreferenceRoomMode.comfort,
        );

        final updateRequest = ModelMutations.update(
          updatedPreference,
          authorizationMode: APIAuthorizationType.apiKey,
        );

        response = await Amplify.API.mutate(request: updateRequest).response;

      } else {
        // Yeni tercih oluştur
        final newPreference = UserPreference(
            roomId: roomId,
            preferredTemperature: preferences['preferredTemperature'],
            preferredHumidity: preferences['preferredHumidity'],
            autoClimate: preferences['autoClimate'],
            automaticLights: preferences['automaticLights'],
            voiceReports: preferences['voiceReports'],
            roomMode: preferences['roomMode'] != null
                ? UserPreferenceRoomMode.values.firstWhere(
                  (e) => e.toString().split('.').last == preferences['roomMode'],
              orElse: () => UserPreferenceRoomMode.comfort,
            ) : UserPreferenceRoomMode.comfort,
        );

        final createRequest = ModelMutations.create(
          newPreference,
          authorizationMode: APIAuthorizationType.apiKey,
        );

        response = await Amplify.API.mutate(request: createRequest).response;
      }

      _callFetchUserPreference(roomId);
      return response.errors.isEmpty;

    } catch (e) {
      log("Kullanıcı tercihleri kaydetme hatası: $e");
      return false;
    }
  }

// Kullanıcı tercihlerini getir
  Future<Map<String, dynamic>?> getUserPreferences(String roomId) async {
    try {
      final request = ModelQueries.get(
        UserPreference.classType,
        UserPreferenceModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data == null) {
        return null;
      }

      final preference = response.data!;

      return {
        'preferredTemperature': preference.preferredTemperature,
        'preferredHumidity': preference.preferredHumidity,
        'autoClimate': preference.autoClimate,
        'automaticLights': preference.automaticLights,
        'voiceReports': preference.voiceReports,
        'roomMode': preference.roomMode,
      };
    } catch (e) {
      log("Kullanıcı tercihleri getirme hatası: $e");
      return {
        'preferredTemperature': 22.0,
        'preferredHumidity': 55.0,
        'autoClimate': true,
        'automaticLights': true,
        'voiceReports': true,
        'roomMode': "comfort",
      };
    }
  }

  // Oda kontrollerini (ışık/cihaz) ayarlamak için fonksiyon
  Future<bool> setRoomControl(String roomId, Map<String, dynamic> controlData) async {
    try {
      // Kontrol tipi ve adını al
      final String controlType = controlData['type'] ?? 'light';
      final String controlName = controlData['type'] == 'light'
          ? controlData['lightType'] ?? 'main'
          : controlData['deviceType'] ?? 'tv';
      final bool status = controlData['status'] ?? false;

      // Model identifier oluştur
      final identifier = RoomControlModelIdentifier(
        roomId: roomId,
        controlName: controlName,
      );

      // Önce mevcut kontrolü sorgula
      final getRequest = ModelQueries.get(
        RoomControl.classType,
        identifier,
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final getResponse = await Amplify.API.query(request: getRequest).response;

      RoomControl? roomControl;

      if (getResponse.data != null) {
        // Mevcut kaydı güncelle
        roomControl = getResponse.data!.copyWith(
          status: status,
          lastUpdated: DateTime.now().second,
        );

        final updateRequest = ModelMutations.update(
          roomControl,
          authorizationMode: APIAuthorizationType.apiKey,
        );

        final updateResponse = await Amplify.API.mutate(request: updateRequest).response;

        if (updateResponse.errors.isNotEmpty) {
          log("Kontrol güncellenirken hata: ${updateResponse.errors}");
          return false;
        }
      } else {
        // Yeni kontrol kaydı oluştur
        roomControl = RoomControl(
          roomId: roomId,
          controlType: controlType == 'light' ? RoomControlControlType.light : RoomControlControlType.device,
          controlName: controlName,
          status: status,
          lastUpdated: DateTime.now().second,
        );

        final createRequest = ModelMutations.create(
          roomControl,
          authorizationMode: APIAuthorizationType.apiKey,
        );

        final createResponse = await Amplify.API.mutate(request: createRequest).response;

        if (createResponse.errors.isNotEmpty) {
          log("Kontrol kaydı oluşturulurken hata: ${createResponse.errors}");
          return false;
        }
      }

      // IoT konusuna kontrol güncellemesini yayınla
      await _callRequestRoomControl(roomId, controlType, controlName, status);

      return true;
    } catch (e) {
      log("Oda kontrol işlemi hatası: $e");
      return false;
    }
  }

// IoT konusuna kontrol güncellemesi yayınla
  Future<void> _callFetchUserPreference(
      String roomId) async {
    try {
      // GraphQL dökümü tanımla
      const document = '''
      query FetchUserPreference(\$roomId: String!) {
        FetchUserPreference(roomId: \$roomId)
          }
        ''';

      // GraphQL isteği oluştur
      final request = GraphQLRequest<String>(
        document: document,
        variables: {'roomId': roomId},
        decodePath: 'FetchUserPreference',
        authorizationMode: APIAuthorizationType.apiKey,
      );

      // API çağrısını yap
      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        log("MQTT yayımlama hatası: ${response.errors}");
      } else {
        log("IoT mesajı başarıyla yayınlandı - Kullanıcı tercihleri");
      }
    } catch (e) {
      log("IoT yayınlama hatası: $e");
    }
  }

// RequestRoomControl Lambda fonksiyonunu çağır
  Future<void> _callRequestRoomControl(String roomId, String controlType, String controlName, bool status) async {
    try {
      const document = '''
    query RequestRoomControl(\$roomId: String!, \$controlType: String!, \$controlName: String!, \$status: Boolean!) {
      RequestRoomControl(roomId: \$roomId, controlType: \$controlType, controlName: \$controlName, status: \$status)
    }
    ''';

      final request = GraphQLRequest<String>(
        document: document,
        variables: {
          'roomId': roomId,
          'controlType': controlType,
          'controlName': controlName,
          'status': status
        },
        decodePath: 'RequestRoomControl',
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        log("RequestRoomControl çağrı hatası: ${response.errors}");
      } else {
        log("RequestRoomControl Lambda fonksiyonu başarıyla çağrıldı: $controlType/$controlName = $status");
      }
    } catch (e) {
      log("RequestRoomControl çağrı hatası: $e");
    }
  }

  // Kaynak temizleme
  void dispose() {
    _subscription?.cancel();
    _eventController.close();
  }
}