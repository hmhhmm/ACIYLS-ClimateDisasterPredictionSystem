import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/business_models.dart';
import '../services/business_service.dart';
import 'package:intl/intl.dart';

class ROIAnalyticsScreen extends StatefulWidget {
  const ROIAnalyticsScreen({super.key});

  @override
  State<ROIAnalyticsScreen> createState() => _ROIAnalyticsScreenState();
}

class _ROIAnalyticsScreenState extends State<ROIAnalyticsScreen> {
  List<ROIAnalytics> _analytics = [];
  List<B2BClient> _clients = [];
  bool _isLoading = true;
  String? _selectedClientId;
  String _selectedPeriod = '30d';
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final clients = await BusinessService.getB2BClients();
      setState(() {
        _clients = clients;
        if (clients.isNotEmpty) {
          _selectedClientId = clients.first.id;
        }
      });
      
      if (_selectedClientId != null) {
        await _loadAnalytics();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadAnalytics() async {
    if (_selectedClientId == null) return;
    
    try {
      final analytics = await BusinessService.getROIAnalytics(_selectedClientId!);
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
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
          'ROI Analytics',
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
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildRevenueChart(),
                  const SizedBox(height: 24),
                  _buildImpactMetrics(),
                  const SizedBox(height: 24),
                  _buildDetailedBreakdown(),
                  const SizedBox(height: 24),
                  _buildComparisonChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedClientId,
                  decoration: const InputDecoration(
                    labelText: 'Client',
                    border: OutlineInputBorder(),
                  ),
                  items: _clients.map((client) {
                    return DropdownMenuItem(
                      value: client.id,
                      child: Text(client.companyName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClientId = value;
                    });
                    _loadAnalytics();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                    DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
                    DropdownMenuItem(value: '90d', child: Text('Last 90 days')),
                    DropdownMenuItem(value: '1y', child: Text('Last year')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                    _loadAnalytics();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_analytics.isEmpty) {
      return const Center(
        child: Text('No analytics data available'),
      );
    }

    final latestAnalytics = _analytics.first;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ROI Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSummaryCard(
              'Total Cost Savings',
              currencyFormat.format(latestAnalytics.costSavings),
              Icons.savings,
              Colors.green,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(
              'Avoided Damage',
              currencyFormat.format(latestAnalytics.avoidedDamage),
              Icons.shield,
              Colors.blue,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard(
              'Lives Saved',
              latestAnalytics.livesSaved.toString(),
              Icons.favorite,
              Colors.red,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(
              'Infrastructure Protected',
              latestAnalytics.infrastructureProtected.toString(),
              Icons.business,
              Colors.orange,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (_analytics.isEmpty) return const SizedBox.shrink();

    final chartData = _analytics.map((analytics) {
      return TimeSeriesData(
        analytics.date,
        analytics.costSavings,
        analytics.avoidedDamage,
        analytics.costSavings + analytics.avoidedDamage,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Impact Over Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                LineSeries<TimeSeriesData, DateTime>(
                  name: 'Cost Savings',
                  dataSource: chartData,
                  xValueMapper: (TimeSeriesData data, _) => data.date,
                  yValueMapper: (TimeSeriesData data, _) => data.costSavings,
                  color: Colors.green,
                ),
                LineSeries<TimeSeriesData, DateTime>(
                  name: 'Avoided Damage',
                  dataSource: chartData,
                  xValueMapper: (TimeSeriesData data, _) => data.date,
                  yValueMapper: (TimeSeriesData data, _) => data.avoidedDamage,
                  color: Colors.blue,
                ),
                LineSeries<TimeSeriesData, DateTime>(
                  name: 'Total Value',
                  dataSource: chartData,
                  xValueMapper: (TimeSeriesData data, _) => data.date,
                  yValueMapper: (TimeSeriesData data, _) => data.totalValue,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMetrics() {
    if (_analytics.isEmpty) return const SizedBox.shrink();

    final latestAnalytics = _analytics.first;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Impact Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildImpactRow('Public Reach', '${latestAnalytics.publicReach.toStringAsFixed(0)} people'),
          _buildImpactRow('CSR Impact Score', '${(latestAnalytics.csrImpact * 100).toStringAsFixed(0)}%'),
          _buildImpactRow('Response Time Reduction', latestAnalytics.detailedMetrics['responseTimeReduction'] ?? 'N/A'),
          _buildImpactRow('Insurance Claims Reduced', latestAnalytics.detailedMetrics['insuranceClaimsReduced'] ?? 'N/A'),
          _buildImpactRow('Community Satisfaction', latestAnalytics.detailedMetrics['communitySatisfaction'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildImpactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF007AFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown() {
    if (_analytics.isEmpty) return const SizedBox.shrink();

    final latestAnalytics = _analytics.first;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfCircularChart(
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CircularSeries>[
                DoughnutSeries<ChartData, String>(
                  dataSource: [
                    ChartData('Cost Savings', latestAnalytics.costSavings, Colors.green),
                    ChartData('Avoided Damage', latestAnalytics.avoidedDamage, Colors.blue),
                  ],
                  xValueMapper: (ChartData data, _) => data.category,
                  yValueMapper: (ChartData data, _) => data.value,
                  pointColorMapper: (ChartData data, _) => data.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart() {
    if (_clients.length < 2) return const SizedBox.shrink();

    final comparisonData = _clients.take(3).map((client) {
      return ComparisonData(
        client.companyName,
        100000 + (client.id.hashCode % 200000), // Mock data
        50000 + (client.id.hashCode % 150000), // Mock data
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client Comparison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<ComparisonData, String>(
                  name: 'Cost Savings',
                  dataSource: comparisonData,
                  xValueMapper: (ComparisonData data, _) => data.clientName,
                  yValueMapper: (ComparisonData data, _) => data.costSavings,
                  color: Colors.green,
                ),
                ColumnSeries<ComparisonData, String>(
                  name: 'Avoided Damage',
                  dataSource: comparisonData,
                  xValueMapper: (ComparisonData data, _) => data.clientName,
                  yValueMapper: (ComparisonData data, _) => data.avoidedDamage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    // Implement report export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating and downloading report...')),
    );
  }
}

// Chart data classes
class TimeSeriesData {
  final DateTime date;
  final double costSavings;
  final double avoidedDamage;
  final double totalValue;

  TimeSeriesData(this.date, this.costSavings, this.avoidedDamage, this.totalValue);
}

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

class ComparisonData {
  final String clientName;
  final double costSavings;
  final double avoidedDamage;

  ComparisonData(this.clientName, this.costSavings, this.avoidedDamage);
}
