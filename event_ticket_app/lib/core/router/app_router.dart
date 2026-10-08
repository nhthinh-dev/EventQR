import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/main_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/events/presentation/event_list_screen.dart';
import '../../features/events/presentation/event_detail_screen.dart';
import '../../features/events/data/models/event_response.dart';
import '../../features/organizer/presentation/organizer_home_screen.dart';
import '../../features/organizer/presentation/organizer_history_screen.dart';
import '../../features/organizer/presentation/qr_scanner_screen.dart';
import '../../features/organizer/presentation/checkin_result_screen.dart';
import '../../features/organizer/presentation/checkin_preview_screen.dart';
import '../network/api_client.dart';

import '../../features/auth/presentation/register_screen.dart';
import '../../features/admin/presentation/admin_home_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRole = ref.watch(authStateProvider);
  final isLoggedIn = authRole != AuthRole.guest;

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final path = state.uri.path;
      final isGoingToAuth = path == '/login' || path == '/register';
      
      if (!isLoggedIn) {
        return isGoingToAuth ? null : '/login';
      }
      
      if (isGoingToAuth || path == '/') {
        if (authRole == AuthRole.admin) return '/admin';
        if (authRole == AuthRole.organizer) return '/organizer';
        return '/home';
      }
      
      if (authRole == AuthRole.user && (path.startsWith('/organizer') || path.startsWith('/admin'))) return '/home';
      if (authRole == AuthRole.organizer && (path.startsWith('/home') || path.startsWith('/admin'))) return '/organizer';
      if (authRole == AuthRole.admin && (path.startsWith('/home') || path.startsWith('/organizer'))) return '/admin';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/home',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/events/detail',
        builder: (context, state) {
          final event = state.extra as EventResponse;
          return EventDetailScreen(event: event);
        },
      ),
      GoRoute(
        path: '/organizer',
        builder: (context, state) => const OrganizerHomeScreen(),
      ),
      GoRoute(
        path: '/organizer/history',
        builder: (context, state) => const OrganizerHistoryScreen(),
      ),
      GoRoute(
        path: '/organizer/scan',
        builder: (context, state) {
          final eventId = state.extra as int;
          return QRScannerScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/organizer/preview',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CheckInPreviewScreen(
            eventId: data['eventId'],
            ticketCode: data['ticketCode'],
          );
        },
      ),
      GoRoute(
        path: '/organizer/result',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CheckInResultScreen(
            eventId: data['eventId'],
            ticketCode: data['ticketCode'],
            attendeeName: data['attendeeName'],
            eventTitle: data['eventTitle'],
          );
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
      ),
    ],
  );
});
