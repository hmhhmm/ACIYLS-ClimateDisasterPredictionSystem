import 'package:flutter/material.dart';

class IssueReportingScreen extends StatefulWidget {
  const IssueReportingScreen({super.key});

  @override
  State<IssueReportingScreen> createState() => _IssueReportingScreenState();
}

class _IssueReportingScreenState extends State<IssueReportingScreen> {
  final List<String> _issueTypes = [
    'Water leak',
    'Filter broken',
    'Tank empty',
    'Dirty latrine',
    'Clogged sanitation point',
  ];
  String? _selectedIssue;
  String? _description;
  String? _photoPath; // Mock photo path
  final List<Map<String, dynamic>> _pendingReports = [];
  int _step = 0;

  void _submitReport() {
    if (_selectedIssue == null) return;
    setState(() {
      _pendingReports.add({
        'issue': _selectedIssue,
        'description': _description ?? '',
        'photo': _photoPath,
        'gps': 'Lat: 1.234, Lng: 103.456', // Fake GPS
        'timestamp': DateTime.now().toString(),
      });
      _selectedIssue = null;
      _description = null;
      _photoPath = null;
      _step = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted (offline queue)')),
    );
  }

  void _mockPickPhoto() {
    setState(() {
      _photoPath = 'mock_photo.jpg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stepper(
              currentStep: _step,
              onStepContinue: () {
                if (_step < 2) {
                  setState(() => _step++);
                } else {
                  _submitReport();
                }
              },
              onStepCancel: () {
                if (_step > 0) setState(() => _step--);
              },
              steps: [
                Step(
                  title: const Text('Select Issue'),
                  content: Wrap(
                    spacing: 8,
                    children: _issueTypes
                        .map(
                          (type) => ChoiceChip(
                            label: Text(type),
                            selected: _selectedIssue == type,
                            onSelected: (val) => setState(
                              () => _selectedIssue = val ? type : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  isActive: _step == 0,
                  state: _step > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Add Details'),
                  content: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                        onChanged: (val) => _description = val,
                        initialValue: _description,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _mockPickPhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Upload Photo'),
                          ),
                          const SizedBox(width: 12),
                          if (_photoPath != null)
                            Row(
                              children: [
                                const Icon(Icons.image, color: Colors.green),
                                const SizedBox(width: 4),
                                const Text(
                                  'Photo attached',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                  isActive: _step == 1,
                  state: _step > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Location'),
                  content: Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.blueGrey),
                      SizedBox(width: 6),
                      Text('Lat: 1.234, Lng: 103.456 (mock)'),
                    ],
                  ),
                  isActive: _step == 2,
                  state: StepState.indexed,
                ),
              ],
              controlsBuilder: (context, details) {
                return Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(_step < 2 ? 'Next' : 'Submit'),
                    ),
                    if (_step > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'Pending Reports (Offline Queue):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._pendingReports.reversed.map(
              (report) => Card(
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
                  trailing: const Icon(Icons.cloud_off, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
