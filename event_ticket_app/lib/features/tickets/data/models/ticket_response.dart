class TicketResponse {
  final int ticketId;
  final String ticketCode;
  final String status;
  final int eventId;
  final String eventTitle;
  final DateTime startTime;
  final String location;

  TicketResponse({
    required this.ticketId,
    required this.ticketCode,
    required this.status,
    required this.eventId,
    required this.eventTitle,
    required this.startTime,
    required this.location,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      ticketId: json['ticketId'],
      ticketCode: json['ticketCode'],
      status: json['status'],
      eventId: json['eventId'],
      eventTitle: json['eventTitle'],
      startTime: DateTime.parse(json['startTime']),
      location: json['location'],
    );
  }
}
