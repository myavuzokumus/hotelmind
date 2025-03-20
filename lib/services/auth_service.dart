import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:amplify_api/amplify_api.dart';

class AuthService {
  // QR kodu doğrula
  Future<bool> verifyQRCode(String qrData) async {
    try {
      // QR verilerini ayrıştır
      final decodedData = _parseQRData(qrData);

      if (decodedData == null) {
        return false;
      }

      // QR kod doğrulama API'sini çağır
      final restOperation = Amplify.API.post(
          '/verify-qr',
          body: HttpPayload.json({
            'qrCode': qrData,
            'roomId': decodedData['roomId'],
            'timestamp': decodedData['timestamp'],
            'signature': decodedData['signature']
          })
      );

      final response = await restOperation.response;

      if (response.statusCode == 200) {
        // Stream'den gelen tüm byte'ları topla
        final bodyBytes = await response.body.toList().then((chunks) =>
            chunks.expand((chunk) => chunk).toList());

        // Byte listesini String'e dönüştür ve JSON olarak çöz
        final data = json.decode(utf8.decode(bodyBytes));

        if (data['isValid'] == true) {
          // Başarılı doğrulamadan sonra kullanıcı oturumunu başlat
          await _signIn(decodedData['roomId']);
          return true;
        }
      }

      return false;
    } catch (e) {
      print("QR kod doğrulama hatası: $e");
      return false;
    }
  }

  // QR kod verilerini ayrıştır
  Map<String, dynamic>? _parseQRData(String qrData) {
    try {
      if (qrData.startsWith('{')) {
        // JSON formatı
        return json.decode(qrData);
      } else {
        // Basit metin formatı
        final parts = qrData.split(':');

        if (parts.length >= 3) {
          return {
            'roomId': parts[0],
            'timestamp': int.tryParse(parts[1]) ?? 0,
            'signature': parts[2]
          };
        }
      }

      return null;
    } catch (e) {
      print("QR veri ayrıştırma hatası: $e");
      return null;
    }
  }

  // Kullanıcı oturumu başlat
  Future<void> _signIn(String roomId) async {
    try {
      // Amplify v2 sign-in
      final signInResult = await Amplify.Auth.signIn(
          username: "guest_$roomId",
          password: _generateTemporaryPassword(roomId)
      );

      if (!signInResult.isSignedIn) {
        // Kullanıcı yoksa kaydol ve tekrar oturum aç
        await _signUp(roomId);
        await Amplify.Auth.signIn(
            username: "guest_$roomId",
            password: _generateTemporaryPassword(roomId)
        );
      }
    } catch (e) {
      print("Oturum açma hatası: $e");
      // Kullanıcı yoksa kaydol ve tekrar oturum aç
      if (e is UserNotFoundException) {
        await _signUp(roomId);
        await Amplify.Auth.signIn(
            username: "guest_$roomId",
            password: _generateTemporaryPassword(roomId)
        );
      } else {
        rethrow;
      }
    }
  }

  // Yeni kullanıcı kaydı oluştur
  Future<void> _signUp(String roomId) async {
    try {
      // Amplify v2 sign-up
      final signUpResult = await Amplify.Auth.signUp(
          username: "guest_$roomId",
          password: _generateTemporaryPassword(roomId),
          options: SignUpOptions(
              userAttributes: {
                AuthUserAttributeKey.email: "guest_$roomId@example.com",
                CognitoUserAttributeKey.custom('room_id'): roomId
              }
          )
      );

    } catch (e) {
      print("Kayıt hatası: $e");
      rethrow;
    }
  }

  // Odaya özel geçici şifre oluştur
  String _generateTemporaryPassword(String roomId) {
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final secretKey = "SmartRoom2025Secret";

    final data = utf8.encode('$roomId:$today:$secretKey');
    final digest = sha256.convert(data);

    return digest.toString().substring(0, 12) + "Aa1!";
  }

  // Oturum durumunu kontrol et
  Future<bool> isSignedIn() async {
    try {
      // Amplify v2
      final result = await Amplify.Auth.fetchAuthSession();
      return result.isSignedIn;
    } catch (e) {
      print("Oturum durumu kontrolü hatası: $e");
      return false;
    }
  }

  // Oturumu kapat
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      print("Oturum kapatma hatası: $e");
      rethrow;
    }
  }
}