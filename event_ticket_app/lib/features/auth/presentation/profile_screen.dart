import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/profile_repository.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/network/api_client.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime? _selectedDate;
  bool _isEditing = false;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    if (!_isEditing) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final dobStr = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '';
      await ref.read(profileRepositoryProvider).updateProfile(
        _nameCtrl.text,
        _phoneCtrl.text,
        dobStr,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thông tin thành công'), backgroundColor: Colors.green));
      setState(() => _isEditing = false);
      ref.invalidate(profileFutureProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ Cá nhân'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(tokenStorageProvider).clear();
              ref.read(authStateProvider.notifier).setRole(AuthRole.guest);
            },
          )
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (data) {
          if (!_isEditing && _nameCtrl.text.isEmpty) {
            _nameCtrl.text = data['name'] ?? '';
            _phoneCtrl.text = data['phone'] ?? '';
            if (data['dob'] != null && data['dob'].isNotEmpty) {
              _selectedDate = DateTime.tryParse(data['dob']);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: TextEditingController(text: data['email']),
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                  readOnly: true, // Email không được sửa
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Họ và tên', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  readOnly: !_isEditing,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                  readOnly: !_isEditing,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Ngày sinh', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                    child: Text(
                      _selectedDate == null 
                        ? 'Chưa cập nhật' 
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_isEditing)
                  _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _nameCtrl.text = data['name'] ?? '';
                                  _phoneCtrl.text = data['phone'] ?? '';
                                  _selectedDate = data['dob'] != null ? DateTime.tryParse(data['dob']) : null;
                                });
                              },
                              child: const Text('HỦY'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                              onPressed: _saveProfile,
                              child: const Text('LƯU LẠI'),
                            ),
                          ),
                        ],
                      )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit),
                    label: const Text('CHỈNH SỬA HỒ SƠ'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
