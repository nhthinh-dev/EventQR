Event Ticket & QR Check-in — Đặc tả chi tiết (Flutter) v2.0

**TÀI LIỆU ĐẶC TẢ CHI TIẾT ĐỒ ÁN**

**XÂY DỰNG ỨNG DỤNG DI ĐỘNG (FLUTTER) ĐẶT VÉ**

**VÀ QUẢN LÝ THAM GIA SỰ KIỆN BẰNG MÃ QR**

*Event Ticket Booking & QR Check-in System*

**Frontend: Flutter (Dart)  |  Backend: Spring Boot  |  Database: MySQL**

Môn học: Lập trình di động nâng cao (Flutter)

Phiên bản tài liệu: 2.0 — Cập nhật: Tháng 10/2026

|<p>**Giải thích cho người mới**</p><p>Tài liệu này mô tả toàn bộ đồ án theo cách **người chưa từng làm dự án tương tự cũng đọc hiểu được**: từ ý tưởng, kiến trúc, cơ sở dữ liệu, API, màn hình, cho đến kế hoạch làm từng bước (Phase 0 → Phase 5) kèm lệnh cần gõ, đoạn code mẫu, cách kiểm tra "đã xong chưa" và các lỗi hay gặp.</p><p>Phiên bản 2.0 chuyển phần giao diện từ Android thuần (Kotlin) sang **Flutter** để một mã nguồn duy nhất chạy được trên cả Android và iOS. Phần Backend (Spring Boot) và Database (MySQL) giữ nguyên hướng thiết kế, có bổ sung một số điểm còn thiếu (xem mục "Các thay đổi so với v1.0").</p>|
| :- |

# **MỤC LỤC**

|**Mục**|**Nội dung**|**Dành cho ai / Khi nào đọc**|
| :- | :- | :- |
|0|Cách đọc tài liệu & các thay đổi so với v1.0|Đọc đầu tiên|
|1|Tổng quan đề tài (ý tưởng, vì sao chọn Flutter, mục tiêu)|Tất cả mọi người|
|2|Từ điển thuật ngữ cho người mới|Gặp từ lạ thì quay lại tra|
|3|Đối tượng sử dụng (3 vai trò)|Tất cả|
|4|Kiến trúc hệ thống & cấu trúc thư mục Flutter|Trước khi viết code|
|5|Công nghệ sử dụng & cài đặt môi trường|Trước Phase 0|
|6|Thiết kế cơ sở dữ liệu (kèm SQL)|Phase 1|
|7|Chức năng hệ thống chi tiết (kèm code mẫu)|Phase 2, 3, 4|
|8|Đặc tả REST API|Phase 2, 3|
|9|Các màn hình Flutter (UI Flow)|Phase 3, 4|
|10|Phạm vi MVP|Lập kế hoạch|
|11|Các trường hợp lỗi phải xử lý|Phase 2, 3, 5|
|12|Yêu cầu phi chức năng|Phase 5|
|13|Kế hoạch triển khai chi tiết theo Phase (0 → 5)|Phần quan trọng nhất|
|14|Tiêu chí hoàn thành MVP (kịch bản demo 13 bước)|Phase 5|
|15|Định hướng mở rộng & Kết quả dự kiến|Sau MVP|
|PL|Phụ lục A: Lỗi thường gặp & cách xử lý — Phụ lục B: Checklist cuối|Khi bị kẹt|

# **0. CÁCH ĐỌC TÀI LIỆU & CÁC THAY ĐỔI SO VỚI v1.0**
## **0.1. Cách đọc tài liệu này**
- Nếu bạn **chưa biết gì**: đọc lần lượt từ mục 1 đến mục 5, rồi mở mục 2 (Từ điển) bất cứ khi nào gặp từ lạ. Sau đó mới làm theo mục 13.
- Nếu bạn **đã biết một phần**: có thể nhảy thẳng đến mục 13 (kế hoạch từng Phase), quay lại các mục 6–9 khi cần tra cứu chi tiết.
- Các **khung màu** trong tài liệu có ý nghĩa như sau:

|<p>**Giải thích cho người mới**</p><p>Khung xanh lá: giải thích một khái niệm khó bằng ngôn ngữ đơn giản.</p>|
| :- |

|<p>**Ví dụ đời thường**</p><p>Khung tím: ví dụ lấy từ đời sống thường ngày để bạn dễ hình dung.</p>|
| :- |

|<p>**Mẹo**</p><p>Khung xanh dương: mẹo giúp làm nhanh hơn hoặc tránh sai.</p>|
| :- |

|<p>**Lưu ý quan trọng**</p><p>Khung cam: điều quan trọng, nếu bỏ qua rất dễ gặp lỗi.</p>|
| :- |

- Các đoạn chữ **màu đỏ nền xám** như flutter run là lệnh hoặc tên file/biến mà bạn gõ/nhìn thấy trong máy.
- Các khối nền xám dài là **đoạn code mẫu**. Bạn không cần chép y nguyên; hãy hiểu ý rồi tự viết lại, vì chép không hiểu sẽ rất khó sửa lỗi sau này.
## **0.2. Các thay đổi so với v1.0**
Bảng dưới đây tóm tắt những gì đã đổi để bạn đối chiếu với bản cũ.

|**Hạng mục**|**v1.0 (Android thuần)**|**v2.0 (Flutter)**|**Lý do**|
| :- | :- | :- | :- |
|Ngôn ngữ & framework giao diện|Kotlin + Jetpack Compose|**Dart + Flutter**|Một mã nguồn chạy cả Android và iOS; có Hot Reload nên học và sửa giao diện nhanh.|
|Gọi API|Retrofit + OkHttp Interceptor|**Dio** + Interceptor|Dio là thư viện gọi API phổ biến nhất của Flutter, hỗ trợ interceptor tương tự OkHttp.|
|Lưu JWT Token|DataStore / EncryptedSharedPreferences|**flutter\_secure\_storage**|Lưu token vào kho an toàn (Keystore trên Android, Keychain trên iOS).|
|Sinh mã QR|ZXing|**qr\_flutter**|Thư viện vẽ mã QR thành widget, chỉ cần truyền chuỗi.|
|Quét mã QR|CameraX + ML Kit / ZXing|**mobile\_scanner**|Một thư viện làm cả mở camera lẫn giải mã QR, không cần ghép nhiều phần.|
|Quản lý state / DI|ViewModel + StateFlow + Hilt|**flutter\_riverpod**|Riverpod vừa quản lý trạng thái vừa chia sẻ đối tượng dùng chung (thay Hilt).|
|Điều hướng|Navigation Compose|**go\_router**|Khai báo đường dẫn màn hình và tự chuyển hướng theo trạng thái đăng nhập/vai trò.|
|Bảng events|Không có cột người phụ trách|Thêm cột **organizer\_id**|v1.0 nói Organizer quản lý "sự kiện do mình phụ trách" nhưng chưa có chỗ lưu ai phụ trách.|
|API check-in|Body chỉ có ticketCode|Body gồm **ticketCode + eventId**|v1.0 yêu cầu kiểm tra "vé có đúng sự kiện đang quét" nhưng thiếu thông tin sự kiện đang quét.|
|API cho Organizer|Chưa có|Thêm **GET /api/organizer/events** và **GET /api/events/{id}/attendees**|Màn hình My Events và danh sách người check-in cần dữ liệu này.|
|Định dạng lỗi|Chỉ mô tả thông báo|JSON lỗi thống nhất có **errorCode**|Flutter dựa vào errorCode để hiển thị đúng thông báo, không so khớp chuỗi.|
|Cách tạo tài khoản Organizer|Không nói rõ|Nêu rõ cách nâng quyền bằng SQL|API register chỉ tạo USER; cần một cách hợp lý để có tài khoản Organizer khi demo.|
|Độ chi tiết|Tóm tắt|Có từ điển, lệnh cài đặt, code mẫu, checklist, bảng test, lỗi thường gặp|Phục vụ người chưa biết gì.|

# **1. TỔNG QUAN ĐỀ TÀI**
## **1.1. Thông tin đề tài**

|**Thuộc tính**|**Nội dung**|
| :- | :- |
|Tên tiếng Việt|Xây dựng ứng dụng di động (Flutter) đặt vé và quản lý tham gia sự kiện bằng mã QR|
|Tên tiếng Anh|Development of a Flutter Mobile Application for Event Ticket Booking and QR Code Check-in|
|Tên ngắn gọn|Event Ticket & QR Check-in|
|Nền tảng|Ứng dụng di động Flutter (Android, có thể build thêm iOS) + Backend REST API + Cơ sở dữ liệu quan hệ|
|Đối tượng|Sinh viên / CLB / phòng đào tạo tổ chức sự kiện, workshop, hội thảo, cuộc thi|

## **1.2. Ý tưởng cốt lõi**
Ứng dụng cho phép người dùng tìm kiếm, xem thông tin và đăng ký tham gia các sự kiện (workshop, hội thảo, cuộc thi, hoạt động câu lạc bộ). Sau khi đăng ký thành công, hệ thống cấp một **vé điện tử (Ticket)** được thể hiện dưới dạng **mã QR**. Khi người dùng đến sự kiện, ban tổ chức (Organizer) dùng camera điện thoại quét mã QR trên vé; Backend sẽ kiểm tra vé có hợp lệ không và cập nhật trạng thái check-in ngay lập tức.

Nói cách khác, đề tài số hóa toàn bộ quy trình vốn thường làm thủ công bằng giấy hoặc Excel:

**Đăng ký  →  Cấp vé  →  Sinh mã QR  →  Quét QR  →  Xác thực  →  Check-in  →  Lưu lịch sử**

|<p>**Ví dụ đời thường**</p><p>Hãy nghĩ đến việc đi xem phim. Bạn đặt vé trên điện thoại, app đưa cho bạn một mã QR. Đến rạp, nhân viên quét mã đó; máy báo "hợp lệ" và bạn được vào. Nếu bạn đưa lại đúng mã đó lần thứ hai, máy báo "vé đã sử dụng".</p><p>Đồ án này làm đúng như vậy, nhưng cho sự kiện của trường/CLB: **User = khán giả**, **Organizer = nhân viên soát vé**, **Backend + Database = hệ thống quản lý rạp** ghi nhớ vé nào đã dùng.</p>|
| :- |

## **1.3. Luồng nghiệp vụ chính (bức tranh tổng thể)**
**Sơ đồ luồng tổng thể**

Người dùng

`   `|

`   `v

Đăng ký / Đăng nhập  --(JWT)-->  Hệ thống xác nhận "bạn là ai"

`   `|

`   `v

Xem danh sách sự kiện  -->  Chọn 1 sự kiện  -->  Xem chi tiết

`   `|

`   `v

Bấm "Đăng ký tham gia"

`   `|

`   `v

Backend kiểm tra: đã đăng ký chưa? sự kiện còn mở không? còn chỗ không?

`   `|

`   `v (hợp lệ)

Tạo Booking  -->  Tạo Ticket (sinh ticket\_code duy nhất)

`   `|

`   `v

Ứng dụng Flutter hiển thị Ticket dưới dạng mã QR

`   `|

`   `|  (đến ngày sự kiện, người dùng mang điện thoại đến)

`   `v

Organizer mở camera --> Quét QR --> Lấy được ticket\_code

`   `|

`   `v

POST /api/check-ins { ticketCode, eventId }  -->  Backend xác thực vé

`   `|

`   `v

CHECK-IN THÀNH CÔNG  (trạng thái vé: VALID -> CHECKED\_IN)

## **1.4. Lý do chọn đề tài**
Trong môi trường trường học và các tổ chức sinh viên, việc quản lý đăng ký và xác nhận người tham gia sự kiện theo cách thủ công thường gặp nhiều vấn đề:

- Khó quản lý danh sách người tham gia khi số lượng lớn.
- Khó kiểm tra vé giấy, dễ bị làm giả hoặc dùng lại.
- Dễ xảy ra tình trạng đăng ký trùng lặp.
- Khó kiểm soát chính xác số người so với sức chứa (capacity).
- Check-in thủ công (ký tên, dò danh sách giấy) mất nhiều thời gian, gây ùn tắc ở cổng vào.
- Khó thống kê số người tham gia thực tế sau sự kiện.

Ứng dụng giải quyết các vấn đề trên bằng cách số hóa quy trình. Đồng thời đề tài tích hợp nhiều mảng kiến thức quan trọng của lập trình di động:

- Xây dựng ứng dụng đa nền tảng với Flutter và ngôn ngữ Dart.
- Sử dụng camera và quét mã QR; sinh và hiển thị mã QR.
- Giao tiếp với REST API (Dio), xử lý bất đồng bộ (async/await).
- Quản lý trạng thái ứng dụng (Riverpod) và điều hướng (go\_router).
- Xác thực (Authentication) và phân quyền (Authorization) bằng JWT.
- Xây dựng Backend với Spring Boot; thiết kế và thao tác cơ sở dữ liệu MySQL.
- Xử lý nghiệp vụ thực tế và các tình huống lỗi.
## **1.5. Vì sao chọn Flutter?**

|<p>**Giải thích cho người mới**</p><p>**Flutter** là bộ công cụ (framework) do Google tạo ra để viết ứng dụng di động. Bạn viết code bằng ngôn ngữ **Dart**; cùng một mã nguồn có thể build ra ứng dụng Android, iOS (và cả web/desktop).</p><p>Mọi thứ trên màn hình trong Flutter là một **Widget** (nút bấm, chữ, ảnh, danh sách, thậm chí cả khoảng trống đều là widget). Bạn ghép các widget nhỏ thành màn hình hoàn chỉnh, giống xếp các khối LEGO.</p>|
| :- |

|**Tiêu chí**|**Android thuần (Kotlin)**|**Flutter (Dart)**|
| :- | :- | :- |
|Số nền tảng chạy được|Chỉ Android|Android và iOS từ cùng một mã nguồn|
|Xem kết quả khi sửa code|Phải build lại, hơi lâu|Hot Reload: lưu file là thấy thay đổi trong vài giây|
|Thư viện QR/Camera|CameraX, ML Kit, ZXing|qr\_flutter, mobile\_scanner (gói sẵn, dùng đơn giản)|
|Độ khó cho người mới|Cần học Kotlin + XML/Compose + vòng đời Activity|Cần học Dart + Widget; ít khái niệm hệ điều hành hơn|
|Phù hợp đồ án này|Có|Có, và tiết kiệm thời gian hơn nếu muốn demo cả iPhone|

|<p>**Lưu ý quan trọng**</p><p>Việc quét QR cần camera thật. Máy ảo (emulator) chỉ có camera giả nên rất khó thử quét. Hãy chuẩn bị ít nhất **một điện thoại thật** để test từ Phase 4. Cách bố trí thiết bị gợi ý nằm trong Phase 4.</p>|
| :- |

## **1.6. Mục tiêu đề tài**
### **Về ứng dụng Flutter**
- Xây dựng giao diện cho người tham gia (User) và ban tổ chức (Organizer) trong cùng một ứng dụng, tự chuyển giao diện theo vai trò sau khi đăng nhập.
- Xem danh sách và chi tiết sự kiện; đăng ký sự kiện; xem vé cá nhân.
- Hiển thị mã QR của vé; quét mã QR bằng camera để check-in.
### **Về Backend**
- Xây dựng REST API bằng Java Spring Boot; xác thực bằng JWT.
- Quản lý User, Event, Booking, Ticket; xử lý nghiệp vụ Check-in và các ràng buộc liên quan.
### **Về Database**
- Dùng MySQL lưu dữ liệu người dùng, sự kiện, đăng ký, vé và lịch sử check-in một cách nhất quán, không trùng lặp, đảm bảo toàn vẹn dữ liệu.
# **2. TỪ ĐIỂN THUẬT NGỮ CHO NGƯỜI MỚI**
Bảng này giải thích các từ sẽ gặp thường xuyên. Bạn không cần thuộc ngay; hãy quay lại tra khi gặp.
## **2.1. Thuật ngữ chung về hệ thống**

