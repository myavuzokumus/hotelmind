import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'debug_log_provider.dart';

class AuthService {

  final DebugLogProvider _debugLogger;

  // Constructor - debug logger'ı dışarıdan alır
  AuthService(this._debugLogger);

  // QR kodu doğrula

  // Hem konsola hem de debug logger'a yazar
  void _log(String message) {
    print(message);
    _debugLogger.log(message);
  }


  Future<bool> verifyQRCode(String qrData) async {
    try {
      _log("=== QR KOD DOĞRULAMA BAŞLADI ===");
      _log("Alınan QR veri: $qrData");

      // QR veriyi parse et
      Map<String, dynamic>? qrJson;
      try {
        qrJson = json.decode(qrData);
        _log("QR Kod JSON formatında başarıyla ayrıştırıldı.");
      } catch (e) {
        _log("QR kod JSON formatı ayrıştırma hatası: $e");
        // Alternatif format denemesi gerekebilir
      }

      if (qrJson == null) {
        _log("QR kod verileri ayrıştırılamadı");
        return false;
      }

      _log("QR Kod alanları kontrol ediliyor...");
      // Gerekli alanları kontrol et
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
        print("QR kod eksik alanlar içeriyor");
        return false;
      }

      _log("Süre kontrolü yapılıyor...");
      // Geçerlilik süresi kontrolü
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _log("Şu anki zaman: $now, Son geçerlilik: $expiry");
      if (now > expiry) {
        _log("HATA: QR kodun süresi dolmuş! Şu anki zaman: $now, Son geçerlilik: $expiry");
        return false;
      }

      _log("QR kod zaman kontrolü başarılı. Kod hala geçerli.");
      // Doğrulama için AWS'ye gönder
      // final restOperation = Amplify.API.post(
      //     '/verify-qr',
      //     body: HttpPayload.json({
      //       'qrCode': qrData,
      //     })
      // );
      //
      // final response = await restOperation.response;
      //
      // if (response.statusCode == 200) {
      //   final responseBytes = await response.body.toList();
      //   final responseString = utf8.decode(responseBytes.expand((i) => i).toList());
      //   final responseData = json.decode(responseString);
      //
      //   if (responseData['isValid'] == true) {
      //     print("QR kod doğrulandı: $responseData");
      //
      //     // Yerel kullanıcı oturumu başlat
      //     await _createLocalSession(roomId, expiry);
      //     return true;
      //   } else {
      //     print("QR kod geçersiz: ${responseData['message']}");
      //   }
      // } else {
      //   print("API yanıt hatası: ${response.statusCode}");
      // }

      await _createLocalSession(roomId, expiry);

      // Simüle edilmiş doğrulama - API olmadan çalışmak için
      _simulateServerVerification(roomId, timestamp, expiry, sessionId, signature);
      // Test için yerel doğrulama - hızlı başlamak için
      _log("Geçici olarak başarılı kabul ediliyor (Debug modu)");

      return true;
    } catch (e) {
      print("QR kod doğrulama hatası: $e");
      return false;
    }
  }

  // Test amaçlı doğrulama simülasyonu
  void _simulateServerVerification(String roomId, int timestamp, int expiry,
      String sessionId, String signature) {
    _log("\n=== SUNUCU DOĞRULAMA SİMÜLASYONU ===");
    _log("roomId: $roomId");
    _log("timestamp: $timestamp (${DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)})");
    _log("expiry: $expiry (${DateTime.fromMillisecondsSinceEpoch(expiry * 1000)})");
    _log("sessionId: $sessionId");
    _log("signature: ${signature.substring(0, 10)}...");

    // Burada gerçek doğrulama mantığı olacak
    // Bu sadece simülasyon amaçlı
    _log("Sunucu doğrulaması başarılı kabul edildi.");
    _log("======================================\n");
  }

  // Yerel oturum başlat
  Future<void> _createLocalSession(String roomId, int expiryTime) async {
    try {
      // Auth sisteminize göre yerel oturum oluşturun
      // Örnek bir yaklaşım:
      _log("Yerel oturum oluşturuluyor roomId: $roomId");
      await Amplify.Auth.signIn(
          username: "guest_$roomId",
          password: _generateSessionPassword(roomId, expiryTime)
      );
    } catch (e) {
      print("Yerel oturum oluşturma hatası: $e");

      // Kullanıcı yoksa kaydol ve tekrar dene
      if (e is UserNotFoundException) {
        await _signUp(roomId, expiryTime);
        await Amplify.Auth.signIn(
            username: "guest_$roomId",
            password: _generateSessionPassword(roomId, expiryTime)
        );
      } else {
        rethrow;
      }
    }
  }

  // Geçici kullanıcı oluştur
  Future<void> _signUp(String roomId, int expiryTime) async {
    try {
      final result = await Amplify.Auth.signUp(
          username: "guest_$roomId",
          password: _generateSessionPassword(roomId, expiryTime),
          options: SignUpOptions(
              userAttributes: {
                AuthUserAttributeKey.email: "guest_$roomId@example.com",
              }
          )
      );

      // Eğer doğrulama gerektirmiyorsa otomatik onayla
      if (result.nextStep.signUpStep == "CONFIRM_SIGN_UP_STEP") {
        await Amplify.Auth.confirmSignUp(
            username: "guest_$roomId",
            confirmationCode: "000000" // Otomatik doğrulama için
        );
      }
    } catch (e) {
      print("Kullanıcı kaydı hatası: $e");
      rethrow;
    }
  }

  // Oturum için parola üret
  String _generateSessionPassword(String roomId, int expiryTime) {
    // Bu fonksiyonu şifreleme algoritmanıza göre uyarlayın
    // Örnek: roomId + expiryTime'dan hash üretme
    final data = '$roomId:$expiryTime:${DateTime.now().day}';
    // Basit bir karışım: gerçek uygulamada daha güçlü bir algoritma kullanın
    String hash = '';
    for (int i = 0; i < data.length; i++) {
      hash += (data.codeUnitAt(i) % 10).toString();
    }
    // AWS Cognito şifre gereksinimleri: en az 8 karakter, büyük/küçük harf, rakam, özel karakter
    return 'Temp${hash.substring(0, 6)}!1';
  }

  // Oturum durumunu kontrol et
  Future<bool> isSignedIn() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      _log("Oturum durumu kontrolü - başarılı kabul edildi (debug)");
      return result.isSignedIn;
    } catch (e) {
      print("Oturum durumu kontrolü hatası: $e");
      return false;
    }
  }

  // Oturumu kapat
  Future<void> signOut() async {
    try {
      _log("Oturum kapatıldı");
      await Amplify.Auth.signOut();
    } catch (e) {
      print("Oturum kapatma hatası: $e");
      rethrow;
    }
  }
}