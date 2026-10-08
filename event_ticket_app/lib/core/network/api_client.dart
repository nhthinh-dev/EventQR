import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

// Enum quy định các loại tài khoản
enum AuthRole { guest, user, organizer, admin }

class AuthStateNotifier extends Notifier<AuthRole> {
  @override
  AuthRole build() => AuthRole.guest;
  
  void setRole(AuthRole role) {
    state = role;
  }
}

final authStateProvider = NotifierProvider<AuthStateNotifier, AuthRole>(() {
  return AuthStateNotifier();
});

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await storage.read();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        await storage.clear();
        // Đăng xuất ngay lập tức
        ref.read(authStateProvider.notifier).setRole(AuthRole.guest);
      }
      handler.next(error);
    },
  ));
  
  return dio;
});