|**Thuật ngữ**|**Giải thích đơn giản**|**Trong đồ án này**|
| :- | :- | :- |
|Frontend|Phần người dùng nhìn thấy và chạm vào (giao diện).|Ứng dụng Flutter trên điện thoại.|
|Backend|Phần chạy ngầm trên máy chủ, xử lý logic và truy cập dữ liệu.|Chương trình Spring Boot.|
|Database (CSDL)|Nơi lưu dữ liệu lâu dài, giống một tập các bảng Excel có quy tắc chặt chẽ.|MySQL với 5 bảng.|
|API|Tập "cửa giao dịch" mà Backend mở ra để ứng dụng gọi vào xin hoặc gửi dữ liệu.|Ví dụ: cửa lấy danh sách sự kiện.|
|REST API|Kiểu API dùng địa chỉ web (URL) và các động từ HTTP để thao tác tài nguyên.|GET /api/events lấy danh sách sự kiện.|
|JSON|Định dạng văn bản để trao đổi dữ liệu, dạng {"tên": "giá trị"}.|Mọi request/response đều là JSON.|
|Endpoint|Một địa chỉ cụ thể của API.|/api/auth/login.|
|HTTP method|Động từ cho biết bạn muốn làm gì: GET (lấy), POST (tạo mới/gửi), PUT (cập nhật), DELETE (xóa).|POST /api/events/5/book = đăng ký sự kiện số 5.|
|HTTP status code|Con số Backend trả về cho biết kết quả: 200 thành công, 201 đã tạo, 400 dữ liệu sai, 401 chưa đăng nhập, 403 không đủ quyền, 404 không tìm thấy, 409 xung đột, 500 lỗi máy chủ.|Đăng ký trùng sự kiện trả 409.|
|Authentication (xác thực)|Trả lời câu hỏi "Bạn là ai?" (đăng nhập).|Email + mật khẩu.|
|Authorization (phân quyền)|Trả lời câu hỏi "Bạn được làm gì?".|USER không được tạo sự kiện.|
|JWT (JSON Web Token)|Một chuỗi ký tự dài do server cấp sau khi đăng nhập, như "vòng tay" bạn đeo để chứng minh mình đã được kiểm tra. Mỗi lần gọi API bạn đưa chuỗi này ra.|Gửi trong header Authorization: Bearer <token>.|
|Hash / BCrypt|Biến mật khẩu thành chuỗi khác không thể dịch ngược. Server chỉ lưu chuỗi băm.|Cột password trong bảng users.|
|ORM / JPA / Hibernate|Công cụ cho phép làm việc với bảng DB bằng đối tượng Java, ít phải viết SQL tay.|Entity User ánh xạ bảng users.|
|Entity|Một lớp Java đại diện cho một bảng trong DB.|User, Event, Booking, Ticket, CheckIn.|
|DTO|Lớp Java chỉ chứa dữ liệu dùng để nhận/gửi qua API (không đưa Entity trực tiếp ra ngoài).|LoginRequest, TicketResponse.|
|Transaction (giao dịch)|Nhóm thao tác "làm hết hoặc không làm gì". Một bước lỗi thì tất cả được hoàn tác (rollback).|Tạo Booking + Ticket phải cùng thành công.|
|Foreign Key (khóa ngoại)|Cột trỏ sang bảng khác, đảm bảo không có dữ liệu "mồ côi".|bookings.user\_id trỏ tới users.id.|
|UNIQUE|Ràng buộc cấm hai dòng có cùng giá trị ở cột đó.|Email, ticket\_code không được trùng.|
|MVP|Phiên bản tối thiểu nhưng chạy trọn vẹn luồng chính.|Đăng ký → vé QR → check-in.|
|QR Code|Hình vuông đen trắng "viết" một chuỗi chữ thành hình để máy quét đọc lại.|Chứa chuỗi ticket\_code.|
|Postman|Phần mềm dùng để thử gọi API mà chưa cần có ứng dụng.|Test Backend ở Phase 2.|

## **2.2. Thuật ngữ riêng của Flutter / Dart**

|**Thuật ngữ**|**Giải thích đơn giản**|**Trong đồ án này**|
| :- | :- | :- |
|Dart|Ngôn ngữ lập trình dùng để viết Flutter. Cú pháp gần giống Java/Kotlin/JavaScript.|Toàn bộ code ứng dụng.|
|Widget|Mọi thành phần giao diện: Text, Button, Image, ListView, Scaffold...|Màn hình = cây widget lồng nhau.|
|StatelessWidget|Widget "tĩnh": cho dữ liệu nào hiển thị đúng như vậy, không tự thay đổi.|Thẻ sự kiện (EventCard).|
|StatefulWidget|Widget có dữ liệu bên trong thay đổi theo thời gian, gọi setState để vẽ lại.|Màn hình quét QR giữ cờ "đang xử lý".|
|State (trạng thái)|Dữ liệu quyết định giao diện hiện tại (đang tải, có lỗi, danh sách sự kiện...).|Đổi state thì giao diện tự vẽ lại.|
|Riverpod / Provider|Thư viện giữ và chia sẻ state cùng đối tượng dùng chung. "Provider" là một nơi cung cấp dữ liệu; widget "lắng nghe" provider bằng ref.watch.|eventsProvider cung cấp danh sách sự kiện.|
|Future / async / await|Cách chờ một việc lâu (gọi mạng) mà không làm đơ giao diện. await nghĩa là "chờ kết quả rồi mới chạy dòng tiếp".|Mọi lần gọi API.|
|Interceptor|"Trạm kiểm soát" chặn mọi request/response để làm gì đó trước khi đi tiếp.|Tự gắn JWT vào mọi request.|
|Route / Điều hướng|Địa chỉ của một màn hình và cách chuyển giữa các màn hình.|/events/5 mở chi tiết sự kiện 5.|
|Package (pub.dev)|Thư viện có sẵn do cộng đồng viết, thêm bằng flutter pub add.|dio, qr\_flutter, mobile\_scanner...|
|pubspec.yaml|File khai báo tên dự án và danh sách package.|Nằm ở thư mục gốc dự án Flutter.|
|Emulator / Simulator|Điện thoại ảo chạy trên máy tính (Emulator = Android, Simulator = iOS).|Test giao diện.|
|Hot Reload / Hot Restart|Hot Reload: nạp lại code trong tích tắc, giữ nguyên màn hình. Hot Restart: khởi động lại app từ đầu.|Phím r và R trong terminal khi flutter run.|
|Repository|Lớp trung gian lo việc lấy dữ liệu (gọi API) để màn hình khỏi biết chi tiết mạng.|EventRepository, TicketRepository.|
|Model|Lớp Dart đại diện dữ liệu nhận từ API, có hàm fromJson để chuyển JSON thành đối tượng.|EventModel, TicketModel.|

# **3. ĐỐI TƯỢNG SỬ DỤNG (ROLES)**
Hệ thống có 3 vai trò (role). Mỗi vai trò có quyền hạn khác nhau. Vai trò được lưu trong cột role của bảng users, được ghi vào JWT khi đăng nhập, và được Backend (Spring Security) kiểm tra trước khi cho phép dùng từng API.

|<p>**Ví dụ đời thường**</p><p>Giống một buổi hòa nhạc: khán giả (USER) có vé để vào; nhân viên soát vé (ORGANIZER) có máy quét; quản lý sân khấu (ADMIN) có chìa khóa mọi phòng.</p>|
| :- |

## **3.1. USER — Người tham gia**
Đây là vai trò mặc định khi tạo tài khoản mới qua ứng dụng. User có thể:

- Đăng ký tài khoản, đăng nhập, đăng xuất.
- Xem danh sách sự kiện đang mở và chi tiết một sự kiện (mô tả, thời gian, địa điểm, số chỗ còn lại).
- Đăng ký tham gia sự kiện.
- Xem danh sách vé của mình (My Tickets) và trạng thái từng vé (VALID / CHECKED\_IN).
- Hiển thị mã QR của từng vé.
## **3.2. ORGANIZER — Ban tổ chức**
Vai trò dành cho người phụ trách vận hành sự kiện tại hiện trường. Organizer có thể:

- Tạo, sửa, xóa sự kiện **do chính mình phụ trách**.
- Xem danh sách người đã đăng ký của từng sự kiện.
- Mở camera quét mã QR trên vé của người tham gia.
- Kiểm tra vé hợp lệ và xác nhận check-in; xem danh sách người đã check-in.

|<p>**Lưu ý quan trọng**</p><p>**Cách có tài khoản Organizer:** API đăng ký trong ứng dụng luôn tạo tài khoản USER (nếu cho tự chọn Organizer thì ai cũng tự phong mình làm Organizer, rất không an toàn). Trong MVP, bạn đăng ký một tài khoản bình thường rồi nâng quyền bằng một câu SQL trong MySQL Workbench:</p><p>UPDATE users SET role = 'ORGANIZER' WHERE email = 'organizer@example.com';</p><p>Sau đó đăng nhập lại để nhận token mới mang vai trò mới.</p>|
| :- |

## **3.3. ADMIN — Quản trị viên (mở rộng, không bắt buộc trong MVP)**
- Quản lý tài khoản User/Organizer (khóa/mở khóa).
- Quản lý toàn bộ Event trên hệ thống và xem thống kê tổng thể.

|<p>**Mẹo**</p><p>ADMIN không bắt buộc hoàn thiện trong MVP. Hãy làm xong USER và ORGANIZER trước, sau đó mới mở rộng ADMIN nếu còn thời gian.</p>|
| :- |

# **4. KIẾN TRÚC HỆ THỐNG**
## **4.1. Mô hình 3 tầng**
Hệ thống chia làm 3 tầng. Mỗi tầng chỉ làm một nhiệm vụ và chỉ "nói chuyện" với tầng kề nó. Cách chia này giúp khi có lỗi bạn biết ngay lỗi nằm ở tầng nào.

**Sơ đồ kiến trúc 3 tầng**

+---------------------------------+

|        ỨNG DỤNG FLUTTER         |

|                                 |

|  Dart + Flutter widgets         |

|  Riverpod (quản lý state)       |

|  go\_router (điều hướng)         |

|  Dio (gọi API)                  |

|  qr\_flutter (sinh QR)           |

|  mobile\_scanner (quét QR)       |

|  flutter\_secure\_storage (token) |

+----------------+----------------+

`                 `|

`                 `| REST API (JSON qua HTTP/HTTPS)

`                 `| Header: Authorization: Bearer <JWT>

`                 `v

+---------------------------------+

|           SPRING BOOT           |

|                                 |

|  Controller (nhận request)      |

|  Service    (xử lý nghiệp vụ)   |

|  Repository (thao tác DB)       |

|  Spring Security + JWT Filter   |

|  JPA / Hibernate (ORM)          |

+----------------+----------------+

`                 `|

`                 `| JPA / SQL

`                 `v

+---------------------------------+

|              MYSQL              |

|                                 |

|  users | events | bookings      |

|  tickets | check\_ins            |

+---------------------------------+

## **4.2. Vai trò từng tầng**

|**Tầng**|**Trách nhiệm chính**|**Công nghệ**|
| :- | :- | :- |
|Flutter (Presentation)|Hiển thị giao diện, nhận thao tác của người dùng, gọi API, hiển thị/quét QR.|Flutter, Dart, Riverpod, go\_router, Dio, qr\_flutter, mobile\_scanner|
|Backend (Business Logic)|Xác thực người dùng, kiểm tra nghiệp vụ (đủ chỗ chưa, vé hợp lệ chưa...), điều phối dữ liệu.|Spring Boot, Spring Security, JWT, Spring Data JPA|
|Database (Persistence)|Lưu dữ liệu bền vững, bảo đảm toàn vẹn qua khóa chính, khóa ngoại, UNIQUE.|MySQL, MySQL Workbench|

## **4.3. Kiến trúc phía Flutter**
Phía Flutter tổ chức theo kiểu **"chia theo tính năng" (feature-first)**: mỗi tính năng (đăng nhập, sự kiện, vé...) có thư mục riêng chứa đủ màn hình, logic và code gọi API của chính nó. Bên trong mỗi tính năng có 2 lớp:

- **Presentation (hiển thị):** các màn hình (Screen) và widget, cùng Controller/Provider giữ state cho màn hình đó.
- **Data (dữ liệu):** Model (hình dạng dữ liệu) và Repository (gọi API qua Dio, chuyển JSON thành Model).

|<p>**Ví dụ đời thường**</p><p>Hãy hình dung một nhà hàng:</p><p>**Widget/Screen** = khách và thực đơn (chỉ hiển thị, nhận yêu cầu). **Provider/Controller** = nhân viên phục vụ (nhận yêu cầu, giữ trạng thái "đang chờ món"). **Repository** = quản lý bếp (biết lấy nguyên liệu ở đâu). **Dio/ApiClient** = shipper chạy đi lấy nguyên liệu từ Backend.</p><p>Khách không cần biết bếp lấy nguyên liệu ở đâu. Tương tự, màn hình không cần biết API gọi thế nào; nhờ vậy sửa một phần không làm hỏng phần khác.</p>|
| :- |

