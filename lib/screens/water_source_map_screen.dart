import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class WaterSourceMapScreen extends StatefulWidget {
  const WaterSourceMapScreen({super.key});

  @override
  State<WaterSourceMapScreen> createState() => _WaterSourceMapScreenState();
}

class _WaterSourceMapScreenState extends State<WaterSourceMapScreen> {
  final List<Map<String, dynamic>> _sources = [
    {'name': 'Well A', 'status': 'working', 'lat': 1.300, 'lng': 103.800},
    {'name': 'Tank B', 'status': 'maintenance', 'lat': 1.302, 'lng': 103.802},
    {
      'name': 'Spring C',
      'status': 'contaminated',
      'lat': 1.298,
      'lng': 103.804,
    },
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
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          _hueForStatus(source['status']),
        ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Sources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Legend'),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 4),
                          Text('Working'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text('Maintenance'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          const SizedBox(width: 4),
                          Text('Contaminated'),
                        ],
                      ),
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
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                  label: const Text('✅ Working'),
                  selected: _filters['working']!,
                  onSelected: (val) =>
                      setState(() => _filters['working'] = val),
                  selectedColor: Colors.green[100],
                ),
                FilterChip(
                  label: const Text('⚠️ Maintenance'),
                  selected: _filters['maintenance']!,
                  onSelected: (val) =>
                      setState(() => _filters['maintenance'] = val),
                  selectedColor: Colors.orange[100],
                ),
                FilterChip(
                  label: const Text('❌ Contaminated'),
                  selected: _filters['contaminated']!,
                  onSelected: (val) =>
                      setState(() => _filters['contaminated'] = val),
                  selectedColor: Colors.red[100],
                ),
              ],
            ),
          ),
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
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
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            tileProvider: kIsWeb
                                ? CancellableNetworkTileProvider()
                                : null,
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
            ),
          ),
        ],
      ),
    );
  }
}

// NOTE: To use Google Maps, you must set up your API key for Android and iOS. For web, OpenStreetMap is used as a fallback.
