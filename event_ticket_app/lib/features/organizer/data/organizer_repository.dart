import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/organizer_event_response.dart';

final organizerRepositoryProvider = Provider((ref) => OrganizerRepository(ref.watch(dioProvider)));

final organizerEventsFutureProvider = FutureProvider.autoDispose<List<OrganizerEventResponse>>((ref) async {
  return ref.read(organizerRepositoryProvider).getMyEvents();
});

final recentCheckInsFutureProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return ref.read(organizerRepositoryProvider).getRecentCheckIns();
});

class OrganizerRepository {
  final Dio _dio;
  OrganizerRepository(this._dio);

  Future<List<OrganizerEventResponse>> getMyEvents() async {
    final response = await _dio.get('/api/organizer/events');
    final List content = response.data;
    return content.map((e) => OrganizerEventResponse.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> checkIn(int eventId, String ticketCode) async {
    try {
      final response = await _dio.post('/api/check-ins', data: {
        'eventId': eventId,
        'ticketCode': ticketCode,
      });
      return response.data as Map<String, dynamic>; 
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw Exception(data['message'] ?? 'Lỗi khi check-in');
      }
      throw Exception('Không thể kết nối đến máy chủ.');
    }
  }

  Future<Map<String, dynamic>> verifyTicket(String code, int eventId) async {
    try {
      final response = await _dio.get('/api/tickets/verify?code=$code&eventId=$eventId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw Exception(data['message'] ?? 'Lỗi xác thực vé');
      }
      throw Exception('Không thể kết nối đến máy chủ.');
    }
  }

  Future<Map<String, dynamic>> checkInWithPhoto(int eventId, String ticketCode, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(imagePath, filename: 'photo.jpg'),
      });
      final response = await _dio.post(
        '/api/check-ins/with-photo?ticketCode=$ticketCode&eventId=$eventId',
        data: formData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw Exception(data['message'] ?? 'Lỗi khi check-in');
      }
      throw Exception('Không thể kết nối đến máy chủ.');
    }
  }

  Future<List<dynamic>> getRecentCheckIns() async {
    try {
      final response = await _dio.get('/api/organizer/check-ins/recent');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception('Không thể tải lịch sử check-in.');
    }
  }
}
