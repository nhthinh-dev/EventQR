import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final statusCtrl = TextEditingController(text: event?.status ?? 'OPEN');

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
      builder: (context) => AlertDialog(
        title: Text(event == null ? 'Tạo sự kiện mới' : 'Sửa sự kiện'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên sự kiện')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả')),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Địa điểm')),
              TextField(
                controller: startCtrl, 
                decoration: const InputDecoration(labelText: 'Bắt đầu', suffixIcon: Icon(Icons.calendar_month)),
                readOnly: true,
                onTap: () => pickDateTime(context, true),
              ),
              TextField(
                controller: endCtrl, 
                decoration: const InputDecoration(labelText: 'Kết thúc', suffixIcon: Icon(Icons.calendar_month)),
                readOnly: true,
                onTap: () => pickDateTime(context, false),
              ),
              TextField(controller: capacityCtrl, decoration: const InputDecoration(labelText: 'Sức chứa'), keyboardType: TextInputType.number),
              DropdownButtonFormField<String>(
              value: ['OPEN', 'CLOSED'].contains(statusCtrl.text) ? statusCtrl.text : 'OPEN',
              decoration: const InputDecoration(labelText: 'Trạng thái'),
              items: const [
                DropdownMenuItem(value: 'OPEN', child: Text('OPEN (Mở)')),
                DropdownMenuItem(value: 'CLOSED', child: Text('CLOSED (Đóng/Hết hạn)')),
              ],
              onChanged: (val) {
                if (val != null) statusCtrl.text = val;
              },
            ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              try {
                final req = {
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'location': locationCtrl.text,
                  'startTime': selectedStart.toUtc().toIso8601String(),
                  'endTime': selectedEnd.toUtc().toIso8601String(),
                  'capacity': int.tryParse(capacityCtrl.text) ?? 100,
                  'status': statusCtrl.text,
                };
                if (event == null) {
                  await ref.read(adminRepositoryProvider).createEvent(req);
                } else {
                  await ref.read(adminRepositoryProvider).updateEvent(event.id, req);
                }
                if (context.mounted) Navigator.pop(context);
                _loadEvents();
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text(event == null ? 'Tạo' : 'Lưu'),
          )
        ],
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
      _checkIns = await ref.read(adminRepositoryProvider).getCheckIns(0, 50);
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
              Text('Sự kiện: ${c['eventTitle']}'),
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    
    final filteredCheckIns = _checkIns.where((c) {
      final code = (c['ticketCode'] ?? '').toString().toLowerCase();
      final name = (c['attendeeName'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return code.contains(query) || name.contains(query);
    }).toList();

    return Column(
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
            padding: const EdgeInsets.only(bottom: 80),
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
                subtitle: Text('Sự kiện: ${c['eventTitle']}\nNgười check-in: ${c['checkedInBy']['name']}'),
                isThreeLine: true,
              );
            },
          ),
        ),
      ],
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
