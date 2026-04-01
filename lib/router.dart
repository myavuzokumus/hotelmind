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
      // Dashboard access control
      if (state.matchedLocation == '/dashboard' && (!isAuthenticated || roomId == null || sessionId == null)) {
        return '/';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // Determine tab index from URL
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

          // Track tab change and update URL
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

            // Update if URL is not already the same
            if (state.matchedLocation != newLocation) {
              context.go(newLocation);
            }
          });

          // Return AppScaffold with initial tab index
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
              child: Container(), // Managed within AppScaffold
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Container(), // Managed within AppScaffold
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: '/admin_login',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Container(), // Managed within AppScaffold
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
                    message: 'A valid room and session information is required to access this page.'
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