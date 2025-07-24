import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/responsive_utils.dart';

class WaterInsightsScreen extends StatefulWidget {
  const WaterInsightsScreen({super.key});

  @override
  State<WaterInsightsScreen> createState() => _WaterInsightsScreenState();
}

class _WaterInsightsScreenState extends State<WaterInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 1; // 0: Day, 1: Week, 2: Month

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Insights'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Quality'),
            Tab(text: 'Usage'),
            Tab(text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildQualityTab(), _buildUsageTab(), _buildCommunityTab()],
      ),
    );
  }

  Widget _buildQualityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQualityOverview(),
        const SizedBox(height: 24),
        _buildQualityTrends(),
        const SizedBox(height: 24),
        _buildRiskAssessment(),
      ],
    );
  }

  Widget _buildQualityOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Water Quality',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQualityIndicator(
                    'pH Level',
                    '7.2',
                    'Normal',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildQualityIndicator(
                    'Turbidity',
                    '0.5 NTU',
                    'Excellent',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildQualityIndicator(
                    'Chlorine',
                    '1.2 mg/L',
                    'Good',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityIndicator(
    String title,
    String value,
    String status,
    Color color,
  ) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQualityTrends() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quality Trends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(
                  height: 32,
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Day')),
                      ButtonSegment(value: 1, label: Text('Week')),
                      ButtonSegment(value: 2, label: Text('Month')),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() => _selectedPeriod = newSelection.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
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
                              value.toStringAsFixed(1),
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
                            String label;
                            switch (_selectedPeriod) {
                              case 0: // Day
                                label = '${index * 4}h';
                                break;
                              case 1: // Week
                                final day = DateTime.now().subtract(
                                  Duration(days: 6 - index),
                                );
                                label = '${day.day}/${day.month}';
                                break;
                              case 2: // Month
                                label = 'W${index + 1}';
                                break;
                              default:
                                label = '';
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            );
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
                    minX: 0,
                    maxX: 6,
                    minY: 7.0,
                    maxY: 7.6,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(7, (index) {
                          return FlSpot(index.toDouble(), 7.0 + index * 0.1);
                        }),
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessment() {
    return Card(
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
            _buildRiskItem(
              'Contamination Risk',
              'Low',
              Colors.green,
              'Based on current quality metrics',
            ),
            const SizedBox(height: 12),
            _buildRiskItem(
              'Supply Risk',
              'Medium',
              Colors.orange,
              'Due to upcoming maintenance',
            ),
            const SizedBox(height: 12),
            _buildRiskItem(
              'Infrastructure Risk',
              'Low',
              Colors.green,
              'All systems operating normally',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskItem(
    String title,
    String level,
    Color color,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            level,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUsageStats(),
        const SizedBox(height: 24),
        _buildUsageBreakdown(),
        const SizedBox(height: 24),
        _buildConservationTips(),
      ],
    );
  }

  Widget _buildUsageStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Daily Average',
                    '2,500L',
                    Icons.water_drop,
                    Colors.blue,
                    '+5% vs last week',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Peak Usage',
                    '350L/h',
                    Icons.show_chart,
                    Colors.orange,
                    '8-9 AM today',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildUsageCategory('Domestic', 0.45, Colors.blue, '1,125L/day'),
            const SizedBox(height: 12),
            _buildUsageCategory('Agriculture', 0.30, Colors.green, '750L/day'),
            const SizedBox(height: 12),
            _buildUsageCategory('Commercial', 0.25, Colors.orange, '625L/day'),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCategory(
    String category,
    double percentage,
    Color color,
    String amount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category),
            Text(amount, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildConservationTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conservation Tips',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Show all tips
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipCard(
              'Fix Leaking Taps',
              'A dripping tap can waste more than 20,000L per year',
              Icons.build,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildTipCard(
              'Harvest Rainwater',
              'Use rainwater for gardening and cleaning',
              Icons.water,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildTipCard(
              'Efficient Irrigation',
              'Water plants early morning or late evening',
              Icons.grass,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCommunityStats(),
        const SizedBox(height: 24),
        _buildLeaderboard(),
        const SizedBox(height: 24),
        _buildCommunityEvents(),
      ],
    );
  }

  Widget _buildCommunityStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Impact',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildImpactStat(
                    'Water Saved',
                    '25,000L',
                    'This month',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImpactStat(
                    'Issues Fixed',
                    '15',
                    'This month',
                    Icons.build,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImpactStat(
                    'Active Users',
                    '250',
                    'This week',
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactStat(
    String title,
    String value,
    String period,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        Text(
          period,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conservation Leaders',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Show full leaderboard
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLeaderboardItem(
              'Block A Community',
              '2,500L saved',
              1,
              Colors.amber,
            ),
            const SizedBox(height: 12),
            _buildLeaderboardItem(
              'Green Gardens',
              '2,100L saved',
              2,
              Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            _buildLeaderboardItem(
              'Water Warriors',
              '1,800L saved',
              3,
              Colors.brown.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
    String name,
    String achievement,
    int rank,
    Color medalColor,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle),
          child: Center(
            child: Text(
              rank.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                achievement,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right),
      ],
    );
  }

  Widget _buildCommunityEvents() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              'Community Cleanup',
              'Join us in cleaning the local water sources',
              'Mar 20, 9:00 AM',
              '25 participants',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildEventCard(
              'Water Conservation Workshop',
              'Learn water-saving techniques',
              'Mar 25, 2:00 PM',
              '15 participants',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String description,
    String datetime,
    String participants,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: color),
              const SizedBox(width: 4),
              Text(datetime, style: TextStyle(color: color, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.people, size: 16, color: color),
              const SizedBox(width: 4),
              Text(participants, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
