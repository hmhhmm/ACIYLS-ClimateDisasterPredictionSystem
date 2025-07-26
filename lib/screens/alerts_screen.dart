import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _showPersonalizedPlans = false;
  String _selectedHealthProfile = 'None';

  // Mock health profiles for demonstration
  final Map<String, Map<String, dynamic>> _healthProfiles = {
    'None': {
      'name': 'No Special Needs',
      'icon': Icons.person,
      'color': Colors.grey,
    },
    'Diabetes': {
      'name': 'Diabetes Management',
      'icon': Icons.medical_services,
      'color': Colors.red,
    },
    'Asthma': {
      'name': 'Respiratory Conditions',
      'icon': Icons.air,
      'color': Colors.blue,
    },
    'Mobility': {
      'name': 'Mobility Challenges',
      'icon': Icons.accessible,
      'color': Colors.purple,
    },
    'Mental Health': {
      'name': 'Mental Health Support',
      'icon': Icons.psychology,
      'color': Colors.green,
    },
    'Heart Condition': {
      'name': 'Cardiovascular Health',
      'icon': Icons.favorite,
      'color': Colors.pink,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alerts & Plans'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPersonalizedPlansSection(),
          const SizedBox(height: 24),
          _buildAIPrioritizationSection(),
          const SizedBox(height: 24),
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

  Widget _buildPersonalizedPlansSection() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.purple,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Personalized Emergency Plans',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: _showPersonalizedPlans,
                  onChanged: (value) {
                    setState(() {
                      _showPersonalizedPlans = value;
                    });
                  },
                  activeColor: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_showPersonalizedPlans) ...[
              _buildHealthProfileSelector(),
              const SizedBox(height: 16),
              _buildPersonalizedEmergencyPlan(),
            ] else ...[
              Text(
                'Enable personalized emergency plans for customized alerts and protocols based on your health needs.',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthProfileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Health Profile:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedHealthProfile,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Health Profile',
          ),
          items: _healthProfiles.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Row(
                children: [
                  Icon(entry.value['icon'], color: entry.value['color']),
                  const SizedBox(width: 8),
                  Text(entry.value['name']),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedHealthProfile = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPersonalizedEmergencyPlan() {
    if (_selectedHealthProfile == 'None') {
      return const SizedBox.shrink();
    }

    final profile = _healthProfiles[_selectedHealthProfile]!;
    final color = profile['color'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Personalized Emergency Plan for ${profile['name']}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        ..._getPersonalizedTips(_selectedHealthProfile).map(
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
        const SizedBox(height: 16),
        _buildEmergencyContacts(color),
        const SizedBox(height: 12),
        _buildMedicationReminder(color),
      ],
    );
  }

  List<String> _getPersonalizedTips(String profile) {
    switch (profile) {
      case 'Diabetes':
        return [
          'Keep insulin and medications in a cool, dry place.',
          'Monitor blood sugar more frequently during heat stress.',
          'Stay hydrated and avoid sugary drinks.',
          'Have glucose tablets or candy readily available.',
          'Wear medical alert bracelet or necklace.',
        ];
      case 'Asthma':
        return [
          'Keep rescue inhaler easily accessible at all times.',
          'Monitor air quality and pollen levels daily.',
          'Avoid outdoor activities during poor air quality.',
          'Use air purifiers and keep windows closed when needed.',
          'Have backup inhalers in emergency kit.',
        ];
      case 'Mobility':
        return [
          'Identify accessible evacuation routes in advance.',
          'Keep mobility aids (wheelchair, walker) near exits.',
          'Have backup batteries for electric mobility devices.',
          'Establish support network for emergency assistance.',
          'Keep emergency contact numbers on speed dial.',
        ];
      case 'Mental Health':
        return [
          'Maintain regular medication schedule during stress.',
          'Practice grounding techniques during anxiety episodes.',
          'Keep emergency mental health hotline numbers handy.',
          'Have a trusted support person for crisis situations.',
          'Create a calming emergency kit with comfort items.',
        ];
      case 'Heart Condition':
        return [
          'Monitor blood pressure more frequently during stress.',
          'Keep nitroglycerin or prescribed medications accessible.',
          'Avoid strenuous activities during extreme weather.',
          'Have emergency contact information readily available.',
          'Wear medical alert identification.',
        ];
      default:
        return [];
    }
  }

  Widget _buildEmergencyContacts(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('• Primary Care Doctor: Dr. Smith (555-0101)'),
          const Text('• Emergency Contact: John Doe (555-0102)'),
          const Text('• Pharmacy: City Pharmacy (555-0103)'),
          const Text('• Emergency Services: 911'),
        ],
      ),
    );
  }

  Widget _buildMedicationReminder(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medication, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Medication Reminder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('• Store medications in cool, dry place'),
          const Text('• Keep 7-day emergency supply'),
          const Text('• Update medication list monthly'),
          const Text('• Include dosage instructions'),
        ],
      ),
    );
  }

  Widget _buildAIPrioritizationSection() {
    // Hardcoded mock data for demonstration
    final List<Map<String, dynamic>> zones = [
      {
        'name': 'Zone 1',
        'urgency': 'Low',
        'color': Colors.green,
        'explanation':
            'Low population density, no major health risks detected.',
      },
      {
        'name': 'Zone 2',
        'urgency': 'Medium',
        'color': Colors.orange,
        'explanation':
            'Several users with chronic illnesses and moderate flood risk.',
      },
      {
        'name': 'Zone 3',
        'urgency': 'High',
        'color': Colors.red,
        'explanation':
            'High density of users with mobility challenges and severe weather alert.',
      },
    ];
    final String userZone = 'Zone 3';
    final String userRisk = 'HIGH';
    final String userReason =
        'You have a heart condition and are in a high-risk flood area with limited mobility.';

    return Card(
      color: Colors.red.withValues(alpha: 0.06),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.priority_high,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'AI-Driven Evacuation Urgency',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Evacuation Urgency by Zone:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            _buildZoneUrgencyMap(zones),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_pin_circle,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your Zone: $userZone',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PRIORITY: $userRisk',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(userReason, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Why this priority?\n• Zone 3 has many users with mobility and chronic health risks.\n• Severe weather alert (flood) is active.\n• Limited accessible evacuation routes detected.\n• AI recommends immediate evacuation for your safety.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneUrgencyMap(List<Map<String, dynamic>> zones) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: zones.map((zone) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: zone['color'].withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: zone['color'], width: 2),
                  ),
                  child: Center(
                    child: Text(
                      zone['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  zone['urgency'],
                  style: TextStyle(
                    color: zone['color'],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Zone explanations in a more compact format
        Column(
          children: zones.map((zone) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: zone['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${zone['name']}: ${zone['explanation']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> tips,
  }) {
    return Card(
      color: color.withValues(alpha: 0.08),
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
                  backgroundColor: color.withValues(alpha: 0.2),
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
