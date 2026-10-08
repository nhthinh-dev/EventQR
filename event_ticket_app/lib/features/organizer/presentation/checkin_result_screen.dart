import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckInResultScreen extends StatelessWidget {
  final int eventId;
  final String ticketCode;
  final String? attendeeName;
  final String? eventTitle;

  const CheckInResultScreen({
    super.key,
    required this.eventId,
    required this.ticketCode,
    this.attendeeName,
    this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả Check-in'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text('Check-in thành công!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 16),
              Text('Mã vé: $ticketCode', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 16),
              if (attendeeName != null)
                Text('Khách hàng: $attendeeName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (eventTitle != null) ...[
                const SizedBox(height: 8),
                Text('Sự kiện: $eventTitle', style: const TextStyle(fontSize: 16)),
              ],
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                onPressed: () {
                  context.pushReplacement('/organizer/scan', extra: eventId);
                },
                child: const Text('QUÉT TIẾP', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
