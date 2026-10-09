import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../events/data/models/event_response.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository(ref.watch(dioProvider)));

class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get('/api/admin/users');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> createUser(String name, String email, String password, String role) async {
    try {
      await _dio.post('/api/admin/users', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<EventResponse>> getEvents() async {
    try {
      final response = await _dio.get('/api/events');
      final content = response.data['content'] as List;
      return content.map((e) => EventResponse.fromJson(e)).toList();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> deleteEvent(int eventId) async {
    try {
      await _dio.delete('/api/events/$eventId');
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> createEvent(Map<String, dynamic> request) async {
    try {
      await _dio.post('/api/events', data: request);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> updateEvent(int id, Map<String, dynamic> request) async {
    try {
      await _dio.put('/api/events/$id', data: request);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<dynamic>> getCheckIns(int page, int size) async {
    try {
      final response = await _dio.get('/api/admin/check-ins?page=$page&size=$size');
      return response.data['content'] as List<dynamic>;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> toggleUserLock(int id) async {
    try {
      await _dio.post('/api/admin/users/$id/toggle-lock');
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<String> uploadImage(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final response = await _dio.post('/api/admin/upload-image', data: formData);
      return response.data['imageUrl'] as String;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

}