import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmind/models/ResponseModel.dart';
import 'package:hotelmind/services/debug_log_provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../services/auth_service.dart';
import '../services/navigation_service.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  String _message = "Please Scan QR Code";
  bool _isAuthorized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    const Text(
                      'Room Access',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 4,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan the QR code to access the room',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 24, // horizontal spacing
                  runSpacing: 32, // vertical spacing
                  alignment: WrapAlignment.center,
                  children: [
                    // QR Scanner section
                    Container(
                      constraints: const BoxConstraints(maxWidth: 512),
                      width: 512,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // QR Scanning / Processing / Result section
                              Container(
                                height: 480,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _isProcessing
                                      ? _buildProcessingView()
                                      : (_isAuthorized
                                      ? _buildAuthorizedView()
                                      : (_hasError)
                                      ? _buildErrorView()
                                      : _buildQRView()),
                                ),
                              ),

                              // Camera controls
                              if (!_hasError &&
                                  !_isAuthorized &&
                                  !_isProcessing)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: _buildCameraControls(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer area
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      width: 400,
                      padding: const EdgeInsets.all(24),
                      color: Colors.grey.shade100,
                      child: Column(
                        children: [
                          const Text(
                            'How Does QR Code Work?',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoItem(
                            icon: Icons.qr_code,
                            title: 'Find QR Code',
                            description: 'Find the QR code on the room door or provided by the reception',
                          ),
                          _buildInfoItem(
                            icon: Icons.mobile_screen_share,
                            title: 'Scan QR Code',
                            description: 'Hold your camera over the QR code to scan',
                          ),
                          _buildInfoItem(
                            icon: Icons.lock_open,
                            title: 'Gain Access',
                            description: 'After the QR code is verified, you will gain access to room controls',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// QR scanning view
  Widget _buildQRView() {
    return Stack(
      children: [
        // Camera view
        OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 1000,
              height: 1000,
              child: QRView(
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
          ),
        ),

        // Status message - at the bottom of the screen
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withValues(alpha:0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _isAuthorized
                      ? Icons.check_circle
                      : _isProcessing
                      ? Icons.hourglass_top
                      : Icons.qr_code_scanner,
                  color: _isAuthorized
                      ? Colors.green
                      : _isProcessing
                      ? Colors.orange
                      : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _message,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Processing view
  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            _message,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Authorized view
  Widget _buildAuthorizedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _message,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Error view
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 2),
            ),
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _message,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () {
              // Let's reset the scanner instead of redirecting to home page
              setState(() {
                _isProcessing = false;
                _isAuthorized = false;
                _hasError = false;
                _message = "Please Scan QR Code";
              });

            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Camera control buttons
  Widget _buildCameraControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              if (controller != null) {
                controller!.flipCamera();
              }
            },
            icon: const Icon(Icons.flip_camera_ios),
            label: const Text('Switch Camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _hasError = false;
        _message = "Processing QR Code...";
      });
    }

    try {
      final authService = ref.read(authServiceProvider);

      // Developer mode check
      final isDeveloperMode = ref.read(developerModeProvider);
      if (isDeveloperMode) {
        // Skip QR verification in developer mode
        ref.read(debugLogProvider.notifier).log("QR code verification skipped in developer mode: $qrData");

        Map<String, dynamic>? parsedData = authService.parseQrData(qrData);
        if (parsedData != null) {
          _showSuccessAndNavigate(parsedData);
        } else {
          setState(() {
            _isProcessing = false;
            _hasError = true;
            _message = "Invalid QR Code format.";
          });
        }
      } else {
        // Normal mode QR verification
        ResponseModel<Map<String, dynamic>> result = await authService.verifyQRCode(qrData);

        if (result.success) {
          _showSuccessAndNavigate(result.data!);
        } else {
          // Show error message
          setState(() {
            _isProcessing = false;
            _hasError = true;
            _message = result.error ?? "An unknown error occurred.";
          });
        }
      }
    } catch (e) {
      String userFriendlyError;

      if (e is UnimplementedError) {
        userFriendlyError = "Attempted to use an incomplete feature";
      } else if (e.toString().contains("network")) {
        userFriendlyError = "Network connection error. Please check your internet connection";
      } else if (e.toString().contains("permission")) {
        userFriendlyError = "Camera access permission is required";
      } else if (e.toString().contains("timeout")) {
        userFriendlyError = "Server is not responding. Please try again";
      } else {
        userFriendlyError = "QR code scanning error";
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _message = userFriendlyError;
          _hasError = true;
        });
      }

      ref.read(debugLogProvider.notifier).log("QR processing error: $userFriendlyError");
    }
  }

// Helper method for successful operation
  void _showSuccessAndNavigate(Map<String, dynamic> parsedData) async {
    String roomId = parsedData['roomId'];
    String sessionId = parsedData['sessionId'];

    // First show that it's authorized
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isAuthorized = true;
        _message = "Authorization Successful! Room access granted.";
      });
    }

    // Wait 2 seconds and then switch to control panel
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Update state with NavigationService
      ref.read(navigationServiceProvider).updateAuthState(
        isAuthenticated: true,
        roomId: roomId,
        sessionId: sessionId,
      );
    }
  }
}