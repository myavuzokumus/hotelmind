import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmind/models/ResponseModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'debug_log_provider.dart';

// Provider definition for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {

  AuthService();

  // Rate limiting variables
  static const String _RATE_LIMIT_KEY = "qr_scan_timestamps";
  static const int _MAX_REQUESTS_PER_MINUTE = 10;
  static const int _WINDOW_SECONDS = 60;

  // Rate limiting check
  Future<bool> _checkRateLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedData = prefs.getString(_RATE_LIMIT_KEY);

      List<int> timestamps = [];
      if (storedData != null) {
        timestamps = List<int>.from(jsonDecode(storedData));
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final windowStart = now - _WINDOW_SECONDS;

      // Clear records outside the time window
      timestamps = timestamps.where((time) => time >= windowStart).toList();

      // Check the number of recent requests
      if (timestamps.length >= _MAX_REQUESTS_PER_MINUTE) {
        log("Rate limit exceeded! $_MAX_REQUESTS_PER_MINUTE requests made in the last 1 minute.");
        return false;
      }

      // Add new timestamp
      timestamps.add(now);
      await prefs.setString(_RATE_LIMIT_KEY, jsonEncode(timestamps));

      log("Rate limit check successful. ${timestamps.length} requests in the last 1 minute.");
      return true;
    } catch (e) {
      log("Error during rate limit check: $e");
      return false;
    }
  }

  Map<String, dynamic>? parseQrData(String qrData) {
    // Parse QR data
    Map<String, dynamic>? qrJson;
    try {
      qrJson = json.decode(qrData);
      log("QR Code successfully parsed in JSON format.");
    } catch (e) {
      log("QR code JSON format parsing error: $e");
      return null;
    }

    if (qrJson == null) {
      log("QR code data could not be parsed");
      return null;
    }

    log("Checking QR Code fields...");
    final roomId = qrJson['roomId'];
    final timestamp = qrJson['timestamp'];
    final expiry = qrJson['expiry'];
    final sessionId = qrJson['sessionId'];
    final signature = qrJson['signature'];

    log("roomId: $roomId");
    log("timestamp: $timestamp");
    log("expiry: $expiry");
    log("sessionId: $sessionId");
    log("signature: ${signature?.substring(0, 10)}...");

    if (roomId == null || timestamp == null || expiry == null ||
        sessionId == null || signature == null) {
      log("ERROR: QR code continues missing fields.");
      return null;
    }

    return qrJson;
  }

  Future<ResponseModel<Map<String, dynamic>>> verifyQRCode(String qrData) async {
    try {
      log("=== QR CODE VERIFICATION STARTED ===");

      if (!await _checkRateLimit()) {
        log("Too many requests sent. Please wait a bit.");
        return ResponseModel.error("Too many requests sent. Please wait a bit.");
      }

      log("Received QR data: $qrData");

      Map<String, dynamic>? qrJson = parseQrData(qrData);
      if (qrJson == null) {
        return ResponseModel.error("QR code format is not valid.");
      }

      log("Checking expiry...");
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiry = qrJson['expiry'];
      log("Current time: $now, Expiry: $expiry");

      if (now > expiry) {
        log("ERROR: QR code has expired!");
        return ResponseModel.error("QR code has expired.");
      }

      log("QR code time check successful. Code is still valid.");

      try {
        const document = '''
      query QrVerify(\$name: String!) {
              QrVerify(name: \$name)
            }
      ''';

        final request = GraphQLRequest<String>(
          document: document,
          variables: {'name': qrData},
          decodePath: 'qrVerify',
          authorizationMode: APIAuthorizationType.apiKey,
        );

        final response = await Amplify.API.query(request: request).response;

        if (response.data != null) {
          log("Raw QR API response: ${response.data}");

          try {
            Map<String, dynamic> firstLevel = jsonDecode(response.data!);
            Map<String, dynamic> secondLevel = jsonDecode(firstLevel['QrVerify']);
            int statusCode = secondLevel['statusCode'];
            Map<String, dynamic> thirdLevel = jsonDecode(secondLevel['body']);

            bool isValid = thirdLevel['isValid'];
            String message = thirdLevel['message'];

            log("API Status Code: $statusCode");
            log("Verification Result: $isValid");
            log("Message: $message");

            if (statusCode == 200) {
              if (isValid) {
                return ResponseModel.success(qrJson);
              } else {
                log("QR code is not valid: $message");
                return ResponseModel.error(message);
              }
            } else {
              log("API returned error: $message");
              return ResponseModel.error("Server error: $message");
            }
          } catch (e) {
            log("JSON parsing error: $e");
            return ResponseModel.error("Error processing server response.");
          }
        } else if (response.errors.isNotEmpty) {
          log("API error: ${response.errors.first.message}");
          return ResponseModel.error("API error: ${response.errors.first.message}");
        }

        return ResponseModel.error("An unknown error occurred.");
      } catch (e) {
        log("API call error: $e");
        return ResponseModel.error("Error connecting to server.");
      }
    } catch (e) {
      log("QR code verification error: $e");
      return ResponseModel.error("QR code verification error");
    }
  }
}
