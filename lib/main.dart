import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'amplify_outputs.dart';
import 'screens/dashboard_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SmartRoomApp());
}

class SmartRoomApp extends StatefulWidget {
  const SmartRoomApp({super.key});

  @override
  State<SmartRoomApp> createState() => _SmartRoomAppState();
}

class _SmartRoomAppState extends State<SmartRoomApp> {
  bool _amplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      // Amplify plugins
      final authPlugin = AmplifyAuthCognito();
      final apiPlugin = AmplifyAPI();

      // Add plugins to Amplify
      await Amplify.addPlugins([authPlugin, apiPlugin]);

      // Configure Amplify with the configuration from amplify_outputs.dart
      await Amplify.configure(amplifyConfig);

      // Önemli: State'i güncelleyin, yoksa uygulama hep loading ekranında kalır
      setState(() {
        _amplifyConfigured = true;
      });

      print("Amplify configured successfully");
    } catch (e) {
      print("Error configuring Amplify: $e");

      // Hata durumlarında da state'i güncelliyoruz, hata mesajı gösterebiliriz
      setState(() {
        _amplifyConfigured = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Room Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _amplifyConfigured
          ? QRScannerScreen()
          : Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Amplify yapılandırılıyor...'),
            ],
          ),
        ),
      ),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}