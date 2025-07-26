import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/water_usage_stats.dart';
import 'package:intl/intl.dart';

class WaterUnitDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> unit;
  final WaterUsageStats stats;

  const WaterUnitDetailsScreen({
    super.key,
    required this.unit,
    required this.stats,
  });

  @override
  State<WaterUnitDetailsScreen> createState() => _WaterUnitDetailsScreenState();
}

class _WaterUnitDetailsScreenState extends State<WaterUnitDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit['name'] ?? 'Unknown Unit'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Usage'),
            Tab(text: 'Quality'),
            Tab(text: 'Issues'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsageTab(),
          _buildQualityTab(),
          _buildIssuesTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    IconData icon;
    String label;
    VoidCallback onPressed;

    switch (_selectedTab) {
      case 1: // Usage tab
        icon = Icons.add_chart;
        label = 'Log Usage';
        onPressed = () => _showLogUsageDialog();
        break;
      case 2: // Quality tab
        icon = Icons.science;
        label = 'Add Test';
        onPressed = () => _showQualityTestDialog();
        break;
      case 3: // Issues tab
        icon = Icons.report_problem;
        label = 'Report Issue';
        onPressed = () => _showReportIssueDialog();
        break;
      default:
        return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildQuickStats(),
          const SizedBox(height: 16),
          _buildMaintenanceTimeline(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.unit['type'] ?? '-',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.unit['location'] ?? '-',
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.unit['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.unit['status'] ?? '-',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow('Capacity', widget.unit['capacity'] ?? '-'),
            _buildInfoRow('Current Level', widget.unit['currentLevel'] ?? '-'),
            _buildInfoRow(
              'Last Maintenance',
              widget.unit['lastMaintenance'] ?? '-',
            ),
            _buildInfoRow(
              'Next Maintenance',
              widget.unit['nextMaintenance'] ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Daily Usage',
          '2,500L',
          Icons.water_drop,
          Colors.blue,
          '+15% vs last week',
        ),
        _buildStatCard(
          'Quality Score',
          '95%',
          Icons.check_circle,
          Colors.green,
          'Excellent',
        ),
        _buildStatCard(
          'Active Issues',
          '2',
          Icons.warning,
          Colors.orange,
          '1 high priority',
        ),
        _buildStatCard(
          'Efficiency',
          '88%',
          Icons.speed,
          Colors.purple,
          'Good performance',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Maintenance Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.stats.maintenanceRecords.map(
              (record) => _buildTimelineItem(record),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(MaintenanceRecord record) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(record.date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(record.type),
                Text(
                  'Technician: ${record.technician}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUsageChart(),
          const SizedBox(height: 24),
          _buildUsageList(),
        ],
      ),
    );
  }

  Widget _buildUsageChart() {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    DateFormat('MMM d').format(
                      DateTime.now().subtract(
                        Duration(days: 6 - value.toInt()),
                      ),
                    ),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(7, (index) {
                return FlSpot(index.toDouble(), index * 100 + 500);
              }),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Usage',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...widget.stats.dailyUsage.map(
          (usage) => Card(
            child: ListTile(
              title: Text('${usage.amount}L'),
              subtitle: Text(
                '${DateFormat('MMM d, yyyy').format(usage.date)} - ${usage.purpose}',
              ),
              trailing: Text(usage.userId),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQualityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQualityIndicators(),
          const SizedBox(height: 24),
          _buildQualityHistory(),
        ],
      ),
    );
  }

  Widget _buildQualityIndicators() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildQualityIndicator('pH Level', 7.2, 0, 14),
        _buildQualityIndicator('Turbidity', 0.5, 0, 5),
        _buildQualityIndicator('Dissolved Oxygen', 8.5, 0, 10),
        _buildQualityIndicator('Temperature', 22, 0, 40),
      ],
    );
  }

  Widget _buildQualityIndicator(
    String title,
    double value,
    double min,
    double max,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (value - min) / (max - min),
                  backgroundColor: Colors.grey[200],
                ),
                Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quality Test History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.stats.qualityRecords.map(
              (record) => ListTile(
                title: Text(DateFormat('MMM d, yyyy').format(record.timestamp)),
                subtitle: Text('Tested by: ${record.testedBy}'),
                trailing: Icon(
                  record.passesStandards ? Icons.check_circle : Icons.warning,
                  color: record.passesStandards ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.stats.issueReports.length,
      itemBuilder: (context, index) {
        final issue = widget.stats.issueReports[index];
        return Card(
          child: ExpansionTile(
            title: Text(issue.type),
            subtitle: Text(
              'Reported on ${DateFormat('MMM d, yyyy').format(issue.reportedAt)}',
            ),
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: issue.priority.color,
                shape: BoxShape.circle,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: issue.status.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                issue.status.toString().split('.').last,
                style: TextStyle(color: issue.status.color, fontSize: 12),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(issue.description),
                    const SizedBox(height: 8),
                    Text(
                      'Reported by: ${issue.reportedBy}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (issue.resolvedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Resolved on: ${DateFormat('MMM d, yyyy').format(issue.resolvedAt!)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      Text(
                        'Resolution: ${issue.resolution}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'working':
        return Colors.green;
      case 'needs maintenance':
        return Colors.orange;
      case 'low level':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  void _showLogUsageDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController purposeController = TextEditingController();
    String selectedPurpose = 'Community Usage';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Water Usage'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  border: OutlineInputBorder(),
                ),
                value: selectedPurpose,
                items:
                    [
                      'Community Usage',
                      'Irrigation',
                      'Cleaning',
                      'Construction',
                      'Emergency',
                      'Other',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) {
                  selectedPurpose = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (Liters)',
                  border: OutlineInputBorder(),
                  suffixText: 'L',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: purposeController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This usage will be recorded for ${widget.unit['name'] ?? 'Unknown Unit'}',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement usage logging
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Logged ${amountController.text}L for ${selectedPurpose.toLowerCase()}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Log Usage'),
          ),
        ],
      ),
    );
  }

  void _showQualityTestDialog() {
    final formKey = GlobalKey<FormState>();
    final Map<String, TextEditingController> controllers = {
      'ph': TextEditingController(),
      'turbidity': TextEditingController(),
      'dissolvedOxygen': TextEditingController(),
      'temperature': TextEditingController(),
      'conductivity': TextEditingController(),
    };
    List<String> selectedContaminants = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Quality Test'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...controllers.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: e.value,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: e.key
                            .split(RegExp(r'(?=[A-Z])'))
                            .join(' ')
                            .capitalize(),
                        border: const OutlineInputBorder(),
                        suffixText: _getUnitForParameter(e.key),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Detected Contaminants',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children:
                      [
                            'Bacteria',
                            'Heavy Metals',
                            'Chlorine',
                            'Nitrates',
                            'Pesticides',
                            'Trace Minerals',
                          ]
                          .map(
                            (contaminant) => FilterChip(
                              label: Text(contaminant),
                              selected: selectedContaminants.contains(
                                contaminant,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  selectedContaminants.add(contaminant);
                                } else {
                                  selectedContaminants.remove(contaminant);
                                }
                              },
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // TODO: Implement quality test logging
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quality test recorded'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save Test'),
          ),
        ],
      ),
    );
  }

  String _getUnitForParameter(String parameter) {
    switch (parameter) {
      case 'ph':
        return 'pH';
      case 'turbidity':
        return 'NTU';
      case 'dissolvedOxygen':
        return 'mg/L';
      case 'temperature':
        return '°C';
      case 'conductivity':
        return 'µS/cm';
      default:
        return '';
    }
  }

  void _showReportIssueDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    Priority selectedPriority = Priority.medium;
    String selectedType = 'Mechanical';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Report Issue'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Issue Type',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedType,
                    items:
                        [
                          'Mechanical',
                          'Electrical',
                          'Water Quality',
                          'Structural',
                          'Access',
                          'Other',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Issue Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Priority>(
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedPriority,
                    items: Priority.values.map((Priority priority) {
                      return DropdownMenuItem<Priority>(
                        value: priority,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: priority.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              priority.toString().split('.').last.capitalize(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedPriority = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      // TODO: Implement image picking
                      // For now, just add a placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image picking not implemented yet'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Photos'),
                  ),
                  if (false) ...[
                    // Placeholder for images
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 0, // No images added yet
                        itemBuilder: (context, index) {
                          return const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Icon(Icons.camera_alt, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // TODO: Implement issue reporting
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Issue reported (placeholder)'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
