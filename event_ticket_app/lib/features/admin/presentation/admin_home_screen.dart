import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/admin_repository.dart';
import '../../events/data/models/event_response.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authStateProvider.notifier).setRole(AuthRole.guest);
              },
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Events'),
              Tab(text: 'Check-ins'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UsersTab(),
            _EventsTab(),
            _CheckInsTab(),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends ConsumerStatefulWidget {
  const _UsersTab();
  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      _users = await ref.read(adminRepositoryProvider).getUsers();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showCreateUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'ORGANIZER';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Tạo tài khoản'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
              const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Vai trò', border: OutlineInputBorder()),
                  controller: TextEditingController(text: 'Nhân viên (ORGANIZER)'),
                  readOnly: true,
                )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(adminRepositoryProvider).createUser(
                        nameCtrl.text,
                        emailCtrl.text,
                        passCtrl.text,
                        selectedRole,
                      );
                  if (context.mounted) Navigator.pop(context);
                  _loadUsers();
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Tạo'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    
    final usersCount = _users.where((u) => u['role'] == 'USER').length;
    final orgsCount = _users.where((u) => u['role'] == 'ORGANIZER').length;
    final adminsCount = _users.where((u) => u['role'] == 'ADMIN').length;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (adminsCount > 0)
            Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.purple, foregroundColor: Colors.white, child: Text('A')),
                title: const Text('Quản trị viên (ADMIN)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Số lượng: $adminsCount'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const RoleUsersScreen(title: 'Quản trị viên', role: 'ADMIN')
                  )).then((_) => _loadUsers());
                },
              ),
            ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, foregroundColor: Colors.white, child: Text('O')),
              title: const Text('Ban tổ chức (ORGANIZER)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Số lượng: $orgsCount'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const RoleUsersScreen(title: 'Ban tổ chức', role: 'ORGANIZER')
                )).then((_) => _loadUsers());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, foregroundColor: Colors.white, child: Text('U')),
              title: const Text('Khán giả (USER)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Số lượng: $usersCount'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const RoleUsersScreen(title: 'Khán giả', role: 'USER')
                )).then((_) => _loadUsers());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}


