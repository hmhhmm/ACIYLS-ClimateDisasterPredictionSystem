import 'package:flutter/material.dart';

class OfflineQueueScreen extends StatefulWidget {
  const OfflineQueueScreen({super.key});

  @override
  State<OfflineQueueScreen> createState() => _OfflineQueueScreenState();
}

class _OfflineQueueScreenState extends State<OfflineQueueScreen> {
  List<Map<String, dynamic>> _unsyncedReports = [
    {
      'issue': 'Water leak',
      'description': 'Pipe leaking near tank',
      'gps': 'Lat: 1.234, Lng: 103.456',
      'timestamp': '2024-06-01 10:00',
    },
    {
      'issue': 'Dirty latrine',
      'description': 'Needs cleaning',
      'gps': 'Lat: 1.235, Lng: 103.457',
      'timestamp': '2024-06-02 14:30',
    },
  ];
  bool _syncing = false;
  bool _offline = true; // Mock offline status

  void _syncNow() async {
    setState(() {
      _syncing = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _unsyncedReports = [];
      _syncing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All reports synced! (mock)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Queue')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_offline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.wifi_off, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You are offline. Reports will sync when online.',
                      ),
                    ),
                  ],
                ),
              ),
            const Text(
              'Offline Reporting Queue',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _unsyncedReports.isEmpty
                  ? const Center(child: Text('No unsynced reports!'))
                  : ListView.builder(
                      itemCount: _unsyncedReports.length,
                      itemBuilder: (context, idx) {
                        final report = _unsyncedReports[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(
                              Icons.report_problem,
                              color: Colors.orange,
                            ),
                            title: Text(report['issue']),
                            subtitle: Text(
                              'At ${report['gps']}\n${report['description']}',
                            ),
                            trailing: const Icon(
                              Icons.cloud_off,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _unsyncedReports.isEmpty || _syncing
                    ? null
                    : _syncNow,
                icon: _syncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_syncing ? 'Syncing...' : 'Sync Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
