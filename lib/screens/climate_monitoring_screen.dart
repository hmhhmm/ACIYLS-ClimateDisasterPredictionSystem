import 'package:flutter/material.dart';
import '../models/climate_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class WeatherColors {
  static const Color primary = Color(0xFFF2F2F7);
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _downloadCsv(String title, List<double> values) {
    // For web, use AnchorElement; for mobile, use share package (not implemented here)
    final csv = StringBuffer();
    csv.writeln('Index,Value');
    for (int i = 0; i < values.length; i++) {
      csv.writeln('$i,${values[i]}');
    }
    // For web only:
    // ignore: undefined_prefixed_name
    // import 'dart:html' as html;
    // final blob = html.Blob([csv.toString()]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.AnchorElement(href: url)
    //   ..setAttribute('download', '$title.csv')
    //   ..click();
    // html.Url.revokeObjectUrl(url);
    // For now, just show a dialog with CSV text
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

  Widget _buildCommunityTrendsChart() {
    // Count reports per day for the selected range
    int len = _getTrendLen();
    final data = _historicalData.take(len).toList();
    final reportCounts = List<int>.filled(len, 0);
    for (int i = 0; i < data.length; i++) {
      final date = data[i].timestamp;
      reportCounts[i] = _communityHazardReports
          .where((r) => DateTime.parse(r['timestamp'] ?? '') == date)
          .length;
    }
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Reports Trend',
              style: Theme.of(context).textTheme.titleLarge,
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
            Text('Number of community hazard reports per day'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WeatherColors.primary,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Climate Monitoring'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Trends'),
              Tab(text: 'Alerts'),
              Tab(text: 'Risk Map'),
              Tab(text: 'Prediction'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Overview Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderCard(),
                _buildCurrentConditions(),
                const SizedBox(height: 8),
                _buildRiskAssessment(),
                const SizedBox(height: 8),
                _buildActiveAlerts(),
              ],
            ),
            // Trends Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Time range selector
                Row(
                  children: [
                    const Text('Time Range: '),
                    DropdownButton<String>(
                      value: _trendRange,
                      items: const [
                        DropdownMenuItem(value: '7d', child: Text('7 days')),
                        DropdownMenuItem(value: '30d', child: Text('30 days')),
                        DropdownMenuItem(value: '1y', child: Text('1 year')),
                      ],
                      onChanged: (v) =>
                          setState(() => _trendRange = v ?? '30d'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Summary/insight section
                Card(
                  color: Colors.blue.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
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
                // Rainfall Trend with historical average overlay and anomaly
                _buildMetricTrendWithAverage(
                  'Rainfall',
                  _historicalData
                      .take(_getTrendLen())
                      .map((d) => d.rainfall)
                      .toList(),
                  _getHistoricalAverageList('rainfall'),
                  Colors.blue,
                  'mm',
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      tooltip: 'Download CSV',
                      onPressed: () => _downloadCsv(
                        'Rainfall',
                        _historicalData
                            .take(_getTrendLen())
                            .map((d) => d.rainfall)
                            .toList(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: 'Share Chart',
                      onPressed: () =>
                          _shareChartPlaceholder(context, 'Rainfall'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildAnomalyChart(
                  'Rainfall Anomaly',
                  _historicalData
                      .take(_getTrendLen())
                      .map((d) => d.rainfall)
                      .toList(),
                  _getHistoricalAverageList('rainfall'),
                  Colors.blue,
                  'mm',
                ),
                const SizedBox(height: 8),
                // Temperature Trend with historical average overlay and anomaly
                _buildMetricTrendWithAverage(
                  'Temperature',
                  _historicalData
                      .take(_getTrendLen())
                      .map((d) => d.temperature)
                      .toList(),
                  _getHistoricalAverageList('temperature'),
                  Colors.red,
                  '°C',
                ),
                const SizedBox(height: 8),
                _buildAnomalyChart(
                  'Temperature Anomaly',
                  _historicalData
                      .take(_getTrendLen())
                      .map((d) => d.temperature)
                      .toList(),
                  _getHistoricalAverageList('temperature'),
                  Colors.red,
                  '°C',
                ),
                // Rainfall Trend with event markers and projection
                _buildMetricTrendWithEventsAndProjection(
                  'Rainfall',
                  _historicalData
                      .take(_getTrendLen())
                      .map((d) => d.rainfall)
                      .toList(),
                  _getHistoricalAverageList('rainfall'),
                  Colors.blue,
                  'mm',
                  _getEventMarkers('Flood'),
                  _getProjectionList(
                    _historicalData
                        .take(_getTrendLen())
                        .map((d) => d.rainfall)
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Temperature Trend with projection
                _buildMetricTrendWithEventsAndProjection(
                  'Temperature',
                  _historicalData
                      .take(_getTrendLen())
                      .map((d) => d.temperature)
                      .toList(),
                  _getHistoricalAverageList('temperature'),
                  Colors.red,
                  '°C',
                  [],
                  _getProjectionList(
                    _historicalData
                        .take(_getTrendLen())
                        .map((d) => d.temperature)
                        .toList(),
                  ),
                ),
                // Community Trends Chart
                _buildCommunityTrendsChart(),
                const SizedBox(height: 8),
                // ... (community trends, download/share, etc. will follow) ...
              ],
            ),
            // Alerts Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [_buildActiveAlerts()],
            ),
            // Risk Map Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [_buildRiskMapTab()],
            ),
            // Risk Prediction Tab
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 420),
                child: Card(
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shield,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Risk Prediction',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildPredictionSection(
                            'Rule-based Prediction',
                            Icons.rule,
                            _buildRuleBasedChips(),
                            'This section uses simple rules based on rainfall and soil moisture.',
                          ),
                          SizedBox(height: 12),
                          _buildPredictionSection(
                            'Forecast (7-day avg)',
                            Icons.cloud,
                            _buildForecastChips(),
                            'This section uses a 7-day moving average of rainfall and temperature.',
                          ),
                          SizedBox(height: 12),
                          _buildPredictionSection(
                            'ML Model (mock)',
                            Icons.smart_toy,
                            _buildMLChips(),
                            'This section shows a mock machine learning prediction.',
                          ),
                          SizedBox(height: 12),
                          _buildPredictionSection(
                            'Community Reports',
                            Icons.people,
                            _buildCommunityChips(),
                            'This section summarizes recent community hazard reports.',
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.science,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Scenario Simulation:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: _buildScenarioSelector(
                              key: ValueKey(_selectedScenario),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kuala Lumpur',
              style: const TextStyle(
                color: Colors.black,
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
                    color: Colors.black,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  ' | Mostly Sunny',
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentConditions() {
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Conditions',
              style: Theme.of(context).textTheme.titleLarge,
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
        ),
      ),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRiskAssessment() {
    // Example scoring logic (replace with real data as needed)
    final floodScore =
        (_currentData.rainfall * 2 + _currentData.soilMoisture) ~/ 3;
    final droughtScore =
        (100 - _currentData.rainfall + (100 - _currentData.soilMoisture)) ~/ 2;
    String floodLevel;
    String droughtLevel;
    Color floodColor;
    Color droughtColor;
    String floodRecommendation;
    String droughtRecommendation;

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

    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Assessment',
              style: Theme.of(context).textTheme.titleLarge,
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
        ),
      ),
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
                    style: const TextStyle(fontWeight: FontWeight.w500),
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

  Widget _buildActiveAlerts() {
    if (_currentData.activeAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Alerts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    _tabController.animateTo(3); // Switch to Alerts tab
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
                    Expanded(child: Text(alert)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskTrendChart(String title, List<double> scores, Color color) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
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
                          if (index % 5 == 0 && index < scores.length) {
                            final date = _historicalData[index].timestamp;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(
                                  color: Colors.grey,
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
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature Trend',
              style: Theme.of(context).textTheme.titleLarge,
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
                                style: const TextStyle(
                                  color: Colors.grey,
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
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rainfall Distribution',
              style: Theme.of(context).textTheme.titleLarge,
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
                                style: const TextStyle(
                                  color: Colors.grey,
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
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Table Level',
              style: Theme.of(context).textTheme.titleLarge,
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
                                style: const TextStyle(
                                  color: Colors.grey,
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
    return Stack(
      children: [
        Card(
          color: Colors.white.withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (kIsWeb) {
                    return SizedBox(
                      height: 400,
                      child: fmap.FlutterMap(
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
                            markers: [
                              fmap.Marker(
                                width: 40,
                                height: 40,
                                point: latlong.LatLng(1.301, 103.800),
                                child: Tooltip(
                                  message: 'Flood Risk Zone',
                                  child: Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                ),
                              ),
                              fmap.Marker(
                                width: 40,
                                height: 40,
                                point: latlong.LatLng(1.299, 103.805),
                                child: Tooltip(
                                  message: 'Drought Risk Zone',
                                  child: Icon(
                                    Icons.water_drop,
                                    color: Colors.orange,
                                    size: 36,
                                  ),
                                ),
                              ),
                              // Community hazard report markers
                              ..._communityHazardReports.map(
                                (report) => fmap.Marker(
                                  width: 40,
                                  height: 40,
                                  point: latlong.LatLng(
                                    report['lat'],
                                    report['lng'],
                                  ),
                                  child: Tooltip(
                                    message:
                                        report['type'] +
                                        (report['description'].isNotEmpty
                                            ? ': ' + report['description']
                                            : ''),
                                    child: Icon(
                                      report['type'] == 'Flood'
                                          ? Icons.warning
                                          : report['type'] == 'Drought'
                                          ? Icons.water_drop
                                          : Icons.report,
                                      color: report['type'] == 'Flood'
                                          ? Colors.red
                                          : report['type'] == 'Drought'
                                          ? Colors.orange
                                          : Colors.blueGrey,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: 400,
                      child: gmaps.GoogleMap(
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
                          gmaps.Marker(
                            markerId: const gmaps.MarkerId('flood'),
                            position: const gmaps.LatLng(1.301, 103.800),
                            infoWindow: const gmaps.InfoWindow(
                              title: 'Flood Risk Zone',
                            ),
                            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                              gmaps.BitmapDescriptor.hueRed,
                            ),
                          ),
                          gmaps.Marker(
                            markerId: const gmaps.MarkerId('drought'),
                            position: const gmaps.LatLng(1.299, 103.805),
                            infoWindow: const gmaps.InfoWindow(
                              title: 'Drought Risk Zone',
                            ),
                            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                              gmaps.BitmapDescriptor.hueOrange,
                            ),
                          ),
                          // Community hazard report markers
                          ..._communityHazardReports.map(
                            (report) => gmaps.Marker(
                              markerId: gmaps.MarkerId(report['id']),
                              position: gmaps.LatLng(
                                report['lat'],
                                report['lng'],
                              ),
                              infoWindow: gmaps.InfoWindow(
                                title: report['type'],
                                snippet: report['description'],
                              ),
                              icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                                report['type'] == 'Flood'
                                    ? gmaps.BitmapDescriptor.hueRed
                                    : report['type'] == 'Drought'
                                    ? gmaps.BitmapDescriptor.hueOrange
                                    : gmaps.BitmapDescriptor.hueAzure,
                              ),
                            ),
                          ),
                        },
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        // Floating action button for reporting hazard
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: _showReportHazardDialog,
            icon: const Icon(Icons.add_alert),
            label: const Text('Report Hazard'),
          ),
        ),
      ],
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
              // For demo, let user enter lat/lng (in real app, use geolocation)
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

  Widget _buildRiskPredictionCard(BuildContext context) {
    // 1. Rule-based risk
    final ruleFlood =
        (_currentData.rainfall > 30 && _currentData.soilMoisture > 60)
        ? 'High'
        : (_currentData.rainfall > 15 ? 'Moderate' : 'Low');
    final ruleDrought =
        (_currentData.rainfall < 5 && _currentData.soilMoisture < 30)
        ? 'High'
        : (_currentData.rainfall < 15 ? 'Moderate' : 'Low');

    // 2. Simple moving average forecast (last 7 days)
    double avgRain =
        _historicalData.take(7).map((d) => d.rainfall).reduce((a, b) => a + b) /
        7;
    double avgTemp =
        _historicalData
            .take(7)
            .map((d) => d.temperature)
            .reduce((a, b) => a + b) /
        7;
    String forecastFlood = avgRain > 20 ? 'Likely' : 'Unlikely';
    String forecastDrought = avgRain < 8 ? 'Likely' : 'Unlikely';

    // 3. ML mock risk (random for now)
    double mlFloodProb =
        0.2 + (_currentData.rainfall / 100) + (_currentData.soilMoisture / 200);
    double mlDroughtProb =
        0.1 +
        ((100 - _currentData.rainfall) / 100) +
        ((100 - _currentData.soilMoisture) / 200);

    // 4. Community report influence
    int floodReports = _communityHazardReports
        .where((r) => r['type'] == 'Flood')
        .length;
    int droughtReports = _communityHazardReports
        .where((r) => r['type'] == 'Drought')
        .length;
    String communityFlood = floodReports > 0 ? 'Increased' : 'No effect';
    String communityDrought = droughtReports > 0 ? 'Increased' : 'No effect';

    // 5. Scenario simulation
    String scenario = _selectedScenario ?? 'Normal';
    String scenarioFlood = 'Normal';
    String scenarioDrought = 'Normal';
    if (scenario == 'Heavy Rain') scenarioFlood = 'High';
    if (scenario == 'Dry Spell') scenarioDrought = 'High';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Risk Prediction', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Rule-based Prediction:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Flood: $ruleFlood, Drought: $ruleDrought'),
        const SizedBox(height: 8),
        Text(
          'Forecast (7-day avg):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Avg Rainfall: ${avgRain.toStringAsFixed(1)} mm, Avg Temp: ${avgTemp.toStringAsFixed(1)}°C',
        ),
        Text('Flood Risk: $forecastFlood, Drought Risk: $forecastDrought'),
        const SizedBox(height: 8),
        Text('ML Model (mock):', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          'Flood Probability: ${(mlFloodProb * 100).toStringAsFixed(0)}%, Drought Probability: ${(mlDroughtProb * 100).toStringAsFixed(0)}%',
        ),
        const SizedBox(height: 8),
        Text(
          'Community Reports:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Flood: $communityFlood (${floodReports} reports), Drought: $communityDrought (${droughtReports} reports)',
        ),
        const SizedBox(height: 8),
        Text(
          'Scenario Simulation:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            DropdownButton<String>(
              value: _selectedScenario,
              items: const [
                DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                DropdownMenuItem(
                  value: 'Heavy Rain',
                  child: Text('Heavy Rain'),
                ),
                DropdownMenuItem(value: 'Dry Spell', child: Text('Dry Spell')),
              ],
              onChanged: (v) => setState(() => _selectedScenario = v),
            ),
            const SizedBox(width: 12),
            Text('Flood: $scenarioFlood, Drought: $scenarioDrought'),
          ],
        ),
      ],
    );
  }

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
    // Example: compare last 7 days avg rainfall to previous 7 days
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

  List<double> _getHistoricalAverageList(String metric) {
    // For demo, use a flat average (could be improved with real historical data)
    int len = _getTrendLen();
    double avg = 0;
    if (metric == 'rainfall') {
      avg =
          _historicalData.map((d) => d.rainfall).reduce((a, b) => a + b) /
          _historicalData.length;
    } else if (metric == 'temperature') {
      avg =
          _historicalData.map((d) => d.temperature).reduce((a, b) => a + b) /
          _historicalData.length;
    }
    return List.filled(len, avg);
  }

  Widget _buildMetricTrendWithAverage(
    String title,
    List<double> values,
    List<double> avg,
    Color color,
    String unit,
  ) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        values.length,
                        (i) => FlSpot(i.toDouble(), values[i]),
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
                    LineChartBarData(
                      spots: List.generate(
                        avg.length,
                        (i) => FlSpot(i.toDouble(), avg[i]),
                      ),
                      isCurved: false,
                      color: Colors.grey,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 16, height: 4, color: color),
                const SizedBox(width: 4),
                Text('Current'),
                const SizedBox(width: 16),
                Container(width: 16, height: 4, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Historical Avg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalyChart(
    String title,
    List<double> values,
    List<double> avg,
    Color color,
    String unit,
  ) {
    final anomaly = List.generate(values.length, (i) => values[i] - avg[i]);
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
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
                    anomaly.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: anomaly[i],
                          color: anomaly[i] >= 0 ? color : Colors.grey,
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Positive = Above Avg, Negative = Below Avg ($unit)'),
          ],
        ),
      ),
    );
  }

  List<int> _getEventMarkers(String type) {
    // Return indices of days with community reports of the given type
    int len = _getTrendLen();
    final data = _historicalData.take(len).toList();
    final eventDays = <int>[];
    for (int i = 0; i < data.length; i++) {
      final date = data[i].timestamp;
      if (_communityHazardReports.any(
        (r) =>
            r['type'] == type && DateTime.parse(r['timestamp'] ?? '') == date,
      )) {
        eventDays.add(i);
      }
    }
    return eventDays;
  }

  List<double> _getProjectionList(List<double> values) {
    // Simple projection: extend last value with the average change
    if (values.length < 2)
      return List.filled(7, values.isNotEmpty ? values.last : 0);
    double last = values.last;
    double delta = (values.last - values.first) / (values.length - 1);
    return List.generate(7, (i) => last + delta * (i + 1));
  }

  Widget _buildMetricTrendWithEventsAndProjection(
    String title,
    List<double> values,
    List<double> avg,
    Color color,
    String unit,
    List<int> eventMarkers,
    List<double> projection,
  ) {
    final totalLen = values.length + projection.length;
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title + ' (with Events & Projection)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
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
                  lineBarsData: [
                    // Current values
                    LineChartBarData(
                      spots: List.generate(
                        values.length,
                        (i) => FlSpot(i.toDouble(), values[i]),
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
                    // Historical average
                    LineChartBarData(
                      spots: List.generate(
                        avg.length,
                        (i) => FlSpot(i.toDouble(), avg[i]),
                      ),
                      isCurved: false,
                      color: Colors.grey,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Projection (dashed)
                    LineChartBarData(
                      spots: List.generate(
                        projection.length,
                        (i) => FlSpot(
                          (values.length + i).toDouble(),
                          projection[i],
                        ),
                      ),
                      isCurved: true,
                      color: color.withOpacity(0.5),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      dashArray: [6, 6],
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  // Event markers
                  extraLinesData: ExtraLinesData(
                    verticalLines: eventMarkers
                        .map(
                          (i) => VerticalLine(
                            x: i.toDouble(),
                            color: Colors.purple,
                            strokeWidth: 2,
                            dashArray: [4, 4],
                            label: VerticalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 10,
                              ),
                              labelResolver: (line) => 'Event',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(width: 16, height: 4, color: color),
                Text('Current'),
                Container(width: 16, height: 4, color: Colors.grey),
                Text('Historical Avg'),
                SizedBox(
                  width: 24,
                  height: 4,
                  child: CustomPaint(painter: _DashedLinePainter()),
                ),
                Text('Projection'),
                Container(width: 16, height: 4, color: Colors.purple),
                Text('Event'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionSection(
    String title,
    IconData icon,
    Widget content,
    String details,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            IconButton(
              icon: Icon(Icons.info_outline, size: 20),
              tooltip: 'Details',
              onPressed: () => _showDetailsDialog(title, details),
            ),
          ],
        ),
        SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildRuleBasedChips() {
    final flood = (_currentData.rainfall > 30 && _currentData.soilMoisture > 60)
        ? 'High'
        : (_currentData.rainfall > 15 ? 'Moderate' : 'Low');
    final drought =
        (_currentData.rainfall < 5 && _currentData.soilMoisture < 30)
        ? 'High'
        : (_currentData.rainfall < 15 ? 'Moderate' : 'Low');
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Row(children: [Text('Flood: '), _riskChip(flood)]),
        Row(children: [Text('Drought: '), _riskChip(drought)]),
      ],
    );
  }

  Widget _buildForecastChips() {
    double avgRain =
        _historicalData.take(7).map((d) => d.rainfall).reduce((a, b) => a + b) /
        7;
    double avgTemp =
        _historicalData
            .take(7)
            .map((d) => d.temperature)
            .reduce((a, b) => a + b) /
        7;
    String flood = avgRain > 20 ? 'Likely' : 'Unlikely';
    String drought = avgRain < 8 ? 'Likely' : 'Unlikely';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avg Rainfall: ${avgRain.toStringAsFixed(1)} mm, Avg Temp: ${avgTemp.toStringAsFixed(1)}°C',
        ),
        SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            Row(children: [Text('Flood: '), _riskChip(flood)]),
            Row(children: [Text('Drought: '), _riskChip(drought)]),
          ],
        ),
      ],
    );
  }

  Widget _buildMLChips() {
    double mlFloodProb =
        0.2 + (_currentData.rainfall / 100) + (_currentData.soilMoisture / 200);
    double mlDroughtProb =
        0.1 +
        ((100 - _currentData.rainfall) / 100) +
        ((100 - _currentData.soilMoisture) / 200);
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Row(
          children: [
            Text('Flood: '),
            _probabilityChip((mlFloodProb * 100).clamp(0, 100)),
          ],
        ),
        Row(
          children: [
            Text('Drought: '),
            _probabilityChip((mlDroughtProb * 100).clamp(0, 100)),
          ],
        ),
      ],
    );
  }

  Widget _buildCommunityChips() {
    int floodReports = _communityHazardReports
        .where((r) => r['type'] == 'Flood')
        .length;
    int droughtReports = _communityHazardReports
        .where((r) => r['type'] == 'Drought')
        .length;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Row(children: [Text('Flood: '), _reportChip(floodReports)]),
        Row(children: [Text('Drought: '), _reportChip(droughtReports)]),
      ],
    );
  }

  Widget _buildScenarioSelector({Key? key}) {
    String scenario = _selectedScenario ?? 'Normal';
    String scenarioFlood = 'Normal';
    String scenarioDrought = 'Normal';
    if (scenario == 'Heavy Rain') scenarioFlood = 'High';
    if (scenario == 'Dry Spell') scenarioDrought = 'High';
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        DropdownButton<String>(
          value: _selectedScenario,
          items: const [
            DropdownMenuItem(value: 'Normal', child: Text('Normal')),
            DropdownMenuItem(value: 'Heavy Rain', child: Text('Heavy Rain')),
            DropdownMenuItem(value: 'Dry Spell', child: Text('Dry Spell')),
          ],
          onChanged: (v) {
            setState(() => _selectedScenario = v);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Scenario changed to $v'),
                duration: Duration(milliseconds: 800),
              ),
            );
          },
          dropdownColor: Theme.of(context).cardColor,
          icon: Icon(Icons.arrow_drop_down),
        ),
        Text(
          'Flood: $scenarioFlood, Drought: $scenarioDrought',
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }

  Widget _riskChip(String level) {
    Color color = level == 'High'
        ? Colors.red
        : level == 'Moderate'
        ? Colors.orange
        : Colors.green;
    return Semantics(
      label: 'Risk level: $level',
      child: Chip(
        label: Text(level, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.symmetric(horizontal: 8),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
    );
  }

  Widget _probabilityChip(num value) {
    Color color = value > 70
        ? Colors.red
        : value > 40
        ? Colors.orange
        : Colors.green;
    return Semantics(
      label: 'Probability: ${value.toStringAsFixed(0)} percent',
      child: Chip(
        label: Text(
          '${value.toStringAsFixed(0)}%',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.symmetric(horizontal: 8),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
    );
  }

  Widget _reportChip(int count) {
    Color color = count > 0 ? Colors.red : Colors.green;
    return Semantics(
      label: 'Reports: $count',
      child: Chip(
        label: Text(
          '$count report${count == 1 ? '' : 's'}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.symmetric(horizontal: 8),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
    );
  }

  // Details dialog
  void _showDetailsDialog(String title, String details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(details),
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

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = size.height
      ..style = PaintingStyle.stroke;
    double dashWidth = 4, dashSpace = 4, startX = 0;
    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0, size.width).toDouble();
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(endX, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
