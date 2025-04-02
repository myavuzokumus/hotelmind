// lib/providers/debug_log_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugLogNotifier extends StateNotifier<List<String>> {
  static const int maxLogEntries = 100;

  DebugLogNotifier() : super([]);

  void log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = "[$timestamp] $message";

    final updatedLogs = [...state, logEntry];

    // Log listesi çok uzarsa eski kayıtları temizle
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

final debugLogProvider = StateNotifierProvider<DebugLogNotifier, List<String>>(
      (ref) => DebugLogNotifier(),
);

// Geliştirici modu için provider
final developerModeProvider = StateProvider<bool>((ref) => false);