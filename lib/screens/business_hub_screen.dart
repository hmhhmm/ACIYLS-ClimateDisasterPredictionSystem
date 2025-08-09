import 'package:flutter/material.dart';
import 'b2b_subscription_screen.dart';
import 'roi_analytics_screen.dart';
import 'csr_sponsorship_screen.dart';
import 'data_licensing_screen.dart';
import 'advertising_portal_screen.dart';

class BusinessHubScreen extends StatelessWidget {
  const BusinessHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Business Hub',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildBusinessFeatures(context),
              const SizedBox(height: 24),
              _buildQuickStats(),
              const SizedBox(height: 100), // Add extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Solutions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comprehensive climate intelligence for enterprise clients',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('500+', 'Organizations'),
              const SizedBox(width: 16),
              _buildStatCard('99.9%', 'Uptime'),
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

  Widget _buildBusinessFeatures(BuildContext context) {
    final features = [
      {
        'title': 'B2B Subscriptions',
        'description': 'Enterprise climate monitoring and analytics',
        'icon': Icons.business,
        'color': Colors.blue,
        'screen': const B2BSubscriptionScreen(),
      },
      {
        'title': 'ROI Analytics',
        'description': 'Impact measurement and cost savings tracking',
        'icon': Icons.analytics,
        'color': Colors.green,
        'screen': const ROIAnalyticsScreen(),
      },
      {
        'title': 'CSR Sponsorships',
        'description': 'Corporate social responsibility partnerships',
        'icon': Icons.volunteer_activism,
        'color': Colors.orange,
        'screen': const CSRSponsorshipScreen(),
      },
      {
        'title': 'Data Licensing',
        'description': 'Climate and infrastructure data marketplace',
        'icon': Icons.data_usage,
        'color': Colors.purple,
        'screen': const DataLicensingScreen(),
      },
      {
        'title': 'Advertising Portal',
        'description': 'Climate-resilient product promotions',
        'icon': Icons.campaign,
        'color': Colors.red,
        'screen': const AdvertisingPortalScreen(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Features',
          style: TextStyle(
            fontSize: 20,
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
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1, // Make cards slightly taller
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureCard(feature, context);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => feature['screen'] as Widget,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced padding
                decoration: BoxDecoration(
                  color: feature['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature['icon'],
                  color: feature['color'],
                  size: 24, // Smaller icon
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                feature['title'],
                style: const TextStyle(
                  fontSize: 12, // Smaller font
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4), // Reduced spacing
              Text(
                feature['description'],
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

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickStatCard('Revenue', '\$2.4M', '+12%', Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard('Clients', '156', '+8%', Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickStatCard('ROI', '340%', '+15%', Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard('Data Sets', '2.1K', '+25%', Colors.purple),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String title, String value, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
