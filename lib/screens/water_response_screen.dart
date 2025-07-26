import 'package:flutter/material.dart';
import '../models/water_point.dart';
import '../services/water_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'qr_scanner_screen.dart';
import 'report_issue_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class WaterResponseScreen extends StatefulWidget {
  const WaterResponseScreen({super.key});

  @override
  State<WaterResponseScreen> createState() => _WaterResponseScreenState();
}

class _WaterResponseScreenState extends State<WaterResponseScreen>
    with SingleTickerProviderStateMixin {
  final WaterService waterService = WaterService();
  final List<Map<String, dynamic>> _offlineReports = [];
  bool _isOnline = true;
  late TabController _tabController;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Nearest Clean Water',
      'message': 'Clean water source available 200m away at Block A',
      'icon': Icons.location_on,
      'time': '2 mins ago',
      'type': 'info',
    },
    {
      'title': 'Maintenance Required',
      'message': 'Tank B2 requires maintenance - Last scan: 30 days ago',
      'icon': Icons.warning,
      'time': '5 mins ago',
      'type': 'warning',
    },
    {
      'title': 'Report Resolved',
      'message': 'Water leak at Block C has been fixed',
      'icon': Icons.check_circle,
      'time': '1 hour ago',
      'type': 'success',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Enhanced card with accent color/gradient
  Widget _niceCard(
    BuildContext context,
    Widget child, {
    Color? accent,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                (accent ?? Colors.blue).withValues(alpha: 0.1),
                (accent ?? Colors.blue).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (accent ?? Colors.blue).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (accent ?? Colors.blue).withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = waterService.getWaterPoints();
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Water & Sanitation',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(color: Colors.white),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E5EA), width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelColor: Color(0xFF007AFF),
                unselectedLabelColor: Colors.black54,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: Color(0xFF007AFF)),
                  insets: EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
                tabs: const [
                  Tab(text: 'Status'),
                  Tab(text: 'Quality'),
                  Tab(text: 'Community'),
                ],
              ),
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _showNotifications(context),
                ),
                if (_notifications.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        _notifications.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStatusTab(points),
            _buildQualityTab(),
            _buildCommunityTab(),
          ],
        ),
      ),
    );
  }

  // --- Status Tab (original WaterResponseScreen content) ---
  Widget _buildStatusTab(List points) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _niceCard(context, _buildStatusBannerContent(), accent: Colors.blue),
        const SizedBox(height: 12),
        _niceCard(context, _buildActionButtonsContent(), accent: Colors.green),
        const SizedBox(height: 12),
        _niceCard(context, _buildOfflineQueueContent(), accent: Colors.orange),
        const SizedBox(height: 12),
        ...points.map(
          (p) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: p.status == WaterStatus.available
                    ? [Colors.green.shade100, Colors.green.shade200]
                    : p.status == WaterStatus.low
                    ? [Colors.orange.shade100, Colors.orange.shade200]
                    : [Colors.red.shade100, Colors.red.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      (p.status == WaterStatus.available
                              ? Colors.green
                              : p.status == WaterStatus.low
                              ? Colors.orange
                              : Colors.red)
                          .withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.1)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: p.status == WaterStatus.available
                          ? Colors.green
                          : p.status == WaterStatus.low
                          ? Colors.orange
                          : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (p.status == WaterStatus.available
                                      ? Colors.green
                                      : p.status == WaterStatus.low
                                      ? Colors.orange
                                      : Colors.red)
                                  .withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lat: ${p.latitude.toStringAsFixed(4)}, Lng: ${p.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: p.status == WaterStatus.available
                          ? Colors.green
                          : p.status == WaterStatus.low
                          ? Colors.orange
                          : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (p.status == WaterStatus.available
                                      ? Colors.green
                                      : p.status == WaterStatus.low
                                      ? Colors.orange
                                      : Colors.red)
                                  .withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      p.status == WaterStatus.available
                          ? 'Available'
                          : p.status == WaterStatus.low
                          ? 'Low'
                          : 'Out',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildRecentReports(),
        const SizedBox(height: 24),
        SizedBox(height: 400, child: _EmbeddedWaterSourceMap()),
      ],
    );
  }

  // --- Quality Tab (from WaterInsightsScreen) ---
  Widget _buildQualityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _niceCard(context, _buildQualityOverviewContent(), accent: Colors.cyan),
        const SizedBox(height: 12),
        _niceCard(context, _buildQualityTrendsContent(), accent: Colors.indigo),
        const SizedBox(height: 12),
        _niceCard(context, _buildRiskAssessmentContent(), accent: Colors.green),
        const SizedBox(height: 12),
        _niceCard(context, _buildUsageStatsContent(), accent: Colors.blue),
        const SizedBox(height: 12),
        _niceCard(
          context,
          _buildUsageBreakdownContent(),
          accent: Colors.purple,
        ),
        const SizedBox(height: 12),
        _niceCard(
          context,
          _buildConservationTipsContent(),
          accent: Colors.teal,
        ),
      ],
    );
  }

  // --- Community Tab (from WaterInsightsScreen) ---
  Widget _buildCommunityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCommunityStats(),
        const SizedBox(height: 24),
        _buildLeaderboard(),
        const SizedBox(height: 24),
        _buildCommunityEvents(),
      ],
    );
  }

  Widget _buildStatusBannerContent() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _isOnline
                ? 'Connected - Reports will sync immediately'
                : 'Offline - Reports will sync when connection is restored',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScannerScreen(),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner, size: 24),
            label: const Text(
              'Scan QR for Water Unit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportIssueScreen(),
                ),
              );
            },
            icon: const Icon(Icons.report_problem, size: 24),
            label: const Text(
              'Report Issue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF007AFF),
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Color(0xFF007AFF), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScannerScreen()),
            );
          },
          icon: const Icon(Icons.qr_code_scanner, size: 24),
          label: const Text(
            'Scan QR for Water Unit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportIssueScreen(),
              ),
            );
          },
          icon: const Icon(Icons.report_problem, size: 24),
          label: const Text(
            'Report Issue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF007AFF),
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: Color(0xFF007AFF), width: 2),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineQueue() {
    if (_offlineReports.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pending_actions,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pending Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${_offlineReports.length} reports waiting to sync',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: _syncReports,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sync Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _offlineReports.length,
              itemBuilder: (context, index) {
                final report = _offlineReports[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.sync,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              report['location'],
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineQueueContent() {
    if (_offlineReports.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.pending_actions,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pending Reports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${_offlineReports.length} reports waiting to sync',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _syncReports,
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sync Now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._offlineReports.map(
          (report) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.sync, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        report['location'],
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReports() {
    final reports = [
      {
        'title': 'Water Leak',
        'location': 'Block A, Main Pipeline',
        'status': 'In Progress',
        'type': 'leak',
        'time': '2 hours ago',
      },
      {
        'title': 'Filter Broken',
        'location': 'Treatment Plant B2',
        'status': 'Pending',
        'type': 'filter',
        'time': '3 hours ago',
      },
      {
        'title': 'Tank Empty',
        'location': 'Emergency Tank E5',
        'status': 'Resolved',
        'type': 'tank',
        'time': '1 day ago',
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.grey.withOpacity(0.2),
              ),
              itemBuilder: (context, index) {
                final report = reports[index];
                final type = report['type'] as String;
                final status = report['status'] as String;
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getReportTypeColor(
                            type,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getReportTypeColor(
                                type,
                              ).withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getReportTypeIcon(type),
                          color: _getReportTypeColor(type),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${report['location']} • ${report['time']}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(
                                status,
                              ).withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _notifications.clear());
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: _notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final type = notification['type'] as String;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getNotificationColor(
                        type,
                      ).withValues(alpha: 0.1),
                      child: Icon(
                        notification['icon'] as IconData,
                        color: _getNotificationColor(type),
                      ),
                    ),
                    title: Text(notification['title'] as String),
                    subtitle: Text(notification['message'] as String),
                    trailing: Text(
                      notification['time'] as String,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Report an Issue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildIssueCategory('Water Infrastructure Issues', [
                    {
                      'title': 'Water Leak',
                      'icon': Icons.opacity,
                      'color': Colors.blue,
                    },
                    {
                      'title': 'Filter Broken',
                      'icon': Icons.filter_alt,
                      'color': Colors.orange,
                    },
                    {
                      'title': 'Tank Empty',
                      'icon': Icons.water_damage,
                      'color': Colors.red,
                    },
                  ]),
                  const SizedBox(height: 24),
                  _buildIssueCategory('Sanitation Issues', [
                    {
                      'title': 'Dirty Latrine',
                      'icon': Icons.cleaning_services,
                      'color': Colors.brown,
                    },
                    {
                      'title': 'Clogged Point',
                      'icon': Icons.plumbing,
                      'color': Colors.purple,
                    },
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueCategory(String title, List<Map<String, dynamic>> issues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: issues.map((issue) => _buildIssueButton(issue)).toList(),
        ),
      ],
    );
  }

  Widget _buildIssueButton(Map<String, dynamic> issue) {
    return Material(
      color: issue['color'].withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showReportDetailsDialog(issue),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(issue['icon'], color: issue['color'], size: 32),
              const SizedBox(height: 8),
              Text(
                issue['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: issue['color'],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetailsDialog(Map<String, dynamic> issue) {
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report ${issue['title'] as String}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement image picking
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image upload coming soon')),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Add Photo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (!_isOnline) {
                _offlineReports.add({
                  'title': issue['title'] as String,
                  'location': locationController.text,
                  'description': descriptionController.text,
                  'type': issue['type'] as String,
                  'time': DateTime.now(),
                });
              }
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isOnline
                        ? 'Report submitted successfully'
                        : 'Report saved offline and will sync when online',
                  ),
                  backgroundColor: _isOnline ? Colors.green : Colors.orange,
                ),
              );
              setState(() {}); // Refresh UI
            },
            icon: const Icon(Icons.send),
            label: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _syncReports() {
    // Simulate syncing
    setState(() {
      _offlineReports.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All reports synced successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Color _getReportTypeColor(String type) {
    switch (type) {
      case 'leak':
        return Colors.blue;
      case 'filter':
        return Colors.orange;
      case 'tank':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportTypeIcon(String type) {
    switch (type) {
      case 'leak':
        return Icons.opacity;
      case 'filter':
        return Icons.filter_alt;
      case 'tank':
        return Icons.water_damage;
      default:
        return Icons.error;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQualityOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.water_drop, color: Colors.cyan, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Water Quality Overview',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildQualityIndicatorContent('pH Level', 7.2, 'Normal'),
        _buildQualityIndicatorContent('Turbidity', 0.5, 'Good'),
        _buildQualityIndicatorContent('Chlorine', 1.0, 'Normal'),
        _buildQualityIndicatorContent('Bacteria Count', 0, 'Excellent'),
      ],
    );
  }

  Widget _buildQualityIndicatorContent(
    String name,
    double value,
    String status,
  ) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'excellent':
        statusColor = Colors.green;
        break;
      case 'good':
        statusColor = Colors.blue;
        break;
      case 'normal':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityTrendsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.trending_up,
                color: Colors.indigo,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quality Trends',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final labels = [
                        'Day 0',
                        'Day 5',
                        'Day 10',
                        'Day 15',
                        'Day 20',
                        'Day 25',
                      ];
                      if (value.toInt() < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[value.toInt()],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 7.2),
                    const FlSpot(1, 7.3),
                    const FlSpot(2, 7.1),
                    const FlSpot(3, 7.4),
                    const FlSpot(4, 7.2),
                    const FlSpot(5, 7.5),
                  ],
                  isCurved: true,
                  color: Colors.indigo,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.indigo.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskAssessmentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.security, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Risk Assessment',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Water quality is within safe parameters. No immediate risks detected.',
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildUsageStatsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.analytics, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Usage Statistics',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Daily average: 150L per person\nWeekly total: 1,050L\nMonthly trend: Stable',
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildUsageBreakdownContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.pie_chart,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Usage Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Drinking: 30%\nBathing: 25%\nCooking: 20%\nCleaning: 15%\nOther: 10%',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildConservationTipsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb, color: Colors.teal, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Conservation Tips',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '• Fix leaky faucets promptly\n• Take shorter showers\n• Use water-efficient appliances\n• Collect rainwater for plants',
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildCommunityStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Impact',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatCard('Active Users', '1,234', Icons.people, Colors.blue),
            _buildStatCard(
              'Reports Submitted',
              '456',
              Icons.assignment,
              Colors.green,
            ),
            _buildStatCard(
              'Issues Resolved',
              '89%',
              Icons.check_circle,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Leaders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildLeaderboardItem('John Doe', '120 points', 1, Colors.amber),
            _buildLeaderboardItem(
              'Jane Smith',
              '115 points',
              2,
              Colors.grey.shade400,
            ),
            _buildLeaderboardItem(
              'Bob Johnson',
              '110 points',
              3,
              Colors.brown.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
    String name,
    String points,
    int rank,
    Color medalColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: medalColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  points,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityEvents() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              'Community Cleanup',
              'Join us in cleaning local water sources',
              'Saturday, 10:00 AM',
              Icons.cleaning_services,
              Colors.blue,
            ),
            _buildEventCard(
              'Water Conservation Workshop',
              'Learn water-saving techniques',
              'Sunday, 2:00 PM',
              Icons.school,
              Colors.green,
            ),
            _buildEventCard(
              'Infrastructure Inspection',
              'Volunteer for water point inspection',
              'Next Week',
              Icons.build,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the original _EmbeddedWaterSourceMap class
class _EmbeddedWaterSourceMap extends StatefulWidget {
  @override
  State<_EmbeddedWaterSourceMap> createState() =>
      _EmbeddedWaterSourceMapState();
}

class _EmbeddedWaterSourceMapState extends State<_EmbeddedWaterSourceMap> {
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
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    );
  }
}