### **Cấu trúc thư mục đề xuất**
**Cây thư mục lib/**

event\_ticket\_app/

├─ pubspec.yaml                  # khai báo package

├─ android/  ios/                # phần dành riêng cho từng nền tảng

└─ lib/                          # TOÀN BỘ code Dart nằm ở đây

`   `├─ main.dart                  # điểm khởi chạy ứng dụng

`   `├─ app.dart                   # MaterialApp.router + theme

`   `├─ core/                      # thứ dùng chung cho mọi tính năng

`   `│  ├─ config/app\_config.dart       # địa chỉ Backend (baseUrl)

`   `│  ├─ network/api\_client.dart      # Dio + Interceptor gắn JWT

`   `│  ├─ storage/token\_storage.dart   # lưu/đọc/xóa token an toàn

`   `│  ├─ errors/app\_exception.dart    # chuyển lỗi mạng/API thành thông báo

`   `│  ├─ router/app\_router.dart       # khai báo các route (go\_router)

`   `│  └─ widgets/                     # widget dùng chung: loading, error...

`   `└─ features/

`      `├─ auth/        (data/ + presentation/: login, register, auth\_controller)

`      `├─ events/      (data/ + presentation/: event\_list, event\_detail)

`      `├─ booking/     (data/ + presentation/: booking\_success)

`      `├─ tickets/     (data/ + presentation/: my\_tickets, ticket\_qr)

`      `├─ organizer/   (data/ + presentation/: organizer\_home, my\_events,

`      `│                scan\_qr, check\_in\_result)

`      `└─ profile/     (presentation/: profile\_screen)

## **4.4. Đường đi của dữ liệu khi mở một màn hình**
Hiểu đường đi này là hiểu 80% cách app hoạt động. Ví dụ màn hình danh sách sự kiện:

**Luồng dữ liệu**

EventListScreen (widget)

`   `|  ref.watch(eventsProvider)        <- "tôi muốn danh sách sự kiện"

`   `v

eventsProvider (Riverpod)

`   `|  gọi eventRepository.getEvents()

`   `v

EventRepository

`   `|  dio.get('/api/events')           <- Interceptor tự gắn JWT

`   `v

Backend Spring Boot  ->  MySQL

`   `|

`   `v  trả JSON

EventRepository: chuyển JSON -> List<EventModel>

`   `|

`   `v

eventsProvider: state = loading -> data (hoặc error)

`   `|

`   `v

EventListScreen tự vẽ lại: vòng xoay -> danh sách (hoặc thông báo lỗi)

|<p>**Giải thích cho người mới**</p><p>Điểm quan trọng: màn hình **không** tự gọi mạng. Nó chỉ "nhìn" vào provider. Khi provider đổi trạng thái (đang tải → có dữ liệu → lỗi), Flutter tự vẽ lại phần giao diện liên quan.</p>|
| :- |

# **5. CÔNG NGHỆ SỬ DỤNG & CÀI ĐẶT MÔI TRƯỜNG**
## **5.1. Flutter (Frontend)**

|**Công nghệ**|**Dùng để làm gì**|**Ghi chú**|
| :- | :- | :- |
|Flutter SDK|Bộ công cụ build và chạy ứng dụng.|Cài từ trang flutter.dev; kiểm tra bằng flutter doctor.|
|Dart|Ngôn ngữ lập trình của Flutter.|Đi kèm Flutter SDK, không cần cài riêng.|
|Android Studio hoặc VS Code|Trình soạn code. Android Studio còn cung cấp Android SDK và máy ảo.|Cần cài thêm plugin Flutter và Dart.|
|flutter\_riverpod|Quản lý state và chia sẻ đối tượng dùng chung (Dio, Repository...).|Nếu thấy khó, có thể thay bằng provider đơn giản hơn.|
|go\_router|Điều hướng giữa các màn hình theo đường dẫn, có redirect theo đăng nhập/vai trò.|Do đội Flutter duy trì.|
|dio|Gọi REST API, cấu hình timeout, interceptor.|Thay cho Retrofit + OkHttp.|
|flutter\_secure\_storage|Lưu JWT token vào kho an toàn của hệ điều hành.|Không lưu token bằng SharedPreferences thường.|
|qr\_flutter|Vẽ mã QR từ một chuỗi (hiển thị vé).|Widget QrImageView.|
|mobile\_scanner|Mở camera và quét/giải mã QR theo thời gian thực.|Widget MobileScanner.|
|intl|Định dạng ngày giờ theo tiếng Việt.|Ví dụ DateFormat("dd/MM/yyyy HH:mm").|
|cached\_network\_image|Tải và lưu tạm ảnh sự kiện, có ảnh chờ khi đang tải.|Tùy chọn nhưng nên dùng.|

|<p>**Mẹo**</p><p>Khi thêm package, dùng lệnh flutter pub add tên\_gói. Lệnh này tự chọn phiên bản mới nhất tương thích và ghi vào pubspec.yaml. Không cần tự gõ số phiên bản. Nếu sau này code mẫu trong tài liệu khác với tài liệu chính thức của package, **hãy tin tài liệu chính thức** (trang của package trên pub.dev), vì API có thể đã đổi.</p>|
| :- |

## **5.2. Backend**

|**Công nghệ**|**Dùng để làm gì**|
| :- | :- |
|Java 17+|Ngôn ngữ lập trình Backend (Spring Boot 3 yêu cầu từ Java 17).|
|Spring Boot|Framework giúp dựng ứng dụng Java nhanh, ít phải cấu hình.|
|Spring Web (MVC)|Viết REST API qua các Controller.|
|Spring Security|Xác thực và phân quyền.|
|JWT (thư viện jjwt)|Sinh và kiểm tra token, không cần lưu session trên server.|
|Spring Data JPA + Hibernate|ORM: thao tác DB bằng đối tượng Java.|
|Maven|Quản lý thư viện và build project.|
|Bean Validation|Kiểm tra dữ liệu đầu vào (email đúng dạng, mật khẩu đủ dài...).|
|Lombok (tùy chọn)|Tự sinh getter/setter để code Java gọn hơn.|

## **5.3. Cơ sở dữ liệu & công cụ hỗ trợ**

|**Công nghệ**|**Dùng để làm gì**|
| :- | :- |
|MySQL 8|Hệ quản trị cơ sở dữ liệu quan hệ.|
|MySQL Workbench|Công cụ trực quan để vẽ ERD, tạo bảng, xem dữ liệu.|
|IntelliJ IDEA|Trình soạn code cho Backend Java.|
|Postman|Test API thủ công trước khi gắn vào Flutter.|
|Flutter DevTools|Công cụ đi kèm Flutter để xem log, kiểm tra widget, theo dõi các request mạng.|
|Git & GitHub|Quản lý phiên bản mã nguồn và làm việc nhóm.|

## **5.4. Cài đặt môi trường (làm trong Phase 0)**
1. **Cài JDK 17** (hoặc mới hơn). Kiểm tra: mở terminal gõ java -version.
1. **Cài MySQL 8 và MySQL Workbench.** Ghi nhớ mật khẩu tài khoản root bạn đặt khi cài. Mở Workbench, kết nối thử với localhost:3306.
1. **Cài IntelliJ IDEA** (bản Community là đủ) để làm Backend.
1. **Cài Postman** để test API.
1. **Cài Git**, tạo tài khoản GitHub.
1. **Cài Flutter SDK:** tải từ trang chính thức flutter.dev, giải nén vào thư mục không có dấu cách (ví dụ C:\src\flutter), thêm thư mục bin của Flutter vào biến môi trường PATH.
1. **Cài Android Studio:** mở lần đầu cho nó tải Android SDK. Vào SDK Manager cài thêm "Android SDK Command-line Tools". Cài plugin **Flutter** (plugin Dart sẽ cài kèm).
1. **Tạo máy ảo Android:** Android Studio → Device Manager → Create Device (chọn Pixel, chọn bản Android mới).
1. **Chạy `flutter doctor`** trong terminal. Lệnh này kiểm tra mọi thứ và báo mục nào còn thiếu. Nếu báo chưa chấp nhận giấy phép Android, chạy flutter doctor --android-licenses và bấm y cho các câu hỏi.
1. (Chỉ khi cần chạy iOS) Cần máy Mac có Xcode. Nếu dùng Windows/Linux, bỏ qua bước này và chỉ làm Android.

|<p>**Lưu ý quan trọng**</p><p>Mục tiêu của Phase 0 là thấy dòng chữ **"No issues found!"** (hoặc ít nhất các mục Flutter, Android toolchain, Android Studio có dấu tích xanh) khi chạy flutter doctor. Đừng bắt đầu viết code khi mục này còn đỏ, vì lỗi môi trường rất khó phân biệt với lỗi code.</p>|
| :- |

# **6. THIẾT KẾ CƠ SỞ DỮ LIỆU**
MVP chỉ cần **5 bảng**. Giới hạn số bảng giúp bạn tập trung làm trọn luồng nghiệp vụ cốt lõi trước khi mở rộng.

**Quan hệ giữa các bảng**

users (Organizer) 1 ----< N events



users (User)      1 ----< N bookings

events            1 ----< N bookings



bookings          1 ---- 1 tickets

tickets           1 ---- 0..1 check\_ins



Ký hiệu: 1 ----< N nghĩa là "một bên có nhiều bên kia"

Diễn giải quan hệ:

- Một USER (vai trò Organizer) phụ trách nhiều EVENT (1 - N). **Đây là điểm mới của v2.0** (cột organizer\_id).
- Một USER có thể có nhiều BOOKING; một EVENT có thể có nhiều BOOKING (1 - N).
- Mỗi BOOKING hợp lệ sinh đúng 1 TICKET (1 - 1).
- Mỗi TICKET có tối đa 1 bản ghi CHECK\_IN (1 - 0..1).

|<p>**Giải thích cho người mới**</p><p>**Vì sao cần cả Booking lẫn Ticket?** Booking là "việc đăng ký" (ai, sự kiện nào, lúc nào, còn hiệu lực không). Ticket là "tấm vé" dùng để vào cửa (mã vé, đã dùng chưa). Tách hai thứ giúp sau này mở rộng dễ hơn, ví dụ một booking có nhiều vé hoặc nhiều loại vé.</p>|
| :- |

## **6.1. Bảng users**

|**Cột**|**Kiểu dữ liệu**|**Ghi chú**|
| :- | :- | :- |
|id|BIGINT, PK, AUTO\_INCREMENT|Khóa chính (số tự tăng, định danh duy nhất).|
|name|VARCHAR(100)|Họ tên người dùng.|
|email|VARCHAR(150), UNIQUE|Dùng để đăng nhập, phải duy nhất.|
|password|VARCHAR(255)|Mật khẩu đã băm bằng BCrypt, tuyệt đối không lưu mật khẩu gốc.|
|role|ENUM('USER','ORGANIZER','ADMIN')|Phân quyền.|
|created\_at|DATETIME|Thời điểm tạo tài khoản.|

## **6.2. Bảng events**

|**Cột**|**Kiểu dữ liệu**|**Ghi chú**|
| :- | :- | :- |
|id|BIGINT, PK, AUTO\_INCREMENT|Khóa chính.|
|organizer\_id|BIGINT, FK -> users.id|**Mới ở v2.0.** Organizer phụ trách sự kiện.|
|title|VARCHAR(200)|Tên sự kiện.|
|description|TEXT|Mô tả chi tiết.|
|image\_url|VARCHAR(500)|Đường dẫn ảnh đại diện (MVP chỉ cần dán URL).|
|location|VARCHAR(255)|Địa điểm tổ chức.|
|start\_time|DATETIME|Thời gian bắt đầu.|
|end\_time|DATETIME|Thời gian kết thúc.|
|capacity|INT|Số người tham gia tối đa (phải > 0).|
|status|ENUM('OPEN','CLOSED')|Mở hay đóng đăng ký.|
|created\_at|DATETIME|Thời điểm tạo sự kiện.|

## **6.3. Bảng bookings**

|**Cột**|**Kiểu dữ liệu**|**Ghi chú**|
| :- | :- | :- |
|id|BIGINT, PK, AUTO\_INCREMENT|Khóa chính.|
|user\_id|BIGINT, FK -> users.id|Người đăng ký.|
|event\_id|BIGINT, FK -> events.id|Sự kiện được đăng ký.|
|booking\_time|DATETIME|Thời điểm đăng ký.|
|status|ENUM('CONFIRMED','CANCELLED')|Trạng thái đăng ký (MVP chỉ dùng CONFIRMED).|

|<p>**Mẹo**</p><p>Thêm ràng buộc **UNIQUE(user\_id, event\_id)** để chặn đăng ký trùng ngay ở tầng database. Kể cả khi code Backend có lỗi hoặc hai yêu cầu đến cùng lúc, database vẫn từ chối bản ghi thứ hai. Đây gọi là "lớp bảo vệ cuối cùng".</p>|
| :- |

## **6.4. Bảng tickets**

|**Cột**|**Kiểu dữ liệu**|**Ghi chú**|
| :- | :- | :- |
|id|BIGINT, PK, AUTO\_INCREMENT|Khóa chính.|
|booking\_id|BIGINT, FK -> bookings.id, UNIQUE|Mỗi booking chỉ có 1 ticket.|
|ticket\_code|VARCHAR(50), UNIQUE|Mã định danh duy nhất, ví dụ EVT-2026-A8F31. Chính chuỗi này được đưa vào QR.|
|status|ENUM('VALID','CHECKED\_IN')|Trạng thái vé.|
|version|BIGINT (mặc định 0)|**Mới ở v2.0.** Số phiên bản dùng để chống hai máy quét cùng lúc check-in một vé (xem mục 7.5).|
|created\_at|DATETIME|Thời điểm tạo vé.|

## **6.5. Bảng check\_ins**

|**Cột**|**Kiểu dữ liệu**|**Ghi chú**|
| :- | :- | :- |
|id|BIGINT, PK, AUTO\_INCREMENT|Khóa chính.|
|ticket\_id|BIGINT, FK -> tickets.id, UNIQUE|Vé được check-in (UNIQUE = mỗi vé chỉ check-in 1 lần).|
|checked\_in\_at|DATETIME|Thời điểm check-in.|
|checked\_in\_by|BIGINT, FK -> users.id|Organizer thực hiện quét vé.|

## **6.6. Script SQL tạo bảng (schema.sql)**
Bạn có thể chạy nguyên script này trong MySQL Workbench (File → Open SQL Script → bấm biểu tượng tia sét). Thứ tự tạo bảng quan trọng vì bảng sau tham chiếu bảng trước.

**schema.sql**

CREATE DATABASE IF NOT EXISTS event\_ticket\_db

`  `CHARACTER SET utf8mb4 COLLATE utf8mb4\_unicode\_ci;

USE event\_ticket\_db;



CREATE TABLE users (

`  `id          BIGINT PRIMARY KEY AUTO\_INCREMENT,

`  `name        VARCHAR(100) NOT NULL,

`  `email       VARCHAR(150) NOT NULL UNIQUE,

`  `password    VARCHAR(255) NOT NULL,

`  `role        ENUM('USER','ORGANIZER','ADMIN') NOT NULL DEFAULT 'USER',

`  `created\_at  DATETIME NOT NULL DEFAULT CURRENT\_TIMESTAMP

);



CREATE TABLE events (

`  `id            BIGINT PRIMARY KEY AUTO\_INCREMENT,

`  `organizer\_id  BIGINT NOT NULL,

`  `title         VARCHAR(200) NOT NULL,

`  `description   TEXT,

`  `image\_url     VARCHAR(500),

`  `location      VARCHAR(255) NOT NULL,

`  `start\_time    DATETIME NOT NULL,

`  `end\_time      DATETIME NOT NULL,

`  `capacity      INT NOT NULL,

`  `status        ENUM('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',

`  `created\_at    DATETIME NOT NULL DEFAULT CURRENT\_TIMESTAMP,

`  `CONSTRAINT fk\_events\_organizer FOREIGN KEY (organizer\_id) REFERENCES users(id),

`  `CONSTRAINT chk\_events\_capacity CHECK (capacity > 0),

`  `CONSTRAINT chk\_events\_time CHECK (end\_time > start\_time)

);



CREATE TABLE bookings (

`  `id            BIGINT PRIMARY KEY AUTO\_INCREMENT,

`  `user\_id       BIGINT NOT NULL,

`  `event\_id      BIGINT NOT NULL,

`  `booking\_time  DATETIME NOT NULL DEFAULT CURRENT\_TIMESTAMP,

`  `status        ENUM('CONFIRMED','CANCELLED') NOT NULL DEFAULT 'CONFIRMED',

`  `CONSTRAINT fk\_bookings\_user  FOREIGN KEY (user\_id)  REFERENCES users(id),

`  `CONSTRAINT fk\_bookings\_event FOREIGN KEY (event\_id) REFERENCES events(id),

`  `CONSTRAINT uq\_bookings\_user\_event UNIQUE (user\_id, event\_id)

);



CREATE TABLE tickets (

`  `id           BIGINT PRIMARY KEY AUTO\_INCREMENT,

`  `booking\_id   BIGINT NOT NULL UNIQUE,

`  `ticket\_code  VARCHAR(50) NOT NULL UNIQUE,

`  `status       ENUM('VALID','CHECKED\_IN') NOT NULL DEFAULT 'VALID',

`  `version      BIGINT NOT NULL DEFAULT 0,

`  `created\_at   DATETIME NOT NULL DEFAULT CURRENT\_TIMESTAMP,

`  `CONSTRAINT fk\_tickets\_booking FOREIGN KEY (booking\_id) REFERENCES bookings(id)

);



CREATE TABLE check\_ins (

`  `id             BIGINT PRIMARY KEY AUTO\_INCREMENT,

`  `ticket\_id      BIGINT NOT NULL UNIQUE,

`  `checked\_in\_at  DATETIME NOT NULL DEFAULT CURRENT\_TIMESTAMP,

`  `checked\_in\_by  BIGINT NOT NULL,

`  `CONSTRAINT fk\_checkins\_ticket FOREIGN KEY (ticket\_id)     REFERENCES tickets(id),

`  `CONSTRAINT fk\_checkins\_by     FOREIGN KEY (checked\_in\_by) REFERENCES users(id)

);

|<p>**Lưu ý quan trọng**</p><p>Câu lệnh CHECK (...) chỉ thực sự có tác dụng từ MySQL 8.0.16 trở lên. Nếu bạn dùng bản cũ hơn, MySQL sẽ bỏ qua ràng buộc này mà không báo lỗi; khi đó Backend phải tự kiểm tra capacity > 0 và end\_time > start\_time.</p>|
| :- |

# **7. CHỨC NĂNG HỆ THỐNG CHI TIẾT**
## **7.1. Authentication (Xác thực)**
Chức năng gồm: Đăng ký (Register), Đăng nhập (Login), Đăng xuất (Logout), xác thực bằng JWT và phân quyền theo vai trò.

|<p>**Ví dụ đời thường**</p><p>JWT giống chiếc **vòng tay vào công viên giải trí**. Bạn xuất trình giấy tờ (email + mật khẩu) một lần ở quầy, nhân viên đeo cho bạn chiếc vòng. Sau đó đi đến trò chơi nào chỉ cần giơ vòng tay, không phải trình giấy tờ lại. Vòng tay có hạn sử dụng; hết hạn thì phải ra quầy làm lại.</p>|
| :- |

**Luồng đăng nhập**

Email + Password

`     `|

`     `v

Spring Security kiểm tra thông tin đăng nhập

`     `|

`     `v

Sinh JWT Token (chứa user\_id, role, thời hạn hết hạn)

`     `|

`     `v

Trả về cho Flutter  -->  Flutter lưu token bằng flutter\_secure\_storage



Từ lần gọi API tiếp theo, Flutter đính kèm token vào header:

Authorization: Bearer <jwt\_token>

Ở Backend, có một **JWT Filter** chạy trước mọi request để: (1) kiểm tra token hợp lệ và chưa hết hạn, (2) giải mã lấy user\_id và role, (3) ghi thông tin đó vào SecurityContext để Controller biết ai đang gọi.
### **Quy tắc dữ liệu đầu vào**
- Email: đúng định dạng, chưa tồn tại trong hệ thống.
- Mật khẩu: tối thiểu 6 ký tự (MVP). Backend băm bằng BCrypt trước khi lưu.
- Tên: không để trống, tối đa 100 ký tự.
- Thời hạn token: 24 giờ (có thể chỉnh trong cấu hình).
### **Phía Flutter: lưu token và tự gắn vào mọi request**
Hai file dưới đây là "xương sống" của việc gọi API. Hãy hiểu từng dòng.

**token\_storage.dart — lưu token an toàn**

// lib/core/storage/token\_storage.dart

import 'package:flutter\_secure\_storage/flutter\_secure\_storage.dart';



class TokenStorage {

`  `static const \_key = 'jwt\_token';

`  `final \_storage = const FlutterSecureStorage();



`  `Future<void> save(String token) => \_storage.write(key: \_key, value: token);

`  `Future<String?> read() => \_storage.read(key: \_key);

`  `Future<void> clear() => \_storage.delete(key: \_key);

}

**api\_client.dart — Dio và Interceptor**

// lib/core/network/api\_client.dart

import 'package:dio/dio.dart';

import 'package:flutter\_riverpod/flutter\_riverpod.dart';

import '../config/app\_config.dart';

import '../storage/token\_storage.dart';



final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());



final dioProvider = Provider<Dio>((ref) {

`  `final storage = ref.watch(tokenStorageProvider);



`  `final dio = Dio(BaseOptions(

`    `baseUrl: AppConfig.baseUrl,

`    `connectTimeout: const Duration(seconds: 10),

`    `receiveTimeout: const Duration(seconds: 10),

`    `headers: {'Content-Type': 'application/json'},

`  `));



`  `dio.interceptors.add(InterceptorsWrapper(

`    `// Chạy TRƯỚC khi request rời khỏi máy: gắn token nếu có

`    `onRequest: (options, handler) async {

`      `final token = await storage.read();

`      `if (token != null) {

`        `options.headers['Authorization'] = 'Bearer $token';

`      `}

`      `handler.next(options);

`    `},

`    `// Chạy khi có lỗi: nếu 401 (token hết hạn/sai) thì xóa token

`    `onError: (error, handler) async {

`      `if (error.response?.statusCode == 401) {

`        `await storage.clear();

`        `// Việc chuyển về màn hình đăng nhập do go\_router xử lý

`        `// khi trạng thái đăng nhập thay đổi (xem Phase 3).

`      `}

`      `handler.next(error);

`    `},

`  `));



`  `return dio;

});

|<p>**Giải thích cho người mới**</p><p>Provider<Dio> nghĩa là "một nơi cung cấp đối tượng Dio cho cả ứng dụng". Mọi Repository chỉ cần xin ref.watch(dioProvider) là có Dio đã cấu hình sẵn timeout và đã tự động gắn token. Bạn chỉ phải cấu hình một lần.</p><p>Bearer $token có **dấu cách** giữa chữ Bearer và token. Thiếu dấu cách là lỗi 401 rất hay gặp.</p>|
| :- |

### **Tài khoản và quyền**
Sau khi đăng nhập thành công, Backend trả về role. Flutter dựa vào role để quyết định mở giao diện nào: USER vào Home (danh sách sự kiện), ORGANIZER vào Organizer Home. Tuy nhiên đây chỉ là tiện lợi cho giao diện; **Backend mới là nơi bắt buộc kiểm tra quyền** (kể cả khi giao diện ẩn nút, kẻ xấu vẫn có thể gọi API trực tiếp).
## **7.2. Quản lý sự kiện (Event)**
Gồm: xem danh sách (có phân trang), xem chi tiết, tạo/sửa/xóa (chỉ ORGANIZER và chỉ sự kiện của chính mình), tính số chỗ còn lại.

- **Số chỗ còn lại** = capacity trừ số booking có status = CONFIRMED của sự kiện. Giá trị này **tính khi cần**, không lưu thành cột riêng, để tránh dữ liệu bị lệch (ví dụ quên cập nhật cột khi có người hủy).
- **Phân trang:** API nhận page (trang, bắt đầu từ 0) và size (số sự kiện mỗi trang). Flutter tải trang đầu, khi người dùng cuộn gần cuối thì tải trang tiếp.
- **Xóa sự kiện:** nếu sự kiện đã có booking thì không cho xóa (mã lỗi EVENT\_HAS\_BOOKINGS); Organizer nên chuyển trạng thái sang CLOSED.
- **Chỉ sự kiện OPEN** mới hiện trong danh sách của User; Organizer thấy tất cả sự kiện của mình.
## **7.3. Đăng ký sự kiện (Booking)**
Khi người dùng bấm "Đăng ký tham gia", Backend thực hiện **tuần tự** các bước sau (đúng thứ tự để tối ưu và tránh xử lý thừa):

1. Khóa dòng sự kiện trong DB (xem giải thích bên dưới) và đọc thông tin sự kiện.
1. Kiểm tra người dùng **đã đăng ký** sự kiện này chưa. Nếu rồi → lỗi ALREADY\_REGISTERED.
1. Kiểm tra sự kiện còn **mở đăng ký** không (status = OPEN). Nếu không → lỗi EVENT\_CLOSED.
1. Kiểm tra **còn chỗ** không (số booking hiện tại < capacity). Hết chỗ → lỗi EVENT\_FULL.
1. Hợp lệ: tạo Booking mới với status = CONFIRMED.
1. Ngay sau đó tạo Ticket tương ứng, sinh ticket\_code duy nhất (ví dụ ghép: EVT + năm + 5 ký tự ngẫu nhiên), status = VALID.
1. Trả thông tin Ticket về cho Flutter để hiển thị màn hình "Đăng ký thành công".

|<p>**Giải thích cho người mới**</p><p>**Transaction:** toàn bộ các bước trên nằm trong một giao dịch (@Transactional). Nếu bước tạo Ticket lỗi, Booking vừa tạo cũng bị hoàn tác. Không bao giờ xảy ra tình huống có Booking mà thiếu Ticket.</p>|
| :- |

|<p>**Ví dụ đời thường**</p><p>**Vì sao phải khóa dòng sự kiện?** Giả sử còn đúng 1 chỗ và hai bạn A, B cùng bấm "Đăng ký" trong cùng một giây. Nếu không khóa, cả hai cùng đọc thấy "còn 1 chỗ" rồi cùng tạo booking → sự kiện bị quá tải. Khóa dòng (PESSIMISTIC\_WRITE) khiến yêu cầu thứ hai phải **xếp hàng chờ** yêu cầu thứ nhất xong, lúc đó nó sẽ thấy "hết chỗ" và nhận lỗi EVENT\_FULL. Giống như chỉ một người được vào phòng thử đồ tại một thời điểm.</p>|
| :- |

**BookingService.java (rút gọn, minh họa ý tưởng)**

// Repository: truy vấn có khóa dòng

@Lock(LockModeType.PESSIMISTIC\_WRITE)

@Query("select e from Event e where e.id = :id")

Optional<Event> findByIdForUpdate(@Param("id") Long id);



// Service

@Transactional

public TicketResponse book(Long eventId, Long userId) {

`    `Event event = eventRepository.findByIdForUpdate(eventId)

.orElseThrow(() -> new AppException(ErrorCode.EVENT\_NOT\_FOUND));



`    `if (bookingRepository.existsByUserIdAndEventIdAndStatus(

`            `userId, eventId, BookingStatus.CONFIRMED))

`        `throw new AppException(ErrorCode.ALREADY\_REGISTERED);



`    `if (event.getStatus() != EventStatus.OPEN)

`        `throw new AppException(ErrorCode.EVENT\_CLOSED);



`    `long taken = bookingRepository.countByEventIdAndStatus(

`            `eventId, BookingStatus.CONFIRMED);

`    `if (taken >= event.getCapacity())

`        `throw new AppException(ErrorCode.EVENT\_FULL);



`    `User user = userRepository.getReferenceById(userId);

`    `Booking booking = bookingRepository.save(

`            `new Booking(user, event, BookingStatus.CONFIRMED));

`    `Ticket ticket = ticketRepository.save(

`            `Ticket.create(booking, generateUniqueCode()));



`    `return TicketResponse.from(ticket);

}

## **7.4. Ticket và QR Code**
Mỗi Booking hợp lệ tạo ra đúng một Ticket. Flutter lấy giá trị ticket\_code và vẽ thành mã QR bằng package qr\_flutter.

Booking  ->  Ticket  ->  ticket\_code ("EVT-2026-A8F31")  ->  QR Code (hiển thị trên màn hình)

|<p>**Giải thích cho người mới**</p><p>Mã QR **không phải "vé"**, nó chỉ là cách viết chuỗi ticket\_code thành hình ảnh để camera đọc. Toàn bộ thông tin thật (vé của ai, sự kiện nào, đã dùng chưa) nằm ở Database. Vì vậy QR chỉ chứa mã vé, **không nhét thêm tên, email hay dữ liệu nhạy cảm** vào QR.</p>|
| :- |

**Màn hình hiển thị QR (Flutter)**

// lib/features/tickets/presentation/ticket\_qr\_screen.dart

import 'package:flutter/material.dart';

import 'package:qr\_flutter/qr\_flutter.dart';



class TicketQrScreen extends StatelessWidget {

`  `const TicketQrScreen({super.key, required this.ticket});

`  `final TicketModel ticket;   // gồm ticketCode, eventTitle, status...



`  `@override

`  `Widget build(BuildContext context) {

`    `return Scaffold(

`      `appBar: AppBar(title: const Text('Vé của bạn')),

`      `body: Center(

`        `child: Column(

`          `mainAxisSize: MainAxisSize.min,

`          `children: [

`            `Text(ticket.eventTitle,

`                `style: Theme.of(context).textTheme.titleLarge),

`            `const SizedBox(height: 16),

`            `// Nền trắng + viền trắng giúp camera quét dễ hơn

`            `Container(

`              `padding: const EdgeInsets.all(12),

`              `color: Colors.white,

`              `child: QrImageView(

`                `data: ticket.ticketCode,      // chuỗi được "viết" thành QR

`                `version: QrVersions.auto,

`                `size: 260,

`              `),

`            `),

`            `const SizedBox(height: 12),

`            `Text(ticket.ticketCode),          // in cả mã chữ để dự phòng

`            `const SizedBox(height: 8),

`            `Chip(label: Text(ticket.status)), // VALID / CHECKED\_IN

`          `],

`        `),

`      `),

`    `);

`  `}

}

|<p>**Mẹo**</p><p>Luôn in kèm **mã chữ** bên dưới QR. Nếu camera hỏng hoặc QR bị mờ, Organizer có thể nhập tay mã đó.</p><p>Nền QR nên luôn màu trắng, QR màu đen, kể cả khi ứng dụng đang ở chế độ tối; nền tối làm nhiều máy quét không đọc được.</p>|
| :- |

|<p>**Lưu ý quan trọng**</p><p>Ai chụp màn hình vé gửi cho người khác thì người đó vẫn có QR. Tuy nhiên vì mỗi vé chỉ check-in **một lần** nên người đến sau sẽ bị báo "vé đã check-in". Mức bảo vệ này đủ cho MVP; muốn chặt hơn có thể làm QR đổi mới mỗi 30 giây ở giai đoạn mở rộng.</p>|
| :- |

## **7.5. QR Check-in**
Organizer chọn sự kiện đang phụ trách, rồi quét vé của từng người tham gia. **Lưu ý thay đổi v2.0:** màn hình quét luôn biết eventId (vì Organizer chọn sự kiện trước), nên gửi kèm eventId để Backend kiểm tra vé có đúng sự kiện này không.

**Luồng quét**

Organizer chọn sự kiện (eventId = 7)

`      `|

`      `v

Mở Camera (mobile\_scanner)  -->  Quét QR  -->  Lấy được ticketCode

`      `|

`      `v

POST /api/check-ins   { "ticketCode": "EVT-2026-A8F31", "eventId": 7 }

Backend kiểm tra **lần lượt**:

1. Ticket có tồn tại không? Không → TICKET\_NOT\_FOUND.
1. Organizer đang gọi có phải người phụ trách sự kiện này không? Không → FORBIDDEN.
1. Ticket có thuộc đúng sự kiện eventId không? Không → TICKET\_WRONG\_EVENT (chặn dùng vé sự kiện A để vào sự kiện B).
1. Ticket có đang VALID không? Nếu đã CHECKED\_IN → TICKET\_ALREADY\_CHECKED\_IN.
1. Hợp lệ: đổi trạng thái VALID → CHECKED\_IN và tạo bản ghi trong bảng check\_ins; trả về tên người tham gia để hiển thị.

|<p>**Giải thích cho người mới**</p><p>**Chống hai máy quét cùng lúc:** nếu hai Organizer quét cùng một vé trong cùng một tích tắc, cả hai có thể cùng thấy "VALID". Giải pháp: cột version trong bảng tickets (annotation @Version của JPA). Khi hai bên cùng lưu, bên đến sau sẽ bị lỗi xung đột phiên bản; Backend bắt lỗi này và trả TICKET\_ALREADY\_CHECKED\_IN. Thêm vào đó cột ticket\_id trong check\_ins là UNIQUE nên không thể có hai bản ghi check-in cho cùng một vé.</p>|
| :- |

**CheckInService.java (rút gọn)**

@Transactional

public CheckInResponse checkIn(CheckInRequest req, Long organizerId) {

`    `Ticket ticket = ticketRepository.findByTicketCode(req.getTicketCode())

.orElseThrow(() -> new AppException(ErrorCode.TICKET\_NOT\_FOUND));



`    `Event event = ticket.getBooking().getEvent();



`    `if (!event.getOrganizer().getId().equals(organizerId))

`        `throw new AppException(ErrorCode.FORBIDDEN);



`    `if (!event.getId().equals(req.getEventId()))

`        `throw new AppException(ErrorCode.TICKET\_WRONG\_EVENT);



`    `if (ticket.getStatus() != TicketStatus.VALID)

`        `throw new AppException(ErrorCode.TICKET\_ALREADY\_CHECKED\_IN);



`    `ticket.setStatus(TicketStatus.CHECKED\_IN);       // @Version bảo vệ ở đây

`    `CheckIn ci = checkInRepository.save(

`        `new CheckIn(ticket, organizerRepository.getReferenceById(organizerId)));



`    `return CheckInResponse.of(ticket, ci);           // có attendeeName, eventTitle

}

### **Phía Flutter: màn hình quét**
**Màn hình quét QR (Flutter)**

// lib/features/organizer/presentation/scan\_qr\_screen.dart

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter\_riverpod/flutter\_riverpod.dart';

import 'package:go\_router/go\_router.dart';

import 'package:mobile\_scanner/mobile\_scanner.dart';



class ScanQrScreen extends ConsumerStatefulWidget {

`  `const ScanQrScreen({super.key, required this.eventId});

`  `final int eventId;

`  `@override

`  `ConsumerState<ScanQrScreen> createState() => \_ScanQrScreenState();

}



class \_ScanQrScreenState extends ConsumerState<ScanQrScreen> {

`  `final \_controller = MobileScannerController(

`    `detectionSpeed: DetectionSpeed.noDuplicates,

`    `formats: const [BarcodeFormat.qrCode],

`  `);

`  `bool \_busy = false;   // cờ: đang xử lý 1 lần quét thì bỏ qua lần quét khác



`  `Future<void> \_onDetect(BarcodeCapture capture) async {

`    `if (\_busy) return;

`    `final code = capture.barcodes.isNotEmpty

`        `? capture.barcodes.first.rawValue : null;

`    `if (code == null) return;



`    `\_busy = true;

`    `await \_controller.stop();            // tạm dừng camera trong lúc xử lý

`    `HapticFeedback.mediumImpact();       // rung nhẹ báo đã đọc được



`    `CheckInOutcome outcome;

`    `try {

`      `final res = await ref.read(checkInRepositoryProvider)

.checkIn(ticketCode: code, eventId: widget.eventId);

`      `outcome = CheckInOutcome.success(res.attendeeName);

`    `} on AppException catch (e) {

`      `outcome = CheckInOutcome.failure(e.message);

`    `}



`    `if (!mounted) return;

`    `await context.push('/organizer/result', extra: outcome);  // chờ đóng màn kết quả



`    `\_busy = false;

`    `if (mounted) await \_controller.start();   // quét tiếp người kế tiếp

`  `}



`  `@override

`  `void dispose() {

`    `\_controller.dispose();

`    `super.dispose();

`  `}



`  `@override

`  `Widget build(BuildContext context) {

`    `return Scaffold(

`      `appBar: AppBar(title: const Text('Quét vé')),

`      `body: MobileScanner(controller: \_controller, onDetect: \_onDetect),

`    `);

`  `}

}

|<p>**Giải thích cho người mới**</p><p>Camera đọc hàng chục khung hình mỗi giây, nên cùng một mã QR có thể được "phát hiện" nhiều lần liên tiếp. Nếu không có cờ \_busy, ứng dụng sẽ gọi API nhiều lần cho cùng một vé. Đây là lỗi rất phổ biến của người mới.</p>|
| :- |

Kết quả hiển thị cho Organizer:

|**Trường hợp**|**Kết quả hiển thị**|
| :- | :- |
|Vé hợp lệ, chưa check-in|CHECK-IN THÀNH CÔNG (màn hình xanh, kèm tên người tham gia)|
|Vé đã check-in trước đó|Vé đã được check-in trước đó (màn hình đỏ)|
|Vé không tồn tại trong hệ thống|Vé không hợp lệ (màn hình đỏ)|
|Vé của sự kiện khác|Vé không thuộc sự kiện này (màn hình đỏ)|
|Mất mạng / máy chủ không phản hồi|Không thể kết nối đến máy chủ, vui lòng thử quét lại (màn hình vàng)|

# **8. ĐẶC TẢ REST API (MVP)**
Toàn bộ API gửi và nhận JSON. Mọi API đều phải có header Authorization: Bearer <token>, **trừ** hai API đăng ký và đăng nhập.
## **8.1. Quy ước chung**
### **Định dạng thông báo lỗi thống nhất**
Mọi lỗi nghiệp vụ đều trả về cùng một dạng JSON. Flutter chỉ cần đọc errorCode để biết lỗi gì và message để hiển thị.

**Ví dụ response lỗi**

HTTP 409

{

`  `"success": false,

`  `"errorCode": "EVENT\_FULL",

`  `"message": "Sự kiện đã đủ số lượng người tham gia.",

`  `"timestamp": "2026-10-01T09:30:00"

}

### **Danh sách mã lỗi**

|**errorCode**|**HTTP**|**Ý nghĩa**|
| :- | :- | :- |
|VALIDATION\_ERROR|400|Dữ liệu gửi lên sai định dạng (email sai, thiếu trường...).|
|INVALID\_CREDENTIALS|401|Sai email hoặc mật khẩu.|
|UNAUTHORIZED|401|Thiếu token, token sai hoặc hết hạn.|
|FORBIDDEN|403|Đã đăng nhập nhưng không đủ quyền.|
|EVENT\_NOT\_FOUND|404|Không tìm thấy sự kiện.|
|TICKET\_NOT\_FOUND|404|Không tìm thấy vé / mã vé không tồn tại.|
|EMAIL\_ALREADY\_EXISTS|409|Email đã được đăng ký.|
|ALREADY\_REGISTERED|409|Người dùng đã đăng ký sự kiện này.|
|EVENT\_FULL|409|Sự kiện đã đủ người.|
|EVENT\_CLOSED|409|Sự kiện đã đóng đăng ký.|
|EVENT\_HAS\_BOOKINGS|409|Không thể xóa sự kiện đã có người đăng ký.|
|TICKET\_ALREADY\_CHECKED\_IN|409|Vé đã được check-in trước đó.|
|TICKET\_WRONG\_EVENT|409|Vé không thuộc sự kiện đang quét.|
|INTERNAL\_ERROR|500|Lỗi không lường trước ở máy chủ.|

|<p>**Mẹo**</p><p>Backend nên có một lớp bắt lỗi tập trung (@ControllerAdvice + @ExceptionHandler) để mọi lỗi đều thành đúng dạng JSON ở trên. Nhờ đó không có chuyện lỗi trả về là một trang HTML hoặc một đoạn "stack trace" khó đọc.</p>|
| :- |

## **8.2. Authentication**

|**Method**|**Endpoint**|**Mô tả**|**Cần token?**|
| :- | :- | :- | :- |
|POST|/api/auth/register|Đăng ký tài khoản mới (luôn tạo vai trò USER)|Không|
|POST|/api/auth/login|Đăng nhập, trả JWT|Không|

**Đăng ký**

POST /api/auth/register

Body:

{ "name": "Nguyen Van A", "email": "a@example.com", "password": "123456" }



Response 201:

{ "userId": 12, "email": "a@example.com", "message": "Đăng ký thành công" }

**Đăng nhập (v2.0 trả thêm name, email để màn hình Profile không cần gọi API riêng)**

POST /api/auth/login

Body:

{ "email": "a@example.com", "password": "123456" }



Response 200:

{

`  `"token": "eyJhbGciOi...",

`  `"role": "USER",

`  `"userId": 12,

`  `"name": "Nguyen Van A",

`  `"email": "a@example.com"

}

## **8.3. Event**

|**Method**|**Endpoint**|**Mô tả**|**Quyền**|
| :- | :- | :- | :- |
|GET|/api/events?page=0&size=10|Danh sách sự kiện đang OPEN, có phân trang|USER, ORGANIZER|
|GET|/api/events/{id}|Chi tiết một sự kiện|USER, ORGANIZER|
|POST|/api/events|Tạo sự kiện mới|ORGANIZER|
|PUT|/api/events/{id}|Cập nhật sự kiện (chỉ của mình)|ORGANIZER|
|DELETE|/api/events/{id}|Xóa sự kiện (chỉ của mình, chưa có booking)|ORGANIZER|

**Danh sách sự kiện**

GET /api/events?page=0&size=10



Response 200:

{

`  `"content": [

`    `{

`      `"id": 7,

`      `"title": "Workshop Flutter cơ bản",

`      `"imageUrl": "https://example.com/flutter.jpg",

`      `"location": "Phòng B201",

`      `"startTime": "2026-10-20T08:00:00",

`      `"endTime": "2026-10-20T11:30:00",

`      `"capacity": 100,

`      `"remainingSeats": 37,

`      `"status": "OPEN"

`    `}

`  `],

`  `"page": 0,

`  `"size": 10,

`  `"totalPages": 3,

`  `"last": false

}

## **8.4. Dành riêng cho Organizer (bổ sung ở v2.0)**

|**Method**|**Endpoint**|**Mô tả**|**Quyền**|
| :- | :- | :- | :- |
|GET|/api/organizer/events|Danh sách sự kiện do mình phụ trách, kèm số đã đăng ký / đã check-in|ORGANIZER|
|GET|/api/events/{id}/attendees|Danh sách người đăng ký của sự kiện (tên, email, trạng thái vé, giờ check-in)|ORGANIZER (chủ sự kiện)|

**Sự kiện của Organizer**

GET /api/organizer/events



Response 200:

[

`  `{

`    `"id": 7, "title": "Workshop Flutter cơ bản",

`    `"startTime": "2026-10-20T08:00:00",

`    `"capacity": 100, "registeredCount": 63, "checkedInCount": 41,

`    `"status": "OPEN"

`  `}

]

## **8.5. Booking**

|**Method**|**Endpoint**|**Mô tả**|**Quyền**|
| :- | :- | :- | :- |
|POST|/api/events/{id}/book|Đăng ký tham gia sự kiện; trả về vé vừa tạo|USER|
|GET|/api/bookings/me|Danh sách đăng ký của bản thân|USER|

**Đăng ký sự kiện**

POST /api/events/7/book        (không cần body)



Response 201:

{

`  `"ticketId": 10025,

`  `"ticketCode": "EVT-2026-A8F31",

`  `"status": "VALID",

`  `"eventId": 7,

`  `"eventTitle": "Workshop Flutter cơ bản",

`  `"startTime": "2026-10-20T08:00:00",

`  `"location": "Phòng B201"

}

## **8.6. Ticket**

|**Method**|**Endpoint**|**Mô tả**|**Quyền**|
| :- | :- | :- | :- |
|GET|/api/tickets/me|Danh sách vé của bản thân|USER|
|GET|/api/tickets/{id}|Chi tiết một vé (chỉ chủ vé được xem)|USER|

## **8.7. Check-in**

|**Method**|**Endpoint**|**Mô tả**|**Quyền**|
| :- | :- | :- | :- |
|POST|/api/check-ins|Gửi ticketCode + eventId để xác thực và check-in|ORGANIZER|

**Check-in**

POST /api/check-ins

Body:

{ "ticketCode": "EVT-2026-A8F31", "eventId": 7 }



Response 200:

{

`  `"ticketCode": "EVT-2026-A8F31",

`  `"attendeeName": "Nguyen Van A",

`  `"eventTitle": "Workshop Flutter cơ bản",

`  `"checkedInAt": "2026-10-20T08:12:45"

}



Response 409 (vé đã dùng):

{ "success": false, "errorCode": "TICKET\_ALREADY\_CHECKED\_IN",

`  `"message": "Vé đã được check-in trước đó.", "timestamp": "..." }

# **9. CÁC MÀN HÌNH FLUTTER (UI FLOW)**
Ứng dụng dùng **một app duy nhất** cho cả hai vai trò. Sau khi đăng nhập, go\_router đọc role và đưa người dùng đến đúng khu vực: USER → /home, ORGANIZER → /organizer.
## **9.1. Luồng dành cho USER**
Splash  (kiểm tra token đã lưu)

`   `|

`   `+-- không có token / hết hạn --> Login <--> Register

`   `|

`   `v  có token hợp lệ

Home (thanh điều hướng dưới đáy có 3 tab)

`  `|-- Tab "Sự kiện":   Event List --> Event Detail --> (hộp thoại xác nhận)

`  `|                                         |

`  `|                                         v

`  `|                                  Booking Success --> QR Ticket

`  `|-- Tab "Vé của tôi": My Tickets --> QR Ticket

`  `|-- Tab "Tài khoản":  Profile (thông tin + Đăng xuất)

|**Màn hình**|**Route**|**API gọi**|**Nội dung hiển thị**|
| :- | :- | :- | :- |
|Splash|/splash|(đọc token cục bộ)|Logo; kiểm tra token đã lưu để tự đăng nhập nếu còn hạn.|
|Login|/login|POST /api/auth/login|Form email/mật khẩu, nút "Đăng nhập", liên kết sang Register.|
|Register|/register|POST /api/auth/register|Form họ tên, email, mật khẩu; kiểm tra hợp lệ trước khi gửi.|
|Event List|/home/events|GET /api/events|Danh sách thẻ sự kiện: ảnh, tên, thời gian, địa điểm, số chỗ còn lại; kéo xuống để tải lại, cuộn cuối để tải thêm.|
|Event Detail|/events/:id|GET /api/events/{id}|Thông tin đầy đủ + nút "Đăng ký tham gia" (vô hiệu nếu hết chỗ/đóng).|
|Booking (hộp thoại)|(dialog)|POST /api/events/{id}/book|Hộp thoại xác nhận; trong lúc gửi hiện vòng xoay và khóa nút để tránh bấm hai lần.|
|Booking Success|/booking-success|(dùng dữ liệu vé vừa nhận)|Thông báo thành công, nút "Xem vé".|
|My Tickets|/home/tickets|GET /api/tickets/me|Danh sách vé, phân loại VALID / CHECKED\_IN.|
|QR Ticket|/tickets/:id|GET /api/tickets/{id}|QR lớn, tên sự kiện, thời gian, trạng thái vé, mã chữ.|
|Profile|/home/profile|(dữ liệu lưu từ lúc login)|Họ tên, email, nút Đăng xuất (xóa token, về Login).|

## **9.2. Luồng dành cho ORGANIZER**
Organizer Home  (tổng quan)

`     `|

`     `v

My Events  (danh sách sự kiện mình phụ trách + số đăng ký / đã check-in)

`     `|   chọn 1 sự kiện

`     `v

Scan QR  (camera, biết sẵn eventId)

`     `|   quét được mã

`     `v

Check-in Result  (thành công / lỗi, đóng lại để quét tiếp)

|**Màn hình**|**Route**|**API gọi**|**Nội dung hiển thị**|
| :- | :- | :- | :- |
|Organizer Home|/organizer|GET /api/organizer/events|Tổng quan sự kiện đang/sắp diễn ra do mình phụ trách.|
|My Events|/organizer/events|GET /api/organizer/events|Danh sách sự kiện kèm số đã đăng ký / đã check-in; nút "Quét vé" ở mỗi sự kiện.|
|Scan QR|/organizer/scan/:eventId|POST /api/check-ins|Camera toàn màn hình có khung ngắm; tự nhận mã; nút "Nhập mã thủ công" dự phòng.|
|Check-in Result|/organizer/result|(nhận kết quả từ màn Scan)|Xanh + tên người tham gia khi thành công; đỏ + lý do khi lỗi; có rung/âm báo.|

## **9.3. Quy tắc chung cho mọi màn hình**
Màn hình nào có gọi API đều phải xử lý đủ **bốn trạng thái**. Người mới thường chỉ làm trạng thái "có dữ liệu" nên app trông như bị treo khi mạng chậm.

|**Trạng thái**|**Hiển thị gì**|**Widget gợi ý**|
| :- | :- | :- |
|Đang tải|Vòng xoay hoặc khung xương (skeleton).|CircularProgressIndicator|
|Có dữ liệu|Nội dung bình thường.|ListView.builder, Card|
|Rỗng|Thông báo thân thiện ("Chưa có sự kiện nào").|Center(child: Text(...))|
|Lỗi|Thông báo dễ hiểu + nút "Thử lại".|Widget ErrorView dùng chung|

### **Ví dụ: danh sách sự kiện với đủ 4 trạng thái**
**Mẫu màn hình có 4 trạng thái**

// lib/features/events/presentation/event\_list\_screen.dart

class EventListScreen extends ConsumerWidget {

`  `const EventListScreen({super.key});



`  `@override

`  `Widget build(BuildContext context, WidgetRef ref) {

`    `final eventsAsync = ref.watch(eventsProvider);   // lắng nghe provider



`    `return Scaffold(

`      `appBar: AppBar(title: const Text('Sự kiện')),

`      `body: eventsAsync.when(

`        `loading: () => const Center(child: CircularProgressIndicator()),

`        `error: (err, \_) => ErrorView(

`          `message: err is AppException ? err.message : 'Đã có lỗi xảy ra.',

`          `onRetry: () => ref.invalidate(eventsProvider),   // tải lại

`        `),

`        `data: (events) {

`          `if (events.isEmpty) {

`            `return const Center(child: Text('Chưa có sự kiện nào'));

`          `}

`          `return RefreshIndicator(                 // kéo xuống để tải lại

`            `onRefresh: () async => ref.refresh(eventsProvider.future),

`            `child: ListView.builder(

`              `itemCount: events.length,

`              `itemBuilder: (\_, i) => EventCard(event: events[i]),

`            `),

`          `);

`        `},

`      `),

`    `);

`  `}

}

|<p>**Mẹo**</p><p>Các widget hay dùng trong đồ án: Scaffold, AppBar, NavigationBar (thanh tab dưới), ListView.builder, Card, Image.network / CachedNetworkImage, ElevatedButton, TextFormField + Form (kiểm tra dữ liệu nhập), AlertDialog, SnackBar (thông báo ngắn), RefreshIndicator.</p>|
| :- |

# **10. PHẠM VI MVP (MINIMUM VIABLE PRODUCT)**
MVP là phiên bản tối thiểu nhưng **phải chạy trọn vẹn nghiệp vụ cốt lõi**: một người dùng thật có thể đăng ký, nhận vé và được check-in thành công từ đầu đến cuối.
## **10.1. Flutter — bắt buộc**
- **Authentication:** Register, Login, Logout, tự đăng nhập lại khi còn token.
- **Event:** danh sách (có phân trang), chi tiết.
- **Booking:** đăng ký sự kiện, báo lỗi đã đăng ký / hết chỗ / đóng đăng ký.
- **Ticket:** xem danh sách vé, hiển thị mã QR.
- **Check-in (Organizer):** chọn sự kiện, mở camera, quét QR, gửi lên Backend, hiển thị kết quả.
## **10.2. Backend — bắt buộc**
- Spring Boot REST API, Spring Security, JWT; phân quyền USER / ORGANIZER.
- CRUD Event, Booking, Ticket, Check-in; kiểm tra dữ liệu đầu vào (validation).
- Xử lý lỗi tập trung, trả mã lỗi thống nhất (mục 8.1).
## **10.3. Database — bắt buộc**
- 5 bảng: users, events, bookings, tickets, check\_ins, kèm đủ khóa ngoại và ràng buộc UNIQUE.

|<p>**Lưu ý quan trọng**</p><p>Mọi tính năng ngoài danh sách trên (Maps, Notification, Favorite, Chat, thanh toán, ADMIN...) đều thuộc phần mở rộng và **không được làm chậm tiến độ MVP**.</p>|
| :- |

# **11. CÁC TRƯỜNG HỢP LỖI PHẢI XỬ LÝ**
Hệ thống chỉ chạy tốt khi "mọi thứ suôn sẻ" là chưa đủ. MVP phải xử lý tối thiểu các tình huống sau, ở **cả Backend** (trả mã lỗi + thông điệp rõ ràng) **lẫn Flutter** (hiển thị thông báo thân thiện, không crash).

|**Tình huống**|**errorCode**|**Thông báo hiển thị cho người dùng**|
| :- | :- | :- |
|Đăng ký trùng sự kiện|ALREADY\_REGISTERED|Bạn đã đăng ký sự kiện này.|
|Sự kiện đã đủ chỗ|EVENT\_FULL|Sự kiện đã đủ số lượng người tham gia.|
|Sự kiện đã đóng đăng ký|EVENT\_CLOSED|Sự kiện đã đóng đăng ký.|
|Quét mã QR không tồn tại|TICKET\_NOT\_FOUND|Vé không hợp lệ.|
|Quét mã QR đã check-in|TICKET\_ALREADY\_CHECKED\_IN|Vé đã được check-in trước đó.|
|Quét vé của sự kiện khác|TICKET\_WRONG\_EVENT|Vé không thuộc sự kiện này.|
|Sai email/mật khẩu|INVALID\_CREDENTIALS|Email hoặc mật khẩu không đúng.|
|Email đã tồn tại khi đăng ký|EMAIL\_ALREADY\_EXISTS|Email này đã được sử dụng.|
|Token hết hạn|UNAUTHORIZED|Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại. (tự về màn Login)|
|Mất kết nối mạng / quá thời gian chờ|NETWORK\_ERROR (do Flutter tự tạo)|Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet.|

|<p>**Mẹo**</p><p>Hãy để **Backend gửi sẵn `message` tiếng Việt** và Flutter chỉ cần hiển thị. Riêng lỗi NETWORK\_ERROR thì Flutter tự tạo vì lúc đó không có phản hồi nào từ Backend. Flutter dùng errorCode để quyết định hành động (ví dụ UNAUTHORIZED → về Login), không so sánh chuỗi thông báo.</p>|
| :- |

### **Một lớp lỗi dùng chung cho toàn app**
**app\_exception.dart**

// lib/core/errors/app\_exception.dart

import 'package:dio/dio.dart';



class AppException implements Exception {

`  `AppException(this.code, this.message);

`  `final String code;      // ví dụ 'EVENT\_FULL'

`  `final String message;   // thông báo hiển thị cho người dùng



`  `factory AppException.fromDio(DioException e) {

`    `// 1) Không có phản hồi: mất mạng, timeout, không tới được server

`    `final noResponse = e.type == DioExceptionType.connectionError ||

`        `e.type == DioExceptionType.connectionTimeout ||

`        `e.type == DioExceptionType.sendTimeout ||

`        `e.type == DioExceptionType.receiveTimeout;

`    `if (noResponse) {

`      `return AppException('NETWORK\_ERROR',

`          `'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet.');

`    `}

`    `// 2) Có phản hồi lỗi từ Backend (JSON theo mục 8.1)

`    `final data = e.response?.data;

`    `if (data is Map<String, dynamic>) {

`      `return AppException(

`        `(data['errorCode'] as String?) ?? 'UNKNOWN',

`        `(data['message'] as String?) ?? 'Đã có lỗi xảy ra.',

`      `);

`    `}

`    `// 3) Trường hợp còn lại

`    `return AppException('UNKNOWN', 'Đã có lỗi xảy ra. Vui lòng thử lại.');

`  `}



`  `@override

`  `String toString() => message;

}

Mỗi Repository bọc lời gọi Dio bằng try { ... } on DioException catch (e) { throw AppException.fromDio(e); }. Nhờ vậy các màn hình chỉ cần xử lý một loại lỗi duy nhất là AppException.
# **12. YÊU CẦU PHI CHỨC NĂNG**
## **12.1. Hiệu năng**
- Giao diện không được đứng hình khi gọi API; luôn hiển thị vòng xoay tải (Flutter xử lý mạng bằng async/await nên không chặn giao diện nếu bạn dùng đúng).
- Danh sách sự kiện phân trang (page, size), cuộn gần cuối thì tải trang kế (dùng ScrollController).
- Check-in phản hồi dưới 1–2 giây khi mạng ổn định, vì phải quét liên tục nhiều người. Đặt timeout của Dio ở mức 10 giây để không chờ vô hạn.
- Ảnh sự kiện dùng cached\_network\_image để không tải lại mỗi lần cuộn.
## **12.2. Bảo mật**
- JWT cho mọi API cần xác thực; Backend kiểm tra token trước khi xử lý.
- Mật khẩu băm BCrypt, không lưu dạng gốc, không in vào log.
- Token trên điện thoại lưu bằng flutter\_secure\_storage, không lưu ở nơi người khác đọc được.
- Phân quyền rõ ràng USER / ORGANIZER / ADMIN, kiểm tra ở Backend (không chỉ ẩn nút trong giao diện).
- Không cho USER làm việc của ORGANIZER (tạo sự kiện, check-in); Organizer chỉ sửa/quét sự kiện của chính mình.
- Không cho một vé check-in nhiều lần.
- Khi chạy thật (ngoài môi trường học), bắt buộc dùng HTTPS; HTTP thuần chỉ dùng khi phát triển trên máy mình.
## **12.3. Toàn vẹn dữ liệu**
- Email duy nhất; ticket\_code duy nhất; một User chỉ đăng ký một lần cho một Event.
- Tổng Booking hợp lệ không vượt capacity (nhờ khóa dòng khi đăng ký).
- Ticket luôn thuộc một Booking hợp lệ; Check-in luôn thuộc một Ticket hợp lệ (khóa ngoại).
## **12.4. Khả dụng**
- Ứng dụng không được crash khi mất mạng; mọi lời gọi API đều có try/catch (hoặc xử lý lỗi của AsyncValue).
- Hiển thị thông báo dễ hiểu, tuyệt đối không hiện lỗi kỹ thuật (stack trace) cho người dùng.
- Sau khi await, nếu cần dùng context (mở hộp thoại, chuyển màn hình) thì kiểm tra mounted để tránh lỗi khi màn hình đã bị đóng.
## **12.5. Khả năng bảo trì**
Backend phân lớp rõ ràng: Controller → Service → Repository → Database. Flutter tách: Screen (hiển thị) → Provider/Controller (state) → Repository (dữ liệu) → Dio (mạng). Chạy flutter analyze định kỳ để phát hiện cảnh báo sớm.
## **12.6. Khả năng mở rộng**
Thiết kế cho phép bổ sung sau này mà không phải làm lại: Notification, Google Maps, Favorite, Chat, thanh toán, nhiều loại vé (VIP/Thường), thống kê, email xác nhận, xuất danh sách Excel/PDF.
# **13. KẾ HOẠCH TRIỂN KHAI CHI TIẾT THEO TỪNG PHASE**
Đây là phần quan trọng nhất đối với người mới. Kế hoạch gồm **6 Phase (0 → 5)**, sắp xếp theo đúng thứ tự phụ thuộc: môi trường → database (mọi thứ dựa vào cấu trúc dữ liệu) → backend → Flutter luồng chính → QR → kiểm thử. Mỗi Phase có: mục tiêu, các bước làm, **cách kiểm tra "đã xong chưa"**, lỗi hay gặp và đầu ra.

|**Phase**|**Nội dung**|**Thời lượng tham khảo\***|
| :- | :- | :- |
|0|Chuẩn bị môi trường, làm quen Flutter|2–3 ngày|
|1|Thiết kế & khởi tạo Database|2–3 ngày|
|2|Xây dựng Backend Spring Boot|1,5–2 tuần|
|3|Xây dựng ứng dụng Flutter (luồng USER)|2 tuần|
|4|Tích hợp QR (sinh + quét) và luồng Organizer|1 tuần|
|5|Kiểm thử tổng thể & hoàn thiện|1 tuần|

*\*Thời lượng chỉ để tham khảo cho người mới làm một mình; có thể nhanh hơn nếu làm nhóm hoặc đã có kinh nghiệm.*

|<p>**Lưu ý quan trọng**</p><p>Hoàn thành dứt điểm **từng Phase theo thứ tự** trước khi sang Phase kế tiếp. Làm song song khi chưa quen sẽ dẫn đến việc Flutter gọi vào API chưa hoàn chỉnh, và bạn không biết lỗi nằm ở Flutter, Backend hay Database.</p>|
| :- |

## **PHASE 0 — Chuẩn bị môi trường & làm quen Flutter**
**Mục tiêu:** Máy tính của bạn chạy được một ứng dụng Flutter mẫu trên máy ảo; đã cài đủ công cụ cho Backend và Database.
### **Các bước**
1. Làm theo mục 5.4 để cài toàn bộ công cụ. Chạy flutter doctor cho đến khi không còn mục lỗi nghiêm trọng.
1. Tạo dự án Flutter đầu tiên: mở terminal tại thư mục bạn muốn lưu code và gõ flutter create --org com.example --project-name event\_ticket\_app event\_ticket\_app. Lệnh này tạo sẵn một ứng dụng đếm số mẫu.
1. Mở máy ảo Android (Device Manager → nút Play), rồi trong thư mục dự án gõ flutter run. Bạn sẽ thấy ứng dụng mẫu xuất hiện trên máy ảo.
1. Thử **Hot Reload**: mở lib/main.dart, đổi một dòng chữ (ví dụ tiêu đề), lưu file, rồi nhấn phím r trong terminal. Chữ trên máy ảo đổi gần như tức thì.
1. Làm quen Dart và Widget trong 1–2 ngày: biến, hàm, lớp, async/await, List/Map; và các widget Column, Row, Container, Text, ElevatedButton, ListView. Tự làm một màn hình nhỏ có danh sách và một nút bấm.
1. Tạo repository Git: git init, tạo repo trên GitHub, commit lần đầu. Nên tạo 2 thư mục/repo riêng: event-ticket-backend và event\_ticket\_app.

|<p>**Giải thích cho người mới**</p><p>**Hai thứ cần phân biệt khi làm quen Flutter:** (1) \*Widget là mô tả giao diện\*: bạn khai báo "tôi muốn một cột gồm chữ và nút", Flutter lo việc vẽ. (2) \*Khi dữ liệu đổi, bạn không tự sửa giao diện\*: bạn đổi state, Flutter vẽ lại. Hiểu hai ý này là qua được ngưỡng khó nhất của người mới.</p>|
| :- |

### **Cách kiểm tra đã xong**
- flutter doctor cho kết quả tốt, flutter run mở được app mẫu trên máy ảo.
- Bạn tự sửa được chữ trên màn hình và thấy kết quả bằng Hot Reload.
- MySQL Workbench kết nối được localhost; IntelliJ mở được; Postman chạy được.

**Đầu ra Phase 0:** Dự án event\_ticket\_app chạy được trên máy ảo + môi trường đầy đủ.
## **PHASE 1 — Thiết kế & khởi tạo Cơ sở dữ liệu**
**Mục tiêu:** Có database MySQL đúng cấu trúc, sẵn sàng để Backend kết nối.

|<p>**Giải thích cho người mới**</p><p>Vì sao làm Database trước? Mọi tầng khác đều dựa vào dữ liệu: Backend cần biết có những bảng nào, Flutter cần biết dữ liệu trả về có những trường nào. Sửa cấu trúc dữ liệu về sau tốn công hơn rất nhiều so với nghĩ kỹ từ đầu.</p>|
| :- |

### **Các bước**
1. Mở MySQL Workbench, vẽ **sơ đồ ERD** (File → New Model → Add Diagram). Đặt đủ 5 bảng, nối khóa ngoại theo mục 6. Chụp ảnh sơ đồ để đưa vào báo cáo.
1. Chạy script schema.sql (mục 6.6) để tạo database event\_ticket\_db và 5 bảng. Nếu bạn tự tạo từng bảng thì phải theo thứ tự: users → events → bookings → tickets → check\_ins.
1. Kiểm tra các bảng đã có: chạy SHOW TABLES; rồi DESCRIBE events; để xem cấu trúc.
1. Nhập vài dòng dữ liệu mẫu bằng tay: 1 user, 1 organizer, 2 event, rồi thử các **ràng buộc** như bên dưới.

**Dữ liệu mẫu và thử ràng buộc**

-- Mật khẩu mẫu chỉ để thử ràng buộc; khi chạy thật mật khẩu do Backend băm BCrypt

INSERT INTO users (name, email, password, role)

VALUES ('Organizer A', 'org@example.com', 'x', 'ORGANIZER');



INSERT INTO events (organizer\_id, title, location, start\_time, end\_time, capacity)

VALUES (1, 'Workshop Flutter', 'B201', '2026-10-20 08:00', '2026-10-20 11:30', 2);



-- Thử vi phạm ràng buộc: các lệnh sau PHẢI báo lỗi

INSERT INTO users (name, email, password) VALUES ('Trùng', 'org@example.com', 'x'); -- email trùng

INSERT INTO events (organizer\_id, title, location, start\_time, end\_time, capacity)

VALUES (999, 'Sai', 'B', '2026-10-20 08:00', '2026-10-20 09:00', 5);  -- organizer không tồn tại

### **Cách kiểm tra đã xong**
- Có đủ 5 bảng; chèn email trùng bị từ chối; chèn booking cùng (user\_id, event\_id) hai lần bị từ chối; chèn tham chiếu đến khóa ngoại không tồn tại bị từ chối.
### **Lỗi hay gặp**
- Lỗi khi tạo khóa ngoại: do tạo bảng sai thứ tự hoặc kiểu dữ liệu hai cột không giống nhau (cùng phải là BIGINT).
- Tiếng Việt bị lỗi font: hãy tạo database với utf8mb4 như trong script.

**Đầu ra Phase 1:** File schema.sql + ảnh sơ đồ ERD.
## **PHASE 2 — Xây dựng Backend (Spring Boot)**
**Mục tiêu:** Có bộ REST API hoàn chỉnh theo mục 8, đã test bằng Postman cả trường hợp thành công lẫn thất bại. **Chưa cần đụng đến Flutter ở phase này.**
### **Các bước**
1. **Khởi tạo project** tại trang Spring Initializr (start.spring.io): Maven, Java 17, Spring Boot 3.x. Chọn dependency: Spring Web, Spring Data JPA, Spring Security, MySQL Driver, Validation, Lombok. Tải về, giải nén, mở bằng IntelliJ.
1. **Thêm thư viện JWT** (jjwt: jjwt-api, jjwt-impl, jjwt-jackson) vào pom.xml.
1. **Cấu hình kết nối DB** trong src/main/resources/application.properties (xem khung bên dưới). Chạy thử ứng dụng; nếu console báo kết nối thành công và không lỗi là được.
1. **Viết Entity** (User, Event, Booking, Ticket, CheckIn) khớp với 5 bảng ở Phase 1; khai báo quan hệ @ManyToOne, @OneToOne; thêm @Version cho trường version của Ticket.
1. **Viết Repository** cho từng Entity (kế thừa JpaRepository), thêm các hàm truy vấn cần dùng (findByEmail, findByTicketCode, countByEventIdAndStatus, findByIdForUpdate...).
1. **Cấu hình Spring Security + JWT:** JwtUtil (sinh/giải mã token), JwtAuthenticationFilter (kiểm tra token mỗi request), SecurityConfig (endpoint nào công khai, endpoint nào cần quyền). Cấu hình STATELESS vì dùng JWT.
1. **Authentication:** AuthController với register/login; mã hóa mật khẩu bằng BCryptPasswordEncoder. Test bằng Postman đến khi đăng nhập trả về token.
1. **Event:** EventController + EventService, đủ CRUD, phân trang, tính remainingSeats; kiểm tra Organizer chỉ sửa/xóa sự kiện của mình.
1. **Booking:** BookingController + BookingService theo đúng thứ tự mục 7.3 (có transaction và khóa dòng).
1. **Ticket:** TicketController để xem danh sách và chi tiết vé của người đang đăng nhập (kiểm tra vé phải thuộc về họ).
1. **Check-in:** CheckInController + CheckInService theo mục 7.5.
1. **API cho Organizer:** /api/organizer/events và /api/events/{id}/attendees.
1. **Xử lý lỗi tập trung:** ErrorCode (enum), AppException, GlobalExceptionHandler với @RestControllerAdvice, trả đúng JSON ở mục 8.1. Đồng thời cấu hình để thiếu/sai token trả **401** theo dạng JSON thống nhất.
1. **Test toàn bộ bằng Postman** (xem bảng kiểm tra bên dưới).

**application.properties**

\# src/main/resources/application.properties

spring.datasource.url=jdbc:mysql://localhost:3306/event\_ticket\_db?serverTimezone=Asia/Ho\_Chi\_Minh&allowPublicKeyRetrieval=true&useSSL=false

spring.datasource.username=root

spring.datasource.password=MAT\_KHAU\_CUA\_BAN



\# validate: Hibernate chỉ KIỂM TRA entity khớp bảng, không tự sửa database

spring.jpa.hibernate.ddl-auto=validate

spring.jpa.show-sql=true



\# Khóa bí mật ký JWT: dài, ngẫu nhiên, KHÔNG đưa lên GitHub công khai

app.jwt.secret=DOI\_THANH\_CHUOI\_NGAU\_NHIEN\_DAI\_IT\_NHAT\_32\_KY\_TU

app.jwt.expiration-ms=86400000



server.port=8080

|<p>**Giải thích cho người mới**</p><p>**`ddl-auto=validate`** nghĩa là: Hibernate không được tự ý tạo hay sửa bảng. Cấu trúc database do **bạn** quyết định qua schema.sql; nếu Entity lệch với bảng thì ứng dụng báo lỗi ngay lúc khởi động. Cách này an toàn hơn update (tự sửa bảng, đôi khi tạo ra cột không mong muốn).</p><p>**Mật khẩu DB và khóa JWT** là thông tin nhạy cảm. Đừng commit lên GitHub công khai; nên dùng file cấu hình riêng hoặc biến môi trường và thêm vào .gitignore.</p>|
| :- |

**SecurityConfig.java**

// SecurityConfig.java (rút gọn, minh họa ý tưởng cho Spring Security 6)

@Bean

SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

`    `http

.csrf(csrf -> csrf.disable())                 // app di động dùng JWT, không dùng cookie

.sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

.authorizeHttpRequests(a -> a

.requestMatchers("/api/auth/\*\*").permitAll()

.requestMatchers(HttpMethod.POST, "/api/events").hasRole("ORGANIZER")

.requestMatchers(HttpMethod.PUT, "/api/events/\*\*").hasRole("ORGANIZER")

.requestMatchers(HttpMethod.DELETE, "/api/events/\*\*").hasRole("ORGANIZER")

.requestMatchers("/api/organizer/\*\*", "/api/check-ins").hasRole("ORGANIZER")

.requestMatchers("/api/events/\*/attendees").hasRole("ORGANIZER")

