import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/offline_queue_service.dart';

class WaterResponseScreen extends StatefulWidget {
  const WaterResponseScreen({super.key});

  @override
  State<WaterResponseScreen> createState() => _WaterResponseScreenState();
}

class _WaterResponseScreenState extends State<WaterResponseScreen> {
  int _selectedIndex = 0;
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Water & Sanitation',
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
            child: _buildTabButton('Water Points', 0),
          ),
          Expanded(
            child: _buildTabButton('Report Issue', 1),
          ),
          Expanded(
            child: _buildTabButton('Personal', 2),
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
        return _buildWaterPoints();
      case 1:
        return _buildReportIssue();
      case 2:
        return _buildPersonalSystem();
      default:
        return _buildWaterPoints();
    }
  }

  Widget _buildWaterPoints() {
    final waterPoints = [
      {
        'name': 'Community Water Hub',
        'type': 'Drinking Water',
        'status': 'Available',
        'distance': '0.2 km',
        'lastUpdated': '2 hours ago',
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'name': 'Emergency Relief Station',
        'type': 'Sanitation',
        'status': 'Available',
        'distance': '0.5 km',
        'lastUpdated': '1 hour ago',
        'icon': Icons.clean_hands,
        'color': Colors.green,
      },
      {
        'name': 'Mobile Water Unit',
        'type': 'Portable',
        'status': 'In Transit',
        'distance': '1.2 km',
        'lastUpdated': '30 min ago',
        'icon': Icons.local_shipping,
        'color': Colors.orange,
      },
      {
        'name': 'Purification Center',
        'type': 'Treatment',
        'status': 'Maintenance',
        'distance': '2.1 km',
        'lastUpdated': '4 hours ago',
        'icon': Icons.filter_alt,
        'color': Colors.red,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildWaterPointsList(waterPoints),
          const SizedBox(height: 100), // Add extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clean Water Points',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find clean water and sanitation facilities near you',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('4', 'Available'),
              const SizedBox(width: 16),
              _buildStatCard('0.2km', 'Nearest'),
              const SizedBox(width: 16),
              _buildStatCard('24/7', 'Support'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
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

  Widget _buildWaterPointsList(List<Map<String, dynamic>> waterPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Water Points',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...waterPoints.map((point) => _buildWaterPointCard(point)).toList(),
      ],
    );
  }

  Widget _buildWaterPointCard(Map<String, dynamic> point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced margin
      padding: const EdgeInsets.all(12), // Reduced padding
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced padding
            decoration: BoxDecoration(
              color: point['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8), // Smaller radius
            ),
            child: Icon(
              point['icon'],
              color: point['color'],
              size: 24, // Smaller icon
            ),
          ),
          const SizedBox(width: 12), // Reduced spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point['name'],
                  style: const TextStyle(
                    fontSize: 14, // Smaller font
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // Reduced spacing
                Text(
                  point['type'],
                  style: TextStyle(
                    fontSize: 12, // Smaller font
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6), // Reduced spacing
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, // Reduced padding
                        vertical: 2, // Reduced padding
                      ),
                      decoration: BoxDecoration(
                        color: point['status'] == 'Available'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6), // Smaller radius
                      ),
                      child: Text(
                        point['status'],
                        style: TextStyle(
                          fontSize: 10, // Smaller font
                          fontWeight: FontWeight.bold,
                          color: point['status'] == 'Available'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6), // Reduced spacing
                    Text(
                      point['distance'],
                      style: TextStyle(
                        fontSize: 10, // Smaller font
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showWaterPointDetails(point);
            },
            icon: const Icon(Icons.arrow_forward_ios, size: 16), // Smaller icon
            color: Colors.grey,
            padding: EdgeInsets.zero, // Remove padding
            constraints: const BoxConstraints(), // Remove constraints
          ),
        ],
      ),
    );
  }

  void _showWaterPointDetails(Map<String, dynamic> point) {
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
                    color: point['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    point['icon'],
                    color: point['color'],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        point['type'],
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
            _buildDetailRow('Status', point['status'], point['color']),
            _buildDetailRow('Distance', point['distance'], Colors.blue),
            _buildDetailRow('Last Updated', point['lastUpdated'], Colors.grey),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showDirections(point);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: point['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Get Directions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
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
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDirections(Map<String, dynamic> point) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions to ${point['name']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildReportIssue() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Water Issue',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Help us maintain clean water access by reporting issues',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          _buildIssueForm(),
          const SizedBox(height: 100), // Add extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildIssueForm() {
    final issueTypeController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    return Column(
      children: [
        _buildFormField('Issue Type', 'Select issue type...', issueTypeController),
        const SizedBox(height: 16),
        _buildFormField('Location', 'Enter location...', locationController),
        const SizedBox(height: 16),
        _buildFormField('Description', 'Describe the issue...', descriptionController),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _submitIssueReport(issueTypeController.text, locationController.text, descriptionController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Submit Report',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  void _submitIssueReport(String type, String location, String description) {
    if (type.isEmpty || location.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simulate submitting report
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Issue report submitted for $location'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    setState(() {
      // Reset form or navigate back
    });
  }

  Widget _buildPersonalSystem() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Water System',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildPersonalStats(),
          const SizedBox(height: 24),
          _buildPersonalActions(),
          const SizedBox(height: 100), // Add extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildPersonalStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPersonalStat('Daily Usage', '15L', Icons.water_drop),
              ),
              Expanded(
                child: _buildPersonalStat('Quality', 'Good', Icons.check_circle),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPersonalStat('Last Test', '2 days ago', Icons.science),
              ),
              Expanded(
                child: _buildPersonalStat('Next Test', '5 days', Icons.schedule),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.blue,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalActions() {
    final actions = [
      {
        'title': 'Test Water Quality',
        'description': 'Check your water quality',
        'icon': Icons.science,
        'color': Colors.green,
      },
      {
        'title': 'Update Usage',
        'description': 'Log your water consumption',
        'icon': Icons.edit,
        'color': Colors.blue,
      },
      {
        'title': 'Set Reminders',
        'description': 'Configure water testing reminders',
        'icon': Icons.notifications,
        'color': Colors.orange,
      },
      {
        'title': 'View History',
        'description': 'Check your water usage history',
        'icon': Icons.history,
        'color': Colors.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12, // Reduced spacing
            mainAxisSpacing: 12, // Reduced spacing
            childAspectRatio: 1.3, // Make cards slightly wider
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(action);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () {
        _handlePersonalAction(action);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Smaller radius
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced padding
                decoration: BoxDecoration(
                  color: action['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8), // Smaller radius
                ),
                child: Icon(
                  action['icon'],
                  color: action['color'],
                  size: 24, // Smaller icon
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                action['title'],
                style: const TextStyle(
                  fontSize: 12, // Smaller font
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Reduced spacing
              Text(
                action['description'],
                style: TextStyle(
                  fontSize: 10, // Smaller font
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePersonalAction(Map<String, dynamic> action) {
    switch (action['title']) {
      case 'Test Water Quality':
        _showWaterQualityTest();
        break;
      case 'Update Usage':
        _showUpdateUsage();
        break;
      case 'Set Reminders':
        _showSetReminders();
        break;
      case 'View History':
        _showUsageHistory();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${action['title']} feature coming soon!'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  void _showWaterQualityTest() {
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
          children: [
            const Text(
              'Water Quality Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Testing your water quality...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Water quality test completed!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Complete Test'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateUsage() {
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
          children: [
            const Text(
              'Update Water Usage',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Daily Usage (Liters)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usage updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetReminders() {
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
          children: [
            const Text(
              'Set Water Testing Reminders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Remind me to test water quality every:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _setReminder('3 days'),
                  child: const Text('3 Days'),
                ),
                ElevatedButton(
                  onPressed: () => _setReminder('1 week'),
                  child: const Text('1 Week'),
                ),
                ElevatedButton(
                  onPressed: () => _setReminder('1 month'),
                  child: const Text('1 Month'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setReminder(String period) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for every $period'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showUsageHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          children: [
            const Text(
              'Water Usage History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildHistoryItem('Today', '15L'),
                  _buildHistoryItem('Yesterday', '18L'),
                  _buildHistoryItem('2 days ago', '12L'),
                  _buildHistoryItem('3 days ago', '20L'),
                  _buildHistoryItem('4 days ago', '16L'),
                  _buildHistoryItem('5 days ago', '14L'),
                  _buildHistoryItem('6 days ago', '17L'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String usage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: const TextStyle(fontSize: 16)),
          Text(usage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
