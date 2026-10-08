import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../data/organizer_repository.dart';
import 'organizer_home_screen.dart'; // Import Ä‘á»ƒ cÃ³ organizerEventsFutureProvider

class CheckInPreviewScreen extends ConsumerStatefulWidget {
  final int eventId;
  final String ticketCode;

  const CheckInPreviewScreen({
    super.key,
    required this.eventId,
    required this.ticketCode,
  });

  @override
  ConsumerState<CheckInPreviewScreen> createState() => _CheckInPreviewScreenState();
}

class _CheckInPreviewScreenState extends ConsumerState<CheckInPreviewScreen> {
  Map<String, dynamic>? _ticketInfo;
  bool _isLoading = true;
  bool _isCheckingIn = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _verifyTicket();
  }

  Future<void> _verifyTicket() async {
    try {
      final info = await ref.read(organizerRepositoryProvider).verifyTicket(
            widget.ticketCode,
            widget.eventId,
          );
      if (mounted) {
        setState(() {
          _ticketInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        context.pop();
      }
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _confirmCheckIn() async {
    if (_imageFile == null) return;
    
    setState(() => _isCheckingIn = true);
    try {
      await ref.read(organizerRepositoryProvider).checkInWithPhoto(
            widget.eventId,
            widget.ticketCode,
            _imageFile!.path,
          );
          
      if (mounted) {
        // !!! ĐIỂM QUAN TRỌNG: Làm mới số lượng check-in trước khi chuyển trang!!!
        ref.invalidate(organizerEventsFutureProvider);
        
        // Chuyá»ƒn sang mÃ n hÃ¬nh thÃ nh cÃ´ng
        context.pushReplacement('/organizer/result', extra: {
          'eventId': widget.eventId,
          'ticketCode': widget.ticketCode,
          'attendeeName': _ticketInfo?['attendeeName'],
          'eventTitle': _ticketInfo?['eventTitle']
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isCheckingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_ticketInfo == null) {
      return const Scaffold(body: Center(child: Text('Lỗi tải thông tin vé.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực & Chụp ảnh')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.confirmation_number, size: 60, color: Colors.blue),
            const SizedBox(height: 16),
            Text('Tên khách: ${_ticketInfo!['attendeeName'] ?? 'Không rõ'}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            
            // Hiá»ƒn thá»‹ SÄ T vÃ  NgÃ y sinh náº¿u cÃ³
            if (_ticketInfo!['attendeePhone'] != null)
              Text('SĐT: ${_ticketInfo!['attendeePhone']}', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            if (_ticketInfo!['attendeeDob'] != null)
              Text('Ngày sinh: ${_ticketInfo!['attendeeDob']}', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              
            const SizedBox(height: 8),
            Text('Mã vé: ${_ticketInfo!['ticketCode']}', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            Text('Sự kiện: ${_ticketInfo!['eventTitle']}', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            
            if (_imageFile != null)
              Image.file(_imageFile!, height: 300, fit: BoxFit.cover)
            else
              Container(
                height: 300,
                color: Colors.grey[200],
                child: const Center(child: Text('Chưa có ảnh chụp')),
              ),
              
            const SizedBox(height: 24),
            
            if (_imageFile == null)
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('CHỤP ẢNH KHÁCH HÀNG', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.refresh),
                    label: const Text('CHỤP LẠI'),
                  ),
                  const SizedBox(height: 16),
                  _isCheckingIn
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _confirmCheckIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('XÁC NHẬN CHECK-IN', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
