import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/alert_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService alertService = AlertService();

  @override
  Widget build(BuildContext context) {
    final alerts = alertService.getAlerts();
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: alerts.isEmpty
          ? const Center(child: Text('No alerts yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, i) {
                final alert = alerts[i];
                return Card(
                  color: Colors.red[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(alert.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(alert.message),
                    trailing: Text(
                      '${alert.timestamp.month}/${alert.timestamp.day} ${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 