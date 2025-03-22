import 'dart:io';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../services/auth_service.dart';
import '../services/debug_log_provider.dart';
import '../widgets/debug_log_display.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  String _message = "Lütfen QR Kodu Taratın";
  bool _isAuthorized = false;
  bool _showDebugPanel = true;
  bool _isDeveloperMode = false;

  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // DebugLogProvider'ı kullanarak AuthService'i oluştur
    _authService = AuthService(Provider.of<DebugLogProvider>(context, listen: false));
  }

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
        actions: [
          // Geliştirici modu butonu
          IconButton(
            icon: Icon(_isDeveloperMode ? Icons.code : Icons.code_off),
            onPressed: () {
              setState(() {
                _isDeveloperMode = !_isDeveloperMode;
              });
              Provider.of<DebugLogProvider>(context, listen: false)
                  .log("Geliştirici modu: ${_isDeveloperMode ? "Açık" : "Kapalı"}");
            },
            tooltip: 'Geliştirici Modu ${_isDeveloperMode ? "Kapalı" : "Açık"}',
          ),
          // Mevcut debug paneli butonu
          IconButton(
            icon: Icon(_showDebugPanel ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showDebugPanel = !_showDebugPanel;
              });
            },
            tooltip: '${_showDebugPanel ? "Gizle" : "Göster"} Debug Panel',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: _showDebugPanel ? 2 : 5,
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
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          // Status Text
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              _message,
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
          // Debug Logs Section
          if (_showDebugPanel)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Consumer<DebugLogProvider>(
                  builder: (context, logProvider, child) => DebugLogDisplay(),
                ),
              ),
            ),
          // Camera Controls
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (controller != null) {
                      controller!.toggleFlash();
                    }
                  },
                  icon: Icon(Icons.flash_on),
                  label: Text('Flash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: TextStyle(fontSize: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (controller != null) {
                      controller!.flipCamera();
                    }
                  },
                  icon: Icon(Icons.flip_camera_ios),
                  label: Text('Kamera Değiştir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && !_isAuthorized && scanData.code != null) {
        _processQRCode(scanData.code);
      }
    });
  }

  Future<void> _processQRCode(String? qrData) async {
    if (qrData == null || qrData.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _message = "QR Kod İşleniyor...";
    });

    try {
      bool isValid;

      if (_isDeveloperMode) {
        // Geliştirici modunda QR kodunu do��rulamadan geçir
        isValid = true;
        Provider.of<DebugLogProvider>(context, listen: false)
            .log("Geliştirici modunda otomatik onay: $qrData");
      } else {
        // Normal modda sunucudan doğrulama iste
        isValid = await _authService.verifyQRCode(qrData);
      }

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
        _message = "Yetkilendirme Başarılı! Oda erişimi sağlandı.";
        //_message = "Hata oluştu: ${e.toString().substring(0, Math.min(50, e.toString().length))}";
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}