import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugLogNotifier extends StateNotifier<List<String>> {
  static const int maxLogEntries = 100;

  DebugLogNotifier() : super([]);

  void log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = "[$timestamp] $message";
    safePrint(logEntry);

    final updatedLogs = [...state, logEntry];

    // Clear old records if log list gets too long
    if (updatedLogs.length > maxLogEntries) {
      state = updatedLogs.sublist(updatedLogs.length - maxLogEntries);
    } else {
      state = updatedLogs;
    }
  }

  void clear() {
    state = [];
  }
}

// Global log instance
final DebugLogNotifier _globalLogNotifier = DebugLogNotifier();

// Global log function
void log(String message) {
  _globalLogNotifier.log(message);
}

// Global clear function
void clearLogs() {
  _globalLogNotifier.clear();
}

final debugLogProvider = StateNotifierProvider<DebugLogNotifier, List<String>>(
      (ref) => _globalLogNotifier, // Provide the same instance to the provider
);

// Provider for developer mode
final developerModeProvider = StateProvider<bool>((ref) => false);