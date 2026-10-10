class EventResponse {
  final int id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final int totalTickets;
  final int availableTickets;
  final String status;
  final int cancelDeadlineHours;
  final String? imageUrl;

  EventResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.totalTickets,
    required this.availableTickets,
    required this.status,
    required this.cancelDeadlineHours,
    this.imageUrl,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      location: json['location'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      totalTickets: json['capacity'] ?? 0,
      availableTickets: json['remainingSeats'] ?? 0,
      status: json['status'] ?? 'UNKNOWN',
      cancelDeadlineHours: json['cancelDeadlineHours'] ?? 72,
      imageUrl: json['imageUrl'],
    );
  }
}
