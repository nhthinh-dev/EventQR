class OrganizerEventResponse {
  final int id;
  final String title;
  final DateTime startTime;
  final int capacity;
  final int registeredCount;
  final int checkedInCount;
  final String status;

  OrganizerEventResponse({
    required this.id,
    required this.title,
    required this.startTime,
    required this.capacity,
    required this.registeredCount,
    required this.checkedInCount,
    required this.status,
  });

  factory OrganizerEventResponse.fromJson(Map<String, dynamic> json) {
    return OrganizerEventResponse(
      id: json['id'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      capacity: json['capacity'],
      registeredCount: json['registeredCount'] ?? 0,
      checkedInCount: json['checkedInCount'] ?? 0,
      status: json['status'],
    );
  }
}
