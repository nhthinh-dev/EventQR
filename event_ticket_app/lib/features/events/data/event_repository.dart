import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/event_response.dart';

// Provider cung cấp Repository
final eventRepositoryProvider = Provider((ref) => EventRepository(ref.watch(dioProvider)));

// Provider gọi API và quản lý trạng thái Tải/Lỗi/Thành công (tự động dọn rác khi đóng màn hình)
final eventListFutureProvider = FutureProvider.autoDispose<List<EventResponse>>((ref) async {
  return ref.read(eventRepositoryProvider).getEvents(upcoming: false);
});

class EventRepository {
  final Dio _dio;
  EventRepository(this._dio);

  Future<List<EventResponse>> getEvents({bool upcoming = false}) async {
    final response = await _dio.get('/api/events?upcoming=$upcoming');
    
    // Backend trả về PageResponse, dữ liệu nằm trong mảng 'content'
    final List content = response.data['content'];
    return content.map((e) => EventResponse.fromJson(e)).toList();
  }

  // Chức năng Đăng ký sự kiện
  Future<void> bookEvent(int eventId) async {
    try {
      await _dio.post('/api/events/$eventId/book');
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw Exception(data['message'] ?? 'Lỗi khi đăng ký sự kiện');
      }
      throw Exception('Không thể kết nối đến máy chủ.');
    }
  }
}
