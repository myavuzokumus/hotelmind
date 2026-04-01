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
  // Stream controller for room events
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  String roomId = "room_001";
  int? _lastProcessedEventTimestamp;

  // Stream getter
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  // Singleton pattern
  static final RoomAutomationService _instance = RoomAutomationService._internal();

  factory RoomAutomationService() {
    return _instance;
  }

  RoomAutomationService._internal();

  // Adding Initialize method
  void initialize({String? roomId}) {
    if (roomId != null) {
      this.roomId = roomId;
    }
    // Start listening for events on startup
    _subscribeToEvents();
  }

  // Subscription
  StreamSubscription? _subscription;

  void _subscribeToEvents() {
    try {
      // Cancel existing subscription (if any)
      _subscription?.cancel();

      // Fetch first data immediately
      _fetchLatestEvents();

      // Create a Timer to fetch data periodically (every 10 seconds)
      _subscription = Stream.periodic(Duration(seconds: 10)).listen((_) {
        _fetchLatestEvents();
      });

      log('Periodic querying of event data started');
    } catch (e) {
      log("Event listening error: $e");
    }
  }

  Future<void> _fetchLatestEvents() async {
    try {
      // Query returning a single record
      final request = ModelQueries.get(
        RoomEvent.classType,
        RoomEventModelIdentifier(roomId: roomId), // Default room ID
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final eventData = response.data!;

        // Loop through events in payload array
        if (eventData.payload.isNotEmpty) {
          // Get the latest event
          final lastEvent = eventData.payload.last;

          // If this event has not been processed before, send it to the stream
          if (_lastProcessedEventTimestamp == null ||
              lastEvent.timestamp != _lastProcessedEventTimestamp) {

            _eventController.add({
              'eventType': lastEvent.eventType,
              'timestamp': lastEvent.timestamp,
              'description': lastEvent.description,
              'resolved': lastEvent.resolved
            });

            // Update timestamp of the last processed event
            _lastProcessedEventTimestamp = lastEvent.timestamp;

            log("New event data received: ${lastEvent.eventType} - ${lastEvent.description}");

            // Play sound if it is an Alarm type event
            if (lastEvent.eventType != null && lastEvent.eventType!.toLowerCase().contains("alert")) {
              _playAlarmSequence(); // Call without await to prevent blocking
            }
          } else {
            log("Event already processed, not added again: ${lastEvent.timestamp}");
          }
        }

      }
    } catch (e) {
      log("Error fetching event data: $e");
    }
  }

  Future<void> _playAlarmSequence() async {
    const int alarmTekrarSayisi = 3;
    const Duration alarmArasiGecikme = Duration(seconds: 1);

    for (int i = 0; i < alarmTekrarSayisi; i++) {
      await Future.delayed(alarmArasiGecikme); // Short delay before playing sound
      _playAlarmSound();
    }
  }

  // Method to play alarm sound
  void _playAlarmSound() {
    // Playing sound using AudioPlayer
    try {
      final player = AudioPlayer();
      player.play(AssetSource('sounds/alarm.wav')); //

      log("PLAYING ALARM SOUND!");

      SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      log("Sound playback error: $e");
    }
  }

  // void _subscribeToEvents() {
  //   try {
  //       // Model-based subscription
  //       final subscription = Amplify.API.subscribe(
  //         ModelSubscriptions.onUpdate(RoomEvent.classType,
  //             authorizationMode: APIAuthorizationType.apiKey),
  //         onEstablished: () => log('Room events subscription established'),
  //       );
  //
  //       _subscription = subscription.listen(
  //             (event) {
  //           if (event.data != null && event.data is RoomEvent) {
  //             final roomEvent = event.data as RoomEvent;
  //
  //             // In the new structure, events are in the payload array
  //             if (roomEvent.payload.isNotEmpty) {
  //               // Get the last added event (last element of array)
  //               final lastEvent = roomEvent.payload.last;
  //
  //               // Send to event stream
  //               _eventController.add({
  //                 'eventType': lastEvent.eventType,
  //                 'timestamp': lastEvent.timestamp,
  //                 'description': lastEvent.description,
  //                 'resolved': lastEvent.resolved
  //               });
  //             }
  //           }
  //         },
  //         onError: (error) {
  //           log("Event subscription error: $error");
  //         },
  //       );
  //     } catch (e) {
  //       log("Error creating event subscription: $e");
  //   }
  // }

  // Get sensor history
