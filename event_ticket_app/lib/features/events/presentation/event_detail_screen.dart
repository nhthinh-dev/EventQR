import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/models/event_response.dart';
import '../data/event_repository.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final EventResponse event;
  const EventDetailScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isBooking = false;

  Future<void> _handleBookEvent() async {
    // 1. Hiển thị hộp thoại xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng ký'),
        content: Text('Bạn có chắc chắn muốn đăng ký tham gia sự kiện "${widget.event.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // 2. Gọi API đăng ký
    setState(() => _isBooking = true);
    try {
      await ref.read(eventRepositoryProvider).bookEvent(widget.event.id);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Đăng ký thành công! Hãy kiểm tra mã QR trong mục Vé của bạn.'), backgroundColor: Colors.green),
      );
      
      // Load lại danh sách sự kiện bên ngoài để cập nhật số vé
      ref.invalidate(eventListFutureProvider);
      
      // Tạm thời quay lại màn hình trước
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final isClosed = event.status == 'CLOSED';
    final isSoldOut = event.availableTickets <= 0;
    
    // Nút đăng ký bị vô hiệu hóa nếu: Hết vé, Sự kiện đã đóng, hoặc Đang tải API
    final canBook = !isClosed && !isSoldOut && !_isBooking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sự kiện'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(event.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 16),
            
            // Thời gian và Địa điểm
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey),
                const SizedBox(width: 8),
                Text('${formatter.format(event.startTime)}\n${formatter.format(event.endTime)}', 
                     style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(event.location, style: const TextStyle(fontSize: 16))),
              ],
            ),
            const SizedBox(height: 24),
            
            // Số lượng vé
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Tổng số vé', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('${event.totalTickets}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.blue.shade200),
                  Column(
                    children: [
                      const Text('Còn lại', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('${event.availableTickets}', style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, 
                        color: isSoldOut ? Colors.red : Colors.green
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Mô tả
            const Text('Mô tả sự kiện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(event.description.isNotEmpty ? event.description : 'Sự kiện này chưa có mô tả chi tiết.', 
                 style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: canBook ? _handleBookEvent : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: _isBooking 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  isClosed ? 'SỰ KIỆN ĐÃ ĐÓNG' : (isSoldOut ? 'ĐÃ HẾT VÉ' : 'ĐĂNG KÝ THAM GIA'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
          ),
        ),
      ),
    );
  }
}
