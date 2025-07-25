import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Climate Action Tips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            icon: Icons.wb_sunny,
            title: 'What to do during Heatwaves',
            color: Colors.orange,
            tips: [
              'Stay hydrated and drink plenty of water.',
              'Avoid outdoor activities during peak heat.',
              'Wear light, loose-fitting clothing.',
              'Check on vulnerable neighbors and family.',
              'Keep your home cool with fans or air conditioning.',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.water,
            title: 'What to do during Floods',
            color: Colors.blue,
            tips: [
              'Move to higher ground immediately if advised.',
              'Avoid walking or driving through flood waters.',
              'Disconnect electrical appliances if safe.',
              'Prepare an emergency kit with essentials.',
              'Stay informed via local alerts and news.',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.grass,
            title: 'What to do during Droughts',
            color: Colors.brown,
            tips: [
              'Conserve water: fix leaks and limit usage.',
              'Use water-efficient appliances and fixtures.',
              'Collect and reuse rainwater for plants.',
              'Avoid watering lawns during the day.',
              'Support community water-saving initiatives.',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> tips,
  }) {
    return Card(
      color: color.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: color, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(tip, style: const TextStyle(fontSize: 15)),
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
}
