import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import '../models/water_point.dart';
import '../services/water_service.dart';

class WaterSourceMapScreen extends StatefulWidget {
  const WaterSourceMapScreen({super.key});

  @override
  State<WaterSourceMapScreen> createState() => _WaterSourceMapScreenState();
}

class _WaterSourceMapScreenState extends State<WaterSourceMapScreen> {
  final WaterService waterService = WaterService();
  final Map<String, bool> _filters = {
    'available': true,
    'low': true,
    'out': true,
  };

  @override
  Widget build(BuildContext context) {
    final points = waterService.getWaterPoints();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Sources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: kIsWeb
          ? fmap.FlutterMap(
              options: fmap.MapOptions(
                initialCenter: latlong.LatLng(1.300, 103.800),
                initialZoom: 14,
              ),
              children: [
                fmap.TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  tileProvider: kIsWeb
                      ? CancellableNetworkTileProvider()
                      : null,
                ),
                fmap.MarkerLayer(markers: _buildWebMarkers(points)),
              ],
            )
          : gmaps.GoogleMap(
              initialCameraPosition: const gmaps.CameraPosition(
                target: gmaps.LatLng(1.300, 103.800),
                zoom: 14,
              ),
              markers: _buildMarkers(points),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
            ),
    );
  }

  Set<gmaps.Marker> _buildMarkers(List<WaterPoint> points) {
    return points
        .where(
          (point) => _filters[point.status.toString().split('.').last] == true,
        )
        .map((point) {
          return gmaps.Marker(
            markerId: gmaps.MarkerId(point.id),
            position: gmaps.LatLng(point.latitude, point.longitude),
            infoWindow: gmaps.InfoWindow(
              title: point.name,
              snippet: point.status.toString().split('.').last,
            ),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              _hueForStatus(point.status),
            ),
          );
        })
        .toSet();
  }

  List<fmap.Marker> _buildWebMarkers(List<WaterPoint> points) {
    return points
        .where(
          (point) => _filters[point.status.toString().split('.').last] == true,
        )
        .map((point) {
          return fmap.Marker(
            width: 40.0,
            height: 40.0,
            point: latlong.LatLng(point.latitude, point.longitude),
            child: Icon(
              Icons.location_on,
              color: _colorForStatus(point.status),
              size: 36,
            ),
          );
        })
        .toList();
  }

  double _hueForStatus(WaterStatus status) {
    switch (status) {
      case WaterStatus.available:
        return gmaps.BitmapDescriptor.hueGreen;
      case WaterStatus.low:
        return gmaps.BitmapDescriptor.hueOrange;
      case WaterStatus.out:
        return gmaps.BitmapDescriptor.hueRed;
    }
  }

  Color _colorForStatus(WaterStatus status) {
    switch (status) {
      case WaterStatus.available:
        return Colors.green;
      case WaterStatus.low:
        return Colors.orange;
      case WaterStatus.out:
        return Colors.red;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Water Sources'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterTile('Available', 'available', Colors.green),
            _buildFilterTile('Low', 'low', Colors.orange),
            _buildFilterTile('Out', 'out', Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTile(String label, String status, Color color) {
    return CheckboxListTile(
      title: Text(label),
      secondary: Icon(Icons.water_drop, color: color),
      value: _filters[status],
      onChanged: (value) {
        setState(() {
          _filters[status] = value!;
          Navigator.pop(context);
        });
      },
    );
  }
}
