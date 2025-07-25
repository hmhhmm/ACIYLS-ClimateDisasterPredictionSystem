import 'package:flutter/material.dart';
import '../models/water_usage_stats.dart';
import 'water_unit_details_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/responsive_utils.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  // Mock data for water units with enhanced information
  final Map<String, Map<String, dynamic>> _mockWaterUnits = {
    'UNIT001': {
      'id': 'UNIT001',
      'name': 'Water Tank A1',
      'type': 'Storage Tank',
      'status': 'Working',
      'lastMaintenance': '2024-03-01',
      'nextMaintenance': '2024-04-01',
      'capacity': '1000L',
      'currentLevel': '75%',
      'waterQuality': 'Good',
      'ph': '7.2',
      'temperature': '22°C',
      'location': 'Block A, Main Building',
      'coordinates': '3.0738° N, 101.5183° E',
      'lastScanned': '2024-03-15 14:30',
    },
    'UNIT002': {
      'id': 'UNIT002',
      'name': 'Filter System B2',
      'type': 'Water Filter',
      'status': 'Needs Maintenance',
      'lastMaintenance': '2024-02-15',
      'nextMaintenance': '2024-03-15',
      'capacity': 'N/A',
      'filterType': 'Reverse Osmosis',
      'filterLife': '15%',
      'waterQuality': 'Fair',
      'ph': '6.8',
      'temperature': '23°C',
      'location': 'Block B, Treatment Plant',
      'coordinates': '3.0739° N, 101.5184° E',
      'lastScanned': '2024-03-10 09:15',
    },
    'UNIT003': {
      'id': 'UNIT003',
      'name': 'Community Well C3',
      'type': 'Well',
      'status': 'Working',
      'lastMaintenance': '2024-03-10',
      'nextMaintenance': '2024-04-10',
      'capacity': '5000L',
      'currentLevel': '90%',
      'waterQuality': 'Excellent',
      'ph': '7.0',
      'temperature': '21°C',
      'depth': '45m',
      'location': 'Community Center',
      'coordinates': '3.0740° N, 101.5185° E',
      'lastScanned': '2024-03-14 16:45',
    },
    'UNIT004': {
      'id': 'UNIT004',
      'name': 'Treatment Plant D4',
      'type': 'Treatment Facility',
      'status': 'Working',
      'lastMaintenance': '2024-03-05',
      'nextMaintenance': '2024-04-05',
      'capacity': '10000L/day',
      'currentOutput': '8500L/day',
      'waterQuality': 'Good',
      'ph': '7.1',
      'temperature': '24°C',
      'location': 'Industrial Zone',
      'coordinates': '3.0741° N, 101.5186° E',
      'lastScanned': '2024-03-13 11:20',
    },
    'UNIT005': {
      'id': 'UNIT005',
      'name': 'Emergency Tank E5',
      'type': 'Emergency Storage',
      'status': 'Low Level',
      'lastMaintenance': '2024-03-12',
      'nextMaintenance': '2024-04-12',
      'capacity': '2000L',
      'currentLevel': '30%',
      'waterQuality': 'Good',
      'ph': '7.3',
      'temperature': '22°C',
      'location': 'Emergency Response Center',
      'coordinates': '3.0742° N, 101.5187° E',
      'lastScanned': '2024-03-15 08:00',
    },
  };

  Future<void> _handleScannedCode(String code) async {
    if (!_isScanning) return;

    setState(() => _isScanning = false);
    controller.stop();

    try {
      if (_mockWaterUnits.containsKey(code)) {
        final unit = _mockWaterUnits[code]!;
        final mockStats = await _createMockStats(code);

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WaterUnitDetailsScreen(unit: unit, stats: mockStats),
          ),
        );

        setState(() => _isScanning = true);
        controller.start();
      } else {
        _showInvalidCodeDialog();
      }
    } catch (e) {
      _showErrorDialog('Error processing QR code: $e');
    }
  }

  Future<WaterUsageStats> _createMockStats(String unitId) async {
    // Create mock daily usage data
    final dailyUsage = List.generate(
      7,
      (index) => DailyUsage(
        unitId: unitId,
        date: DateTime.now().subtract(Duration(days: index)),
        amount: 2000 + (index * 100),
        userId: 'User${100 + index}',
        purpose: index % 2 == 0 ? 'Community Usage' : 'Irrigation',
      ),
    );

    // Create mock maintenance records
    final maintenanceRecords = [
      MaintenanceRecord(
        unitId: unitId,
        date: DateTime.now().subtract(const Duration(days: 30)),
        type: 'Filter Change',
        technician: 'John Doe',
        description: 'Regular maintenance and filter replacement',
        partsReplaced: ['Main Filter', 'O-rings'],
        cost: 150.0,
        status: MaintenanceStatus.completed,
      ),
      MaintenanceRecord(
        unitId: unitId,
        date: DateTime.now().add(const Duration(days: 15)),
        type: 'Scheduled Service',
        technician: 'Jane Smith',
        description: 'Regular scheduled maintenance',
        partsReplaced: [],
        cost: 100.0,
        status: MaintenanceStatus.scheduled,
      ),
    ];

    // Create mock quality records
    final qualityRecords = [
      QualityRecord(
        unitId: unitId,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ph: 7.2,
        turbidity: 0.5,
        dissolvedOxygen: 8.5,
        temperature: 22.0,
        conductivity: 250.0,
        testedBy: 'Lab Tech 1',
        contaminants: [],
        passesStandards: true,
      ),
      QualityRecord(
        unitId: unitId,
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        ph: 7.1,
        turbidity: 0.6,
        dissolvedOxygen: 8.3,
        temperature: 23.0,
        conductivity: 255.0,
        testedBy: 'Lab Tech 2',
        contaminants: ['Trace Minerals'],
        passesStandards: true,
      ),
    ];

    // Create mock issue reports
    final issueReports = [
      IssueReport(
        unitId: unitId,
        reportId: 'ISS001',
        reportedAt: DateTime.now().subtract(const Duration(days: 5)),
        reportedBy: 'Field Inspector',
        type: 'Mechanical',
        description: 'Minor vibration in pump',
        images: [],
        status: IssueStatus.resolved,
        priority: Priority.medium,
        resolvedAt: DateTime.now().subtract(const Duration(days: 3)),
        resolvedBy: 'Maintenance Team',
        resolution: 'Adjusted pump alignment and tightened mounting bolts',
      ),
    ];

    return WaterUsageStats(
      unitId: unitId,
      dailyUsage: dailyUsage,
      maintenanceRecords: maintenanceRecords,
      qualityRecords: qualityRecords,
      issueReports: issueReports,
    );
  }

  void _showInvalidCodeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Invalid QR Code',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 17),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This QR code is not associated with any water unit.',
          style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 15)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isScanning = true);
              controller.start();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 17),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 15)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isScanning = true);
              controller.start();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scannerHeight = screenSize.height * 0.45; // 45% of screen height

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 17),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Scan Water Unit QR'),
          actions: [
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                size: ResponsiveUtils.getScaledIconSize(context, 24),
              ),
              onPressed: () async {
                try {
                  await controller.toggleTorch();
                  setState(() => _isFlashOn = !_isFlashOn);
                } catch (e) {
                  _showErrorDialog('Error toggling flash: $e');
                }
              },
            ),
            IconButton(
              icon: Icon(
                _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                size: ResponsiveUtils.getScaledIconSize(context, 24),
              ),
              onPressed: () async {
                try {
                  await controller.switchCamera();
                  setState(() => _isFrontCamera = !_isFrontCamera);
                } catch (e) {
                  _showErrorDialog('Error switching camera: $e');
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: scannerHeight,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: controller,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null) {
                              _handleScannedCode(barcode.rawValue!);
                              break;
                            }
                          }
                        },
                      ),
                      CustomPaint(
                        size: Size(screenSize.width - 32, scannerHeight),
                        painter: ScannerOverlayPainter(),
                      ),
                      if (!_isScanning)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: ResponsiveUtils.getScaledHeight(context, 16),
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: ResponsiveUtils.getScaledIconSize(
                                context,
                                32,
                              ),
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getScaledHeight(
                                context,
                                8,
                              ),
                            ),
                            Text(
                              'Position QR code in frame',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveUtils.getFontSize(
                                  context,
                                  15,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    padding: ResponsiveUtils.getScaledPadding(
                      context,
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test QR Codes',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 17),
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveUtils.getScaledHeight(context, 12),
                        ),
                        Wrap(
                          spacing: ResponsiveUtils.getScaledWidth(context, 8),
                          runSpacing: ResponsiveUtils.getScaledHeight(
                            context,
                            8,
                          ),
                          alignment: WrapAlignment.start,
                          children:
                              [
                                    'UNIT001',
                                    'UNIT002',
                                    'UNIT003',
                                    'UNIT004',
                                    'UNIT005',
                                  ]
                                  .map(
                                    (code) => ActionChip(
                                      label: Text(
                                        code,
                                        style: TextStyle(
                                          fontSize: ResponsiveUtils.getFontSize(
                                            context,
                                            13,
                                          ),
                                        ),
                                      ),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                      labelStyle: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      onPressed: () => _handleScannedCode(code),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scannerSize = size.width * 0.7;
    final left = (size.width - scannerSize) / 2;
    final top = (size.height - scannerSize) / 2;
    final right = left + scannerSize;
    final bottom = top + scannerSize;

    // Draw semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(left, top, right, bottom),
            const Radius.circular(12),
          ),
        ),
      ),
      paint,
    );

    // Draw scanner corners
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cornerLength = scannerSize * 0.15;

    // Top left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(right - cornerLength, top),
      Offset(right, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + cornerLength),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(left, bottom - cornerLength),
      Offset(left, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerLength, bottom),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(right - cornerLength, bottom),
      Offset(right, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
