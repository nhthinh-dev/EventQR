import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../data/ticket_repository.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé của tôi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $err', textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: () => ref.invalidate(myTicketsFutureProvider),
                child: const Text('Thử lại'),
              )
            ],
          ),
        ),
        data: (tickets) {
          if (tickets.isEmpty) {
            return const Center(child: Text('Bạn chưa đăng ký sự kiện nào.'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myTicketsFutureProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final formatter = DateFormat('dd/MM/yyyy HH:mm');
                final isValid = ticket.status == 'VALID';


                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(ticket.eventTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${formatter.format(ticket.startTime)} - ${ticket.location}'),
                        const SizedBox(height: 8),
                        Text(
                          isValid ? 'VÉ HỢP LỆ' : 'ĐÃ CHECK-IN',
                          style: TextStyle(
                            color: isValid ? Colors.green.shade700 : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                                        trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isValid)
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                            tooltip: 'Hủy vé',
                            onPressed: () {
                              if (ticket.endTime.difference(DateTime.now()).inHours >= ticket.cancelDeadlineHours) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Hủy Vé', style: TextStyle(color: Colors.red)),
                                    content: const Text('BẠN CÓ CHẮC CHẮN MUỐN HỦY VÉ?\n\nHành động này không thể hoàn tác. Sức chứa sẽ được hoàn lại cho người khác.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('ĐÓNG')),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          try {
                                            await ref.read(ticketRepositoryProvider).cancelTicket(ticket.ticketId);
                                            ref.invalidate(myTicketsFutureProvider);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy vé thành công!')));
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                            }
                                          }
                                        },
                                        child: const Text('HỦY VÉ'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Không thể hủy vé', style: TextStyle(color: Colors.orange)),
                                    content: Text('Đã vượt quá thời hạn cho phép.\n\nBạn chỉ có thể hủy vé muộn nhất là ${ticket.cancelDeadlineHours} giờ trước hạn chót.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('ĐÃ HIỂU'))
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        const Icon(Icons.qr_code_2, size: 40, color: Colors.blue),
                      ],
                    ),

                    onTap: ticket.status == 'CANCELLED' ? null : () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Mã QR Của Bạn', textAlign: TextAlign.center),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(ticket.eventTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              Container(
                                width: 216,
                                height: 216,
                                padding: const EdgeInsets.all(8),
                                color: Colors.white,
                                child: QrImageView(
                                  data: ticket.ticketCode,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(ticket.ticketCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ĐÓNG'))
                          ],
                        ),
                      );
                    },
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
