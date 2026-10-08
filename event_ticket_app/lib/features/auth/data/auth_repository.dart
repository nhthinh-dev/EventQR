import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/errors/app_exception.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
      ref.watch(dioProvider),
      ref.watch(tokenStorageProvider),
      ref,
    ));

class AuthRepository {
  final Dio _dio;
  final TokenStorage _storage;
  final Ref _ref;

  AuthRepository(this._dio, this._storage, this._ref);

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final token = response.data['token'] as String;
      final role = response.data['role'] as String;
      
      await _storage.save(token); 
      await _storage.saveRole(role);
      
      AuthRole authRole = AuthRole.user;
      if (role == 'ORGANIZER') authRole = AuthRole.organizer;
      if (role == 'ADMIN') authRole = AuthRole.admin;

      _ref.read(authStateProvider.notifier).setRole(authRole); 
      
      return response.data['name'] as String; 
    } on DioException catch (e) {
      throw AppException.fromDio(e); 
    }
  }

  Future<void> register(String name, String email, String password, String phone, String dob) async {
    try {
      await _dio.post('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'dob': dob,
      });
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
