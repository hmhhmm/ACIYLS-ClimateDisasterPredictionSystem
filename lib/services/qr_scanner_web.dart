import 'dart:html' as html;
import 'package:flutter/material.dart';

class QRScannerWeb extends StatefulWidget {
  final Function(String) onScan;

  const QRScannerWeb({super.key, required this.onScan});

  @override
  State<QRScannerWeb> createState() => _QRScannerWebState();
}

class _QRScannerWebState extends State<QRScannerWeb> {
  late final html.VideoElement _videoElement;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      // Create video element
      _videoElement = html.VideoElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..setAttribute('playsinline', 'true')
        ..setAttribute('autoplay', 'true');

      // Get user media
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {'facingMode': 'environment'},
      });

      if (stream != null) {
        _videoElement.srcObject = stream;
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing scanner: $e');
    }
  }

  @override
  void dispose() {
    // Stop video stream
    final stream = _videoElement.srcObject;
    if (stream != null) {
      stream.getTracks().forEach((track) => track.stop());
    }
    _videoElement.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // For web, we'll just show a message since QR scanning is complex in web
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'QR Scanning on Web',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please use the test buttons below\nor scan using a mobile device.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => widget.onScan('UNIT001'),
            child: const Text('Test Scan UNIT001'),
          ),
        ],
      ),
    );
  }
}
