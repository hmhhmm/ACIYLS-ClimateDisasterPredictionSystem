import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'risk_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final String location = 'Kuala Lumpur, Malaysia';
  final DateTime now = DateTime.now();
  final mockWeather = {
    'icon': '10d',
    'temperature': 28.5,
    'minTemperature': 25.0,
    'maxTemperature': 32.0,
    'condition': 'Rainy',
    'humidity': 88,
    'rainfall': 12.5,
  };
  // Forecast starts from today, then next 6 days
  List<Map<String, dynamic>> get orderedForecast {
    final List<Map<String, dynamic>> base = [
      {'icon': '10d', 'temp': 28, 'min': 25, 'max': 32},
      {'icon': '01d', 'temp': 30, 'min': 27, 'max': 33},
      {'icon': '01d', 'temp': 32, 'min': 29, 'max': 35},
      {'icon': '02d', 'temp': 31, 'min': 28, 'max': 34},
      {'icon': '09d', 'temp': 27, 'min': 24, 'max': 29},
      {'icon': '10d', 'temp': 26, 'min': 23, 'max': 28},
      {'icon': '10d', 'temp': 25, 'min': 22, 'max': 27},
    ];
    return List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      final day = i == 0 ? 'Today' : DateFormat('E').format(date);
      return {
        'day': day,
        'icon': base[i]['icon'],
        'temp': base[i]['temp'],
        'min': base[i]['min'],
        'max': base[i]['max'],
      };
    });
  }

  // Multiple demo risks
  final List<Map<String, dynamic>> demoRisks = [
    {
      'type': 'Flood',
      'icon': Icons.water,
      'color': Color(0xFFD32F2F),
      'riskLevel': 0.85,
      'description':
          'High flood risk due to heavy rainfall expected this week.',
    },
    {
      'type': 'Typhoon',
      'icon': Icons.air,
      'color': Color(0xFF1976D2),
      'riskLevel': 0.65,
      'description':
          'Moderate typhoon risk: strong winds and heavy rain possible.',
    },
    {
      'type': 'Heatwave',
      'icon': Icons.wb_sunny,
      'color': Color(0xFFFFA000),
      'riskLevel': 0.55,
      'description':
          'Heatwave risk: high temperatures expected for several days.',
    },
    {
      'type': 'Drought',
      'icon': Icons.grass,
      'color': Color(0xFF388E3C),
      'riskLevel': 0.30,
      'description': 'Low drought risk: rainfall is near normal.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3ECF7), Color(0xFFB0C4DE)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // Extra space for notch
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222B45),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(now),
                  style: const TextStyle(
                    color: Color(0xFF6B7A8F),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: const Color(0xFF3A5A98),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Image.network(
                          'https://openweathermap.org/img/wn/${mockWeather['icon']}@2x.png',
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.cloud,
                                size: 60,
                                color: Colors.white54,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${mockWeather['temperature']}°C',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${mockWeather['condition']}',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Min: ${mockWeather['minTemperature']}°  Max: ${mockWeather['maxTemperature']}°',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Humidity: ${mockWeather['humidity']}%',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Rain: ${mockWeather['rainfall']} mm',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  '7-Day Forecast',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A5A98),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: orderedForecast.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final w = orderedForecast[i];
                      return Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 4,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                '${w['day']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF3A5A98),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Image.network(
                              'https://openweathermap.org/img/wn/${w['icon']}.png',
                              width: 22,
                              height: 22,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.cloud,
                                    size: 22,
                                    color: Colors.blueGrey,
                                  ),
                            ),
                            Flexible(
                              child: Text(
                                '${w['temp']}°',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF222B45),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Min: ${w['min']}°',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6B7A8F),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Max: ${w['max']}°',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6B7A8F),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                // Multiple climate risks
                ...demoRisks.map(
                  (risk) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RiskDetailScreen(
                              type: risk['type'],
                              description: risk['description'],
                              color: _getRiskCardColor(risk['type']),
                              icon: risk['icon'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        color: _getRiskCardColor(risk['type']),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(risk['icon'], color: Colors.white, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          risk['type'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Tooltip(
                                          message:
                                              'Risk is calculated based on 7-day weather trends.',
                                          child: Icon(
                                            Icons.info_outline,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      risk['description'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: LinearProgressIndicator(
                                        value: risk['riskLevel'],
                                        color: Colors.white,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.3),
                                      ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRiskCardColor(String type) {
    switch (type) {
      case 'Flood':
        return const Color(0xFFE57373); // Light red
      case 'Typhoon':
        return const Color(0xFF64B5F6); // Light blue
      case 'Heatwave':
        return const Color(0xFFFFB74D); // Light orange
      case 'Drought':
        return const Color(0xFF81C784); // Light green
      default:
        return Colors.grey.shade300;
    }
  }
}
