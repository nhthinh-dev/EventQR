import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/organizer_repository.dart';

class OrganizerHistoryScreen extends ConsumerStatefulWidget {
  const OrganizerHistoryScreen({super.key});

  @override
  ConsumerState<OrganizerHistoryScreen> createState() => _OrganizerHistoryScreenState();
}

class _OrganizerHistoryScreenState extends ConsumerState<OrganizerHistoryScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await ref.read(tokenStorageProvider).read();
    if (mounted) {
      setState(() {
        _token = token;
      });
    }
  }

  void _showCheckInDetail(Map<String, dynamic> c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết Check-in', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              c['photoUrl'] != null
                  ? Image.network(
                      '${AppConfig.baseUrl}${c['photoUrl']}',
                      headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                    )
                  : const Icon(Icons.person, size: 100),
              const SizedBox(height: 16),
              Text('Khách: ${c['attendeeName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Mã vé: ${c['ticketCode']}'),
              const Divider(),
              Text('Sự kiện: ${c['eventTitle']}'),
              Text('Thời gian: ${c['checkedInAt']}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkInsAsync = ref.watch(recentCheckInsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử Check-in'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: checkInsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (checkIns) {
          if (checkIns.isEmpty) return const Center(child: Text('Chưa có lịch sử check-in.'));
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(recentCheckInsFutureProvider),
            child: ListView.builder(
              itemCount: checkIns.length,
              itemBuilder: (context, index) {
                final c = checkIns[index];
                return ListTile(
                  leading: c['photoUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            '${AppConfig.baseUrl}${c['photoUrl']}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                        )
                      : const Icon(Icons.person, size: 50),
                  title: Text('${c['attendeeName']} - ${c['ticketCode']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${c['eventTitle']} - ${c['checkedInAt']}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCheckInDetail(c),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