.requestMatchers("/api/events/\*/book").hasRole("USER")

.requestMatchers("/api/tickets/\*\*", "/api/bookings/\*\*").hasRole("USER")

.anyRequest().authenticated())

.addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

`    `return http.build();

}

Bảng kiểm tra bằng Postman (làm theo thứ tự, mỗi dòng ghi lại kết quả thật):

|**#**|**Thao tác**|**Kết quả mong đợi**|
| :- | :- | :- |
|1|POST /api/auth/register (email mới)|201, tạo được tài khoản USER|
|2|Register lại cùng email|409 EMAIL\_ALREADY\_EXISTS|
|3|POST /api/auth/login đúng|200, có token, role USER|
|4|Login sai mật khẩu|401 INVALID\_CREDENTIALS|
|5|GET /api/events không gửi token|401 UNAUTHORIZED|
|6|Nâng một tài khoản lên ORGANIZER bằng SQL, login lại, POST /api/events|201, tạo được sự kiện|
|7|POST /api/events bằng token của USER|403 FORBIDDEN|
|8|USER gọi POST /api/events/{id}/book|201, nhận được ticketCode; trong DB có 1 booking + 1 ticket VALID|
|9|Gọi book lần thứ hai cùng sự kiện|409 ALREADY\_REGISTERED|
|10|Tạo sự kiện capacity = 1, hai USER khác nhau cùng book|Người đầu 201, người sau 409 EVENT\_FULL|
|11|Đổi sự kiện sang CLOSED rồi book|409 EVENT\_CLOSED|
|12|ORGANIZER POST /api/check-ins với ticketCode đúng + eventId đúng|200; vé thành CHECKED\_IN|
|13|Check-in lại cùng vé|409 TICKET\_ALREADY\_CHECKED\_IN|
|14|Check-in với ticketCode bịa|404 TICKET\_NOT\_FOUND|
|15|Check-in với eventId của sự kiện khác|409 TICKET\_WRONG\_EVENT|

