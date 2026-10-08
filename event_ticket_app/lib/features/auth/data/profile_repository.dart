import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository(ref.watch(dioProvider)));

final profileFutureProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(profileRepositoryProvider).getMyProfile();
});

class ProfileRepository {
  final Dio _dio;
  ProfileRepository(this._dio);

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _dio.get('/api/users/me');
    return response.data;
  }

  Future<void> updateProfile(String name, String phone, String dob) async {
    await _dio.put('/api/users/me', data: {
      'name': name,
      'phone': phone,
      'dob': dob,
    });
  }
}
