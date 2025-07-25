import 'package:flutter/material.dart';
import '../models/water_point.dart';
import '../services/water_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import '../utils/responsive_utils.dart';
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
  int _selectedPeriod = 1;

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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = waterService.getWaterPoints();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water & Sanitation'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Status'),
            Tab(text: 'Quality'),
            Tab(text: 'Usage'),
            Tab(text: 'Community'),
            Tab(text: 'Tips'),
          ],
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
                      style: const TextStyle(color: Colors.white, fontSize: 10),
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
          _buildUsageTab(),
          _buildCommunityTab(),
          _buildTipsTab(),
        ],
      ),
    );
  }

  // --- Status Tab (original WaterResponseScreen content) ---
  Widget _buildStatusTab(List points) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusBanner(),
        const SizedBox(height: 16),
        _buildActionButtons(),
        const SizedBox(height: 24),
        _buildOfflineQueue(),
        const SizedBox(height: 24),
        ...points.map(
          (p) => Card(
            color: p.status == WaterStatus.available
                ? Colors.green[50]
                : p.status == WaterStatus.low
                ? Colors.orange[50]
                : Colors.red[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                p.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Lat:  {p.latitude}, Lng:  {p.longitude}'),
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
        _buildQualityOverview(),
        const SizedBox(height: 24),
        _buildQualityTrends(),
        const SizedBox(height: 24),
        _buildRiskAssessment(),
      ],
    );
  }

  // --- Usage Tab (from WaterInsightsScreen) ---
  Widget _buildUsageTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUsageStats(),
        const SizedBox(height: 24),
        _buildUsageBreakdown(),
        const SizedBox(height: 24),
        _buildConservationTips(),
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

  // --- Tips Tab (from WaterInsightsScreen) ---
  Widget _buildTipsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [_buildConservationTips()],
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      color: _isOnline ? Colors.green.shade50 : Colors.orange.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: _isOnline ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isOnline
                ? 'Connected - Reports will sync immediately'
                : 'Offline - Reports will sync when connection is restored',
            style: TextStyle(
              color: _isOnline ? Colors.green : Colors.orange,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan QR for Water Unit'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
          icon: const Icon(Icons.report_problem),
          label: const Text('Report Issue'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineQueue() {
    if (_offlineReports.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.pending_actions),
            title: const Text('Pending Reports'),
            subtitle: Text('${_offlineReports.length} reports waiting to sync'),
            trailing: TextButton(
              onPressed: _syncReports,
              child: const Text('Sync Now'),
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _offlineReports.length,
            itemBuilder: (context, index) {
              final report = _offlineReports[index];
              return ListTile(
                title: Text(report['title']),
                subtitle: Text(report['location']),
                trailing: const Icon(Icons.sync, color: Colors.orange),
              );
            },
          ),
        ],
      ),
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

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final report = reports[index];
              final type = report['type'] as String;
              final status = report['status'] as String;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getReportTypeColor(type).withOpacity(0.1),
                  child: Icon(
                    _getReportTypeIcon(type),
                    color: _getReportTypeColor(type),
                  ),
                ),
                title: Text(report['title'] as String),
                subtitle: Text('${report['location']} • ${report['time']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
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
                      ).withOpacity(0.1),
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
      color: issue['color'].withOpacity(0.1),
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

  Widget _buildQualityOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Quality Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildQualityIndicator('pH Level', 7.2, 'Normal'),
            _buildQualityIndicator('Turbidity', 0.5, 'Good'),
            _buildQualityIndicator('Chlorine', 1.0, 'Normal'),
            _buildQualityIndicator('Bacteria Count', 0, 'Excellent'),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityIndicator(String name, double value, String status) {
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
          Text(name),
          Row(
            children: [
              Text(value.toString()),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityTrends() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quality Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
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
                          final index = value.toInt();
                          if (index % 5 == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Day $index',
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
                      spots: List.generate(
                        30,
                        (index) =>
                            FlSpot(index.toDouble(), 7.0 + (index % 5) * 0.2),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Assessment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildRiskIndicator(
              'Contamination Risk',
              'Low',
              Colors.green,
              'No immediate concerns',
            ),
            _buildRiskIndicator(
              'Supply Risk',
              'Moderate',
              Colors.orange,
              'Monitor usage patterns',
            ),
            _buildRiskIndicator(
              'Infrastructure Risk',
              'High',
              Colors.red,
              'Maintenance required',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicator(
    String title,
    String level,
    Color color,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning, color: color),
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
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildUsageStat(
              'Daily Average',
              '2,500',
              'liters',
              Icons.water_drop,
              Colors.blue,
            ),
            _buildUsageStat(
              'Peak Usage',
              '180',
              'liters/hour',
              Icons.show_chart,
              Colors.orange,
            ),
            _buildUsageStat(
              'Conservation',
              '15%',
              'reduction',
              Icons.eco,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStat(
    String title,
    String value,
    String unit,
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
              color: color.withOpacity(0.1),
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
                  '$value $unit',
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

  Widget _buildUsageBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Usage Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: 40,
                        title: '40%',
                        color: Colors.blue,
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: 30,
                        title: '30%',
                        color: Colors.green,
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: 30,
                        title: '30%',
                        color: Colors.orange,
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 4,
                children: [
                  _buildUsageLegend('Residential', Colors.blue),
                  _buildUsageLegend('Commercial', Colors.green),
                  _buildUsageLegend('Industrial', Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageLegend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildConservationTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conservation Tips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildTip(
              'Fix Leaky Faucets',
              'A dripping faucet can waste up to 20 gallons per day',
              Icons.build,
              Colors.blue,
            ),
            _buildTip(
              'Water Plants Early',
              'Water early morning or late evening to reduce evaporation',
              Icons.wb_sunny,
              Colors.orange,
            ),
            _buildTip(
              'Install Water-Efficient Fixtures',
              'Low-flow fixtures can reduce water usage by 30%',
              Icons.shower,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(
    String title,
    String description,
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
              color: color.withOpacity(0.1),
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
              ],
            ),
          ),
        ],
      ),
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
              color: color.withOpacity(0.1),
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
              color: color.withOpacity(0.1),
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
