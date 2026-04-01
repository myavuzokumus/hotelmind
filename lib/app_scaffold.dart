import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmind/screens/admin_login_screen.dart';
import 'package:hotelmind/screens/dashboard_screen.dart';
import 'package:hotelmind/screens/home_screen.dart';
import 'package:hotelmind/screens/qr_scanner_screen.dart';
import 'package:hotelmind/widgets/developer_drawer.dart';

// Providers remain exactly the same
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);
final roomIdProvider = StateProvider<String?>((ref) => null);
final sessionIdProvider = StateProvider<String?>((ref) => null);
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);
// Lazy loading control for QR Scanner
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
    _screens.add(_buildQRPlaceholder()); // Placeholder for QR initially
    _screens.add(Container()); // Placeholder for Dashboard, dynamically updated
    _screens.add(const AdminLoginScreen());

    // If initialTab exists, select it
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

  // Placeholder widget for QR scanner
  Widget _buildQRPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('Preparing QR scanner...',
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

    // Clear QR Scanner when switching to a tab other than QR Scanner
    if (oldIndex == 1 && index != 1 && ref.read(qrScannerLoadedProvider)) {
      setState(() {
        _screens[1] = _buildQRPlaceholder();
        ref.read(qrScannerLoadedProvider.notifier).state = false;
      });
    }

    // Load QR Scanner when we select the QR Scanner tab
    if (index == 1) {
      _loadQRScanner();
    }
  }

  void _loadQRScanner() {
    final qrLoaded = ref.read(qrScannerLoadedProvider);

    // Load if QR Scanner is not yet loaded
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

    // If the app is sent to the background or screen changes
    final selectedIndex = ref.read(selectedTabIndexProvider);
    if (selectedIndex != 1 && ref.read(qrScannerLoadedProvider)) {
      // Reset the QR scanner
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // Threshold for Tablet/Desktop

    // Update the Dashboard screen
    if (isAuthenticated && roomId != null && sessionId != null) {
      if (_screens[2] is! DashboardScreen ||
          (_screens[2] as DashboardScreen).roomId != roomId ||
          (_screens[2] as DashboardScreen).sessionId != sessionId) {
        _screens[2] = DashboardScreen(roomId: roomId, sessionId: sessionId);
      }
    } else {
      _screens[2] = Container();
    }

    // Check the QR tab and load if necessary
    if (selectedIndex == 1 && !ref.read(qrScannerLoadedProvider)) {
      _loadQRScanner();
    }

    // Items for NavigationRail (large screen)
    final navigationRailItems = [
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Home'),
      ),
      NavigationRailDestination(
        icon: Icon(isAuthenticated ? Icons.dashboard_outlined : Icons.qr_code_scanner_outlined),
        selectedIcon: Icon(isAuthenticated ? Icons.dashboard : Icons.qr_code_scanner),
        label: Text(isAuthenticated ? 'Dashboard' : 'QR Scanner'),
      ),
    ];

    // Items for BottomNavigationBar (small screen)
    final bottomNavItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(isAuthenticated ? Icons.dashboard_outlined : Icons.qr_code_scanner_outlined),
        activeIcon: Icon(isAuthenticated ? Icons.dashboard : Icons.qr_code_scanner),
        label: isAuthenticated ? 'Dashboard' : 'QR Scanner',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings_outlined),
        activeIcon: Icon(Icons.admin_panel_settings),
        label: 'Admin',
      ),
    ];

    return Scaffold(
      // Add bottomNavigationBar for small screens
      bottomNavigationBar: !isLargeScreen
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            currentIndex: selectedIndex == 3 ? 2 : (selectedIndex == 2 && isAuthenticated ? 1 : selectedIndex),
            items: bottomNavItems,
            onTap: (index) {
              if (index == 2) {
                // Go to Admin screen
                _updateTabIndex(3);
              } else if (index == 1 && isAuthenticated) {
                // Go to Dashboard
                _updateTabIndex(2);
              } else {
                _updateTabIndex(index);
              }
            },
          ),
          // Developer console button
          Container(
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
                    'Developer Console',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : null,
      body: isLargeScreen
      // Large screen layout (NavigationRail)
          ? Row(
        children: [
          // NavigationRail
          NavigationRail(
            selectedIndex: selectedIndex == 2 && isAuthenticated ? 1 : (selectedIndex < 2 ? selectedIndex : null),
            onDestinationSelected: (int index) {
              if (index == 1 && isAuthenticated) {
                _updateTabIndex(2); // Go to Dashboard
              } else {
                _updateTabIndex(index);
              }
            },
            labelType: NavigationRailLabelType.selected,
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
                      child: Image(image: AssetImage('assets/icon/hotelmind_logo.png')),
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
                        tooltip: 'Admin Login',
                        onPressed: () {
                          _updateTabIndex(3);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: navigationRailItems,
            extended: false,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Stack(
              children: [
                IndexedStack(
                  index: selectedIndex,
                  children: _screens,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
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
                            'Developer Console',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
      // Narrow screen layout (Content only)
          : IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
    );
  }
}
