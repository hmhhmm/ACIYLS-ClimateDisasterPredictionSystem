enum WaterStatus { available, low, out }

class WaterPoint {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final WaterStatus status;

  WaterPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  factory WaterPoint.fromJson(Map<String, dynamic> json) {
    return WaterPoint(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      status: WaterStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'available'),
        orElse: () => WaterStatus.available,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'status': status.toString().split('.').last,
      };
} 