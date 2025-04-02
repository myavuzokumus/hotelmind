import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmind/screens/admin_login_screen.dart';
import 'package:hotelmind/screens/dashboard_screen.dart';
import 'package:hotelmind/screens/home_screen.dart';
import 'package:hotelmind/screens/qr_scanner_screen.dart';
import 'package:hotelmind/widgets/developer_drawer.dart';

// Providers aynen kalıyor
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);
final roomIdProvider = StateProvider<String?>((ref) => null);
final sessionIdProvider = StateProvider<String?>((ref) => null);
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);
// QR Scanner için lazy loading kontrolü
final qrScannerLoadedProvider = StateProvider<bool>((ref) => false);

class AppScaffold extends ConsumerStatefulWidget {
  final int? initialTab;

  const AppScaffold({super.key, this.initialTab});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> with WidgetsBindingObserver {
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _screens.add(const HomeScreen());
    _screens.add(_buildQRPlaceholder()); // QR için başlangıçta yer tutucu
    _screens.add(Container()); // Dashboard için yer tutucu, dinamik güncellenir
    _screens.add(const AdminLoginScreen());

    // initialTab varsa, onu seç
    if (widget.initialTab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedTabIndexProvider.notifier).state = widget.initialTab!;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // QR tarayıcı için yer tutucu widget
  Widget _buildQRPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('QR tarayıcı hazırlanıyor...',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showDeveloperConsole() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DeveloperConsoleSheet(),
    );
  }

  void _updateTabIndex(int index) {
    final oldIndex = ref.read(selectedTabIndexProvider);
    ref.read(selectedTabIndexProvider.notifier).state = index;

    // QR Scanner'dan başka bir tab'a geçildiğinde, QR Scanner'ı temizle
    if (oldIndex == 1 && index != 1 && ref.read(qrScannerLoadedProvider)) {
      setState(() {
        _screens[1] = _buildQRPlaceholder();
        ref.read(qrScannerLoadedProvider.notifier).state = false;
      });
    }

    // QR Scanner tab'ını seçtiğimizde QR Scanner'ı yükle
    if (index == 1) {
      _loadQRScanner();
    }
  }

  void _loadQRScanner() {
    final qrLoaded = ref.read(qrScannerLoadedProvider);

    // QR Scanner henüz yüklenmediyse, yükle
    if (!qrLoaded) {
      setState(() {
        _screens[1] = const QRScannerScreen(key: ValueKey('qrscreen'));
      });

      Future.microtask(() {
        ref.read(qrScannerLoadedProvider.notifier).state = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Eğer uygulama arka plana alındı veya ekran değiştiğinde
    final selectedIndex = ref.read(selectedTabIndexProvider);
    if (selectedIndex != 1 && ref.read(qrScannerLoadedProvider)) {
      // QR tarayıcıyı resetleyin
      setState(() {
        _screens[1] = _buildQRPlaceholder();
        ref.read(qrScannerLoadedProvider.notifier).state = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final roomId = ref.watch(roomIdProvider);
    final sessionId = ref.watch(sessionIdProvider);
    final selectedIndex = ref.watch(selectedTabIndexProvider);

    // Kullanıcı giriş yaptıysa, dashboard ekranını güncelle
    if (isAuthenticated && roomId != null && sessionId != null) {
      // Dashboard'u yalnızca değişiklik olduğunda güncelle
      if (_screens[2] is! DashboardScreen ||
          (_screens[2] as DashboardScreen).roomId != roomId ||
          (_screens[2] as DashboardScreen).sessionId != sessionId) {
        _screens[2] = DashboardScreen(roomId: roomId, sessionId: sessionId);
      }
    } else {
      // Boş container kalsın, bu sekme kullanılmayacak
      _screens[2] = Container();
    }

    // Eğer şu anda QR sekmesindeyse ve QR henüz yüklenmemişse, yükle
    if (selectedIndex == 1 && !ref.read(qrScannerLoadedProvider)) {
      _loadQRScanner();
    }

    return Scaffold(
      bottomNavigationBar: Container(
        height: 40,
        color: Colors.grey[200],
        child: InkWell(
          onTap: _showDeveloperConsole,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.code, size: 16),
              const SizedBox(width: 8),
              Text(
                'Geliştirici Konsolu',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          // NavigationRail
          NavigationRail(
            selectedIndex: selectedIndex == 2 && isAuthenticated ? 1 : (selectedIndex < 2 ? selectedIndex : null),
            onDestinationSelected: (int index) {
              // Oturum durumuna göre index belirle
              if (index == 1 && isAuthenticated) {
                _updateTabIndex(2); // Dashboard'a git
              } else {
                _updateTabIndex(index);
              }
            },
            labelType: NavigationRailLabelType.selected,
            // Logo üstte
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Image(
                          image: AssetImage('assets/icon/hotelmind_logo.png')
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 24,
                    height: 2,
                    color: Colors.blue.shade200,
                  ),
                ],
              ),
            ),
            // Admin butonu en altta
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 2,
                        color: Colors.blue.shade200,
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings),
                        color: selectedIndex == 3 ? Colors.blue : null,
                        tooltip: 'Yetkili Girişi',
                        onPressed: () {
                          _updateTabIndex(3);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: [
              // Ana Sayfa butonu
              const NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Ana Sayfa'),
              ),
              // Kullanıcı durumuna göre QR veya Panel butonu
              NavigationRailDestination(
                icon: Icon(isAuthenticated ? Icons.dashboard_outlined : Icons.qr_code_scanner_outlined),
                selectedIcon: Icon(isAuthenticated ? Icons.dashboard : Icons.qr_code_scanner),
                label: Text(isAuthenticated ? 'Panel' : 'QR Tarayıcı'),
              ),
            ],
            extended: false,
          ),
          // Dikey çizgi
          const VerticalDivider(thickness: 1, width: 1),
          // Sayfa içeriği - IndexedStack sayesinde sayfalar hafızada kalır
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}
