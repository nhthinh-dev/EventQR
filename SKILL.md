---
name: event-ticket-qr-checkin
description: Hướng dẫn xây dựng hệ thống đặt vé sự kiện và check-in bằng mã QR gồm app Flutter (Dart), backend Spring Boot (Java 17) và MySQL 8. Dùng khi viết, sửa, review hoặc debug bất kỳ phần nào của dự án "Event Ticket & QR Check-in": entity/API Spring Boot, JWT, đăng ký sự kiện (booking), sinh vé, hiển thị và quét QR, check-in, màn hình Flutter, Riverpod, go_router, Dio, schema MySQL.
---

# Event Ticket & QR Check-in — Skill cho AI coding tool

Nguồn: *Đặc tả chi tiết Event Ticket & QR Check-in (Flutter) v2.0*. File này là bản rút gọn dạng chỉ dẫn để viết code đúng đặc tả. Khi có mâu thuẫn giữa file này và code sẵn có trong repo, **hỏi người dùng** thay vì tự đoán.

## 1. Tổng quan

Người dùng đăng ký sự kiện → hệ thống cấp vé (`ticket_code`) → app hiển thị vé dạng QR → Organizer quét QR → backend xác thực và check-in.

```
Đăng ký → Booking → Ticket (ticket_code) → QR → Quét → POST /api/check-ins → VALID → CHECKED_IN
```

| Tầng | Công nghệ |
|---|---|
| Mobile | Flutter, Dart, flutter_riverpod, go_router, dio, flutter_secure_storage, qr_flutter, mobile_scanner, intl, cached_network_image |
| Backend | Java 17+, Spring Boot 3.x, Spring Web, Spring Security (stateless), jjwt, Spring Data JPA/Hibernate, Bean Validation, Lombok, Maven |
| DB | MySQL 8 (schema do `schema.sql` quản lý, không dùng Hibernate tự tạo bảng) |

Vai trò: `USER` (mặc định khi đăng ký), `ORGANIZER`, `ADMIN` (ngoài MVP). Một app duy nhất, sau đăng nhập `go_router` đưa USER vào `/home`, ORGANIZER vào `/organizer`.

## 2. Quy tắc bắt buộc (không được vi phạm)

1. **Backend là nơi kiểm tra quyền.** Ẩn nút trên UI không thay thế `hasRole` + kiểm tra chủ sở hữu ở service.
2. `POST /api/auth/register` **luôn tạo role USER**. Không nhận `role` từ client. Tài khoản Organizer được nâng bằng SQL: `UPDATE users SET role='ORGANIZER' WHERE email='...'`, sau đó đăng nhập lại để lấy token mới.
3. Mật khẩu băm BCrypt; không log mật khẩu, token, JWT secret.
4. **Mọi lỗi nghiệp vụ trả JSON thống nhất** có `errorCode` (mục 6). Flutter quyết định hành động theo `errorCode`, **không** so khớp chuỗi `message`.
5. Đăng ký sự kiện phải nằm trong **một transaction** và **khóa dòng event** (`PESSIMISTIC_WRITE`) để không vượt `capacity`. Booking và Ticket cùng thành công hoặc cùng rollback.
6. `remainingSeats` **tính khi cần** (`capacity − số booking CONFIRMED`), không lưu thành cột.
7. QR chỉ chứa `ticket_code`. Không đưa tên, email hay dữ liệu nhạy cảm vào QR.
8. Check-in dùng **cả** `ticketCode` và `eventId`; mỗi vé chỉ check-in một lần (chống đua bằng `@Version` và `UNIQUE(check_ins.ticket_id)`).
9. Màn hình Flutter nào gọi API cũng phải xử lý đủ 4 trạng thái: loading, data, empty, error (có nút "Thử lại"). App không được crash khi mất mạng và không hiện stack trace cho người dùng.
10. Màn hình **không tự gọi mạng**: Screen → Provider → Repository → Dio.
11. Không làm tính năng ngoài MVP (mục 11) trừ khi người dùng yêu cầu rõ.
12. Không commit mật khẩu DB hay JWT secret thật; dùng biến môi trường hoặc file cấu hình riêng nằm trong `.gitignore`.

## 3. Cơ sở dữ liệu

5 bảng, tên DB `event_ticket_db`, charset `utf8mb4_unicode_ci`.

```sql
CREATE DATABASE IF NOT EXISTS event_ticket_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE event_ticket_db;

CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('USER','ORGANIZER','ADMIN') NOT NULL DEFAULT 'USER',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE events (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  organizer_id BIGINT NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  location VARCHAR(255) NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  capacity INT NOT NULL,
  status ENUM('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_events_organizer FOREIGN KEY (organizer_id) REFERENCES users(id),
  CONSTRAINT chk_events_capacity CHECK (capacity > 0),
  CONSTRAINT chk_events_time CHECK (end_time > start_time)
);

CREATE TABLE bookings (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  event_id BIGINT NOT NULL,
  booking_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('CONFIRMED','CANCELLED') NOT NULL DEFAULT 'CONFIRMED',
  CONSTRAINT fk_bookings_user  FOREIGN KEY (user_id)  REFERENCES users(id),
  CONSTRAINT fk_bookings_event FOREIGN KEY (event_id) REFERENCES events(id),
  CONSTRAINT uq_bookings_user_event UNIQUE (user_id, event_id)
);

CREATE TABLE tickets (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  booking_id BIGINT NOT NULL UNIQUE,
  ticket_code VARCHAR(50) NOT NULL UNIQUE,
  status ENUM('VALID','CHECKED_IN') NOT NULL DEFAULT 'VALID',
  version BIGINT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tickets_booking FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

CREATE TABLE check_ins (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  ticket_id BIGINT NOT NULL UNIQUE,
  checked_in_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  checked_in_by BIGINT NOT NULL,
  CONSTRAINT fk_checkins_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id),
  CONSTRAINT fk_checkins_by FOREIGN KEY (checked_in_by) REFERENCES users(id)
);
```

Quan hệ: `users(Organizer) 1—N events`, `users 1—N bookings`, `events 1—N bookings`, `bookings 1—1 tickets`, `tickets 1—0..1 check_ins`.

Lưu ý: `CHECK` chỉ có hiệu lực từ MySQL 8.0.16, nên service vẫn phải tự kiểm tra `capacity > 0` và `endTime > startTime`. Entity `Ticket` có `@Version Long version`. Dùng `ddl-auto=validate`.

