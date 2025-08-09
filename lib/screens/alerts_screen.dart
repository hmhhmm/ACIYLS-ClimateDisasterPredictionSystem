import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Emergency Alerts',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Active Alerts', 0),
          ),
          Expanded(
            child: _buildTabButton('Action Plans', 1),
          ),
          Expanded(
            child: _buildTabButton('History', 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildActiveAlerts();
      case 1:
        return _buildActionPlans();
      case 2:
        return _buildAlertHistory();
      default:
        return _buildActiveAlerts();
    }
  }

  Widget _buildActiveAlerts() {
    final alerts = [
      {
        'title': 'Flood Warning',
        'severity': 'High',
        'location': 'Coastal Areas',
        'description': 'Heavy rainfall expected. Risk of flooding in low-lying areas.',
        'time': '2 hours ago',
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'title': 'Drought Alert',
        'severity': 'Medium',
        'location': 'Eastern Region',
        'description': 'Prolonged dry conditions. Water conservation measures advised.',
        'time': '4 hours ago',
        'icon': Icons.water_drop,
        'color': Colors.orange,
      },
      {
        'title': 'Storm Warning',
        'severity': 'High',
        'location': 'Northern Districts',
        'description': 'Strong winds and heavy rain expected. Secure loose objects.',
        'time': '6 hours ago',
        'icon': Icons.thunderstorm,
        'color': Colors.purple,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlertHeader(),
          const SizedBox(height: 24),
          _buildAlertsList(alerts),
          const SizedBox(height: 100), // Add extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildAlertHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Alerts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay informed about climate-related emergencies',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAlertStatCard('3', 'Active'),
              const SizedBox(width: 16),
              _buildAlertStatCard('2', 'High Risk'),
              const SizedBox(width: 16),
              _buildAlertStatCard('24/7', 'Monitoring'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList(List<Map<String, dynamic>> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...alerts.map((alert) => _buildAlertCard(alert)).toList(),
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced margin
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Smaller radius
        border: Border.all(color: alert['color'].withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: alert['color'].withValues(alpha: 0.1),
            blurRadius: 4, // Reduced blur
            offset: const Offset(0, 1), // Smaller offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), // Reduced padding
                decoration: BoxDecoration(
                  color: alert['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6), // Smaller radius
                ),
                child: Icon(
                  alert['icon'],
                  color: alert['color'],
                  size: 20, // Smaller icon
                ),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title'],
                      style: const TextStyle(
                        fontSize: 14, // Smaller font
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      alert['location'],
                      style: TextStyle(
                        fontSize: 12, // Smaller font
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6, // Reduced padding
                  vertical: 2, // Reduced padding
                ),
                decoration: BoxDecoration(
                  color: alert['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6), // Smaller radius
                ),
                child: Text(
                  alert['severity'],
                  style: TextStyle(
                    fontSize: 10, // Smaller font
                    fontWeight: FontWeight.bold,
                    color: alert['color'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Reduced spacing
          Text(
            alert['description'],
            style: TextStyle(
              fontSize: 12, // Smaller font
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8), // Reduced spacing
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14, // Smaller icon
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4), // Reduced spacing
              Text(
                alert['time'],
                style: TextStyle(
                  fontSize: 10, // Smaller font
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showAlertDetails(alert);
                },
                child: const Text('View Details', style: TextStyle(fontSize: 12)), // Smaller font
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                  minimumSize: Size.zero, // Remove minimum size
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Smaller tap target
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: alert['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    alert['icon'],
                    color: alert['color'],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        alert['location'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Severity', alert['severity'], alert['color']),
            _buildDetailRow('Time', alert['time'], Colors.grey),
            _buildDetailRow('Description', alert['description'], Colors.black),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _acknowledgeAlert(alert);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alert['color'],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Acknowledge'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareAlert(alert);
                    },
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _acknowledgeAlert(Map<String, dynamic> alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert acknowledged: ${alert['title']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareAlert(Map<String, dynamic> alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing alert: ${alert['title']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildActionPlans() {
    final actionPlans = [
      {
        'title': 'Flood Response Plan',
        'status': 'Active',
        'steps': [
          'Evacuate low-lying areas',
          'Move to higher ground',
          'Avoid walking in water',
          'Follow emergency broadcasts',
        ],
        'icon': Icons.emergency,
        'color': Colors.red,
      },
      {
        'title': 'Drought Management',
        'status': 'Active',
        'steps': [
          'Conserve water usage',
          'Use water-efficient practices',
          'Report water leaks',
          'Follow rationing schedule',
        ],
        'icon': Icons.water_drop,
        'color': Colors.orange,
      },
      {
        'title': 'Storm Preparedness',
        'status': 'Active',
        'steps': [
          'Secure loose objects',
          'Stay indoors',
          'Avoid coastal areas',
          'Monitor weather updates',
        ],
        'icon': Icons.thunderstorm,
        'color': Colors.purple,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Action Plans',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Follow these steps to stay safe during emergencies',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ...actionPlans.map((plan) => _buildActionPlanCard(plan)).toList(),
          const SizedBox(height: 100), // Add extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildActionPlanCard(Map<String, dynamic> plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Reduced margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Smaller radius
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2, // Reduced blur
            offset: const Offset(0, 1), // Smaller offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Reduced padding
            decoration: BoxDecoration(
              color: plan['color'].withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), // Smaller radius
                topRight: Radius.circular(8), // Smaller radius
              ),
            ),
            child: Row(
              children: [
                Icon(
                  plan['icon'],
                  color: plan['color'],
                  size: 20, // Smaller icon
                ),
                const SizedBox(width: 8), // Reduced spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['title'],
                        style: const TextStyle(
                          fontSize: 14, // Smaller font
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Status: ${plan['status']}',
                        style: TextStyle(
                          fontSize: 12, // Smaller font
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Action Steps:',
                  style: TextStyle(
                    fontSize: 12, // Smaller font
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6), // Reduced spacing
                ...List.generate(
                  plan['steps'].length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 3), // Reduced spacing
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4), // Reduced margin
                          width: 4, // Smaller dot
                          height: 4, // Smaller dot
                          decoration: BoxDecoration(
                            color: plan['color'],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6), // Reduced spacing
                        Expanded(
                          child: Text(
                            plan['steps'][index],
                            style: TextStyle(
                              fontSize: 12, // Smaller font
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertHistory() {
    final history = [
      {
        'title': 'Heat Wave Alert',
        'date': '2024-01-15',
        'status': 'Resolved',
        'icon': Icons.thermostat,
        'color': Colors.orange,
      },
      {
        'title': 'Heavy Rainfall',
        'date': '2024-01-10',
        'status': 'Resolved',
        'icon': Icons.water,
        'color': Colors.blue,
      },
      {
        'title': 'Landslide Warning',
        'date': '2024-01-05',
        'status': 'Resolved',
        'icon': Icons.terrain,
        'color': Colors.brown,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alert History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Past alerts and their resolution status',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ...history.map((item) => _buildHistoryCard(item)).toList(),
          const SizedBox(height: 100), // Add extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item['icon'],
              color: item['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  item['date'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['status'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
