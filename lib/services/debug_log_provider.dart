import 'package:flutter/material.dart';

class DebugLogProvider extends ChangeNotifier {
  final List<String> _logs = [];
  static const int maxLogEntries = 100;

  List<String> get logs => List.unmodifiable(_logs);

  void log(String message) {
    // Zaman damgası ekle
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = "[$timestamp] $message";

    _logs.add(logEntry);

    // Log listesi çok uzarsa eski kayıtları temizle
    if (_logs.length > maxLogEntries) {
      _logs.removeRange(0, _logs.length - maxLogEntries);
    }

    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}