## 4. Backend (Spring Boot)

### 4.1 Cấu trúc và cấu hình

Phân lớp: `Controller → Service → Repository → DB`. Dùng DTO cho request/response, **không trả Entity trực tiếp**. Các thành phần chính: `JwtUtil`, `JwtAuthenticationFilter`, `SecurityConfig`, `ErrorCode` (enum), `AppException`, `GlobalExceptionHandler` (`@RestControllerAdvice`).

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/event_ticket_db?serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true&useSSL=false
spring.datasource.username=root
spring.datasource.password=${DB_PASSWORD}
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=true
app.jwt.secret=${JWT_SECRET}          # tối thiểu 32 ký tự ngẫu nhiên
app.jwt.expiration-ms=86400000        # 24 giờ
server.port=8080
```

Maven: Spring Web, Data JPA, Security, MySQL Driver, Validation, Lombok, `jjwt-api`, `jjwt-impl`, `jjwt-jackson`.

### 4.2 Security

- Stateless, tắt CSRF, JWT filter đặt trước `UsernamePasswordAuthenticationFilter`. JWT chứa `userId`, `role`, hạn dùng.
- Phân quyền theo path (khi dùng `hasRole("X")` thì authority phải là `ROLE_X`):

```java
.requestMatchers("/api/auth/**").permitAll()
.requestMatchers(HttpMethod.POST,   "/api/events").hasRole("ORGANIZER")
.requestMatchers(HttpMethod.PUT,    "/api/events/**").hasRole("ORGANIZER")
.requestMatchers(HttpMethod.DELETE, "/api/events/**").hasRole("ORGANIZER")
.requestMatchers("/api/organizer/**", "/api/check-ins").hasRole("ORGANIZER")
.requestMatchers("/api/events/*/attendees").hasRole("ORGANIZER")
.requestMatchers("/api/events/*/book").hasRole("USER")
.requestMatchers("/api/tickets/**", "/api/bookings/**").hasRole("USER")
.anyRequest().authenticated()
```

- Cấu hình `authenticationEntryPoint` (thiếu/sai token → **401 `UNAUTHORIZED`** dạng JSON) và `accessDeniedHandler` (**403 `FORBIDDEN`** dạng JSON). Nếu không, thiếu token sẽ ra 403 hoặc HTML.
- Quyền sở hữu kiểm tra ở service: Organizer chỉ sửa/xóa/xem attendees/check-in sự kiện có `organizer_id` = chính mình; User chỉ xem vé của mình.

### 4.3 Events

- `GET /api/events` phân trang (`page` từ 0, `size`), **chỉ trả sự kiện OPEN**; mỗi item có `remainingSeats`.
- Xóa sự kiện đã có booking → 409 `EVENT_HAS_BOOKINGS` (Organizer nên chuyển sang CLOSED).
- Validate: `capacity > 0`, `endTime > startTime`, `title`/`location` không rỗng.

### 4.4 Booking — thứ tự bắt buộc

```java
// Repository
@Lock(LockModeType.PESSIMISTIC_WRITE)
@Query("select e from Event e where e.id = :id")
Optional<Event> findByIdForUpdate(@Param("id") Long id);

@Transactional
public TicketResponse book(Long eventId, Long userId) {
    Event event = eventRepository.findByIdForUpdate(eventId)
        .orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));
    if (bookingRepository.existsByUserIdAndEventIdAndStatus(userId, eventId, BookingStatus.CONFIRMED))
        throw new AppException(ErrorCode.ALREADY_REGISTERED);
    if (event.getStatus() != EventStatus.OPEN)
        throw new AppException(ErrorCode.EVENT_CLOSED);
    long taken = bookingRepository.countByEventIdAndStatus(eventId, BookingStatus.CONFIRMED);
    if (taken >= event.getCapacity())
        throw new AppException(ErrorCode.EVENT_FULL);
    User user = userRepository.getReferenceById(userId);
    Booking booking = bookingRepository.save(new Booking(user, event, BookingStatus.CONFIRMED));
    Ticket ticket = ticketRepository.save(Ticket.create(booking, generateUniqueCode()));
    return TicketResponse.from(ticket);
}
```

`ticket_code` dạng `EVT-<năm>-<5 ký tự ngẫu nhiên>` (ví dụ `EVT-2026-A8F31`), phải duy nhất: kiểm tra tồn tại và sinh lại nếu trùng. Nếu `DataIntegrityViolationException` do `uq_bookings_user_event` thì map về `ALREADY_REGISTERED`.

### 4.5 Check-in — thứ tự kiểm tra bắt buộc

1. Không có ticket theo `ticketCode` → 404 `TICKET_NOT_FOUND`
2. Organizer gọi không phải chủ sự kiện của vé → 403 `FORBIDDEN`
3. `ticket.event.id != req.eventId` → 409 `TICKET_WRONG_EVENT`
4. `ticket.status != VALID` → 409 `TICKET_ALREADY_CHECKED_IN`
5. Hợp lệ: đổi `VALID → CHECKED_IN`, tạo bản ghi `check_ins` (`checked_in_by` = organizer), trả `attendeeName`, `eventTitle`, `checkedInAt`.

```java
@Transactional
public CheckInResponse checkIn(CheckInRequest req, Long organizerId) {
    Ticket ticket = ticketRepository.findByTicketCode(req.getTicketCode())
        .orElseThrow(() -> new AppException(ErrorCode.TICKET_NOT_FOUND));
    Event event = ticket.getBooking().getEvent();
    if (!event.getOrganizer().getId().equals(organizerId))
        throw new AppException(ErrorCode.FORBIDDEN);
    if (!event.getId().equals(req.getEventId()))
        throw new AppException(ErrorCode.TICKET_WRONG_EVENT);
    if (ticket.getStatus() != TicketStatus.VALID)
        throw new AppException(ErrorCode.TICKET_ALREADY_CHECKED_IN);
    ticket.setStatus(TicketStatus.CHECKED_IN);                 // @Version bảo vệ ở đây
    CheckIn ci = checkInRepository.save(
        new CheckIn(ticket, userRepository.getReferenceById(organizerId)));
    return CheckInResponse.of(ticket, ci);
}
```

Phải bắt `ObjectOptimisticLockingFailureException` và `DataIntegrityViolationException` (khi hai máy quét cùng lúc) rồi trả `TICKET_ALREADY_CHECKED_IN`. Lưu ý: lỗi optimistic lock thường nổ lúc commit (ngoài thân hàm), nên xử lý ở `GlobalExceptionHandler` hoặc ở tầng gọi service.

### 4.6 Định dạng lỗi

```json
HTTP 409
{ "success": false, "errorCode": "EVENT_FULL",
  "message": "Sự kiện đã đủ số lượng người tham gia.", "timestamp": "2026-10-01T09:30:00" }
