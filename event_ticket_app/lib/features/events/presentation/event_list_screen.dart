import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/event_repository.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theo dõi trạng thái của API lấy danh sách sự kiện
    final eventsAsync = ref.watch(eventListFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Sự kiện'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [],
      ),
      body: eventsAsync.when(
        // Trạng thái 1: Đang tải dữ liệu
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // Trạng thái 2: Lỗi API hoặc mất mạng
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Có lỗi xảy ra: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(eventListFutureProvider), // Tải lại
                child: const Text('Thử lại'),
              )
            ],
          ),
        ),
        
        // Trạng thái 3: Tải thành công
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('Hiện không có sự kiện nào đang mở.'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(eventListFutureProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final formatter = DateFormat('dd/MM/yyyy HH:mm');

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(event.location, style: const TextStyle(color: Colors.grey))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${formatter.format(event.startTime)} - ${formatter.format(event.endTime)}', 
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: event.availableTickets > 0 ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                event.availableTickets > 0 ? 'Còn ${event.availableTickets} vé' : 'Hết vé',
                                style: TextStyle(
                                  color: event.availableTickets > 0 ? Colors.green.shade800 : Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Điều hướng sang màn hình Chi tiết và truyền dữ liệu sự kiện theo
                                context.push('/events/detail', extra: event);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                              child: const Text('XEM CHI TIẾT'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
