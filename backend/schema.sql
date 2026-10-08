-- Tạo database nếu chưa có và chọn để sử dụng
CREATE DATABASE IF NOT EXISTS event_ticket_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE event_ticket_db;

-- 1. Bảng users: Lưu người dùng và ban tổ chức
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('USER','ORGANIZER','ADMIN') NOT NULL DEFAULT 'USER',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng events: Lưu thông tin sự kiện
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

-- 3. Bảng bookings: Lưu lịch sử đặt vé của người dùng
CREATE TABLE bookings (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  event_id BIGINT NOT NULL,
  booking_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('CONFIRMED','CANCELLED') NOT NULL DEFAULT 'CONFIRMED',
  CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_bookings_event FOREIGN KEY (event_id) REFERENCES events(id),
  CONSTRAINT uq_bookings_user_event UNIQUE (user_id, event_id)
);

-- 4. Bảng tickets: Vé định danh cấp cho người dùng
CREATE TABLE tickets (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  booking_id BIGINT NOT NULL UNIQUE,
  ticket_code VARCHAR(50) NOT NULL UNIQUE,
  status ENUM('VALID','CHECKED_IN') NOT NULL DEFAULT 'VALID',
  version BIGINT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tickets_booking FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- 5. Bảng check_ins: Lịch sử quét vé tại cổng
CREATE TABLE check_ins (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  ticket_id BIGINT NOT NULL UNIQUE,
  checked_in_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  checked_in_by BIGINT NOT NULL,
  photo_url VARCHAR(500) NULL,
  CONSTRAINT fk_checkins_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id),
  CONSTRAINT fk_checkins_by FOREIGN KEY (checked_in_by) REFERENCES users(id)
);