```

`message` do backend gửi sẵn bằng **tiếng Việt**. Lỗi không lường trước → 500 `INTERNAL_ERROR` (không lộ stack trace). Lỗi validate → 400 `VALIDATION_ERROR`.

## 5. REST API

JSON hai chiều. Mọi API cần `Authorization: Bearer <token>` (có **dấu cách** sau `Bearer`) trừ register/login. Thời gian dùng ISO-8601 không múi giờ (`2026-10-20T08:00:00`).

| Method | Endpoint | Quyền | Ghi chú |
|---|---|---|---|
| POST | `/api/auth/register` | công khai | body `{name,email,password}` → 201 `{userId,email,message}`. Luôn tạo USER |
| POST | `/api/auth/login` | công khai | body `{email,password}` → 200 `{token,role,userId,name,email}` |
| GET | `/api/events?page=0&size=10` | USER, ORGANIZER | trang `{content[],page,size,totalPages,last}`; item `{id,title,imageUrl,location,startTime,endTime,capacity,remainingSeats,status}` |
| GET | `/api/events/{id}` | USER, ORGANIZER | chi tiết đầy đủ (thêm `description`) |
| POST | `/api/events` | ORGANIZER | tạo sự kiện, `organizer_id` lấy từ token |
| PUT | `/api/events/{id}` | ORGANIZER (chủ) | cập nhật |
| DELETE | `/api/events/{id}` | ORGANIZER (chủ) | 409 `EVENT_HAS_BOOKINGS` nếu đã có booking |
| GET | `/api/organizer/events` | ORGANIZER | mảng `{id,title,startTime,capacity,registeredCount,checkedInCount,status}` |
| GET | `/api/events/{id}/attendees` | ORGANIZER (chủ) | `{tên, email, trạng thái vé, giờ check-in}` |
| POST | `/api/events/{id}/book` | USER | không body → 201 `{ticketId,ticketCode,status,eventId,eventTitle,startTime,location}` |
| GET | `/api/bookings/me` | USER | đăng ký của bản thân |
| GET | `/api/tickets/me` | USER | danh sách vé của bản thân |
| GET | `/api/tickets/{id}` | USER (chủ vé) | chi tiết vé |
| POST | `/api/check-ins` | ORGANIZER | body `{ticketCode,eventId}` → 200 `{ticketCode,attendeeName,eventTitle,checkedInAt}` |

## 6. Mã lỗi

| errorCode | HTTP | Thông báo hiển thị |
|---|---|---|
| VALIDATION_ERROR | 400 | (theo trường sai) |
| INVALID_CREDENTIALS | 401 | Email hoặc mật khẩu không đúng. |
| UNAUTHORIZED | 401 | Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại. (tự về Login) |
| FORBIDDEN | 403 | Bạn không có quyền thực hiện thao tác này. |
| EVENT_NOT_FOUND | 404 | Không tìm thấy sự kiện. |
| TICKET_NOT_FOUND | 404 | Vé không hợp lệ. |
| EMAIL_ALREADY_EXISTS | 409 | Email này đã được sử dụng. |
| ALREADY_REGISTERED | 409 | Bạn đã đăng ký sự kiện này. |
| EVENT_FULL | 409 | Sự kiện đã đủ số lượng người tham gia. |
| EVENT_CLOSED | 409 | Sự kiện đã đóng đăng ký. |
| EVENT_HAS_BOOKINGS | 409 | Không thể xóa sự kiện đã có người đăng ký. |
| TICKET_ALREADY_CHECKED_IN | 409 | Vé đã được check-in trước đó. |
| TICKET_WRONG_EVENT | 409 | Vé không thuộc sự kiện này. |
| INTERNAL_ERROR | 500 | Đã có lỗi xảy ra. |
| NETWORK_ERROR | (không có phản hồi) | Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet. **Do Flutter tự tạo** |

## 7. Flutter

### 7.1 Cấu trúc thư mục (feature-first)

```
event_ticket_app/lib/
├─ main.dart                  # runApp(const ProviderScope(child: App()))
├─ app.dart                   # MaterialApp.router + theme
├─ core/
│  ├─ config/app_config.dart       # baseUrl
│  ├─ network/api_client.dart      # dioProvider + interceptor JWT
│  ├─ storage/token_storage.dart   # flutter_secure_storage
│  ├─ errors/app_exception.dart
│  ├─ router/app_router.dart       # go_router + redirect theo auth/role
│  └─ widgets/                     # LoadingView, ErrorView, ...
└─ features/
   ├─ auth/       (data/ + presentation/: login, register, auth_controller)
   ├─ events/     (data/ + presentation/: event_list, event_detail)
   ├─ booking/    (data/ + presentation/: booking_success)
   ├─ tickets/    (data/ + presentation/: my_tickets, ticket_qr)
   ├─ organizer/  (data/ + presentation/: organizer_home, my_events, scan_qr, check_in_result)
   └─ profile/    (presentation/: profile_screen)
```

Mỗi feature có 2 lớp: `data/` (Model có `fromJson`, Repository gọi Dio) và `presentation/` (Screen, widget, Provider/Controller).

Thêm package bằng `flutter pub add` (không tự gõ số phiên bản):

```
flutter pub add flutter_riverpod go_router dio flutter_secure_storage
flutter pub add qr_flutter mobile_scanner intl cached_network_image
```

**API của package có thể khác code mẫu trong tài liệu** (đặc biệt Riverpod, go_router, mobile_scanner). Hãy đọc phiên bản thực tế trong `pubspec.lock` và tài liệu trên pub.dev, tin tài liệu chính thức hơn code mẫu.

### 7.2 Địa chỉ backend

```dart
class AppConfig {
  static const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080');
}
```

| Chạy ở | Địa chỉ |
|---|---|
| Android Emulator | `http://10.0.2.2:8080` |
| iOS Simulator | `http://localhost:8080` |
| Điện thoại thật | `flutter run -d <id> --dart-define=API_BASE_URL=http://<IP máy tính>:8080` (cùng Wi-Fi, mở firewall cổng 8080) |

