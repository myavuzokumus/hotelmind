import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmind/app_scaffold.dart';
import 'package:hotelmind/services/navigation_service.dart';
import 'package:hotelmind/widgets/developer_drawer.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  void _showDeveloperConsole() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeveloperConsoleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero section
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade200, Colors.white],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Akıllı Oda Yönetimi',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Versiyon: $_appVersion (Build: $_buildNumber)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.watch(isAuthenticatedProvider)
                            ? ref.read(navigationServiceProvider).navigateToDashboard()
                            : ref.read(navigationServiceProvider).navigateToQRScanner();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      icon: Icon(ref.watch(isAuthenticatedProvider) ? Icons.dashboard : Icons.qr_code_scanner),
                      label: Text(ref.watch(isAuthenticatedProvider) ? 'Yönetim Paneline Git' : 'QR Kod ile Oda Girişi'),
                    ),
                  ],
                ),
              ),
            ),

            // Features Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Sistem Özellikleri',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    runAlignment: WrapAlignment.spaceEvenly,
                    spacing: 20,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.meeting_room,
                        title: 'Akıllı Oda Kontrolü',
                        description: 'Oda içindeki tüm sistemleri tek noktadan yönetin.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.sensors,
                        title: 'Canlı Sensör Takibi',
                        description: 'Sıcaklık, nem ve hava kalitesini gerçek zamanlı izleyin.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.history,
                        title: 'Olay Geçmişi',
                        description: 'Odada gerçekleşen tüm olayları takip edin.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.analytics,
                        title: 'Yapay Zeka',
                        description: 'Alışkanlıklarınıza göre odanızı optimize edin.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}