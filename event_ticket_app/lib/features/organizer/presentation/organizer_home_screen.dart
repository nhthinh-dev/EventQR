import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/organizer_repository.dart';

class OrganizerHomeScreen extends ConsumerWidget {
  const OrganizerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(organizerEventsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sự kiện (BTC)'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu), // Icon cuốn lịch sử
            onPressed: () {
              context.push('/organizer/history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(tokenStorageProvider).clear();
              ref.read(authStateProvider.notifier).setRole(AuthRole.guest);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(organizerEventsFutureProvider);
          ref.invalidate(recentCheckInsFutureProvider);
        },
        child: Column(
          children: [
            Expanded(
              child: eventsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Lỗi: $err')),
                data: (events) {
                  if (events.isEmpty) return const Center(child: Text('Bạn chưa tạo sự kiện nào.'));
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final formatter = DateFormat('dd/MM/yyyy HH:mm');
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                              const SizedBox(height: 8),
                              Text('Thời gian: ${formatter.format(event.startTime)}'),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Đã đăng ký', style: TextStyle(color: Colors.grey)),
                                      Text('${event.registeredCount} / ${event.capacity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('Đã Check-in', style: TextStyle(color: Colors.grey)),
                                      Text('${event.checkedInCount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.push('/organizer/scan', extra: event.id);
                                  },
                                  icon: const Icon(Icons.qr_code_scanner),
                                  label: const Text('QUÉT MÃ QR CHECK-IN'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