Chỉ khi dev qua HTTP: `AndroidManifest.xml` thêm `android:usesCleartextTraffic="true"` trong `<application>` và `<uses-permission android:name="android.permission.INTERNET"/>`; iOS `Info.plist` cho phép HTTP cục bộ (`NSAppTransportSecurity` → `NSAllowsLocalNetworking`). Bản chạy thật phải dùng HTTPS.

### 7.3 Nền tảng mạng

```dart
// token_storage.dart
class TokenStorage {
  static const _key = 'jwt_token';
  final _storage = const FlutterSecureStorage();
  Future<void> save(String token) => _storage.write(key: _key, value: token);
  Future<String?> read() => _storage.read(key: _key);
  Future<void> clear() => _storage.delete(key: _key);
}

// api_client.dart
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

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
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        await storage.clear();
        // Đồng thời cập nhật authStateProvider -> "chưa đăng nhập"
        // để go_router tự redirect về /login.
      }
      handler.next(error);
    },
  ));
  return dio;
});
```

Khi gặp 401, ngoài xóa token **phải cập nhật `authStateProvider`**, nếu không `go_router` sẽ không biết để đưa người dùng về Login (tài liệu gốc chỉ nhắc ở bước điều hướng).

```dart
// app_exception.dart
class AppException implements Exception {
  AppException(this.code, this.message);
  final String code;
  final String message;

  factory AppException.fromDio(DioException e) {
    final noResponse = e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
    if (noResponse) {
      return AppException('NETWORK_ERROR',
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet.');
    }
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return AppException((data['errorCode'] as String?) ?? 'UNKNOWN',
          (data['message'] as String?) ?? 'Đã có lỗi xảy ra.');
    }
    return AppException('UNKNOWN', 'Đã có lỗi xảy ra. Vui lòng thử lại.');
  }
  @override
  String toString() => message;
}
```

Mọi Repository bọc lời gọi: `try { ... } on DioException catch (e) { throw AppException.fromDio(e); }`. Màn hình chỉ xử lý `AppException`.

### 7.4 Model và Repository

- Model có `factory X.fromJson(Map<String, dynamic>)`, tên trường **khớp đúng JSON backend** (camelCase: `startTime`, `imageUrl`, `remainingSeats`...). Trường có thể null khai báo `String?`.
- Repository nhận `Dio`, expose qua `Provider`. Provider dữ liệu dùng `FutureProvider` hoặc notifier (nếu cần phân trang).
- `EventRepository.getEvents({page=0,size=10})` đọc `res.data['content']`. Với phân trang cần notifier giữ danh sách + trang hiện tại + cờ `last`, chứ `FutureProvider` chỉ tải trang 0.

### 7.5 Điều hướng

| Route | Màn hình | Khu vực |
|---|---|---|
| `/splash` | Splash (đọc token, tự đăng nhập) | chung |
| `/login`, `/register` | Đăng nhập, đăng ký | chung |
| `/home/events`, `/home/tickets`, `/home/profile` | 3 tab dưới đáy (`NavigationBar`) | USER |
| `/events/:id` | Chi tiết sự kiện + nút "Đăng ký tham gia" | USER |
| `/booking-success` | Đăng ký thành công → "Xem vé" | USER |
| `/tickets/:id` | QR Ticket | USER |
| `/organizer` | Organizer Home | ORGANIZER |
| `/organizer/events` | My Events (đã đăng ký / đã check-in, nút "Quét vé") | ORGANIZER |
| `/organizer/scan/:eventId` | Quét QR | ORGANIZER |
| `/organizer/result` | Kết quả check-in (nhận `extra`) | ORGANIZER |

`redirect` của go_router: chưa đăng nhập vào trang cần đăng nhập → `/login`; đã đăng nhập → USER `/home`, ORGANIZER `/organizer`. Đăng xuất = `TokenStorage.clear()` + cập nhật `authStateProvider` → về Login.

### 7.6 Mẫu màn hình 4 trạng thái

```dart
class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sự kiện')),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: err is AppException ? err.message : 'Đã có lỗi xảy ra.',
          onRetry: () => ref.invalidate(eventsProvider),
        ),
        data: (events) {
          if (events.isEmpty) return const Center(child: Text('Chưa có sự kiện nào'));
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(eventsProvider.future),
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (_, i) => EventCard(event: events[i]),
            ),
          );
        },
      ),
    );
  }
}
```

Form: `Form` + `TextFormField` có `validator` (email đúng dạng, mật khẩu ≥ 6 ký tự, tên không rỗng, tối đa 100 ký tự). Khi gửi: hiện vòng xoay, **khóa nút** để chống bấm đúp, lỗi hiện bằng `SnackBar(e.message)`. Ngày giờ dùng `DateFormat('dd/MM/yyyy HH:mm')`. Ảnh dùng `CachedNetworkImage`.

Event Detail: vô hiệu nút đăng ký nếu `remainingSeats == 0` hoặc `status == 'CLOSED'`. Bấm nút → `AlertDialog` xác nhận → `POST /api/events/{id}/book`.

### 7.7 Hiển thị QR (USER)

```dart
Container(
  padding: const EdgeInsets.all(12),
  color: Colors.white,                       // luôn nền trắng, QR đen, kể cả dark mode
  child: QrImageView(data: ticket.ticketCode, version: QrVersions.auto, size: 260),
),
Text(ticket.ticketCode),                     // luôn in mã chữ để nhập tay dự phòng
Chip(label: Text(ticket.status)),            // VALID xanh, CHECKED_IN xám
```

Hiển thị thêm tên sự kiện, thời gian, địa điểm. QR chỉ chứa `ticketCode`.

### 7.8 Quét QR (ORGANIZER)

```dart
final _controller = MobileScannerController(
  detectionSpeed: DetectionSpeed.noDuplicates,
  formats: const [BarcodeFormat.qrCode],
);
bool _busy = false;      // chống gọi API nhiều lần cho cùng một lần quét

Future<void> _onDetect(BarcodeCapture capture) async {
  if (_busy) return;
  final code = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
  if (code == null) return;
  _busy = true;
  await _controller.stop();
  HapticFeedback.mediumImpact();

  CheckInOutcome outcome;
  try {
    final res = await ref.read(checkInRepositoryProvider)
        .checkIn(ticketCode: code, eventId: widget.eventId);
    outcome = CheckInOutcome.success(res.attendeeName);
  } on AppException catch (e) {
    outcome = CheckInOutcome.failure(e.code, e.message);
  }

  if (!mounted) return;
  await context.push('/organizer/result', extra: outcome);   // chờ đóng màn kết quả
  _busy = false;
  if (mounted) await _controller.start();                    // quét người kế tiếp
}

@override
void dispose() { _controller.dispose(); super.dispose(); }
```

