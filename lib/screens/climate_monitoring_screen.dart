import 'package:flutter/material.dart';
import '../models/climate_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import '../services/weather_service.dart';

class WeatherColors {
  static const Color primary = Color(0xFFF2F2F7);
}

// --- Placeholder screens for prediction types ---
class RuleBasedPredictionScreen extends StatelessWidget {
  const RuleBasedPredictionScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Rule-based Prediction',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPredictionCard(
            context,
            'Temperature Rule',
            'If temperature > 35°C for 3 consecutive days → High heat risk',
            Icons.thermostat,
            Colors.orange,
            'Current: 32°C (2 days above 30°C)',
            'Status: Monitoring',
          ),
          const SizedBox(height: 12),
          _buildPredictionCard(
            context,
            'Rainfall Rule',
            'If rainfall > 50mm in 24h → Flood warning',
            Icons.water_drop,
            Colors.blue,
            'Current: 15mm (last 24h)',
            'Status: Safe',
          ),
          const SizedBox(height: 12),
          _buildPredictionCard(
            context,
            'Drought Rule',
            'If no rain for 7 days + soil moisture < 30% → Drought alert',
            Icons.grass,
            Colors.brown,
            'Current: 3 days no rain, 45% soil moisture',
            'Status: Watch',
          ),
          const SizedBox(height: 12),
          _buildPredictionCard(
            context,
            'Wind Rule',
            'If wind speed > 40km/h → Storm warning',
            Icons.air,
            Colors.grey,
            'Current: 25km/h',
            'Status: Safe',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rule Engine Status',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusItem('Active Rules', '12', Colors.green),
                _buildStatusItem('Triggered Rules', '2', Colors.orange),
                _buildStatusItem('Critical Alerts', '0', Colors.red),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Show rule configuration
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    'Configure Rules',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(
    BuildContext context,
    String title,
    String rule,
    IconData icon,
    Color color,
    String current,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rule,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            current,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class MLModelPredictionScreen extends StatelessWidget {
  const MLModelPredictionScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ML Model Prediction',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Model Performance',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMetricRow('Accuracy', '87.3%', Colors.green),
                _buildMetricRow('Precision', '82.1%', Colors.blue),
                _buildMetricRow('Recall', '89.5%', Colors.orange),
                _buildMetricRow('F1-Score', '85.6%', Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prediction Confidence',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final labels = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ];
                              if (value.toInt() < labels.length) {
                                return Text(
                                  labels[value.toInt()],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 0.85),
                            const FlSpot(1, 0.87),
                            const FlSpot(2, 0.82),
                            const FlSpot(3, 0.89),
                            const FlSpot(4, 0.91),
                            const FlSpot(5, 0.88),
                            const FlSpot(6, 0.90),
                          ],
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next 7 Days Predictions',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPredictionItem('Flood Risk', 'Low (15%)', Colors.green),
                _buildPredictionItem(
                  'Drought Risk',
                  'Medium (45%)',
                  Colors.orange,
                ),
                _buildPredictionItem('Heat Wave', 'High (78%)', Colors.red),
                _buildPredictionItem('Storm Risk', 'Low (22%)', Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Retrain model
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    'Retrain Model',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Export predictions
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text(
                    'Export Data',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScenarioAnalysisScreen extends StatelessWidget {
  const ScenarioAnalysisScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Scenario Analysis',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Climate Scenarios',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildScenarioCard(
                  'Best Case',
                  'Temperature +1°C, Rainfall +10%',
                  'Low risk across all parameters',
                  Colors.green,
                  Icons.trending_up,
                ),
                const SizedBox(height: 8),
                _buildScenarioCard(
                  'Moderate Case',
                  'Temperature +2°C, Rainfall -5%',
                  'Medium flood and drought risks',
                  Colors.orange,
                  Icons.trending_flat,
                ),
                const SizedBox(height: 8),
                _buildScenarioCard(
                  'Worst Case',
                  'Temperature +3°C, Rainfall -20%',
                  'High drought risk, moderate flood risk',
                  Colors.red,
                  Icons.trending_down,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Impact Comparison',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final labels = ['Best', 'Moderate', 'Worst'];
                              if (value.toInt() < labels.length) {
                                return Text(
                                  labels[value.toInt()],
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: 15,
                              color: Colors.green,
                              width: 20,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: 45,
                              color: Colors.orange,
                              width: 20,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: 75,
                              color: Colors.red,
                              width: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended Actions',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionItem(
                  'Water Conservation',
                  'Implement strict water usage policies',
                  Icons.water_drop,
                ),
                _buildActionItem(
                  'Infrastructure',
                  'Strengthen flood defenses',
                  Icons.build,
                ),
                _buildActionItem(
                  'Agriculture',
                  'Switch to drought-resistant crops',
                  Icons.agriculture,
                ),
                _buildActionItem(
                  'Emergency Plans',
                  'Update evacuation procedures',
                  Icons.emergency,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Generate detailed report
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Generate Detailed Report',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(
    String title,
    String conditions,
    String impact,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  conditions,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  impact,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellow, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClimateMonitoringScreen extends StatefulWidget {
  const ClimateMonitoringScreen({super.key});

  @override
  State<ClimateMonitoringScreen> createState() =>
      _ClimateMonitoringScreenState();
}

class _ClimateMonitoringScreenState extends State<ClimateMonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ClimateData _currentData = ClimateData.getMockData();
  final List<ClimateData> _historicalData = ClimateData.getMockHistoricalData(
    30,
  );
  final List<WaterSourceImpact> _impacts = WaterSourceImpact.getMockImpacts();
  final List<ClimateAlert> _alerts = ClimateAlert.getMockAlerts();
  final List<Map<String, dynamic>> _communityHazardReports = [];
  String? _selectedScenario = 'Normal';
  String _trendRange = '30d';
  late WeatherService _weatherService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _weatherService = WeatherService(apiKey: 'YOUR_API_KEY_HERE');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method for cards
  Card _darkCard(BuildContext context, Widget child) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.black),
        child: child,
      ),
    );
  }

  // Enhanced card with accent color/gradient
  Widget _niceCard(
    BuildContext context,
    Widget child, {
    Color? accent,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                (accent ?? Colors.blue).withOpacity(0.10),
                (accent ?? Colors.blue).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (accent ?? Colors.blue).withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (accent ?? Colors.blue).withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }

  void _downloadCsv(String title, List<double> values) {
    final csv = StringBuffer();
    csv.writeln('Index,Value');
    for (int i = 0; i < values.length; i++) {
      csv.writeln('$i,${values[i]}');
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('CSV for $title'),
        content: SingleChildScrollView(child: Text(csv.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareChartPlaceholder(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share $title Chart'),
        content: const Text('Chart sharing is not implemented in this demo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WeatherColors.primary,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Climate Monitoring',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(color: Colors.white),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E5EA), width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Color(0xFF007AFF),
                unselectedLabelColor: Colors.black54,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: Color(0xFF007AFF)),
                  insets: EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Trends'),
                  Tab(text: 'Risk Map'),
                  Tab(text: 'Predict'),
                  Tab(text: 'Sensors'),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Overview Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _niceCard(
                        context,
                        _buildHeaderCardContent(),
                        accent: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _niceCard(
                        context,
                        _buildCurrentConditionsContent(),
                        accent: Colors.cyan,
                      ),
                      const SizedBox(height: 12),
                      _niceCard(
                        context,
                        _buildRiskAssessmentContent(),
                        accent: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _niceCard(
                        context,
                        _buildActiveAlertsContent(),
                        accent: Colors.orange,
                      ),
                    ],
                  ),
                  // Trends Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          const Text('Time Range: '),
                          DropdownButton<String>(
                            value: _trendRange,
                            items: const [
                              DropdownMenuItem(
                                value: '7d',
                                child: Text('7 days'),
                              ),
                              DropdownMenuItem(
                                value: '30d',
                                child: Text('30 days'),
                              ),
                              DropdownMenuItem(
                                value: '1y',
                                child: Text('1 year'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _trendRange = v ?? '30d'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _darkCard(
                        context,
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _trendInsight(),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRiskTrendChart(
                        'Flood Risk Trend',
                        _getTrendData('flood'),
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildRiskTrendChart(
                        'Drought Risk Trend',
                        _getTrendData('drought'),
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildTemperatureTrend(),
                      const SizedBox(height: 8),
                      _buildRainfallTrend(),
                      const SizedBox(height: 8),
                      _buildWaterTableTrend(),
                      const SizedBox(height: 8),
                      _buildCommunityTrendsChart(),
                    ],
                  ),
                  // Risk Map Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [_buildRiskMapTab()],
                  ),
                  // Prediction Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [_buildPredictionContent()],
                  ),
                  // Infrastructure Tab
                  _buildInfrastructureTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Content builders for nice cards
  Widget _buildHeaderCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Kuala Lumpur',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_currentData.temperature.toStringAsFixed(0)}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              ' | Mostly Sunny',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentConditionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Conditions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildConditionItem(
                'Temperature',
                '${_currentData.temperature}°C',
                Icons.thermostat,
                Colors.orange,
              ),
            ),
            Expanded(
              child: _buildConditionItem(
                'Humidity',
                '${_currentData.humidity}%',
                Icons.water_drop,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildConditionItem(
                'Rainfall',
                '${_currentData.rainfall}mm',
                Icons.umbrella,
                Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildConditionItem(
                'Wind Speed',
                '${_currentData.windSpeed}km/h',
                Icons.air,
                Colors.teal,
              ),
            ),
            Expanded(
              child: _buildConditionItem(
                'Soil Moisture',
                '${_currentData.soilMoisture}%',
                Icons.grass,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildConditionItem(
                'Water Table',
                '${_currentData.waterTableLevel}m',
                Icons.waves,
                Colors.cyan,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConditionItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRiskAssessmentContent() {
    final floodScore =
        (_currentData.rainfall * 2 + _currentData.soilMoisture) ~/ 3;
    final droughtScore =
        (100 - _currentData.rainfall + (100 - _currentData.soilMoisture)) ~/ 2;

    String floodLevel, droughtLevel;
    Color floodColor, droughtColor;
    String floodRecommendation, droughtRecommendation;

    if (floodScore < 30) {
      floodLevel = 'Low';
      floodColor = Colors.green;
      floodRecommendation = 'No immediate flood risk. Stay informed.';
    } else if (floodScore < 60) {
      floodLevel = 'Moderate';
      floodColor = Colors.orange;
      floodRecommendation =
          'Monitor local weather updates. Prepare for possible heavy rain.';
    } else {
      floodLevel = 'High';
      floodColor = Colors.red;
      floodRecommendation =
          'High flood risk! Prepare to move to higher ground and follow local alerts.';
    }

    if (droughtScore < 30) {
      droughtLevel = 'Low';
      droughtColor = Colors.green;
      droughtRecommendation = 'No immediate drought risk.';
    } else if (droughtScore < 60) {
      droughtLevel = 'Moderate';
      droughtColor = Colors.orange;
      droughtRecommendation = 'Conserve water and monitor usage.';
    } else {
      droughtLevel = 'High';
      droughtColor = Colors.red;
      droughtRecommendation =
          'Severe drought risk! Limit water use and follow local advisories.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk Assessment',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildScoreRiskIndicator(
          'Flood Risk',
          floodScore,
          floodLevel,
          floodColor,
          Icons.warning,
          floodRecommendation,
        ),
        const SizedBox(height: 12),
        _buildScoreRiskIndicator(
          'Drought Risk',
          droughtScore,
          droughtLevel,
          droughtColor,
          Icons.water_drop,
          droughtRecommendation,
        ),
      ],
    );
  }

  Widget _buildScoreRiskIndicator(
    String title,
    int score,
    String level,
    Color color,
    IconData icon,
    String recommendation,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($score/100)',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                'Level: $level',
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                recommendation,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveAlertsContent() {
    if (_currentData.activeAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Alerts',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            TextButton(
              onPressed: () {
                _tabController.animateTo(3);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._currentData.activeAlerts.map(
          (alert) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskTrendChart(String title, List<double> scores, Color color) {
    return _darkCard(
      context,
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index % 5 == 0 && index < scores.length) {
                            final date = _historicalData[index].timestamp;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        scores.length,
                        (i) => FlSpot(i.toDouble(), scores[i]),
                      ),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
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

  Widget _buildTemperatureTrend() {
    return _darkCard(
      context,
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}°C',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index % 5 == 0) {
                            final date = DateTime.now().subtract(
                              Duration(days: 29 - index),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _historicalData
                          .asMap()
                          .entries
                          .map(
                            (entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.temperature,
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withOpacity(0.1),
                      ),
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

  Widget _buildRainfallTrend() {
    return _darkCard(
      context,
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rainfall Distribution',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}mm',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index % 5 == 0) {
                            final date = DateTime.now().subtract(
                              Duration(days: 29 - index),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  barGroups: _historicalData
                      .asMap()
                      .entries
                      .map(
                        (entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.rainfall,
                              color: Colors.blue,
                              width: 8,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterTableTrend() {
    return _darkCard(
      context,
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Table Level',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}m',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index % 5 == 0) {
                            final date = DateTime.now().subtract(
                              Duration(days: 29 - index),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _historicalData
                          .asMap()
                          .entries
                          .map(
                            (entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.waterTableLevel,
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.cyan,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.cyan.withOpacity(0.1),
                      ),
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

  Widget _buildCommunityTrendsChart() {
    int len = _getTrendLen();
    final data = _historicalData.take(len).toList();
    final reportCounts = List<int>.filled(len, 0);
    for (int i = 0; i < data.length; i++) {
      final date = data[i].timestamp;
      reportCounts[i] = _communityHazardReports
          .where((r) => DateTime.parse(r['timestamp'] ?? '') == date)
          .length;
    }
    return _darkCard(
      context,
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Reports Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  barGroups: List.generate(
                    reportCounts.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: reportCounts[i].toDouble(),
                          color: Colors.purple,
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Number of community hazard reports per day',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskMapTab() {
    final floodZone = [
      [1.300, 103.800],
      [1.301, 103.802],
      [1.302, 103.801],
      [1.301, 103.799],
    ];
    final droughtZone = [
      [1.298, 103.804],
      [1.299, 103.806],
      [1.300, 103.805],
      [1.299, 103.803],
    ];

    // More risk points
    final riskPoints = [
      {
        'lat': 1.301,
        'lng': 103.800,
        'type': 'Flood',
        'severity': 'High',
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'lat': 1.299,
        'lng': 103.805,
        'type': 'Drought',
        'severity': 'Medium',
        'icon': Icons.water_drop,
        'color': Colors.orange,
      },
      {
        'lat': 1.302,
        'lng': 103.798,
        'type': 'Flood',
        'severity': 'Medium',
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'lat': 1.298,
        'lng': 103.802,
        'type': 'Drought',
        'severity': 'High',
        'icon': Icons.water_drop,
        'color': Colors.orange,
      },
      {
        'lat': 1.303,
        'lng': 103.801,
        'type': 'Flood',
        'severity': 'Low',
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'lat': 1.297,
        'lng': 103.807,
        'type': 'Drought',
        'severity': 'Medium',
        'icon': Icons.water_drop,
        'color': Colors.orange,
      },
      {
        'lat': 1.300,
        'lng': 103.797,
        'type': 'Flood',
        'severity': 'High',
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'lat': 1.301,
        'lng': 103.806,
        'type': 'Drought',
        'severity': 'Low',
        'icon': Icons.water_drop,
        'color': Colors.orange,
      },
    ];

    // Helper function to safely get values from risk points
    double getLat(Map<String, dynamic> point) =>
        (point['lat'] as num).toDouble();
    double getLng(Map<String, dynamic> point) =>
        (point['lng'] as num).toDouble();
    IconData getIcon(Map<String, dynamic> point) => point['icon'] as IconData;
    Color getColor(Map<String, dynamic> point) => point['color'] as Color;

    return Column(
      children: [
        // Map section with reduced height
        Container(
          height: 300, // Reduced from 400
          margin: const EdgeInsets.all(8),
          child: _darkCard(
            context,
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (kIsWeb) {
                    return fmap.FlutterMap(
                      options: fmap.MapOptions(
                        center: latlong.LatLng(1.300, 103.800),
                        zoom: 14,
                      ),
                      children: [
                        fmap.TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          tileProvider: CancellableNetworkTileProvider(),
                        ),
                        fmap.PolygonLayer(
                          polygons: [
                            fmap.Polygon(
                              points: floodZone
                                  .map((c) => latlong.LatLng(c[0], c[1]))
                                  .toList(),
                              color: Colors.red.withOpacity(0.3),
                              borderStrokeWidth: 2,
                              borderColor: Colors.red,
                            ),
                            fmap.Polygon(
                              points: droughtZone
                                  .map((c) => latlong.LatLng(c[0], c[1]))
                                  .toList(),
                              color: Colors.orange.withOpacity(0.3),
                              borderStrokeWidth: 2,
                              borderColor: Colors.orange,
                            ),
                          ],
                        ),
                        fmap.MarkerLayer(
                          markers: riskPoints
                              .map(
                                (point) => fmap.Marker(
                                  width: 40,
                                  height: 40,
                                  point: latlong.LatLng(
                                    getLat(point),
                                    getLng(point),
                                  ),
                                  child: Tooltip(
                                    message:
                                        '${point['type']} Risk - ${point['severity']}',
                                    child: Icon(
                                      getIcon(point),
                                      color: getColor(point),
                                      size: 36,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    );
                  } else {
                    return gmaps.GoogleMap(
                      initialCameraPosition: const gmaps.CameraPosition(
                        target: gmaps.LatLng(1.300, 103.800),
                        zoom: 14,
                      ),
                      polygons: {
                        gmaps.Polygon(
                          polygonId: const gmaps.PolygonId('flood'),
                          points: floodZone
                              .map((c) => gmaps.LatLng(c[0], c[1]))
                              .toList(),
                          fillColor: Colors.red.withOpacity(0.3),
                          strokeColor: Colors.red,
                          strokeWidth: 2,
                        ),
                        gmaps.Polygon(
                          polygonId: const gmaps.PolygonId('drought'),
                          points: droughtZone
                              .map((c) => gmaps.LatLng(c[0], c[1]))
                              .toList(),
                          fillColor: Colors.orange.withOpacity(0.3),
                          strokeColor: Colors.orange,
                          strokeWidth: 2,
                        ),
                      },
                      markers: {
                        for (int i = 0; i < riskPoints.length; i++)
                          gmaps.Marker(
                            markerId: gmaps.MarkerId('risk_$i'),
                            position: gmaps.LatLng(
                              getLat(riskPoints[i]),
                              getLng(riskPoints[i]),
                            ),
                            infoWindow: gmaps.InfoWindow(
                              title: '${riskPoints[i]['type']} Risk',
                              snippet: 'Severity: ${riskPoints[i]['severity']}',
                            ),
                            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                              getColor(riskPoints[i]) == Colors.red
                                  ? gmaps.BitmapDescriptor.hueRed
                                  : gmaps.BitmapDescriptor.hueOrange,
                            ),
                          ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                    );
                  }
                },
              ),
            ),
          ),
        ),

        // Cards below the map
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              // Risk Summary Card
              _darkCard(
                context,
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRiskSummaryItem(
                              'Flood',
                              4,
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildRiskSummaryItem(
                              'Drought',
                              4,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Recent Reports Card
              _darkCard(
                context,
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Reports',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                          ),
                          TextButton(
                            onPressed: _showReportHazardDialog,
                            child: const Text('Report'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_communityHazardReports.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No recent hazard reports',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ..._communityHazardReports
                            .take(3)
                            .map(
                              (report) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      report['type'] == 'Flood'
                                          ? Icons.warning
                                          : Icons.water_drop,
                                      color: report['type'] == 'Flood'
                                          ? Colors.red
                                          : Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${report['type']} - ${report['description'].isNotEmpty ? report['description'] : 'No description'}',
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Action Card
              _darkCard(
                context,
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showReportHazardDialog,
                              icon: const Icon(Icons.add_alert),
                              label: const Text('Report Hazard'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // View all reports action
                              },
                              icon: const Icon(Icons.list),
                              label: const Text('View All'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskSummaryItem(String type, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            color == Colors.red ? Icons.warning : Icons.water_drop,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            type,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          Text('$count points', style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _showReportHazardDialog() {
    String selectedType = 'Flood';
    final descController = TextEditingController();
    double lat = 1.300;
    double lng = 103.800;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Hazard'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'Flood', child: Text('Flood')),
                  DropdownMenuItem(value: 'Drought', child: Text('Drought')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => selectedType = v ?? 'Flood',
                decoration: const InputDecoration(labelText: 'Hazard Type'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                onChanged: (v) => lat = double.tryParse(v) ?? lat,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                onChanged: (v) => lng = double.tryParse(v) ?? lng,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _communityHazardReports.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'type': selectedType,
                  'description': descController.text,
                  'lat': lat,
                  'lng': lng,
                });
              });
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionContent() {
    return Column(
      children: [
        _darkCard(
          context,
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Climate Prediction',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Advanced prediction models and scenario analysis for climate risk assessment.',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildPredictionCard(
          'Rule-based Prediction',
          Icons.rule,
          'Based on current conditions and historical patterns',
        ),
        const SizedBox(height: 8),
        _buildPredictionCard(
          'ML Model Prediction',
          Icons.psychology,
          'Machine learning model trained on historical data',
        ),
        const SizedBox(height: 8),
        _buildPredictionCard(
          'Scenario Analysis',
          Icons.analytics,
          'What-if scenarios for different climate conditions',
        ),
      ],
    );
  }

  Widget _buildPredictionCard(String title, IconData icon, String description) {
    void _onTap() {
      if (title == 'Rule-based Prediction') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RuleBasedPredictionScreen()),
        );
      } else if (title == 'ML Model Prediction') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MLModelPredictionScreen()),
        );
      } else if (title == 'Scenario Analysis') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScenarioAnalysisScreen()),
        );
      }
    }

    return GestureDetector(
      onTap: _onTap,
      child: _darkCard(
        context,
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  List<double> _getTrendData(String type) {
    int len = _trendRange == '7d'
        ? 7
        : _trendRange == '1y'
        ? 365
        : 30;
    final data = _historicalData.take(len).toList();
    if (type == 'flood') {
      return data
          .map((d) => ((d.rainfall * 2 + d.soilMoisture) ~/ 3).toDouble())
          .toList();
    } else if (type == 'drought') {
      return data
          .map(
            (d) =>
                ((100 - d.rainfall + (100 - d.soilMoisture)) ~/ 2).toDouble(),
          )
          .toList();
    }
    return [];
  }

  String _trendInsight() {
    int len = _trendRange == '7d'
        ? 7
        : _trendRange == '1y'
        ? 365
        : 30;
    final data = _historicalData.take(len).toList();
    if (data.length < 2) return 'Not enough data for insight.';
    double avgRain =
        data.map((d) => d.rainfall).reduce((a, b) => a + b) / data.length;
    double avgTemp =
        data.map((d) => d.temperature).reduce((a, b) => a + b) / data.length;
    return 'In the last $len days, average rainfall was ${avgRain.toStringAsFixed(1)} mm and average temperature was ${avgTemp.toStringAsFixed(1)}°C.';
  }

  int _getTrendLen() {
    return _trendRange == '7d'
        ? 7
        : _trendRange == '1y'
        ? 365
        : 30;
  }

  Widget _buildInfrastructureTab() {
    // Enhanced mock sensor data with status, maintenance info, and alerts
    final List<Map<String, dynamic>> sensors = [
      {
        'category': 'Building Sensors',
        'icon': Icons.apartment,
        'color': Colors.blueGrey,
        'status': 'Good',
        'lastMaintenance': '2024-01-15',
        'nextMaintenance': '2024-04-15',
        'data': [
          {
            'label': 'Temperature',
            'value': '22°C',
            'status': 'Normal',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Humidity',
            'value': '45%',
            'status': 'Good',
            'trend': 'decreasing',
            'alert': false,
          },
          {
            'label': 'Structural Integrity',
            'value': 'Stable',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Fire Detection',
            'value': 'Clear',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
        ],
      },
      {
        'category': 'Water Infrastructure',
        'icon': Icons.water,
        'color': Colors.blue,
        'status': 'Warning',
        'lastMaintenance': '2024-01-10',
        'nextMaintenance': '2024-03-10',
        'data': [
          {
            'label': 'Pipe Pressure',
            'value': '4.8 bar',
            'status': 'High',
            'trend': 'increasing',
            'alert': true,
          },
          {
            'label': 'Water Quality',
            'value': 'Safe',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Flow Rate',
            'value': '180 L/min',
            'status': 'High',
            'trend': 'increasing',
            'alert': true,
          },
          {
            'label': 'Leak Detection',
            'value': 'None',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
        ],
      },
      {
        'category': 'Power Grid',
        'icon': Icons.electrical_services,
        'color': Colors.orange,
        'status': 'Good',
        'lastMaintenance': '2024-01-20',
        'nextMaintenance': '2024-05-20',
        'data': [
          {
            'label': 'Voltage',
            'value': '230V',
            'status': 'Normal',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Current',
            'value': '15A',
            'status': 'Normal',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Outage',
            'value': 'No',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Transformer Temp',
            'value': '65°C',
            'status': 'Normal',
            'trend': 'stable',
            'alert': false,
          },
        ],
      },
      {
        'category': 'Transportation',
        'icon': Icons.emoji_transportation,
        'color': Colors.green,
        'status': 'Critical',
        'lastMaintenance': '2024-01-05',
        'nextMaintenance': '2024-02-05',
        'data': [
          {
            'label': 'Road Condition',
            'value': 'Clear',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Bridge Sensors',
            'value': 'Warning',
            'status': 'Critical',
            'trend': 'decreasing',
            'alert': true,
          },
          {
            'label': 'Traffic Flow',
            'value': 'Smooth',
            'status': 'Normal',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Tunnel Ventilation',
            'value': 'Operational',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
        ],
      },
      {
        'category': 'Environmental',
        'icon': Icons.eco,
        'color': Colors.teal,
        'status': 'Good',
        'lastMaintenance': '2024-01-12',
        'nextMaintenance': '2024-04-12',
        'data': [
          {
            'label': 'Air Quality',
            'value': 'Good',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Noise Level',
            'value': 'Low',
            'status': 'Normal',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Vibration',
            'value': 'None',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
          {
            'label': 'Radiation Level',
            'value': 'Normal',
            'status': 'Good',
            'trend': 'stable',
            'alert': false,
          },
        ],
      },
    ];

    // Calculate overall status
    final criticalCount = sensors
        .where((s) => s['status'] == 'Critical')
        .length;
    final warningCount = sensors.where((s) => s['status'] == 'Warning').length;
    final alertCount = sensors
        .expand((s) => (s['data'] as List).where((d) => d['alert'] == true))
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall Status Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: criticalCount > 0
                ? Colors.red.withOpacity(0.1)
                : warningCount > 0
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: criticalCount > 0
                  ? Colors.red.withOpacity(0.3)
                  : warningCount > 0
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                criticalCount > 0
                    ? Icons.warning_amber_rounded
                    : warningCount > 0
                    ? Icons.info_outline
                    : Icons.check_circle,
                color: criticalCount > 0
                    ? Colors.red
                    : warningCount > 0
                    ? Colors.orange
                    : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      criticalCount > 0
                          ? 'Critical Infrastructure Alert'
                          : warningCount > 0
                          ? 'Infrastructure Warning'
                          : 'All Systems Operational',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: criticalCount > 0
                            ? Colors.red
                            : warningCount > 0
                            ? Colors.orange
                            : Colors.green,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      '$alertCount active alerts • ${sensors.length} systems monitored',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Enhanced Sensor Cards
        ...sensors.map(
          (sensor) => GestureDetector(
            onTap: () {
              print('Tapped on ${sensor['category']}'); // Debug print
              // Show a simple alert first to test
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped on ${sensor['category']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
              _showInfrastructureDetails(context, sensor);
            },
            child: Card(
              color: (sensor['color'] as Color).withOpacity(0.07),
              elevation: 2,
              shadowColor: (sensor['color'] as Color).withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: sensor['status'] == 'Critical'
                      ? Colors.red.withOpacity(0.3)
                      : sensor['status'] == 'Warning'
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.transparent,
                  width:
                      sensor['status'] == 'Critical' ||
                          sensor['status'] == 'Warning'
                      ? 2
                      : 0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with status indicator
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: (sensor['color'] as Color)
                                  .withOpacity(0.2),
                              child: Icon(
                                sensor['icon'] as IconData,
                                color: sensor['color'] as Color,
                              ),
                            ),
                            if (sensor['status'] == 'Critical' ||
                                sensor['status'] == 'Warning')
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: sensor['status'] == 'Critical'
                                        ? Colors.red
                                        : Colors.orange,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: sensor['status'] == 'Critical'
                                      ? const Icon(
                                          Icons.warning,
                                          color: Colors.white,
                                          size: 8,
                                        )
                                      : const Icon(
                                          Icons.info,
                                          color: Colors.white,
                                          size: 8,
                                        ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sensor['category'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: sensor['color'] as Color,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                              Text(
                                'Last maintenance: ${sensor['lastMaintenance']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: sensor['status'] == 'Critical'
                                    ? Colors.red.withOpacity(0.1)
                                    : sensor['status'] == 'Warning'
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                sensor['status'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: sensor['status'] == 'Critical'
                                      ? Colors.red
                                      : sensor['status'] == 'Warning'
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: (sensor['color'] as Color).withOpacity(
                                0.6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sensor Data with Trends
                    ...List.generate((sensor['data'] as List).length, (i) {
                      final d =
                          (sensor['data'] as List)[i] as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: d['alert'] == true
                              ? Colors.red.withOpacity(0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: d['alert'] == true
                              ? Border.all(color: Colors.red.withOpacity(0.2))
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Status Icon with Animation
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                d['status'] == 'Good'
                                    ? Icons.check_circle
                                    : d['status'] == 'Normal'
                                    ? Icons.radio_button_checked
                                    : Icons.error,
                                color: d['status'] == 'Good'
                                    ? Colors.green
                                    : d['status'] == 'Normal'
                                    ? Colors.blueGrey
                                    : Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Sensor Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          d['label'] as String,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Trend Indicator
                                      Icon(
                                        d['trend'] == 'increasing'
                                            ? Icons.trending_up
                                            : d['trend'] == 'decreasing'
                                            ? Icons.trending_down
                                            : Icons.trending_flat,
                                        color: d['trend'] == 'increasing'
                                            ? Colors.red
                                            : d['trend'] == 'decreasing'
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    d['value'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: d['alert'] == true
                                          ? Colors.red
                                          : Colors.black87,
                                    ),
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),

                            // Action Button
                            if (d['alert'] == true)
                              IconButton(
                                onPressed: () =>
                                    _showSensorDetails(context, sensor, d),
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: Colors.red,
                                ),
                                tooltip: 'View Details',
                              ),
                          ],
                        ),
                      );
                    }),

                    // Maintenance Info
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Next maintenance: ${sensor['nextMaintenance']}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          Text(
                            'Tap for details',
                            style: TextStyle(
                              fontSize: 11,
                              color: (sensor['color'] as Color).withOpacity(
                                0.6,
                              ),
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Historical Data Chart
        const SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sensor Trends (Last 24 Hours)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 22),
                            const FlSpot(4, 23),
                            const FlSpot(8, 21),
                            const FlSpot(12, 24),
                            const FlSpot(16, 22),
                            const FlSpot(20, 23),
                            const FlSpot(24, 22),
                          ],
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 45),
                            const FlSpot(4, 48),
                            const FlSpot(8, 42),
                            const FlSpot(12, 50),
                            const FlSpot(16, 47),
                            const FlSpot(20, 45),
                            const FlSpot(24, 45),
                          ],
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 12, height: 12, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Temperature (°C)'),
                    const SizedBox(width: 20),
                    Container(width: 12, height: 12, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('Humidity (%)'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSensorDetails(
    BuildContext context,
    Map<String, dynamic> sensor,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${data['label']} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sensor: ${sensor['category']}'),
            Text('Current Value: ${data['value']}'),
            Text('Status: ${data['status']}'),
            Text('Trend: ${data['trend']}'),
            const SizedBox(height: 16),
            const Text(
              'Recommended Actions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Check sensor calibration'),
            const Text('• Review maintenance schedule'),
            const Text('• Contact maintenance team if issue persists'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement report issue functionality
            },
            child: const Text('Report Issue'),
          ),
        ],
      ),
    );
  }

  void _showInfrastructureDetails(
    BuildContext context,
    Map<String, dynamic> sensor,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: (sensor['color'] as Color).withOpacity(0.2),
              child: Icon(
                sensor['icon'] as IconData,
                color: sensor['color'] as Color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${sensor['category']} Details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Overview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sensor['status'] == 'Critical'
                      ? Colors.red.withOpacity(0.1)
                      : sensor['status'] == 'Warning'
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      sensor['status'] == 'Critical'
                          ? Icons.warning_amber_rounded
                          : sensor['status'] == 'Warning'
                          ? Icons.info_outline
                          : Icons.check_circle,
                      color: sensor['status'] == 'Critical'
                          ? Colors.red
                          : sensor['status'] == 'Warning'
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${sensor['status']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: sensor['status'] == 'Critical'
                            ? Colors.red
                            : sensor['status'] == 'Warning'
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Maintenance Info
              const Text(
                'Maintenance Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.history, size: 16, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text('Last: ${sensor['lastMaintenance']}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text('Next: ${sensor['nextMaintenance']}'),
                ],
              ),
              const SizedBox(height: 16),

              // Sensor Data
              const Text(
                'Sensor Readings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate((sensor['data'] as List).length, (i) {
                final d = (sensor['data'] as List)[i] as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: d['alert'] == true
                        ? Colors.red.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: d['alert'] == true
                        ? Border.all(color: Colors.red.withOpacity(0.2))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            d['status'] == 'Good'
                                ? Icons.check_circle
                                : d['status'] == 'Normal'
                                ? Icons.radio_button_checked
                                : Icons.error,
                            color: d['status'] == 'Good'
                                ? Colors.green
                                : d['status'] == 'Normal'
                                ? Colors.blueGrey
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              d['label'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            d['value'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: d['alert'] == true
                                  ? Colors.red
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            d['trend'] == 'increasing'
                                ? Icons.trending_up
                                : d['trend'] == 'decreasing'
                                ? Icons.trending_down
                                : Icons.trending_flat,
                            color: d['trend'] == 'increasing'
                                ? Colors.red
                                : d['trend'] == 'decreasing'
                                ? Colors.green
                                : Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Trend: ${d['trend']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          if (d['alert'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ALERT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement maintenance request
                      },
                      icon: const Icon(Icons.build),
                      label: const Text('Request Maintenance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement sensor calibration
                      },
                      icon: const Icon(Icons.tune),
                      label: const Text('Calibrate Sensors'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
