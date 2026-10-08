import 'package:dio/dio.dart';

class AppException implements Exception {
  final String code;
  final String message;

  AppException(this.code, this.message);

  factory AppException.fromDio(DioException e) {
    final noResponse = e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
    
    if (noResponse) {
      return AppException('NETWORK_ERROR', 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet.');
    }

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return AppException(
        (data['errorCode'] as String?) ?? 'UNKNOWN',
        (data['message'] as String?) ?? 'Đã có lỗi xảy ra.',
      );
    }
    
    return AppException('UNKNOWN', 'Đã có lỗi xảy ra. Vui lòng thử lại.');
  }

  @override
  String toString() => message;
}
