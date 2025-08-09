import 'package:flutter/material.dart';
import '../models/business_models.dart';
import '../services/business_service.dart';
import 'package:intl/intl.dart';

class AdvertisingPortalScreen extends StatefulWidget {
  const AdvertisingPortalScreen({super.key});

  @override
  State<AdvertisingPortalScreen> createState() => _AdvertisingPortalScreenState();
}

class _AdvertisingPortalScreenState extends State<AdvertisingPortalScreen> {
  List<Advertisement> _advertisements = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
  }

  Future<void> _loadAdvertisements() async {
    try {
      final advertisements = await BusinessService.getActiveAdvertisements();
      setState(() {
        _advertisements = advertisements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading advertisements: $e')),
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
          'Advertising Portal',
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
            onPressed: _showAdForm,
            tooltip: 'Create Ad',
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
                  child: _buildAdvertisementsList(),
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
          colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Climate-Resilient Advertising',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Reach engaged audiences with products that help communities prepare for and respond to climate challenges',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('${_advertisements.length}', 'Active Ads'),
              const SizedBox(width: 16),
              _buildStatCard(
                currencyFormat.format(_getTotalBudget()),
                'Total Budget',
              ),
              const SizedBox(width: 16),
              _buildStatCard('${_getActiveAdsCount()}', 'Running'),
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
                ButtonSegment(value: 'water_filters', label: Text('Water Filters')),
                ButtonSegment(value: 'solar_lights', label: Text('Solar Lights')),
                ButtonSegment(value: 'emergency_kits', label: Text('Emergency Kits')),
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

  Widget _buildAdvertisementsList() {
    final filteredAds = _advertisements.where((ad) {
      if (_selectedFilter == 'all') return true;
      return ad.targetAudience.contains(_selectedFilter);
    }).toList();

    if (filteredAds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No advertisements found',
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
      itemCount: filteredAds.length,
      itemBuilder: (context, index) {
        final ad = filteredAds[index];
        return _buildAdvertisementCard(ad);
      },
    );
  }

  Widget _buildAdvertisementCard(Advertisement ad) {
    final daysRemaining = ad.endDate.difference(DateTime.now()).inDays;
    final isActive = ad.isActive && daysRemaining > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.orange.shade200 : Colors.grey.shade200,
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
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: ad.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image.network(
                      ad.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No image',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      child: ad.advertiserLogo.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                ad.advertiserLogo,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.business,
                                    color: Colors.grey.shade600,
                                    size: 16,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.business,
                              color: Colors.grey.shade600,
                              size: 16,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ad.advertiserName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            ad.targetAudience.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.orange : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ad.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ad.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Budget: ${currencyFormat.format(ad.budget)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('MMM dd').format(ad.startDate)} - ${DateFormat('MMM dd').format(ad.endDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$daysRemaining days remaining',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewAdDetails(ad),
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewAnalytics(ad),
                        icon: const Icon(Icons.analytics),
                        label: const Text('Analytics'),
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

  double _getTotalBudget() {
    return _advertisements.fold(0.0, (sum, ad) => sum + ad.budget);
  }

  int _getActiveAdsCount() {
    return _advertisements.where((ad) {
      return ad.isActive && ad.endDate.isAfter(DateTime.now());
    }).length;
  }

  void _showAdForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AdFormSheet(),
    );
  }

  void _viewAdDetails(Advertisement ad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AdDetailsScreen(advertisement: ad),
      ),
    );
  }

  void _viewAnalytics(Advertisement ad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AdAnalyticsScreen(advertisement: ad),
      ),
    );
  }
}

class _AdFormSheet extends StatefulWidget {
  const _AdFormSheet();

  @override
  State<_AdFormSheet> createState() => _AdFormSheetState();
}

class _AdFormSheetState extends State<_AdFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _advertiserNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  String _selectedAudience = 'emergency_responders';
  String _selectedRegion = 'US';

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
                      'Create Advertisement',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _advertiserNameController,
                      decoration: const InputDecoration(
                        labelText: 'Advertiser Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter advertiser name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Ad Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ad title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Ad Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ad description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedAudience,
                      decoration: const InputDecoration(
                        labelText: 'Target Audience',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'emergency_responders', child: Text('Emergency Responders')),
                        DropdownMenuItem(value: 'water_filters', child: Text('Water Filter Users')),
                        DropdownMenuItem(value: 'solar_lights', child: Text('Solar Light Users')),
                        DropdownMenuItem(value: 'emergency_kits', child: Text('Emergency Kit Users')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAudience = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRegion,
                      decoration: const InputDecoration(
                        labelText: 'Target Region',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'US', child: Text('United States')),
                        DropdownMenuItem(value: 'CA', child: Text('Canada')),
                        DropdownMenuItem(value: 'EU', child: Text('Europe')),
                        DropdownMenuItem(value: 'Global', child: Text('Global')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Budget',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter budget';
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
                        child: const Text('Create Advertisement'),
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
      // Implement ad creation
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advertisement created successfully')),
      );
    }
  }

  @override
  void dispose() {
    _advertiserNameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}

class _AdDetailsScreen extends StatelessWidget {
  final Advertisement advertisement;

  const _AdDetailsScreen({required this.advertisement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(advertisement.title),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Implementation for detailed ad view
            const Text('Advertisement Details'),
          ],
        ),
      ),
    );
  }
}

class _AdAnalyticsScreen extends StatelessWidget {
  final Advertisement advertisement;

  const _AdAnalyticsScreen({required this.advertisement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Analytics'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Implementation for ad analytics
            const Text('Advertisement Analytics'),
          ],
        ),
      ),
    );
  }
}
