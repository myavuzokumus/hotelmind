import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmind/models/ResponseModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'debug_log_provider.dart';

// AuthService için provider tanımı
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;

  AuthService(this._ref);

  // Rate limiting için değişkenler
  static const String _RATE_LIMIT_KEY = "qr_scan_timestamps";
  static const int _MAX_REQUESTS_PER_MINUTE = 10;
  static const int _WINDOW_SECONDS = 60;

  // Güvenli log metodu
  void _log(String message) {
    safePrint(message);
    try {
        _ref.read(debugLogProvider.notifier).log(message);
    } catch (e) {
      safePrint("Log hatası: $e");
    }
  }

  // Rate limiting kontrolü
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

      // Zaman aralığı dışındaki kayıtları temizle
      timestamps = timestamps.where((time) => time >= windowStart).toList();

      // Son isteklerin sayısını kontrol et
      if (timestamps.length >= _MAX_REQUESTS_PER_MINUTE) {
        _log("Rate limit aşıldı! Son 1 dakikada $_MAX_REQUESTS_PER_MINUTE istek yapıldı.");
        return false;
      }

      // Yeni timestamp ekle
      timestamps.add(now);
      await prefs.setString(_RATE_LIMIT_KEY, jsonEncode(timestamps));

      _log("Rate limit kontrolü başarılı. Son 1 dakikada ${timestamps.length} istek.");
      return true;
    } catch (e) {
      _log("Rate limit kontrolü sırasında hata: $e");
      return false;
    }
  }

  Map<String, dynamic>? parseQrData(String qrData) {
    // QR veriyi parse et
    Map<String, dynamic>? qrJson;
    try {
      qrJson = json.decode(qrData);
      _log("QR Kod JSON formatında başarıyla ayrıştırıldı.");
    } catch (e) {
      _log("QR kod JSON formatı ayrıştırma hatası: $e");
      return null;
    }

    if (qrJson == null) {
      _log("QR kod verileri ayrıştırılamadı");
      return null;
    }

    _log("QR Kod alanları kontrol ediliyor...");
    final roomId = qrJson['roomId'];
    final timestamp = qrJson['timestamp'];
    final expiry = qrJson['expiry'];
    final sessionId = qrJson['sessionId'];
    final signature = qrJson['signature'];

    _log("roomId: $roomId");
    _log("timestamp: $timestamp");
    _log("expiry: $expiry");
    _log("sessionId: $sessionId");
    _log("signature: ${signature?.substring(0, 10)}...");

    if (roomId == null || timestamp == null || expiry == null ||
        sessionId == null || signature == null) {
      _log("HATA: QR kod eksik alanlar içeriyor.");
      return null;
    }

    return qrJson;
  }

  Future<ResponseModel<Map<String, dynamic>>> verifyQRCode(String qrData) async {
    try {
      _log("=== QR KOD DOĞRULAMA BAŞLADI ===");

      if (!await _checkRateLimit()) {
        _log("Çok fazla istek gönderildi. Lütfen biraz bekleyin.");
        return ResponseModel.error("Çok fazla istek gönderildi. Lütfen biraz bekleyin.");
      }

      _log("Alınan QR veri: $qrData");

      Map<String, dynamic>? qrJson = parseQrData(qrData);
      if (qrJson == null) {
        return ResponseModel.error("QR kod formatı geçerli değil.");
      }

      _log("Süre kontrolü yapılıyor...");
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiry = qrJson['expiry'];
      _log("Şu anki zaman: $now, Son geçerlilik: $expiry");

      if (now > expiry) {
        _log("HATA: QR kodun süresi dolmuş!");
        return ResponseModel.error("QR kodun süresi dolmuş.");
      }

      _log("QR kod zaman kontrolü başarılı. Kod hala geçerli.");

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
          _log("Ham QR API yanıtı: ${response.data}");

          try {
            Map<String, dynamic> firstLevel = jsonDecode(response.data!);
            Map<String, dynamic> secondLevel = jsonDecode(firstLevel['QrVerify']);
            int statusCode = secondLevel['statusCode'];
            Map<String, dynamic> thirdLevel = jsonDecode(secondLevel['body']);

            bool isValid = thirdLevel['isValid'];
            String message = thirdLevel['message'];

            _log("API Durum Kodu: $statusCode");
            _log("Doğrulama Sonucu: $isValid");
            _log("Mesaj: $message");

            if (statusCode == 200) {
              if (isValid) {
                return ResponseModel.success(qrJson);
              } else {
                _log("QR kodu geçerli değil: $message");
                return ResponseModel.error(message);
              }
            } else {
              _log("API hata döndürdü: $message");
              return ResponseModel.error("Sunucu hatası: $message");
            }
          } catch (e) {
            _log("JSON ayrıştırma hatası: $e");
            return ResponseModel.error("Sunucu yanıtı işlenirken hata oluştu.");
          }
        } else if (response.errors.isNotEmpty) {
          _log("API hatası: ${response.errors.first.message}");
          return ResponseModel.error("API hatası: ${response.errors.first.message}");
        }

        return ResponseModel.error("Bilinmeyen bir hata oluştu.");
      } catch (e) {
        _log("API çağrısı hatası: $e");
        return ResponseModel.error("Sunucuya bağlanırken hata oluştu.");
      }
    } catch (e) {
      _log("QR kod doğrulama hatası: $e");
      return ResponseModel.error("QR kod doğrulama hatası");
    }
  }
}
