class Alert {
  final String type;
  final String message;
  final DateTime timestamp;
  final String? location;

  Alert({
    required this.type,
    required this.message,
    required this.timestamp,
    this.location,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'location': location,
      };
} 