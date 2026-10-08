import 'package:flutter/foundation.dart';

class AppConfig {
  // Tự động nhận diện: Nếu chạy trên Web thì dùng localhost, nếu chạy trên điện thoại ảo thì dùng 10.0.2.2
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    return 'http://10.0.2.2:8080';
  }
}