### **Lỗi hay gặp**
- Public Key Retrieval is not allowed: thêm allowPublicKeyRetrieval=true vào URL kết nối.
- Khởi động báo lỗi Schema-validation: missing column/table: Entity lệch với bảng thật; sửa Entity hoặc schema.sql cho khớp.
- Thiếu token mà trả 403 thay vì 401: cần cấu hình authenticationEntryPoint để trả 401 đúng dạng JSON.
- Test bằng Postman nhớ chọn Body → raw → JSON, và gắn token ở Authorization → Bearer Token.

**Đầu ra Phase 2:** Backend chạy được tại http://localhost:8080, đủ API theo mục 8, đã qua toàn bộ 15 phép thử trên.
## **PHASE 3 — Xây dựng ứng dụng Flutter (luồng USER)**
**Mục tiêu:** Một User thật có thể đăng ký, đăng nhập, xem sự kiện, đăng ký tham gia và xem lại vé của mình trên ứng dụng Flutter, dữ liệu lấy **thật** từ Backend (không dùng dữ liệu giả).

|<p>**Lưu ý quan trọng**</p><p>Trước khi bắt đầu: Backend từ Phase 2 phải đang chạy. Nếu Flutter báo lỗi, hãy dùng Postman gọi cùng API đó. Nếu Postman chạy được mà Flutter không chạy được thì lỗi nằm ở Flutter; ngược lại thì lỗi ở Backend.</p>|
| :- |

