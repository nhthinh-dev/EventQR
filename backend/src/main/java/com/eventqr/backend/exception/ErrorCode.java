package com.eventqr.backend.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {
    VALIDATION_ERROR(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ."),
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "Email hoặc mật khẩu không đúng."),
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."),
    FORBIDDEN(HttpStatus.FORBIDDEN, "Bạn không có quyền thực hiện thao tác này."),
    EVENT_NOT_FOUND(HttpStatus.NOT_FOUND, "Không tìm thấy sự kiện."),
    TICKET_NOT_FOUND(HttpStatus.NOT_FOUND, "Vé không hợp lệ."),
    EMAIL_ALREADY_EXISTS(HttpStatus.CONFLICT, "Email này đã được sử dụng."),
    ALREADY_REGISTERED(HttpStatus.CONFLICT, "Bạn đã đăng ký sự kiện này."),
    EVENT_FULL(HttpStatus.CONFLICT, "Sự kiện đã đủ số lượng người tham gia."),
    EVENT_CLOSED(HttpStatus.CONFLICT, "Sự kiện đã đóng đăng ký."), 
    EVENT_EXPIRED(HttpStatus.CONFLICT, "Sự kiện đã kết thúc, không thể đăng ký."),
    EVENT_HAS_BOOKINGS(HttpStatus.CONFLICT, "Không thể xóa sự kiện đã có người đăng ký."),
    TICKET_ALREADY_CHECKED_IN(HttpStatus.CONFLICT, "Vé đã được check-in trước đó."),
    TICKET_WRONG_EVENT(HttpStatus.CONFLICT, "Vé không thuộc sự kiện này."),
    INVALID_ROLE(HttpStatus.BAD_REQUEST, "Quyền không hợp lệ."),
    PHOTO_REQUIRED(HttpStatus.BAD_REQUEST, "Vui lòng chụp ảnh khách hàng trước khi xác nhận."),
    CHECKIN_TOO_EARLY(HttpStatus.BAD_REQUEST, "Chưa đến giờ mở cửa soát vé cho sự kiện này!"),
    CANCEL_TOO_LATE(HttpStatus.BAD_REQUEST, "Đã qua thời hạn hủy vé (chỉ được hủy trước 3 ngày)"),
    ACCOUNT_LOCKED(HttpStatus.FORBIDDEN, "Tài khoản của bạn đã bị khóa!"),
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Đã có lỗi xảy ra.");

    private final HttpStatus status;
    private final String message;

    ErrorCode(HttpStatus status, String message) {
        this.status = status;
        this.message = message;
    }
}
