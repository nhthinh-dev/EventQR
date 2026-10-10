import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/ticket_response.dart';

final ticketRepositoryProvider = Provider((ref) => TicketRepository(ref.watch(dioProvider)));

final myTicketsFutureProvider = FutureProvider.autoDispose<List<TicketResponse>>((ref) async {
  return ref.read(ticketRepositoryProvider).getMyTickets();
});

class TicketRepository {
  final Dio _dio;
  TicketRepository(this._dio);

    Future<void> cancelTicket(int ticketId) async {
    try {
      await _dio.put('/api/tickets/$ticketId/cancel');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<List<TicketResponse>> getMyTickets() async {
    final response = await _dio.get('/api/tickets/me');
    final List content = response.data; // API trả về thẳng mảng JSON
    return content.map((e) => TicketResponse.fromJson(e)).toList();
  }
}