Yêu cầu của màn Scan: camera toàn màn hình có khung ngắm, biết sẵn `eventId`, có nút **"Nhập mã thủ công"** (hộp thoại nhập `ticketCode`, gọi cùng `checkIn()`).

Màn kết quả check-in:

| Trường hợp | Màu | Nội dung |
|---|---|---|
| Thành công | Xanh + dấu tích | CHECK-IN THÀNH CÔNG + tên người tham gia |
| `TICKET_ALREADY_CHECKED_IN` | Đỏ | Vé đã được check-in trước đó. |
| `TICKET_NOT_FOUND` (kể cả QR lạ) | Đỏ | Vé không hợp lệ. |
| `TICKET_WRONG_EVENT` | Đỏ | Vé không thuộc sự kiện này. |
| `NETWORK_ERROR` | **Vàng** | Không thể kết nối đến máy chủ, vui lòng thử quét lại. |

Có rung (`HapticFeedback`) và nút "Quét tiếp". Nên đưa `code` của lỗi vào `CheckInOutcome` để chọn màu (đỏ/vàng) theo `errorCode`.

### 7.9 Quyền camera

- Android: `<uses-permission android:name="android.permission.CAMERA"/>` trong `AndroidManifest.xml` (trên thẻ `<application>`); kiểm tra yêu cầu `minSdkVersion` của `mobile_scanner` trong `android/app/build.gradle`.
- iOS: `NSCameraUsageDescription` trong `Info.plist` (ví dụ "Ứng dụng cần camera để quét mã QR trên vé"). Thiếu khóa này app sẽ bị đóng khi mở camera.

### 7.10 Quy ước code Dart

- Sau mỗi `await`, nếu dùng `context` (dialog, điều hướng, snackbar) phải kiểm tra `if (!mounted) return;`.
- Không so sánh chuỗi `message`; dùng `AppException.code`.
- Không gọi Dio trong widget. Chạy `flutter analyze` và để sạch cảnh báo.
- Test tối thiểu: `EventModel.fromJson` đọc đúng JSON mẫu (`flutter test`).

## 8. Thứ tự làm việc

Làm theo đúng thứ tự phụ thuộc, không nhảy cóc:

| Phase | Việc | "Xong" khi |
|---|---|---|
| 0 | Môi trường: JDK 17, MySQL 8, Flutter SDK, Android Studio, Postman | `flutter doctor` không đỏ ở Flutter/Android toolchain |
| 1 | Chạy `schema.sql` | 5 bảng đủ khóa ngoại + UNIQUE; thử chèn dữ liệu mẫu |
| 2 | Backend Spring Boot (không đụng Flutter) | Qua 15 phép thử Postman (mục 9) |
| 3 | Flutter luồng USER với dữ liệu thật | Đăng ký/đăng nhập/tự đăng nhập lại, xem sự kiện, đăng ký sự kiện, xem vé; tắt backend app vẫn không crash |
| 4 | QR + luồng Organizer, thử trên **thiết bị thật** | Quét → xanh, quét lại → đỏ, đúng 1 API call mỗi lần quét |
| 5 | Kiểm thử tổng thể, `flutter analyze`, build APK | Bảng test T01–T18 đạt; `flutter build apk --release` chạy được |

Khi Flutter lỗi: gọi cùng API bằng Postman. Postman chạy được mà app không chạy thì lỗi ở Flutter; ngược lại thì ở backend.

## 9. Kiểm thử

Postman (Phase 2), theo thứ tự:

1. Register email mới → 201.
2. Register trùng email → 409 `EMAIL_ALREADY_EXISTS`.
3. Login đúng → 200 + token + role.
4. Login sai mật khẩu → 401 `INVALID_CREDENTIALS`.
5. `GET /api/events` không token → 401 `UNAUTHORIZED`.
6. Nâng ORGANIZER bằng SQL, login lại, `POST /api/events` → 201.
7. `POST /api/events` bằng token USER → 403 `FORBIDDEN`.
8. USER book → 201 có `ticketCode`; DB có 1 booking + 1 ticket VALID.
9. Book lần hai → 409 `ALREADY_REGISTERED`.
10. Sự kiện capacity=1, hai USER book → người đầu 201, người sau 409 `EVENT_FULL`.
11. Sự kiện CLOSED rồi book → 409 `EVENT_CLOSED`.
12. Check-in đúng `ticketCode` + `eventId` → 200, vé thành CHECKED_IN.
13. Check-in lại → 409 `TICKET_ALREADY_CHECKED_IN`.
14. `ticketCode` bịa → 404 `TICKET_NOT_FOUND`.
15. `eventId` của sự kiện khác → 409 `TICKET_WRONG_EVENT`.

App (Phase 5), tóm tắt: đăng ký/đăng nhập đúng và sai; tự đăng nhập lại sau khi tắt app; đăng xuất; xem danh sách; đăng ký thành công/trùng/hết chỗ/đóng; QR quét ra đúng `ticketCode`; check-in thành công, quét lại, QR lạ, vé sự kiện khác; mất mạng không crash; USER gọi API Organizer bị 403; token hết hạn tự về Login.

## 10. Lỗi thường gặp

| Triệu chứng | Nguyên nhân |
|---|---|
| Connection refused/timeout trên emulator | Dùng `localhost` thay vì `10.0.2.2` |
| Điện thoại thật không kết nối | Khác Wi-Fi hoặc firewall chặn cổng 8080 |
| `Cleartext HTTP traffic not permitted` | Thiếu `usesCleartextTraffic` (chỉ dev) |
| Mọi request 401 | Quên gắn header, thiếu dấu cách sau `Bearer`, token hết hạn |
| `type 'Null' is not a subtype of type 'String'` | Tên trường JSON không khớp model hoặc giá trị null |
| Camera đen, không hỏi quyền | Thiếu khai báo trong `AndroidManifest.xml`/`Info.plist`, hoặc đã từ chối vĩnh viễn |
| Một lần quét gọi API nhiều lần | Thiếu cờ `_busy` hoặc `DetectionSpeed.noDuplicates` |
| Crash/cảnh báo `use_build_context_synchronously` | Thiếu `if (!mounted) return;` sau `await` |
| Quét được máy này không được máy kia | QR quá nhỏ hoặc độ sáng màn hình thấp |
| `Public Key Retrieval is not allowed` | Thêm `allowPublicKeyRetrieval=true` vào URL JDBC |
| `Schema-validation: missing column/table` | Entity lệch `schema.sql` |
| Thiếu token ra 403 thay vì 401 | Chưa cấu hình `authenticationEntryPoint` |

