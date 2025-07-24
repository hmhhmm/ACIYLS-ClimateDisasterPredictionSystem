class Weather {
  final DateTime dateTime;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final int humidity;
  final double rainfall;
  final String condition;
  final String icon;

  Weather({
    required this.dateTime,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.rainfall,
    required this.condition,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
      temperature: (json['main']?['temp'] ?? json['temp'] ?? 0).toDouble(),
      minTemperature: (json['main']?['temp_min'] ?? json['temp_min'] ?? 0).toDouble(),
      maxTemperature: (json['main']?['temp_max'] ?? json['temp_max'] ?? 0).toDouble(),
      humidity: (json['main']?['humidity'] ?? json['humidity'] ?? 0).toInt(),
      rainfall: (json['rain']?['1h'] ?? json['rain']?['3h'] ?? 0).toDouble(),
      condition: (json['weather'] != null && json['weather'].isNotEmpty)
          ? json['weather'][0]['main']
          : 'Unknown',
      icon: (json['weather'] != null && json['weather'].isNotEmpty)
          ? json['weather'][0]['icon']
          : '',
    );
  }
} 