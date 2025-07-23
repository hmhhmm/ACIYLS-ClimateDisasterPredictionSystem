import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, String>> _alerts = [
    {'message': 'Nearest clean water 200m away', 'type': 'info'},
    {
      'message':
          'Your tank requires maintenance – QR code scanned over 30 days ago',
      'type': 'warning',
    },
  ];

  void _dismissAlert(int idx) {
    setState(() {
      _alerts.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alerts',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_alerts.isEmpty)
              const Center(child: Text('No notifications.'))
            else
              ..._alerts.asMap().entries.map((entry) {
                final idx = entry.key;
                final alert = entry.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: alert['type'] == 'warning'
                        ? Colors.orange[100]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: alert['type'] == 'warning'
                          ? Colors.orange
                          : Colors.blue,
                      width: 1.2,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      alert['type'] == 'warning' ? Icons.warning : Icons.info,
                      color: alert['type'] == 'warning'
                          ? Colors.orange
                          : Colors.blue,
                    ),
                    title: Text(alert['message'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _dismissAlert(idx),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
