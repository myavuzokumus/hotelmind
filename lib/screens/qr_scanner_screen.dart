import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../services/auth_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  String _message = "Lütfen QR Kodu Taratın";
  bool _isAuthorized = false;

  final AuthService _authService = AuthService();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oda Erişimi'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: _isProcessing || _isAuthorized
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing) CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    _message,
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  if (_isAuthorized)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                      child: Text('Oda Yönetimine Git'),
                    ),
                ],
              ),
            )
                : QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(_message),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && !_isAuthorized) {
        _processQRCode(scanData.code);
      }
    });
  }

  Future<void> _processQRCode(String? qrData) async {
    if (qrData == null) return;

    setState(() {
      _isProcessing = true;
      _message = "QR Kod İşleniyor...";
    });

    try {
      bool isValid = await _authService.verifyQRCode(qrData);

      setState(() {
        _isProcessing = false;
        if (isValid) {
          _isAuthorized = true;
          _message = "Yetkilendirme Başarılı! Oda erişimi sağlandı.";
          controller?.pauseCamera();
        } else {
          _message = "Geçersiz QR Kod. Lütfen tekrar deneyin.";
        }
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _message = "Hata oluştu: ${e.toString()}";
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}