// Get sensor history
  Future<List<Map<String, dynamic>>?> getSensorHistory(String roomId) async {
    try {
      // Now returning a single record, not a list
      final request = ModelQueries.get(
        SensorData.classType,
        SensorDataModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        log("Sensor history query error: ${response.errors}");
        return null;
      }

      // Return empty list if no data
      if (response.data == null) {
        return [];
      }

      // Now getting the array data inside payload
      final sensorData = response.data!;

      // Convert data in payload and return as a list
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
      log("Error getting sensor history: $e");
      return null;
    }
  }

  // Get event history
  Future<List<Map<String, dynamic>>?> getEventHistory(String roomId) async {
    try {
      // Getting a single record
      final request = ModelQueries.get(
        RoomEvent.classType,
        RoomEventModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        log("Event history query error: ${response.errors}");
        return [];
      }

      if (response.data == null) {
        return [];
      }

      // Getting array data inside payload
      final eventData = response.data!;

      // Convert data
      return eventData.payload.map((event) => {
        'eventType': event.eventType,
        'timestamp': event.timestamp,
        'description': event.description,
        'resolved': event.resolved
      }).toList();

    } catch (e) {
      log("Error getting event history: $e");
      return [];
    }
  }

  // Save user preferences
  Future<bool> saveUserPreferences(String roomId, Map<String, dynamic> preferences) async {
    try {
      // First, query existing preferences
      final getRequest = ModelQueries.get(
        UserPreference.classType,
        UserPreferenceModelIdentifier(roomId: roomId),
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final getResponse = await Amplify.API.query(request: getRequest).response;

      final GraphQLResponse<UserPreference> response;

      if (getResponse.data != null) {
        // Update existing preferences
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
        // Create new preference
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
      log("Error saving user preferences: $e");
      return false;
    }
  }

// Get user preferences
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
      log("Error getting user preferences: $e");
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

  // Function to set room controls (light/device)
  Future<bool> setRoomControl(String roomId, Map<String, dynamic> controlData) async {
    try {
      // Get control type and name
      final String controlType = controlData['type'] ?? 'light';
      final String controlName = controlData['type'] == 'light'
          ? controlData['lightType'] ?? 'main'
          : controlData['deviceType'] ?? 'tv';
      final bool status = controlData['status'] ?? false;

      // Create model identifier
      final identifier = RoomControlModelIdentifier(
        roomId: roomId,
        controlName: controlName,
      );

      // Query existing control first
      final getRequest = ModelQueries.get(
        RoomControl.classType,
        identifier,
        authorizationMode: APIAuthorizationType.apiKey,
      );

      final getResponse = await Amplify.API.query(request: getRequest).response;

      RoomControl? roomControl;

      if (getResponse.data != null) {
        // Update existing record
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
          log("Error updating control: ${updateResponse.errors}");
          return false;
        }
      } else {
        // Create new control record
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
          log("Error creating control record: ${createResponse.errors}");
          return false;
        }
      }

      // Publish control update to IoT topic
      await _callRequestRoomControl(roomId, controlType, controlName, status);

      return true;
    } catch (e) {
      log("Room control operation error: $e");
      return false;
    }
  }

// Publish control update to IoT topic
  Future<void> _callFetchUserPreference(
      String roomId) async {
    try {
      // Define GraphQL document
      const document = '''
      query FetchUserPreference(\$roomId: String!) {
        FetchUserPreference(roomId: \$roomId)
          }
        ''';

      // Create GraphQL request
      final request = GraphQLRequest<String>(
        document: document,
        variables: {'roomId': roomId},
        decodePath: 'FetchUserPreference',
        authorizationMode: APIAuthorizationType.apiKey,
      );

      // Make API call
      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        log("MQTT publish error: ${response.errors}");
      } else {
        log("IoT message published successfully - User preferences");
      }
    } catch (e) {
      log("IoT publish error: $e");
    }
  }

// Call RequestRoomControl Lambda function
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
        log("RequestRoomControl call error: ${response.errors}");
      } else {
        log("RequestRoomControl Lambda function called successfully: $controlType/$controlName = $status");
      }
    } catch (e) {
      log("RequestRoomControl call error: $e");
    }
  }

  // Resource cleanup
  void dispose() {
    _subscription?.cancel();
    _eventController.close();
    _lastProcessedEventTimestamp = null; // Also clear timestamp
  }
}