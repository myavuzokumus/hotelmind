import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
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
  TemporalTimestamp? _lastProcessedEventTimestamp; // Son işlenen olayın zaman damgasını sakla

  // Stream getter
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  // Singleton pattern
  static final RoomAutomationService _instance = RoomAutomationService._internal();

  factory RoomAutomationService() {
    return _instance;
  }

  RoomAutomationService._internal();

  // Initialize metodu güncellendi
  void initialize({String? roomId}) {
    if (roomId != null && this.roomId != roomId) { // Eğer oda ID'si değişirse
      this.roomId = roomId;
      _lastProcessedEventTimestamp = null; // Son işlenen olay zaman damgasını sıfırla
    } else if (roomId != null) { // Oda ID'si sağlanmışsa (aynı olabilir veya ilk atama)
      this.roomId = roomId;
    }
    // Olayları dinlemeye başla (veya yeniden başlat)
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
      final request = ModelQueries.get(
        RoomEvent.classType,
        RoomEventModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final eventData = response.data!;

        if (eventData.payload.isNotEmpty) {
          final lastEvent = eventData.payload.last;

          // Gelen int? zaman damgasını al
          final int? incomingRawTimestamp = lastEvent.timestamp;
          TemporalTimestamp? currentEventTemporalTimestamp;

          if (incomingRawTimestamp != null) {
            // int zaman damgasını TemporalTimestamp'e dönüştür
            // Gelen değerin saniye cinsinden olduğunu varsayıyoruz.
            // Eğer milisaniye ise, TemporalTimestamp.fromMillisecondsSinceEpoch(incomingRawTimestamp) kullanın
            // veya incomingRawTimestamp / 1000 yapın.
            currentEventTemporalTimestamp = TemporalTimestamp.fromSeconds(incomingRawTimestamp);
          }

          bool isNewEvent = false;
          if (currentEventTemporalTimestamp != null) {
            if (_lastProcessedEventTimestamp == null ||
                currentEventTemporalTimestamp.compareTo(_lastProcessedEventTimestamp!) > 0) {
              isNewEvent = true;
            }
          } else if (_lastProcessedEventTimestamp == null) {
            // Eğer mevcut olayın zaman damgası yoksa ama daha önce hiç olay işlenmemişse,
            // bunu yeni olarak kabul edebiliriz (isteğe bağlı bir davranış).
            // Şimdilik, zaman damgası olmayan olayları yalnızca ilk seferde işleyelim.
            // Ya da zaman damgası olmayanları hiç işlemeyebiliriz.
            // Mevcut mantık: Zaman damgası yoksa ve _lastProcessedEventTimestamp null ise isNewEvent false kalır.
            // Bu, zaman damgası olmayan olayların tekrar tekrar işlenmesini önler.
            // Eğer ilk zaman damgasız olayı işlemek isterseniz:
            // if (_lastProcessedEventTimestamp == null) isNewEvent = true;
          }


          if (isNewEvent) {
            _eventController.add({
              'eventType': lastEvent.eventType,
              'timestamp': lastEvent.timestamp, // Stream'e orijinal int değeri gönderiliyor
              'description': lastEvent.description,
              'resolved': lastEvent.resolved
            });

            log("Yeni olay verisi alındı: ${lastEvent.eventType} - ${lastEvent.description}");

            _lastProcessedEventTimestamp = currentEventTemporalTimestamp; // Son işlenen zaman damgasını TemporalTimestamp olarak güncelle

            if (lastEvent.eventType != null && lastEvent.eventType!.toLowerCase().contains("alert")) {
              _playAlarmSound();
            }
          } else {
            if (currentEventTemporalTimestamp != null) {
              log("Alınan son olay zaten işlenmiş veya aynı/eski zaman damgasına sahip. Oda: $roomId. Son işlenen: $_lastProcessedEventTimestamp, Mevcut: $currentEventTemporalTimestamp");
            } else {
              log("Alınan son olayın zaman damgası yok, işlenmiyor (veya daha önce işlenmiş olabilir). Oda: $roomId");
            }
          }
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

  void _playAlarmSound() {
    try {
      final player = AudioPlayer();
      player.play(AssetSource('sounds/alarm.m4a'));
      log("ALARM SESİ ÇALINIYOR!");
      SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      log("Ses çalma hatası: $e");
    }
  }

  Future<List<Map<String, dynamic>>?> getSensorHistory(String roomId) async {
    try {
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

      if (response.data == null) {
        return [];
      }

      final sensorData = response.data!;

      return sensorData.payload?.map((item) => {
        'timestamp': item.timestamp,
        'temperature': item.temperature,
        'pressure': item.pressure,
        'humidity': item.humidity,
        'gasLevel': item.gasLevel,
        'distance': item.distance,
        'occupied': item.occupied,
        'cardInserted': item.cardInserted
      }).toList() ?? [];

    } catch (e) {
      log("Sensör geçmişi getirme hatası: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getEventHistory(String roomId) async {
    try {
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

      final eventData = response.data!;

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

  Future<bool> saveUserPreferences(String roomId, Map<String, dynamic> preferences) async {
    try {
      final getRequest = ModelQueries.get(
        UserPreference.classType,
        UserPreferenceModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final getResponse = await Amplify.API.query(request: getRequest).response;
      final GraphQLResponse<UserPreference> response;

      if (getResponse.data != null) {
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

  Future<bool> setRoomControl(String roomId, Map<String, dynamic> controlData) async {
    try {
      final String controlType = controlData['type'] ?? 'light';
      final String controlName = controlData['type'] == 'light'
          ? controlData['lightType'] ?? 'main'
          : controlData['deviceType'] ?? 'tv';
      final bool status = controlData['status'] ?? false;

      final identifier = RoomControlModelIdentifier(
        roomId: roomId,
        controlName: controlName,
      );

      final getRequest = ModelQueries.get(
        RoomControl.classType,
        identifier,
        authorizationMode: APIAuthorizationType.apiKey,
      );
      final getResponse = await Amplify.API.query(request: getRequest).response;
      RoomControl? roomControl;

      if (getResponse.data != null) {
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
      await _callRequestRoomControl(roomId, controlType, controlName, status);
      return true;
    } catch (e) {
      log("Oda kontrol işlemi hatası: $e");
      return false;
    }
  }

  Future<void> _callFetchUserPreference(String roomId) async {
    try {
      const document = '''
      query FetchUserPreference(\$roomId: String!) {
        FetchUserPreference(roomId: \$roomId)
          }
        ''';
      final request = GraphQLRequest<String>(
        document: document,
        variables: {'roomId': roomId},
        decodePath: 'FetchUserPreference',
        authorizationMode: APIAuthorizationType.apiKey,
      );
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

  void dispose() {
    _subscription?.cancel();
    _eventController.close();
  }
}