## 11. Ngoài MVP (không làm trừ khi được yêu cầu)

ADMIN, Google Maps, Notification, Favorite, Chat, thanh toán, nhiều loại vé (VIP/Thường), thống kê, email xác nhận, xuất Excel/PDF, QR đổi mới mỗi 30 giây, hủy đăng ký (`CANCELLED`).

## 12. Chỗ tài liệu gốc chưa nêu hoặc cần lưu ý

Khi gặp các điểm này, ưu tiên hỏi người dùng; nếu không hỏi được thì dùng giả định bên cạnh và ghi chú rõ trong code/PR.

- **Body của `POST/PUT /api/events`** không được định nghĩa: giả định gồm `title, description, imageUrl, location, startTime, endTime, capacity, status`.
- **Response của `GET /api/bookings/me`, `GET /api/tickets/me`, `GET /api/tickets/{id}`** không có ví dụ: dùng các trường như response của `book` (`ticketId, ticketCode, status, eventId, eventTitle, startTime, location`).
- **Code mẫu check-in** trong tài liệu gọi `organizerRepository.getReferenceById(...)`, nhưng không có bảng organizer riêng. Organizer là `User`, nên dùng `userRepository`.
- **`UNIQUE(user_id, event_id)`** sẽ chặn đăng ký lại sau khi hủy. Vì MVP không có hủy nên chấp nhận được; nếu thêm tính năng hủy thì phải xem lại ràng buộc này.
- **`GET /api/events/{id}`** không nói rõ có cho xem sự kiện CLOSED không. Giả định: cho xem (để hiện nút bị vô hiệu), chỉ danh sách mới lọc OPEN.
- Tài liệu gốc ghi nhận kết quả dự kiến và kịch bản demo 13 bước ở mục 14; xem tài liệu gốc khi cần chuẩn bị demo.


# PHỤ LỤC: PHASE 6 — TÍNH NĂNG NÂNG CAO (NGOÀI MVP, ĐÃ ĐƯỢC YÊU CẦU RÕ)

**Hiệu lực:** Phase 6 ghi đè mục 11 ("Ngoài MVP") **chỉ cho các tính năng liệt kê trong phụ lục này**. Các mục 1–10 vẫn bắt buộc, trừ chỗ mục 3 nêu thay đổi. Chỉ làm Phase 6 **sau khi Phase 0–5 đã đạt**. Không làm thêm bất kỳ thứ gì không có trong phụ lục này; gặp chỗ chưa rõ thì hỏi người dùng.

## 1. Phạm vi theo vai trò

| Vai trò | Làm | Không làm |
|---|---|---|
| USER | Tự đăng ký tài khoản (luôn là USER); xem và đăng ký các sự kiện **sắp diễn ra** | Không chọn được role khi đăng ký |
| ORGANIZER | (1) Check-in 2 bước: quét QR → xem thông tin chủ vé → chụp ảnh khách → xác nhận. (2) Xem **5 lượt check-in gần nhất do chính tài khoản mình thực hiện** để đối soát chụp nhầm/thao tác nhầm | Không xem check-in của organizer khác; không quản trị user; không xóa sự kiện của người khác |
| ADMIN | (1) Xem danh sách user. (2) Tạo tài khoản USER hoặc ORGANIZER. (3) Xem và xóa sự kiện. (4) Xem **toàn bộ danh sách check-in của mọi khán giả** (thông tin khán giả, ảnh, tài khoản organizer đã check-in) | Không tạo tài khoản ADMIN qua API; không sửa sự kiện; không check-in; không sửa/xóa/hủy check-in |

## 2. Mục đích của ảnh check-in và những gì KHÔNG làm

Ảnh chụp tại cổng để **răn đe việc đưa vé cho người khác vào thay**. Ảnh được **lưu cùng bản ghi check-in để xem lại về sau** (đối soát thủ công khi có tranh chấp hoặc thao tác nhầm). Chỉ cần mức đơn giản.

**Lưu ý quan trọng về UX chụp lại ảnh:**
- **TRƯỚC KHI xác nhận:** Khi đang ở màn hình Preview (chưa bấm nút "Xác nhận Check-in"), ORGANIZER được phép bấm nút Camera nhiều lần để chụp lại nếu ảnh mờ, sai người.
- **SAU KHI xác nhận:** Khi đã gửi API thành công, hệ thống khóa cứng bản ghi. Không có tính năng "Hủy check-in" hay "Cập nhật lại ảnh". Quét lại mã QR sẽ báo lỗi `TICKET_ALREADY_CHECKED_IN`.

**KHÔNG làm:**
- nhận diện / so khớp khuôn mặt, hay so ảnh với ảnh hồ sơ
- nén, resize, crop, watermark ảnh
- lưu ảnh lên cloud (S3, Firebase...)
- cho chọn ảnh từ thư viện (chỉ chụp bằng camera)
- thư viện ảnh riêng, tải ảnh hàng loạt, xóa/sửa ảnh
- hủy check-in, chụp lại sau khi đã xác nhận, đánh dấu "thao tác nhầm"
- lọc/tìm kiếm nâng cao, xuất Excel/PDF cho các danh sách check-in
- duyệt/từ chối sự kiện theo trạng thái chờ duyệt ("kiểm duyệt" chỉ là ADMIN xem và xóa)
- sửa/xóa/khóa user, đổi mật khẩu, phân quyền chi tiết

## 3. Thay đổi so với tài liệu chính

