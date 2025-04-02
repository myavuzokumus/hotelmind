import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmind/app_scaffold.dart';
import 'package:hotelmind/router.dart';

class NavigationService {
  final Ref ref;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigationService(this.ref);

  void updateAuthState({
    required bool isAuthenticated,
    String? roomId,
    String? sessionId
  }) {
    ref.read(isAuthenticatedProvider.notifier).state = isAuthenticated;

    if (roomId != null) {
      ref.read(roomIdProvider.notifier).state = roomId;
    }

    if (sessionId != null) {
      ref.read(sessionIdProvider.notifier).state = sessionId;
    }

    // Panel sayfasına geçiş yap
    if (isAuthenticated) {
      navigateToDashboard();
    }
  }

  void navigateToHome() {
    ref.read(selectedTabIndexProvider.notifier).state = 0;
    final router = ref.read(routerProvider);
    router.go('/');
  }

  void navigateToQRScanner() {
    ref.read(selectedTabIndexProvider.notifier).state = 1;
    final router = ref.read(routerProvider);
    router.go('/qr_scanner');
  }

  void navigateToDashboard() {
    ref.read(selectedTabIndexProvider.notifier).state = 2;
    final router = ref.read(routerProvider);
    router.go('/dashboard');
  }

  void navigateByIndex(int index) {
    String location;
    switch (index) {
      case 1:
        location = '/qr_scanner';
        break;
      case 2:
        location = '/dashboard';
        break;
      case 3:
        location = '/admin_login';
        break;
      default:
        location = '/';
    }

    ref.read(selectedTabIndexProvider.notifier).state = index;
    final router = ref.read(routerProvider);
    router.go(location);
  }

}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});