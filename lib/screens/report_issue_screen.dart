import 'package:flutter/material.dart';
import '../services/offline_queue_service.dart';
import 'package:provider/provider.dart';

class ReportIssueScreen extends StatelessWidget {
  const ReportIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final queueService = context.watch<OfflineQueueService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
        actions: [
          if (queueService.queueLength > 0)
            Badge(
              label: Text(queueService.queueLength.toString()),
              child: IconButton(
                icon: const Icon(Icons.sync),
                onPressed: queueService.isOnline
                    ? queueService.syncReports
                    : null,
                tooltip: queueService.isOnline
                    ? 'Sync ${queueService.queueLength} reports'
                    : 'Offline - Cannot sync',
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Online/Offline status banner
          Container(
            color: queueService.isOnline
                ? Colors.green.shade50
                : Colors.orange.shade50,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  queueService.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: queueService.isOnline ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    queueService.isOnline
                        ? 'Connected - Reports will sync immediately'
                        : 'Offline - Reports will sync when connection is restored',
                    style: TextStyle(
                      color: queueService.isOnline
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (!queueService.isOnline && queueService.queueLength > 0)
                  Text(
                    '${queueService.queueLength} pending',
                    style: TextStyle(
                      color: queueService.isOnline
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          // Offline queue if any reports are pending
          if (queueService.queueLength > 0)
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending Reports',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...queueService.offlineReports.map(
                    (report) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.pending_actions,
                          color: Colors.orange,
                        ),
                        title: Text(report['title']),
                        subtitle: Text(report['location']),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              queueService.removeReport(report['id']),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Issue categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildIssueCategory(context, 'Water Infrastructure Issues', [
                  {
                    'title': 'Water Leak',
                    'icon': Icons.opacity,
                    'color': Colors.blue,
                    'description':
                        'Report water leaks in pipes, tanks, or fixtures',
                    'type': 'leak',
                  },
                  {
                    'title': 'Filter Broken',
                    'icon': Icons.filter_alt,
                    'color': Colors.orange,
                    'description':
                        'Report issues with water filtration systems',
                    'type': 'filter',
                  },
                  {
                    'title': 'Tank Empty',
                    'icon': Icons.water_damage,
                    'color': Colors.red,
                    'description': 'Report empty or low water storage tanks',
                    'type': 'tank',
                  },
                ]),
                const SizedBox(height: 32),
                _buildIssueCategory(context, 'Sanitation Issues', [
                  {
                    'title': 'Dirty Latrine',
                    'icon': Icons.cleaning_services,
                    'color': Colors.brown,
                    'description': 'Report unsanitary latrine conditions',
                    'type': 'latrine',
                  },
                  {
                    'title': 'Clogged Point',
                    'icon': Icons.plumbing,
                    'color': Colors.purple,
                    'description': 'Report blocked drains or sanitation points',
                    'type': 'clogged',
                  },
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCategory(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> issues,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...issues.map((issue) => _buildIssueCard(context, issue)),
      ],
    );
  }

  Widget _buildIssueCard(BuildContext context, Map<String, dynamic> issue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showReportDetailsDialog(context, issue),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (issue['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  issue['icon'] as IconData,
                  color: issue['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue['description'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetailsDialog(
    BuildContext context,
    Map<String, dynamic> issue,
  ) {
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report ${issue['title']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Provide details about the issue...',
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
                label: const Text('Add Photos'),
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
            onPressed: () async {
              final queueService = context.read<OfflineQueueService>();
              await queueService.addReport(
                type: issue['type'] as String,
                title: issue['title'] as String,
                location: locationController.text,
                description: descriptionController.text,
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    queueService.isOnline
                        ? 'Report submitted successfully'
                        : 'Report saved and will sync when online',
                  ),
                  backgroundColor: queueService.isOnline
                      ? Colors.green
                      : Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