1. `POST /api/auth/register` **không đổi**: vốn đã công khai, luôn tạo USER, không nhận `role` (quy tắc 2). Chỉ cần hoàn thiện `RegisterScreen`.
2. Chỉ `POST /api/admin/users` được tạo tài khoản ORGANIZER, với `role` ∈ {`USER`,`ORGANIZER`}. Tài khoản ADMIN đầu tiên vẫn tạo bằng SQL (`UPDATE users SET role='ADMIN' WHERE email='...'`).
3. `DELETE /api/events/{id}` cho **ORGANIZER (chỉ sự kiện của mình)** và **ADMIN (mọi sự kiện)**.
4. `GET /api/events` thêm tham số tùy chọn `upcoming=true` → chỉ trả sự kiện `OPEN` có `startTime > now`. App của USER gọi với tham số này. Phân trang và `remainingSeats` giữ nguyên.
5. Quy tắc 8 (check-in dùng cả `ticketCode` và `eventId`, chống đua bằng `@Version` và `UNIQUE(check_ins.ticket_id)`) vẫn áp dụng cho check-in kèm ảnh.
6. `GET /api/events/{id}/attendees` thêm trường `photoUrl`.
7. Mục 4.2 (Security) và mục 7.5 (Điều hướng) của tài liệu chính được cập nhật theo mục 5.6 và 6.2 dưới đây.

## 4. Database

Chỉ một thay đổi trên bảng `check_ins` (số nhiều, đúng tên bảng hiện có):

```sql
ALTER TABLE check_ins ADD COLUMN photo_url VARCHAR(500) NULL;
```

- Entity `CheckIn` thêm `photoUrl`. Vẫn dùng `ddl-auto=validate`, entity phải khớp `schema.sql` (cập nhật cả `schema.sql`).
- Giá trị lưu là **đường dẫn tương đối** tới file ảnh trên đĩa server (ví dụ `/uploads/checkins/<uuid>.jpg`). Không lưu ảnh nhị phân trong DB.
- `NULL` để các check-in cũ (không có ảnh) vẫn hợp lệ.

Cấu hình thêm:

```properties
app.upload.dir=./uploads                     # thư mục lưu ảnh, thêm vào .gitignore
spring.servlet.multipart.max-file-size=5MB
spring.servlet.multipart.max-request-size=6MB
```

## 5. Backend (Spring Boot)

### 5.1 API bổ sung

| Method | Endpoint | Quyền | Mô tả |
|---|---|---|---|
| GET | `/api/tickets/verify?code={ticketCode}&eventId={id}` | ORGANIZER | **Chỉ đọc**, không đổi trạng thái vé. Trả `{ticketCode, attendeeName, attendeeEmail, eventTitle, status}` |
| POST | `/api/check-ins/with-photo` | ORGANIZER | `multipart/form-data`: `ticketCode` (text), `eventId` (text), `photo` (file). → 200 `{ticketCode, attendeeName, eventTitle, checkedInAt}` |
| GET | `/api/organizer/check-ins/recent` | ORGANIZER | Tối đa **5** check-in mới nhất do chính organizer trong token thực hiện, qua mọi sự kiện, `checkedInAt` giảm dần. Item: `{checkInId, ticketCode, attendeeName, attendeeEmail, eventTitle, checkedInAt, photoUrl}` |
| GET | `/api/admin/check-ins?page=0&size=20` | ADMIN | Toàn bộ check-in của mọi sự kiện, mới nhất trước, phân trang như `/api/events`. Item: `{checkInId, ticketCode, attendeeName, attendeeEmail, eventTitle, checkedInAt, photoUrl, checkedInBy: {id, name, email}}` |
| GET | `/api/admin/users` | ADMIN | `[{id, name, email, role, createdAt}]`. **Không bao giờ trả `password`** |
| POST | `/api/admin/users` | ADMIN | Body `{name, email, password, role}`, `role` ∈ {`USER`,`ORGANIZER`} → 201 `{userId, email, role}` |
| DELETE | `/api/events/{id}` | ADMIN hoặc ORGANIZER (chủ) | Xóa sự kiện (chỉ khi chưa có booking) |
| GET | `/api/events/{id}/attendees` | ORGANIZER (chủ) | Đã có; item thành `{attendeeName, email, ticketStatus, checkedInAt, photoUrl}` |

### 5.2 Quy tắc `verify`

Chạy các kiểm tra như check-in nhưng **không ghi DB**, theo thứ tự: `TICKET_NOT_FOUND` (404) → organizer không phải chủ sự kiện của vé `FORBIDDEN` (403) → `TICKET_WRONG_EVENT` (409) → vé đã dùng `TICKET_ALREADY_CHECKED_IN` (409). Qua hết thì trả tên và email chủ vé để Organizer đối chiếu.

### 5.3 Quy tắc `with-photo`

1. Chạy lại **đúng thứ tự kiểm tra check-in**. Không tin kết quả `verify` trước đó.
2. Kiểm tra ảnh tối thiểu: bắt buộc có `photo` (thiếu → 400 `PHOTO_REQUIRED`); chỉ nhận JPEG/PNG; tối đa 5 MB (sai → 400 `VALIDATION_ERROR`).
3. Lưu file vào `app.upload.dir`, **tên file là UUID sinh ở server**, không dùng tên file client gửi (chống path traversal).
4. Đổi vé `VALID → CHECKED_IN`, tạo bản ghi `check_ins`. Xử lý đua như tài liệu chính: bắt `ObjectOptimisticLockingFailureException` và `DataIntegrityViolationException` → `TICKET_ALREADY_CHECKED_IN`.
5. **Xem lại ảnh:** cấu hình `ResourceHandler` để `/uploads/**` trỏ tới thư mục `app.upload.dir`. `photoUrl` trong response là đường dẫn tương đối.

### 5.4 Xóa sự kiện

- ORGANIZER: giữ quy tắc cũ (chỉ chủ sự kiện; đã có booking → 409 `EVENT_HAS_BOOKINGS`).
- ADMIN: xóa được sự kiện của bất kỳ ai, nhưng sự kiện đã có booking vẫn trả 409 `EVENT_HAS_BOOKINGS`. Không thêm xóa dây chuyền (cascade).

### 5.5 Quy tắc cho hai API lịch sử check-in

1. **Organizer lấy từ token**, không nhận `organizerId` từ client.
2. Cả hai API lịch sử phải tải sẵn `ticket → booking → user/event` và `checkedInBy` (`@EntityGraph` hoặc `join fetch`) để tránh N+1.
3. Trả bằng DTO, **không trả Entity**. `checkedInBy` chỉ gồm `id, name, email`.
4. Chỉ đọc: không có endpoint sửa/xóa/hủy check-in.

### 5.6 Cấu hình Security (Thứ tự matcher)

