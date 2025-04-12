import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmind/app_scaffold.dart';
import 'package:hotelmind/screens/home_screen.dart';
import 'package:hotelmind/screens/settings_screen.dart';
import 'package:hotelmind/screens/not_found_screen.dart';

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final roomId = ref.watch(roomIdProvider);
  final sessionId = ref.watch(sessionIdProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Dashboard'a erişim kontrolü
      if (state.matchedLocation == '/dashboard' && (!isAuthenticated || roomId == null || sessionId == null)) {
        return '/';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // URL'den tab indeksini belirle
          int initialTabIndex;
          switch (state.matchedLocation) {
            case '/qr_scanner':
              initialTabIndex = 1;
              break;
            case '/dashboard':
              initialTabIndex = 2;
              break;
            case '/admin_login':
              initialTabIndex = 3;
              break;
            default:
              initialTabIndex = 0;
          }

          // Tab değişimini takip et ve URL'yi güncelle
          ref.listen(selectedTabIndexProvider, (previous, next) {
            String newLocation;
            switch (next) {
              case 1:
                newLocation = '/qr_scanner';
                break;
              case 2:
                newLocation = '/dashboard';
                break;
              case 3:
                newLocation = '/admin_login';
                break;
              default:
                newLocation = '/';
            }

            // Eğer URL zaten aynı değilse güncelle
            if (state.matchedLocation != newLocation) {
              context.go(newLocation);
            }
          });

          // AppScaffold'u başlangıç tab indeksiyle döndür
          return AppScaffold(initialTab: initialTabIndex);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => NoTransitionPage(
              child: HomeScreen(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: '/qr_scanner',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Container(), // AppScaffold içinde yönetiliyor
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Container(), // AppScaffold içinde yönetiliyor
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: '/admin_login',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Container(), // AppScaffold içinde yönetiliyor
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId'];
              final sessionId = state.pathParameters['sessionId'];

              if (roomId == null || sessionId == null) {
                return NotFoundScreen(
                    message: 'Bu sayfaya erişmek için geçerli bir oda ve oturum bilgisi gereklidir.'
                );
              }

              return SettingsScreen(roomId: roomId, sessionId: sessionId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/not_found',
        builder: (context, state) => NotFoundScreen(),
      ),
    ],
    errorBuilder: (context, state) => NotFoundScreen(),
  );
});