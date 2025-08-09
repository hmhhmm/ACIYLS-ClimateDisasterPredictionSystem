import 'package:flutter/material.dart';

class QRScannerWeb extends StatefulWidget {
  final Function(String) onScan;

  const QRScannerWeb({super.key, required this.onScan});

  @override
  State<QRScannerWeb> createState() => _QRScannerWebState();
}

class _QRScannerWebState extends State<QRScannerWeb> {
  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => widget.onScan('UNIT002'),
            child: const Text('Test Scan UNIT002'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => widget.onScan('UNIT003'),
            child: const Text('Test Scan UNIT003'),
          ),
        ],
      ),
    );
  }
}