```java
.requestMatchers("/api/auth/**").permitAll()
.requestMatchers("/api/admin/**").hasRole("ADMIN")
.requestMatchers(HttpMethod.DELETE, "/api/events/**").hasAnyRole("ORGANIZER", "ADMIN")
.requestMatchers(HttpMethod.GET, "/api/tickets/verify").hasRole("ORGANIZER") // PHẢI đứng trước /api/tickets/**
.requestMatchers("/api/check-ins", "/api/check-ins/with-photo").hasRole("ORGANIZER")
.requestMatchers("/uploads/**").hasAnyRole("ORGANIZER", "ADMIN") // KHÔNG permitAll
```

### 5.7 Mã lỗi bổ sung

| errorCode | HTTP | Thông báo |
|---|---|---|
| `INVALID_ROLE` | 400 | Quyền không hợp lệ. (khi `role` ngoài USER/ORGANIZER) |
| `PHOTO_REQUIRED` | 400 | Vui lòng chụp ảnh khách hàng trước khi xác nhận. |

## 6. Flutter

### 6.1 Package
`flutter pub add image_picker`. Chụp bằng `ImageSource.camera`. Gửi ảnh bằng Dio `FormData` + `MultipartFile`.

### 6.2 Route

| Route | Màn hình | Khu vực |
|---|---|---|
| `/register` | `RegisterScreen` (hoàn thiện) | chung |
| `/organizer/preview` | `TicketPreviewScreen` (nhận `extra`: ticketCode + eventId) | ORGANIZER |
| `/organizer/attendees/:eventId` | `AttendeeListScreen` | ORGANIZER |
| `/organizer/recent` | `RecentCheckInsScreen` | ORGANIZER |
| `/admin` | `AdminHomeScreen` | ADMIN |

Cập nhật `redirect` của go_router: `USER → /home`, `ORGANIZER → /organizer`, **`ADMIN → /admin`**.

### 6.3 Luồng check-in 2 bước (ORGANIZER)

```
ScanQR → GET /api/tickets/verify → TicketPreviewScreen
  → [Chụp ảnh khách] (camera) → [Xác nhận] → POST /api/check-ins/with-photo → màn kết quả sẵn có
```
- `TicketPreviewScreen`: Nút **"Xác nhận check-in" bị khóa cho đến khi đã chụp ảnh**. Trước khi xác nhận, được phép chụp lại đè lên. 
- Bấm "Xác nhận": hiện vòng xoay, khóa nút chống bấm đúp, gọi `with-photo`.

### 6.4 Tải ảnh có xác thực (dùng chung)
Dùng `CachedNetworkImage` kèm `httpHeaders: {'Authorization': 'Bearer $token'}`.

### 6.5 Quản trị viên (AdminHomeScreen)
- **Tab "Người dùng":** Danh sách user. Nút "+" mở form tạo tài khoản.
- **Tab "Sự kiện":** Danh sách sự kiện, nút xóa sự kiện.
- **Tab "Check-in":** Lịch sử toàn bộ check-in, phân trang, hiển thị cả người thực hiện (Organizer name).

## 7. Các Bước Triển Khai (Phasing) & Tiêu Chí Nghiệm Thu (Acceptance Criteria)

Để đảm bảo chất lượng, Phase 6 được chia nhỏ thành các bước (sub-phases) sau:

### 7.1. Bước 1: Hạ tầng Database & Backend Core
- **Công việc:** Chạy lệnh `ALTER TABLE`, bổ sung trường `photoUrl` vào Entity. Tích hợp `FileStorageService` lưu ảnh vào `/uploads`.
- **Tiêu chí nghiệm thu:**
  - Khởi động Spring Boot không lỗi. File `schema.sql` phản ánh đúng cấu trúc.
  - Gửi thử một file qua API test (hoặc Postman) và thấy file xuất hiện trong thư mục `/uploads`.

### 7.2. Bước 2: Hoàn thiện API Backend (Các Endpoint Mới)
- **Công việc:** Code API `/verify`, `/with-photo`, phân trang `admin/check-ins`, `admin/users`, `recent check-ins`. Cập nhật Spring Security Matchers.
- **Tiêu chí nghiệm thu (Dùng Postman để verify):**
  - Gọi `/api/tickets/verify` bằng token ORGANIZER đúng sự kiện -> `200 OK` (không thay đổi trạng thái vé).
  - Gọi `/api/tickets/verify` bằng token USER hoặc ADMIN -> `403 Forbidden`.
  - Gọi `/api/check-ins/with-photo` kèm file ảnh -> `200 OK` và Database tạo bản ghi có `photo_url` UUID. Gọi lần 2 báo `409 TICKET_ALREADY_CHECKED_IN`.
  - Truy cập URL ảnh bằng token ORGANIZER/ADMIN -> `200 OK` ra đúng ảnh. Không có token -> `401 Unauthorized`.
  - ADMIN gọi `/api/admin/users` -> Trả về danh sách (không password). Tạo User/Organizer -> `201 Created`. Tạo ADMIN -> `400 INVALID_ROLE`.

### 7.3. Bước 3: Phát triển Giao diện Flutter (Cổng Khán Giả & Admin)
- **Công việc:** Cập nhật Route (`/admin`, `/register`). Viết `RegisterScreen`, viết `AdminHomeScreen` (3 tabs). Chỉnh sửa Danh sách sự kiện để lọc `upcoming=true`.
- **Tiêu chí nghiệm thu:**
  - Đăng ký tài khoản mới thành công -> Đăng nhập vào ra `/home`.
  - Tài khoản ADMIN đăng nhập vào ra `/admin`. Có thể tạo ORGANIZER mới.
  - Danh sách check-in bên Admin tải được ảnh qua `CachedNetworkImage` kèm Bearer Token, xem đủ 3 trạng thái phân trang.

### 7.4. Bước 4: Hoàn thiện Luồng Quét QR 2 Bước (Cổng Organizer)
- **Công việc:** Viết `TicketPreviewScreen`. Cài đặt thư viện `image_picker`. Ràng buộc UI nút "Xác nhận".
- **Tiêu chí nghiệm thu:**
  - Quét QR thành công -> Nhảy sang màn Preview hiển thị đúng Tên/Email.
  - Chưa chụp ảnh -> Nút Xác nhận mờ/khóa.
  - Bấm chụp -> Chụp xong hiện lên UI. Bấm chụp lại -> Đè ảnh cũ.
  - Bấm Xác nhận -> Gửi đi. Lần sau quét lại mã đó -> Nhảy thẳng sang màn báo lỗi Đỏ `TICKET_ALREADY_CHECKED_IN`.