### **Bước 3.1 — Thêm package và dựng khung thư mục**
**Chạy trong terminal, tại thư mục dự án**

cd event\_ticket\_app

flutter pub add flutter\_riverpod go\_router dio flutter\_secure\_storage

flutter pub add qr\_flutter mobile\_scanner intl cached\_network\_image

flutter pub get

Sau đó tạo các thư mục theo cây ở mục 4.3 (core/, features/...). Việc chia thư mục từ đầu giúp bạn không bị rối khi code nhiều.

Bọc toàn bộ ứng dụng bằng ProviderScope để Riverpod hoạt động:

**main.dart**

// lib/main.dart

import 'package:flutter/material.dart';

import 'package:flutter\_riverpod/flutter\_riverpod.dart';

import 'app.dart';



void main() {

`  `runApp(const ProviderScope(child: App()));

}

### **Bước 3.2 — Cấu hình địa chỉ Backend (rất hay sai)**
Máy ảo/điện thoại là một "máy khác", nên **không thể** dùng localhost để gọi tới Backend chạy trên máy tính của bạn. Hãy chọn đúng địa chỉ theo nơi chạy app:

|**App chạy ở đâu**|**Địa chỉ Backend dùng**|**Giải thích**|
| :- | :- | :- |
|Android Emulator (máy ảo Android)|http://10.0.2.2:8080|10\.0.2.2 là địa chỉ đặc biệt mà máy ảo Android dùng để chỉ về máy tính chứa nó.|
|iOS Simulator (trên Mac)|http://localhost:8080|Simulator iOS dùng chung mạng với máy Mac.|
|Điện thoại thật|http://<IP máy tính>:8080, ví dụ http://192.168.1.10:8080|Điện thoại và máy tính phải cùng một Wi-Fi. Xem IP máy tính bằng ipconfig (Windows) hoặc ifconfig (Mac/Linux).|

