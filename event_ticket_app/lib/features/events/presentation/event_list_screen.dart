import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
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
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/events/detail', extra: event),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ảnh Bìa
                        if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                          Image.network(
                            AppConfig.baseUrl + event.imageUrl!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 160,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                            ),
                          )
                        else
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1E1E2C), Color(0xFFFF6E40)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.event, size: 60, color: Colors.white54),
                            ),
                          ),
                        
                        // Nội dung
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(event.location, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(formatter.format(event.startTime), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: event.availableTickets > 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      event.availableTickets > 0 ? 'Còn ${event.availableTickets} vé' : 'Hết vé',
                                      style: TextStyle(
                                        color: event.availableTickets > 0 ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      minimumSize: Size.zero,
                                    ),
                                    onPressed: () => context.push('/events/detail', extra: event),
                                    child: const Text('Xem chi tiết', style: TextStyle(fontSize: 13)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