class _EventsTab extends ConsumerStatefulWidget {
  const _EventsTab();
  @override
  ConsumerState<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends ConsumerState<_EventsTab> {
  List<EventResponse> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    try {
      _events = await ref.read(adminRepositoryProvider).getEvents();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _deleteEvent(int id) async {
    try {
      await ref.read(adminRepositoryProvider).deleteEvent(id);
      _loadEvents();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  
  void _showEventDialog({EventResponse? event}) {
    final titleCtrl = TextEditingController(text: event?.title ?? '');
    final descCtrl = TextEditingController(text: event?.description ?? '');
    final locationCtrl = TextEditingController(text: event?.location ?? '');
    
    DateTime selectedStart = event?.startTime ?? DateTime.now().add(const Duration(days: 1));
    DateTime selectedEnd = event?.endTime ?? selectedStart.add(const Duration(days: 1));
    
    final startCtrl = TextEditingController(text: selectedStart.toIso8601String().split('.')[0]);
    final endCtrl = TextEditingController(text: selectedEnd.toIso8601String().split('.')[0]);
    final capacityCtrl = TextEditingController(text: event?.totalTickets.toString() ?? '100');
      final cancelDeadlineCtrl = TextEditingController(text: event?.cancelDeadlineHours.toString() ?? '72');
    final statusCtrl = TextEditingController(text: event?.status ?? 'OPEN');
    
    File? selectedImage;
    String? currentImageUrl = event?.imageUrl;

    Future<void> pickDateTime(BuildContext context, bool isStart) async {
      final initialDate = isStart ? selectedStart : selectedEnd;
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date == null) return;
      if (!context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (time == null) return;
      
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        selectedStart = dt;
        startCtrl.text = dt.toIso8601String().split('.')[0];
      } else {
        selectedEnd = dt;
        endCtrl.text = dt.toIso8601String().split('.')[0];
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          bool isUploading = false;
          
          Future<void> pickImage() async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setStateDialog(() {
                selectedImage = File(image.path);
              });
            }
          }
          
          return AlertDialog(
            title: Text(event == null ? 'Tạo sự kiện mới' : 'Sửa sự kiện'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : (currentImageUrl != null && currentImageUrl!.isNotEmpty)
                              ? Image.network(
                                  AppConfig.baseUrl + currentImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.image, size: 50, color: Colors.grey),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Thêm ảnh bìa (Tùy chọn)', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên sự kiện')),
                  const SizedBox(height: 16),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả')),
                  const SizedBox(height: 16),
                  TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Địa điểm')),
                  const SizedBox(height: 16),
                  TextField(
                    controller: startCtrl, 
                    decoration: const InputDecoration(labelText: 'Bắt đầu', suffixIcon: Icon(Icons.calendar_month)),
                    readOnly: true,
                    onTap: () => pickDateTime(context, true),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: endCtrl, 
                    decoration: const InputDecoration(labelText: 'Kết thúc', suffixIcon: Icon(Icons.calendar_month)),
                    readOnly: true,
                    onTap: () => pickDateTime(context, false),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: capacityCtrl, decoration: const InputDecoration(labelText: 'Sức chứa'), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  TextField(controller: cancelDeadlineCtrl, decoration: const InputDecoration(labelText: 'Giờ hạn chót hủy vé (Ví dụ: 72)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: ['OPEN', 'CLOSED'].contains(statusCtrl.text) ? statusCtrl.text : 'OPEN',
                    decoration: const InputDecoration(labelText: 'Trạng thái'),
                    items: const [
                      DropdownMenuItem(value: 'OPEN', child: Text('OPEN (Mở)')),
                      DropdownMenuItem(value: 'CLOSED', child: Text('CLOSED (Đóng)')),
                    ],
                    onChanged: (v) => statusCtrl.text = v ?? 'OPEN',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('Hủy')
              ),
              ElevatedButton(
                onPressed: isUploading ? null : () async {
                  setStateDialog(() => isUploading = true);
                  try {
                    String finalImageUrl = currentImageUrl ?? '';
                    
                    if (selectedImage != null) {
                      finalImageUrl = await ref.read(adminRepositoryProvider).uploadImage(selectedImage!);
                    }

                    final req = {
                      'title': titleCtrl.text,
                      'description': descCtrl.text,
                      'location': locationCtrl.text,
                      'startTime': selectedStart.toUtc().toIso8601String(),
                      'endTime': selectedEnd.toUtc().toIso8601String(),
                      'capacity': int.tryParse(capacityCtrl.text) ?? 100,
                      'cancelDeadlineHours': int.tryParse(cancelDeadlineCtrl.text) ?? 72,
                      'status': statusCtrl.text,
                      'imageUrl': finalImageUrl.isNotEmpty ? finalImageUrl : null,
                    };
                    
                    if (event == null) {
                      await ref.read(adminRepositoryProvider).createEvent(req);
                    } else {
                      await ref.read(adminRepositoryProvider).updateEvent(event.id, req);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadEvents();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  } finally {
                    setStateDialog(() => isUploading = false);
                  }
                },
                child: isUploading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Lưu'),
              ),
            ],
          );
        }
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final e = _events[index];
          return ListTile(
            title: Text(e.title),
            subtitle: Text('Status: ${e.status}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEventDialog(event: e),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: const Text('Bạn có chắc muốn xóa sự kiện này không?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteEvent(e.id);
                            },
                            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CheckInsTab extends ConsumerStatefulWidget {
  const _CheckInsTab();
  @override
  ConsumerState<_CheckInsTab> createState() => _CheckInsTabState();
}

class _CheckInsTabState extends ConsumerState<_CheckInsTab> {
  List<Map<String, dynamic>> _eventsSummary = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEventsSummary();
  }

  Future<void> _loadEventsSummary() async {
    setState(() => _loading = true);
    try {
      _eventsSummary = await ref.read(adminRepositoryProvider).getEventsCheckInSummary();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    
    final filteredEvents = _eventsSummary.where((e) {
      final title = (e['title'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Tìm kiếm sự kiện',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (val) {
              setState(() => _searchQuery = val);
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final e = filteredEvents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _EventStatsDashboardScreen(
                          eventId: e['id'],
                          eventTitle: e['title'],
                        ),
                      ),
                    );
                  },
                  leading: e['imageUrl'] != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          AppConfig.baseUrl + e['imageUrl'],
                          width: 50, height: 50, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.event, size: 50),
                        ),
                      )
                    : const Icon(Icons.event, size: 50),
                  title: Text(e['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Đã check-in: ${e['checkInCount']} vé'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EventStatsDashboardScreen extends ConsumerStatefulWidget {
  final int eventId;
  final String eventTitle;
  const _EventStatsDashboardScreen({required this.eventId, required this.eventTitle});

  @override
  ConsumerState<_EventStatsDashboardScreen> createState() => _EventStatsDashboardScreenState();
}

class _EventStatsDashboardScreenState extends ConsumerState<_EventStatsDashboardScreen> {
  Map<String, dynamic>? _eventDetail;
  List<Map<String, dynamic>> _attendees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final futures = await Future.wait([
        repo.getEventDetail(widget.eventId),
        repo.getEventAttendees(widget.eventId),
      ]);
      _eventDetail = futures[0] as Map<String, dynamic>;
      _attendees = futures[1] as List<Map<String, dynamic>>;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(title: Text('Thống kê: ${widget.eventTitle}')), body: const Center(child: CircularProgressIndicator()));

    final capacity = _eventDetail?['capacity'] ?? 0;
    final totalRegistered = _attendees.length;
    final checkedIn = _attendees.where((a) => a['ticketStatus'] == 'CHECKED_IN').length;
    final notCheckedIn = totalRegistered - checkedIn;
    final rate = totalRegistered == 0 ? 0.0 : (checkedIn / totalRegistered * 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê sự kiện'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.eventTitle, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('1. Thẻ số liệu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => _EventAttendeeListScreen(
                        title: 'Đã đăng ký',
                        attendees: _attendees,
                      )));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.confirmation_num_outlined, color: Colors.blue.shade700),
                          const SizedBox(height: 8),
                          Text('Đã đăng ký', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                          Text('$totalRegistered/$capacity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => _EventCheckInDetailScreen(
                        eventId: widget.eventId,
                        eventTitle: widget.eventTitle,
                      )));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.how_to_reg, color: Colors.green.shade700),
                          const SizedBox(height: 8),
                          Text('Đã check-in', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                          Text('$checkedIn', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final list = _attendees.where((a) => a['ticketStatus'] != 'CHECKED_IN').toList();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => _EventAttendeeListScreen(
                        title: 'Chưa check-in',
                        attendees: list,
                      )));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chưa check-in', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text('$notCheckedIn', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tỷ lệ check-in', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('${rate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('2. Biểu đồ vòng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: totalRegistered == 0 
                      ? const Center(child: Text('Chưa có dữ liệu')) 
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 70,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green.shade600,
                                    value: checkedIn.toDouble(),
                                    title: '',
                                    radius: 30,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.grey.shade300,
                                    value: notCheckedIn.toDouble(),
                                    title: '',
                                    radius: 30,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${rate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                const Text('Đã check-in', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ],
                        ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.green.shade600, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('Đã vào: $checkedIn', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('Chưa vào: $notCheckedIn', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('$totalRegistered vé đăng ký', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventAttendeeListScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> attendees;
  const _EventAttendeeListScreen({required this.title, required this.attendees});

  @override
  State<_EventAttendeeListScreen> createState() => _EventAttendeeListScreenState();
}

class _EventAttendeeListScreenState extends State<_EventAttendeeListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.attendees.where((a) {
      final code = (a['ticketCode'] ?? '').toString().toLowerCase();
      final name = (a['name'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return code.contains(q) || name.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Tìm kiếm tên hoặc mã vé',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final a = filtered[index];
                final isCheckedIn = a['ticketStatus'] == 'CHECKED_IN';
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('${a['name']} - ${a['ticketCode']}'),
                  subtitle: Text('Email: ${a['email']}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCheckedIn ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCheckedIn ? 'Đã check-in' : 'Chưa check-in',
                      style: TextStyle(color: isCheckedIn ? Colors.green.shade800 : Colors.orange.shade800, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _EventCheckInDetailScreen extends ConsumerStatefulWidget {
  final int eventId;
  final String eventTitle;
  const _EventCheckInDetailScreen({required this.eventId, required this.eventTitle});

  @override
  ConsumerState<_EventCheckInDetailScreen> createState() => _EventCheckInDetailScreenState();
}

class _EventCheckInDetailScreenState extends ConsumerState<_EventCheckInDetailScreen> {
  List<dynamic> _checkIns = [];
  bool _loading = true;
  String? _token;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    setState(() => _loading = true);
    try {
      _checkIns = await ref.read(adminRepositoryProvider).getCheckInsByEvent(widget.eventId, 0, 100);
      _token = await ref.read(tokenStorageProvider).read(); 
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showCheckInDetail(Map<String, dynamic> c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết Check-in'),
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
              Text('Khách hàng: ${c['attendeeName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              if (c['attendeePhone'] != null) Text('SĐT: ${c['attendeePhone']}'),
              if (c['attendeeDob'] != null) Text('Ngày sinh: ${c['attendeeDob']}'),
              Text('Mã vé: ${c['ticketCode']}'),
              const Divider(),
              Text('Thời gian: ${c['checkedInAt']}'),
              Text('Người kiểm duyệt: ${c['checkedInBy']['name']} (${c['checkedInBy']['email']})'),
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
    final filteredCheckIns = _checkIns.where((c) {
      final code = (c['ticketCode'] ?? '').toString().toLowerCase();
      final name = (c['attendeeName'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return code.contains(query) || name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.eventTitle)),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Tìm kiếm theo tên hoặc mã vé',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filteredCheckIns.length,
                  itemBuilder: (context, index) {
                    final c = filteredCheckIns[index];
                    return ListTile(
                      onTap: () => _showCheckInDetail(c),
                      leading: c['photoUrl'] != null 
                          ? Image.network(
                              '${AppConfig.baseUrl}${c['photoUrl']}',
                              width: 50, height: 50, fit: BoxFit.cover,
                              headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.person, size: 50),
                      title: Text('${c['attendeeName']} - ${c['ticketCode']}'),
                      subtitle: Text('Người check-in: ${c['checkedInBy']['name']}'),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}

class RoleUsersScreen extends ConsumerStatefulWidget {
  final String title;
  final String role;
  const RoleUsersScreen({super.key, required this.title, required this.role});

  @override
  ConsumerState<RoleUsersScreen> createState() => _RoleUsersScreenState();
}

class _RoleUsersScreenState extends ConsumerState<RoleUsersScreen> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final allUsers = await ref.read(adminRepositoryProvider).getUsers();
      _users = allUsers.where((u) => u['role'] == widget.role).toList();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildUserTile(Map<String, dynamic> u) {
    return ListTile(
      leading: CircleAvatar(child: Text(u['role'][0])),
      title: Text(u['name'], style: TextStyle(decoration: u['isActive'] == false ? TextDecoration.lineThrough : null)),
      subtitle: Text(u['email']),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(u['role'], style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(u['isActive'] == false ? Icons.lock : Icons.lock_open, color: u['isActive'] == false ? Colors.red : Colors.green),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận Khóa / Mở Khóa'),
                  content: Text('Bạn có chắc chắn muốn ${u['isActive'] == false ? 'MỞ KHÓA' : 'KHÓA'} tài khoản ${u['name']}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: u['isActive'] == false ? Colors.green : Colors.red),
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await ref.read(adminRepositoryProvider).toggleUserLock(u['id']);
                          _loadUsers();
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      child: const Text('Thực hiện', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách ' + widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) => _buildUserTile(_users[index]),
            ),
    );
  }
}