**app\_config.dart**

// lib/core/config/app\_config.dart

class AppConfig {

`  `// Lấy từ tham số lúc chạy; nếu không truyền thì dùng mặc định cho Android Emulator

`  `static const baseUrl = String.fromEnvironment(

`    `'API\_BASE\_URL',

`    `defaultValue: 'http://10.0.2.2:8080',

`  `);

}



// Chạy trên điện thoại thật:

// flutter run --dart-define=API\_BASE\_URL=http://192.168.1.10:8080

|<p>**Lưu ý quan trọng**</p><p>**Cho phép HTTP khi phát triển.** Android 9 trở lên mặc định chặn địa chỉ http:// (không có chữ s). Trong android/app/src/main/AndroidManifest.xml, thẻ <application ...> thêm thuộc tính android:usesCleartextTraffic="true". Cũng trong file này, thêm dòng <uses-permission android:name="android.permission.INTERNET"/> ngay trên thẻ <application> (bản chạy thật cần quyền Internet).</p><p>Với iOS, trong ios/Runner/Info.plist cho phép HTTP khi dev bằng khóa NSAppTransportSecurity (ví dụ NSAllowsLocalNetworking).</p><p>Đây chỉ dành cho **môi trường học/dev**. Khi triển khai thật phải dùng HTTPS.</p><p>Windows có thể chặn cổng 8080 từ thiết bị khác. Nếu điện thoại thật không gọi được, hãy cho phép cổng 8080 trong Windows Firewall.</p>|
| :- |

### **Bước 3.3 — Dựng nền tảng mạng**
Tạo token\_storage.dart, api\_client.dart (đã có code ở mục 7.1) và app\_exception.dart (mục 11). Đây là ba file nền tảng; làm xong là mọi tính năng sau chỉ việc dùng lại.
### **Bước 3.4 — Model và Repository (làm cho tính năng Event)**
**event\_model.dart**

// lib/features/events/data/event\_model.dart

class EventModel {

`  `EventModel({

`    `required this.id, required this.title, this.imageUrl,

`    `required this.location, required this.startTime,

`    `required this.capacity, required this.remainingSeats,

`    `required this.status,

`  `});



`  `final int id;

`  `final String title;

`  `final String? imageUrl;      // dấu ? nghĩa là có thể null

`  `final String location;

`  `final DateTime startTime;

`  `final int capacity;

`  `final int remainingSeats;

`  `final String status;



`  `// Chuyển Map (từ JSON) thành đối tượng Dart

`  `factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(

`        `id: json['id'] as int,

`        `title: json['title'] as String,

`        `imageUrl: json['imageUrl'] as String?,

`        `location: json['location'] as String,

`        `startTime: DateTime.parse(json['startTime'] as String),

`        `capacity: json['capacity'] as int,

`        `remainingSeats: json['remainingSeats'] as int,

`        `status: json['status'] as String,

`      `);

}

**event\_repository.dart**

// lib/features/events/data/event\_repository.dart

import 'package:dio/dio.dart';

import 'package:flutter\_riverpod/flutter\_riverpod.dart';



class EventRepository {

`  `EventRepository(this.\_dio);

`  `final Dio \_dio;



`  `Future<List<EventModel>> getEvents({int page = 0, int size = 10}) async {

`    `try {

`      `final res = await \_dio.get('/api/events',

`          `queryParameters: {'page': page, 'size': size});

`      `final list = res.data['content'] as List;

`      `return list

.map((e) => EventModel.fromJson(e as Map<String, dynamic>))

.toList();

`    `} on DioException catch (e) {

`      `throw AppException.fromDio(e);     // đổi lỗi Dio thành lỗi của app

`    `}

`  `}

}



final eventRepositoryProvider =

`    `Provider((ref) => EventRepository(ref.watch(dioProvider)));



final eventsProvider = FutureProvider<List<EventModel>>(

`    `(ref) => ref.watch(eventRepositoryProvider).getEvents());

|<p>**Giải thích cho người mới**</p><p>FutureProvider là loại provider "đi lấy dữ liệu một lần rồi giữ kết quả". Widget nào ref.watch(eventsProvider) sẽ tự nhận được 3 trạng thái: đang tải, có dữ liệu, hoặc lỗi (như màn hình mẫu ở mục 9.3).</p><p>as int, as String là ép kiểu; nếu Backend gửi tên trường khác (ví dụ start\_time thay vì startTime) bạn sẽ gặp lỗi kiểu "type Null is not a subtype". Hãy mở Postman đối chiếu tên trường chính xác.</p>|
| :- |

### **Bước 3.5 — Đăng nhập, đăng ký, điều hướng theo trạng thái**
1. Tạo AuthRepository gồm login() và register(). Khi login thành công: lưu token bằng TokenStorage, lưu role, name, email (có thể giữ trong một provider authStateProvider).
1. Tạo LoginScreen và RegisterScreen: dùng Form + TextFormField có validator (email đúng dạng, mật khẩu ≥ 6 ký tự). Khi bấm nút: hiện vòng xoay, vô hiệu nút, gọi repository; lỗi thì hiện SnackBar bằng e.message.
1. Tạo SplashScreen: lúc mở app đọc token. Có token → vào đúng khu vực theo role; không có → sang Login.
1. Khai báo route bằng go\_router (xem mục 9) và dùng tham số redirect: chưa đăng nhập mà vào trang cần đăng nhập thì chuyển về /login; đã đăng nhập thì USER vào /home, ORGANIZER vào /organizer.
1. Khi interceptor gặp lỗi 401 (token hết hạn), cập nhật authStateProvider thành "chưa đăng nhập" để go\_router tự đưa người dùng về Login.
### **Bước 3.6 — Các màn hình còn lại của USER**

|**Màn hình**|**Việc cần làm**|**Điểm cần chú ý**|
| :- | :- | :- |
|Event List|Gọi /api/events, hiển thị ListView.builder với EventCard (ảnh, tên, ngày giờ, địa điểm, số chỗ còn lại).|Đủ 4 trạng thái (mục 9.3). Dùng DateFormat của intl để hiện ngày giờ. Phân trang bằng ScrollController.|
|Event Detail|Gọi /api/events/{id}, hiển thị đầy đủ thông tin và nút "Đăng ký tham gia".|Vô hiệu nút nếu remainingSeats == 0 hoặc status == CLOSED.|
|Booking|Bấm nút → AlertDialog xác nhận → POST /api/events/{id}/book.|Trong lúc chờ phải khóa nút để tránh bấm 2 lần. Lỗi ALREADY\_REGISTERED, EVENT\_FULL, EVENT\_CLOSED hiển thị đúng thông báo ở mục 11.|
|Booking Success|Nhận vé từ response, hiện thông báo và nút "Xem vé" (đi tới QR Ticket).|Truyền ticket bằng extra của go\_router hoặc truyền id rồi gọi lại API chi tiết vé.|
|My Tickets|Gọi /api/tickets/me, nhóm theo trạng thái.|Kéo xuống để làm mới (sau khi check-in, trạng thái vé đổi).|
|Profile|Hiện tên, email; nút Đăng xuất.|Đăng xuất = TokenStorage.clear() + cập nhật trạng thái đăng nhập → về Login.|

### **Cách kiểm tra đã xong**
- Đăng ký tài khoản mới trên app; đóng hẳn app mở lại vẫn còn đăng nhập (nhờ token đã lưu).
- Xem được danh sách sự kiện **thật** (dữ liệu bạn tạo ở Phase 2). Tắt Backend rồi kéo tải lại, app hiện thông báo mất kết nối chứ không crash.
- Đăng ký sự kiện thành công thì ở Workbench thấy có thêm 1 dòng bookings và 1 dòng tickets.
- Đăng ký lần hai cùng sự kiện, app hiện đúng thông báo "Bạn đã đăng ký sự kiện này."
### **Lỗi hay gặp**
- Connection refused / timeout trên máy ảo: bạn đang dùng localhost thay vì 10.0.2.2.
- Điện thoại thật không kết nối được: khác Wi-Fi với máy tính, hoặc firewall chặn cổng 8080.
- Cleartext HTTP traffic not permitted: chưa thêm usesCleartextTraffic (xem bước 3.2).
- Mọi request đều 401: quên gắn header, thiếu dấu cách sau chữ Bearer, hoặc token đã hết hạn.
- Màn hình báo lỗi kiểu type 'Null' is not a subtype of type 'String': JSON có trường null hoặc tên trường không khớp; kiểm tra lại model.

**Đầu ra Phase 3:** Luồng USER chạy trọn vẹn với dữ liệu thật từ Backend.
## **PHASE 4 — Tích hợp QR Code (Sinh + Quét) và luồng Organizer**
**Mục tiêu:** Hoàn thiện tính năng đặc trưng nhất: hiển thị mã QR của vé và quét mã QR để check-in, chạy end-to-end trên thiết bị thật.
### **Bước 4.1 — Màn hình QR Ticket (phía User)**
1. Dùng code ở mục 7.4. Truyền ticketCode vào QrImageView(data: ...).
1. Hiển thị thêm: tên sự kiện, thời gian, địa điểm, trạng thái vé (VALID màu xanh, CHECKED\_IN màu xám) và mã chữ dưới QR.
1. Kiểm tra bằng cách dùng một ứng dụng đọc QR bất kỳ trên điện thoại quét thử màn hình; nội dung đọc ra phải đúng bằng ticketCode.
### **Bước 4.2 — Khai báo quyền Camera**

|<p>**Giải thích cho người mới**</p><p>Camera là chức năng nhạy cảm nên hệ điều hành bắt ứng dụng phải **khai báo** là sẽ dùng camera, và **xin phép người dùng** khi chạy. Thư viện mobile\_scanner sẽ tự hiện hộp thoại xin phép lúc bạn mở màn hình quét; còn phần khai báo thì bạn phải thêm vào file cấu hình của từng nền tảng.</p>|
| :- |

