import '../models/water_point.dart';

class WaterService {
  final List<WaterPoint> _points = [
    WaterPoint(
      id: '1',
      name: 'Central Water Station',
      latitude: 37.33233141,
      longitude: -122.0312186,
      status: WaterStatus.available,
    ),
    WaterPoint(
      id: '2',
      name: 'Northside Pump',
      latitude: 37.34233141,
      longitude: -122.0212186,
      status: WaterStatus.low,
    ),
    WaterPoint(
      id: '3',
      name: 'East Reservoir',
      latitude: 37.32233141,
      longitude: -122.0412186,
      status: WaterStatus.out,
    ),
  ];

  List<WaterPoint> getWaterPoints() => List.unmodifiable(_points);

  void updateStatus(String id, WaterStatus status) {
    final idx = _points.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _points[idx] = WaterPoint(
        id: _points[idx].id,
        name: _points[idx].name,
        latitude: _points[idx].latitude,
        longitude: _points[idx].longitude,
        status: status,
      );
    }
  }
} 