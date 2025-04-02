import 'dart:async';

class EventBus {
  // Singleton pattern
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  // Stream controller for session termination events
  final _sessionTerminatedController =
  StreamController<String>.broadcast();

  // Stream to listen for session termination events
  Stream<String> get onSessionTerminated =>
      _sessionTerminatedController.stream;

  // Notify when a session is terminated
  void terminateSession(String sessionId) {
    _sessionTerminatedController.add(sessionId);
  }

  void dispose() {
    _sessionTerminatedController.close();
  }
}