- **Android:** trong android/app/src/main/AndroidManifest.xml, thêm <uses-permission android:name="android.permission.CAMERA"/> ngay phía trên thẻ <application>. Kiểm tra trang mobile\_scanner trên pub.dev về yêu cầu phiên bản minSdkVersion và chỉnh trong android/app/build.gradle nếu cần.
- **iOS:** trong ios/Runner/Info.plist, thêm khóa NSCameraUsageDescription với nội dung tiếng Việt, ví dụ "Ứng dụng cần camera để quét mã QR trên vé". Không có khóa này, ứng dụng sẽ bị đóng ngay khi mở camera.
### **Bước 4.3 — Luồng Organizer**
1. Mở rộng AuthRepository/router để ORGANIZER sau khi đăng nhập vào /organizer.
1. Tạo OrganizerRepository: getMyEvents() gọi /api/organizer/events, và CheckInRepository.checkIn(ticketCode, eventId) gọi POST /api/check-ins.
1. Màn hình **My Events**: danh sách sự kiện kèm "đã đăng ký / đã check-in"; bấm nút "Quét vé" trên một sự kiện → đi tới /organizer/scan/{eventId}.
1. Màn hình **Scan QR**: dùng code ở mục 7.5. Đặt thêm một khung ngắm ở giữa và nút "Nhập mã thủ công" (hộp thoại nhập ticketCode, gửi qua cùng checkIn()), để vẫn làm việc được khi QR bị mờ.
1. Màn hình **Check-in Result**: nền **xanh** + biểu tượng dấu tích + tên người tham gia khi thành công; nền **đỏ** + lý do khi lỗi; nền **vàng** khi mất mạng. Gọi HapticFeedback (rung) để Organizer nhận biết nhanh mà không cần nhìn kỹ. Có nút "Quét tiếp" (đóng màn hình để quay lại camera).
### **Bước 4.4 — Bố trí thiết bị để test quét QR**

|**Cách bố trí**|**Làm thế nào**|**Ghi chú**|
| :- | :- | :- |
|**Khuyến nghị:** 1 điện thoại thật + 1 máy ảo|Máy ảo đăng nhập USER, mở QR Ticket. Điện thoại thật đăng nhập ORGANIZER, quét màn hình máy tính.|Phải đảm bảo điện thoại thật gọi được Backend (cùng Wi-Fi, địa chỉ IP máy tính).|
|2 điện thoại thật|Một máy là USER hiển thị QR, một máy là ORGANIZER.|Dễ nhất nhưng cần 2 máy.|
|Chỉ 1 điện thoại|Chụp màn hình QR của vé, mở ảnh trên máy tính, dùng điện thoại quét lại.|Hợp để demo một mình.|

|<p>**Mẹo**</p><p>Chạy app trên điện thoại thật: bật **Tùy chọn nhà phát triển → Gỡ lỗi USB** (Android), cắm cáp USB, gõ flutter devices để xem máy đã được nhận chưa, rồi flutter run -d <id thiết bị> kèm --dart-define=API\_BASE\_URL=... như ở bước 3.2.</p>|
| :- |

### **Cách kiểm tra đã xong**
- Quét QR vé hợp lệ → màn hình xanh, tên người tham gia hiện đúng; trong DB vé chuyển CHECKED\_IN và có 1 dòng check\_ins.
- Quét lại cùng QR → màn hình đỏ "Vé đã được check-in trước đó"; **chỉ gọi API một lần cho mỗi lần quét** (xem log Backend).
- Quét vé của sự kiện khác → màn hình đỏ "Vé không thuộc sự kiện này".
### **Lỗi hay gặp**
- Camera màn hình đen / không hỏi quyền: thiếu khai báo ở AndroidManifest hoặc Info.plist; nếu đã từ chối vĩnh viễn thì vào Cài đặt của máy để bật lại quyền Camera.
- Một lần quét mà gọi API nhiều lần: thiếu cờ \_busy hoặc quên DetectionSpeed.noDuplicates.
- Báo lỗi use\_build\_context\_synchronously hoặc crash sau khi await: kiểm tra if (!mounted) return; trước khi dùng context.
- Quét được trên điện thoại này nhưng không được trên điện thoại khác: QR quá nhỏ hoặc độ sáng màn hình thấp; tăng kích thước QR và độ sáng.

**Đầu ra Phase 4:** Toàn bộ vòng đời một vé (sinh QR → quét QR → xác thực → check-in) hoạt động end-to-end trên thiết bị thật.
## **PHASE 5 — Kiểm thử tổng thể & hoàn thiện**
**Mục tiêu:** Hệ thống chạy ổn định, đúng nghiệp vụ, sẵn sàng demo và báo cáo.
### **Các bước**
1. Kiểm thử từng chức năng theo luồng: Register → Login → xem Event → Booking → xem Ticket → Scan QR → Check-in.
1. Chủ động kiểm thử các lỗi ở mục 11 bằng bảng test bên dưới.
1. Kiểm thử nhiều tài khoản: tạo vài USER cùng đăng ký một Event có capacity nhỏ để chắc chắn không bao giờ vượt quá sức chứa.
1. Kiểm thử phân quyền: dùng Postman với token của USER gọi API của ORGANIZER (tạo sự kiện, check-in), phải bị 403.
1. Chạy flutter analyze và sửa các cảnh báo; viết 1–2 unit test đơn giản (ví dụ EventModel.fromJson đọc đúng JSON mẫu) bằng flutter test.
1. Sửa lỗi phát sinh, ưu tiên lỗi ảnh hưởng luồng chính.
1. Build bản cài thử để demo: flutter build apk --release (file nằm ở build/app/outputs/flutter-apk/app-release.apk). Cài lên điện thoại và chạy thử toàn bộ kịch bản.
1. Chuẩn bị kịch bản demo đúng 13 bước ở mục 14 và luyện tập ít nhất hai lần.

Bảng test chính (điền kết quả thật vào cột cuối):

|**ID**|**Tình huống**|**Cách thực hiện**|**Kết quả mong đợi**|**Đạt?**|
| :- | :- | :- | :- | :- |
|T01|Đăng ký tài khoản|Nhập thông tin hợp lệ|Tạo thành công, chuyển sang Login/Home||
|T02|Đăng ký email đã tồn tại|Dùng lại email cũ|Thông báo "Email này đã được sử dụng."||
|T03|Đăng nhập sai mật khẩu|Nhập sai mật khẩu|Thông báo "Email hoặc mật khẩu không đúng."||
|T04|Tự đăng nhập lại|Đăng nhập, tắt hẳn app, mở lại|Vào thẳng Home, không hỏi đăng nhập||
|T05|Đăng xuất|Bấm Đăng xuất ở Profile|Về Login; mở lại app vẫn ở Login||
|T06|Xem danh sách|Mở tab Sự kiện|Thấy sự kiện thật, có số chỗ còn lại||
|T07|Đăng ký thành công|Đăng ký 1 sự kiện còn chỗ|Có vé; DB có booking + ticket VALID||
|T08|Đăng ký trùng|Đăng ký lại cùng sự kiện|"Bạn đã đăng ký sự kiện này."||
|T09|Hết chỗ|Sự kiện capacity = 1, người thứ 2 đăng ký|"Sự kiện đã đủ số lượng người tham gia."||
|T10|Đóng đăng ký|Đặt sự kiện CLOSED rồi đăng ký|"Sự kiện đã đóng đăng ký."||
|T11|Hiển thị QR|Mở vé trong My Tickets|QR rõ, quét ra đúng ticketCode||
|T12|Check-in thành công|Organizer quét vé hợp lệ|Màn xanh + tên; vé thành CHECKED\_IN||
|T13|Quét lại vé đã dùng|Quét lại|"Vé đã được check-in trước đó."||
|T14|Mã QR lạ|Quét QR bất kỳ (ví dụ QR của một website)|"Vé không hợp lệ."||
|T15|Vé sự kiện khác|Quét vé sự kiện A khi đang ở sự kiện B|"Vé không thuộc sự kiện này."||
|T16|Mất mạng|Tắt Wi-Fi/Backend rồi thao tác|"Không thể kết nối đến máy chủ..." và app không crash||
|T17|USER gọi API Organizer|Postman + token USER gọi POST /api/events|403 FORBIDDEN||
|T18|Token hết hạn|Sửa tạm thời hạn token còn 1 phút, chờ hết hạn|App tự về màn Login||

**Đầu ra Phase 5:** Hệ thống ổn định, bảng test đã điền đủ, file APK demo và kịch bản demo đã tập luyện.
# **14. TIÊU CHÍ HOÀN THÀNH MVP (KỊCH BẢN DEMO)**
MVP được xem là hoàn thành khi thực hiện **trọn vẹn 13 bước sau mà không phải can thiệp thủ công vào database** (riêng việc chuẩn bị trước tài khoản Organizer bằng SQL ở mục 3.2 không tính là can thiệp trong lúc demo):

1. User đăng ký tài khoản mới.
1. User đăng nhập.
1. User xem danh sách Event.
1. User xem chi tiết một Event.
1. User đăng ký tham gia Event đó.
1. Backend tự động tạo Booking và Ticket tương ứng.
1. Ứng dụng Flutter hiển thị Ticket dưới dạng mã QR.
1. Organizer đăng nhập bằng tài khoản riêng.
1. Organizer chọn sự kiện và mở chức năng Scan QR (camera).
1. Organizer quét mã QR của User.
1. Backend kiểm tra tính hợp lệ của Ticket.
1. Hệ thống báo Check-in thành công.
1. Database cập nhật đúng trạng thái Ticket: VALID → CHECKED\_IN.

|<p>**Mẹo**</p><p>Khi demo, nên chuẩn bị sẵn: Backend đang chạy, 1–2 sự kiện mẫu, tài khoản Organizer đã nâng quyền, và mở sẵn MySQL Workbench ở bảng tickets để cuối buổi bấm refresh cho thấy trạng thái đã đổi thành CHECKED\_IN. Nếu mạng ở nơi demo không ổn định, dùng điểm phát Wi-Fi từ chính điện thoại hoặc router riêng.</p>|
| :- |

# **15. ĐỊNH HƯỚNG MỞ RỘNG & KẾT QUẢ DỰ KIẾN**
## **15.1. Định hướng mở rộng (sau MVP)**
Chỉ nên làm sau khi MVP chạy ổn định. Chia thành 3 giai đoạn để không ảnh hưởng tiến độ chính.
### **Giai đoạn mở rộng 1 — Trải nghiệm cơ bản**
- Search Event (tìm theo tên); Filter (theo thời gian, địa điểm, danh mục).
- Favorite (đánh dấu sự kiện yêu thích).
- Upload ảnh Event (Organizer tải ảnh lên thay vì dán URL; Flutter dùng package image\_picker).
- Hủy đăng ký (CANCELLED) và mở lại chỗ trống.
### **Giai đoạn mở rộng 2 — Thông báo & vị trí**
- Firebase Push Notification (nhắc lịch sự kiện sắp diễn ra).
- Google Maps (chỉ đường đến địa điểm).
- Email xác nhận vé.
### **Giai đoạn mở rộng 3 — Nghiệp vụ nâng cao**
- Nhiều loại vé (VIP, Thường, Sinh viên).
- Thanh toán online cho sự kiện có phí.
- Thống kê số liệu tham gia; xuất danh sách Excel/PDF.
- QR động đổi mới theo thời gian để chống chụp màn hình chia sẻ vé.
- Chạy trên iOS và đưa lên cửa hàng ứng dụng (lợi thế của Flutter).
## **15.2. Kết quả dự kiến**
Sản phẩm cuối cùng là một ứng dụng di động Flutter hoàn chỉnh, kết nối với Backend Spring Boot và cơ sở dữ liệu MySQL, quản lý trọn vẹn quy trình:

**Đăng nhập → Xem sự kiện → Đăng ký → Nhận vé điện tử → QR Code → Quét → Xác thực → Check-in**

Đề tài thể hiện được nhiều nội dung quan trọng của môn học (phát triển ứng dụng di động Flutter, camera/QR, REST API, quản lý state, điều hướng), đồng thời vận dụng kiến thức về Java Spring Boot, JWT, JPA và MySQL vào một sản phẩm thực tế có tính ứng dụng cao trong môi trường học đường và tổ chức sự kiện sinh viên.
# **PHỤ LỤC A — LỖI THƯỜNG GẶP & CÁCH XỬ LÝ**
Khi bị kẹt, hãy tra bảng này trước khi hỏi người khác. Nguyên tắc chung: **đọc kỹ dòng lỗi đầu tiên màu đỏ trong terminal/console** và xác định lỗi nằm ở tầng nào (Flutter, Backend hay Database).

|**Triệu chứng**|**Nguyên nhân thường gặp**|**Cách xử lý**|
| :- | :- | :- |
|flutter doctor báo thiếu Android licenses|Chưa chấp nhận giấy phép SDK.|Chạy flutter doctor --android-licenses, bấm y.|
|Máy ảo Android chạy rất chậm hoặc không lên|Chưa bật ảo hóa phần cứng (HAXM/Hyper-V/KVM).|Bật Virtualization trong BIOS; chọn ảnh hệ thống phù hợp kiến trúc CPU.|
|Sửa code nhưng giao diện không đổi|Thay đổi nằm ở main() hoặc khai báo provider/biến toàn cục.|Dùng Hot Restart (phím R hoặc nút khởi động lại) thay vì Hot Reload.|
|Connection refused / timeout trên Android Emulator|Dùng localhost thay vì 10.0.2.2.|Đổi baseUrl (xem bước 3.2).|
|Điện thoại thật không gọi được Backend|Khác Wi-Fi; sai IP; firewall chặn cổng 8080.|Cùng mạng; dùng đúng IP máy tính; mở cổng 8080.|
|Cleartext HTTP traffic not permitted|Android chặn HTTP khi không cấu hình.|Thêm android:usesCleartextTraffic="true" (chỉ khi dev).|
|Mọi request đều 401|Thiếu header, thiếu dấu cách sau Bearer, token hết hạn.|In header ra log; đăng nhập lại để lấy token mới.|
|Thiếu token lại nhận 403 thay vì 401|Spring Security chưa cấu hình authenticationEntryPoint.|Cấu hình để trả 401 JSON thống nhất.|
|type 'Null' is not a subtype of type 'String'|Trường JSON null hoặc tên trường không khớp model.|Đối chiếu response trong Postman; dùng kiểu String? cho trường có thể null.|
|Camera đen, không hỏi quyền|Thiếu khai báo CAMERA / NSCameraUsageDescription; hoặc đã từ chối vĩnh viễn.|Bổ sung khai báo; bật lại quyền trong Cài đặt máy.|
|Một lần quét gọi API nhiều lần|Camera phát hiện cùng mã nhiều khung hình liên tiếp.|Dùng cờ \_busy, DetectionSpeed.noDuplicates, tạm dừng camera khi đang xử lý.|
|Cảnh báo/lỗi dùng context sau await|Màn hình có thể đã đóng khi await xong.|Thêm if (!mounted) return; trước khi dùng context.|
|Backend: Public Key Retrieval is not allowed|MySQL 8 yêu cầu tùy chọn kết nối.|Thêm allowPublicKeyRetrieval=true vào URL.|
|Backend: Schema-validation: missing ...|Entity lệch với bảng thật.|Sửa Entity hoặc schema.sql cho khớp.|
|Backend: lỗi LazyInitializationException|Truy cập quan hệ lazy ngoài transaction.|Trả về DTO được dựng trong Service (trong transaction), đừng trả Entity trực tiếp.|
|Hai người đăng ký chỗ cuối cùng cùng lúc đều thành công|Chưa khóa dòng sự kiện.|Dùng PESSIMISTIC\_WRITE (mục 7.3).|

# **PHỤ LỤC B — CHECKLIST CUỐI CÙNG TRƯỚC KHI NỘP / DEMO**
## **Cơ sở dữ liệu**
- Có schema.sql chạy được từ đầu trên một MySQL trống; có ảnh sơ đồ ERD.
- Các ràng buộc UNIQUE (email, ticket\_code, user\_id + event\_id) hoạt động.
## **Backend**
- Toàn bộ API ở mục 8 hoạt động; 15 phép thử Postman ở Phase 2 đều đạt.
- Mật khẩu được băm; khóa JWT và mật khẩu DB không bị đẩy lên GitHub công khai.
- Mọi lỗi trả về đúng dạng JSON có errorCode và message.
## **Ứng dụng Flutter**
- Có đủ các màn hình ở mục 9, mỗi màn hình có đủ 4 trạng thái (tải / dữ liệu / rỗng / lỗi).
- Không crash khi mất mạng; không hiện lỗi kỹ thuật cho người dùng.
- QR hiển thị rõ; quét một lần chỉ gọi một API.
- flutter analyze không còn lỗi nghiêm trọng; đã build được file APK để demo.
## **Tài liệu & demo**
- Bảng test (Phase 5) đã điền kết quả.
- Đã chạy thử đủ 13 bước demo ít nhất hai lần trên thiết bị thật.
- Có sẵn phương án dự phòng: video quay lại luồng demo phòng khi mạng hoặc camera trục trặc.

*— Hết tài liệu —*
Trang 
