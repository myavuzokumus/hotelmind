import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hotelmind/services/debug_log_provider.dart';
import 'package:hotelmind/widgets/debug_log_display.dart';
import 'package:provider/provider.dart';

import 'amplify_outputs.dart';
import 'screens/dashboard_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DebugLogProvider()),
      ],
      child: SmartRoomApp(),
    ),
  );
}

class SmartRoomApp extends StatefulWidget {
  @override
  _SmartRoomAppState createState() => _SmartRoomAppState();
}

class _SmartRoomAppState extends State<SmartRoomApp> {
  bool _amplifyConfigured = false;
  bool _configuring = true;
  String _configError = '';

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

      // Configure Amplify
      await Amplify.configure(amplifyConfig);

      setState(() {
        _amplifyConfigured = true;
        _configuring = false;
      });

      // Provider'a widget ağacı kurulduktan sonra eriş
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final debugLogger = Provider.of<DebugLogProvider>(context, listen: false);
        debugLogger.log("Amplify başarıyla yapılandırıldı");
      });

    } catch (e) {
      setState(() {
        _configuring = false;
        _configError = e.toString();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final debugLogger = Provider.of<DebugLogProvider>(context, listen: false);
        debugLogger.log("Amplify yapılandırma hatası: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Room Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _configuring
          ? _buildLoadingScreen()
          : _amplifyConfigured
          ? QRScannerScreen()
          : _buildErrorScreen(),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Uygulama hazırlanıyor..."),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              SizedBox(height: 20),
              Text(
                "Hata: Uygulama başlatılamadı",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                _configError,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Consumer<DebugLogProvider>(
                builder: (context, logProvider, child) => DebugLogDisplay(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _configureAmplify(),
                child: Text("Yeniden Dene"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}