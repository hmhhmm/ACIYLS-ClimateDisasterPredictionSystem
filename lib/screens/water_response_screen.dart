import 'package:flutter/material.dart';
import '../models/water_point.dart';
import '../services/water_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class WaterResponseScreen extends StatefulWidget {
  const WaterResponseScreen({super.key});

  @override
  State<WaterResponseScreen> createState() => _WaterResponseScreenState();
}

class _WaterResponseScreenState extends State<WaterResponseScreen> {
  final WaterService waterService = WaterService();

  @override
  Widget build(BuildContext context) {
    final points = waterService.getWaterPoints();
    return Scaffold(
      appBar: AppBar(title: const Text('Clean Water Points')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...points.map((p) => Card(
                color: p.status == WaterStatus.available
                    ? Colors.green[50]
                    : p.status == WaterStatus.low
                        ? Colors.orange[50]
                        : Colors.red[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Lat: ${p.latitude}, Lng: ${p.longitude}'),
                  trailing: Text(
                    p.status == WaterStatus.available
                        ? 'Available'
                        : p.status == WaterStatus.low
                            ? 'Low'
                            : 'Out',
                    style: TextStyle(
                      color: p.status == WaterStatus.available
                          ? Colors.green
                          : p.status == WaterStatus.low
                              ? Colors.orange
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.water),
            label: const Text('Request Clean Water'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.report_problem),
            label: const Text('Report Water Shortage'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: _EmbeddedWaterSourceMap(),
          ),
        ],
      ),
    );
  }
}

class _EmbeddedWaterSourceMap extends StatefulWidget {
  @override
  State<_EmbeddedWaterSourceMap> createState() => _EmbeddedWaterSourceMapState();
}

class _EmbeddedWaterSourceMapState extends State<_EmbeddedWaterSourceMap> {
  final List<Map<String, dynamic>> _sources = [
    {'name': 'Well A', 'status': 'working', 'lat': 1.300, 'lng': 103.800},
    {'name': 'Tank B', 'status': 'maintenance', 'lat': 1.302, 'lng': 103.802},
    {'name': 'Spring C', 'status': 'contaminated', 'lat': 1.298, 'lng': 103.804},
    {'name': 'Well D', 'status': 'working', 'lat': 1.301, 'lng': 103.799},
  ];
  final Map<String, bool> _filters = {
    'working': true,
    'maintenance': true,
    'contaminated': true,
  };

  Set<gmaps.Marker> get _filteredMarkers {
    final filtered = _sources.where((s) => _filters[s['status']] == true);
    return filtered.map((source) {
      return gmaps.Marker(
        markerId: gmaps.MarkerId(source['name']),
        position: gmaps.LatLng(source['lat'], source['lng']),
        infoWindow: gmaps.InfoWindow(
          title: source['name'],
          snippet: source['status'],
        ),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(_hueForStatus(source['status'])),
      );
    }).toSet();
  }

  double _hueForStatus(String status) {
    switch (status) {
      case 'working':
        return gmaps.BitmapDescriptor.hueGreen;
      case 'maintenance':
        return gmaps.BitmapDescriptor.hueOrange;
      case 'contaminated':
        return gmaps.BitmapDescriptor.hueRed;
      default:
        return gmaps.BitmapDescriptor.hueAzure;
    }
  }

  List<fmap.Marker> get _webMarkers {
    final filtered = _sources.where((s) => _filters[s['status']] == true);
    return filtered.map((source) {
      Color color;
      switch (source['status']) {
        case 'working':
          color = Colors.green;
          break;
        case 'maintenance':
          color = Colors.orange;
          break;
        case 'contaminated':
          color = Colors.red;
          break;
        default:
          color = Colors.blue;
      }
      return fmap.Marker(
        width: 40.0,
        height: 40.0,
        point: latlong.LatLng(source['lat'], source['lng']),
        child: Icon(Icons.location_on, color: color, size: 36),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: kIsWeb
            ? fmap.FlutterMap(
                options: fmap.MapOptions(
                  center: latlong.LatLng(1.300, 103.800),
                  zoom: 14,
                ),
                children: [
                  fmap.TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    tileProvider: kIsWeb ? CancellableNetworkTileProvider() : null,
                  ),
                  fmap.MarkerLayer(markers: _webMarkers),
                ],
              )
            : gmaps.GoogleMap(
                initialCameraPosition: const gmaps.CameraPosition(
                  target: gmaps.LatLng(1.300, 103.800),
                  zoom: 14,
                ),
                markers: _filteredMarkers,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
              ),
      ),
    );
  }
} 