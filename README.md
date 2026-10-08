# 🎟️ EventQR - Hệ thống Quản lý và Check-in Sự kiện bằng Mã QR

Chào mừng bạn đến với **EventQR**! Đây là dự án quản lý sự kiện và check-in vé bằng QR Code toàn diện bao gồm cả Backend (Máy chủ) và Frontend (App di động). 

Dự án này đã được thiết lập theo chuẩn **"Clone and Play"** (Tải về là chạy). Bạn không cần phải tạo cơ sở dữ liệu hay tạo tài khoản thủ công, hệ thống sẽ tự động cấu hình mọi thứ!

---

## 🛠️ Yêu cầu môi trường (Prerequisites)
Để chạy dự án này trên máy, bạn cần cài đặt:
1. **Java 17** trở lên.
2. **MySQL** (phiên bản 8.0+).
3. **Flutter SDK** (phiên bản 3.x).

---

## 🚀 Hướng dẫn khởi chạy (Dành cho người mới tải Code)

### PHẦN 1: KHỞI ĐỘNG MÁY CHỦ (BACKEND - SPRING BOOT)

1. **Bật MySQL trên máy bạn lên.** Hãy chắc chắn rằng máy chủ MySQL của bạn đang hoạt động ở cổng `3306`.
2. Mở file cấu hình tại: `backend/src/main/resources/application.properties`.
3. Tìm đến dòng `spring.datasource.password` và thay thế nó bằng **mật khẩu MySQL của máy bạn**.
   - *Ví dụ: Nếu mật khẩu MySQL máy bạn là `123456`, hãy sửa thành: `spring.datasource.password=123456`*
4. **Không cần tạo Database!** Chức năng `createDatabaseIfNotExist=true` đã được kích hoạt. Bạn chỉ cần bấm Run (hoặc chạy lệnh `mvn spring-boot:run` trong thư mục `backend`).
5. **Đợi Máy chủ khởi động.** Khi hệ thống chạy thành công, nó sẽ tự động xây dựng các bảng dữ liệu và bơm sẵn một tài khoản Quản trị viên. Trên màn hình Terminal của Backend sẽ in ra dòng chữ:
   ```text
   ====== ĐÃ TẠO TÀI KHOẢN ADMIN MẶC ĐỊNH ======
   Email: admin@gmail.com
   Mật khẩu: admin123
   =============================================
   ```

---

### PHẦN 2: KHỞI ĐỘNG ỨNG DỤNG (FRONTEND - FLUTTER)

1. Mở thư mục `event_ticket_app` bằng Android Studio hoặc VS Code.
2. Mở Terminal và chạy lệnh:
   ```bash
   flutter pub get
   ```
3. Chạy Ứng dụng trên máy ảo (Emulator) hoặc điện thoại thật.
4. Tại màn hình Đăng nhập của App, hãy sử dụng tài khoản Admin vừa được tạo tự động để bắt đầu sử dụng:
   - **Tài khoản:** `admin@gmail.com`
   - **Mật khẩu:** `admin123`

---

## 📱 Cấu trúc Phân quyền (Roles)

Hệ thống cung cấp 3 vai trò:
1. **ADMIN (Quản trị viên):** 
   - Có toàn quyền hệ thống. 
   - Quản lý toàn bộ Danh sách Sự kiện, Người dùng, và Lịch sử Check-in.
   - Trách nhiệm: Tạo ra các tài khoản ORGANIZER (Ban Tổ Chức) và giao cho họ.
2. **ORGANIZER (Ban Tổ Chức):**
   - Đăng nhập vào hệ thống để tổ chức sự kiện.
   - Sở hữu màn hình Quét mã QR riêng biệt và tiến hành xác thực bằng Camera chụp ảnh.
3. **USER (Khán giả/Người dùng):**
   - Tạo tài khoản, cập nhật hồ sơ cá nhân.
   - Lướt xem các sự kiện đang mở và đăng ký (mua vé).
   - Truy cập mã QR cá nhân để xuất trình tại cổng sự kiện.

---

Chúc bạn có trải nghiệm tuyệt vời với **EventQR**! Nếu gặp bất kỳ lỗi gì, hãy kiểm tra lại kết nối MySQL của bạn.