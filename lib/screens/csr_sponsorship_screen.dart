import 'package:flutter/material.dart';
import '../models/business_models.dart';
import '../services/business_service.dart';
import 'package:intl/intl.dart';

class CSRSponsorshipScreen extends StatefulWidget {
  const CSRSponsorshipScreen({super.key});

  @override
  State<CSRSponsorshipScreen> createState() => _CSRSponsorshipScreenState();
}

class _CSRSponsorshipScreenState extends State<CSRSponsorshipScreen> {
  List<CSRSponsorship> _sponsorships = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _loadSponsorships();
  }

  Future<void> _loadSponsorships() async {
    try {
      final sponsorships = await BusinessService.getCSRSponsorships();
      setState(() {
        _sponsorships = sponsorships;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sponsorships: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'CSR Sponsorships',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showSponsorshipForm,
            tooltip: 'Add Sponsorship',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                _buildFilters(),
                Expanded(
                  child: _buildSponsorshipsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Corporate Social Responsibility',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Partner with us to make a real impact in disaster relief and community resilience',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('${_sponsorships.length}', 'Active Sponsors'),
              const SizedBox(width: 16),
              _buildStatCard(
                currencyFormat.format(_getTotalSponsorshipValue()),
                'Total Value',
              ),
              const SizedBox(width: 16),
              _buildStatCard('${_getActiveSponsorshipsCount()}', 'Active Projects'),
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
          color: Colors.white.withOpacity(0.2),
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('All')),
                ButtonSegment(value: 'water_hub', label: Text('Water Hubs')),
                ButtonSegment(value: 'relief_point', label: Text('Relief Points')),
                ButtonSegment(value: 'equipment', label: Text('Equipment')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedFilter = selection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorshipsList() {
    final filteredSponsorships = _sponsorships.where((sponsorship) {
      if (_selectedFilter == 'all') return true;
      return sponsorship.sponsorshipType == _selectedFilter;
    }).toList();

    if (filteredSponsorships.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No sponsorships found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSponsorships.length,
      itemBuilder: (context, index) {
        final sponsorship = filteredSponsorships[index];
        return _buildSponsorshipCard(sponsorship);
      },
    );
  }

  Widget _buildSponsorshipCard(CSRSponsorship sponsorship) {
    final daysRemaining = sponsorship.endDate.difference(DateTime.now()).inDays;
    final isActive = sponsorship.isActive && daysRemaining > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  child: sponsorship.sponsorLogo.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            sponsorship.sponsorLogo,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business,
                                color: Colors.grey.shade600,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.business,
                          color: Colors.grey.shade600,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sponsorship.sponsorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _getSponsorshipTypeLabel(sponsorship.sponsorshipType),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sponsorship.locationName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyFormat.format(sponsorship.amount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${DateFormat('MMM dd, yyyy').format(sponsorship.startDate)} - ${DateFormat('MMM dd, yyyy').format(sponsorship.endDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$daysRemaining days left',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewSponsorshipDetails(sponsorship),
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewImpactReport(sponsorship),
                        icon: const Icon(Icons.analytics),
                        label: const Text('Impact Report'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSponsorshipTypeLabel(String type) {
    switch (type) {
      case 'water_hub':
        return 'Water Hub Sponsorship';
      case 'relief_point':
        return 'Relief Point Sponsorship';
      case 'equipment':
        return 'Equipment Sponsorship';
      default:
        return 'General Sponsorship';
    }
  }

  double _getTotalSponsorshipValue() {
    return _sponsorships.fold(0.0, (sum, sponsorship) => sum + sponsorship.amount);
  }

  int _getActiveSponsorshipsCount() {
    return _sponsorships.where((sponsorship) {
      return sponsorship.isActive && sponsorship.endDate.isAfter(DateTime.now());
    }).length;
  }

  void _showSponsorshipForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SponsorshipFormSheet(),
    );
  }

  void _viewSponsorshipDetails(CSRSponsorship sponsorship) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SponsorshipDetailsScreen(sponsorship: sponsorship),
      ),
    );
  }

  void _viewImpactReport(CSRSponsorship sponsorship) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImpactReportScreen(sponsorship: sponsorship),
      ),
    );
  }
}

class _SponsorshipFormSheet extends StatefulWidget {
  const _SponsorshipFormSheet();

  @override
  State<_SponsorshipFormSheet> createState() => _SponsorshipFormSheetState();
}

class _SponsorshipFormSheetState extends State<_SponsorshipFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _sponsorNameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'water_hub';
  String _selectedLocation = 'hub001';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Sponsorship',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _sponsorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Sponsor Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter sponsor name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Sponsorship Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'water_hub', child: Text('Water Hub')),
                        DropdownMenuItem(value: 'relief_point', child: Text('Relief Point')),
                        DropdownMenuItem(value: 'equipment', child: Text('Equipment')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'hub001', child: Text('Downtown Water Hub')),
                        DropdownMenuItem(value: 'relief001', child: Text('Emergency Relief Center')),
                        DropdownMenuItem(value: 'hub002', child: Text('Community Water Station')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Sponsorship Amount',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Create Sponsorship'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Implement sponsorship creation
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sponsorship created successfully')),
      );
    }
  }

  @override
  void dispose() {
    _sponsorNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

class _SponsorshipDetailsScreen extends StatelessWidget {
  final CSRSponsorship sponsorship;

  const _SponsorshipDetailsScreen({required this.sponsorship});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sponsorship.sponsorName),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Implementation for detailed sponsorship view
            const Text('Sponsorship Details'),
          ],
        ),
      ),
    );
  }
}

class _ImpactReportScreen extends StatelessWidget {
  final CSRSponsorship sponsorship;

  const _ImpactReportScreen({required this.sponsorship});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact Report'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Implementation for impact report
            const Text('Impact Report'),
          ],
        ),
      ),
    );
  }
}
