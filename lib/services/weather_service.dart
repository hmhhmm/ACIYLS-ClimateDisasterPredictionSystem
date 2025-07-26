import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  final String apiKey;
  final String baseUrl;

  WeatherService({required this.apiKey})
    : baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>?> fetchCurrentWeather(String city) async {
    final url = Uri.parse(
      '$baseUrl/weather?q=$city&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  Future<Weather?> getCurrentWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    }
    return null;
  }

  Future<List<Weather>> get7DayForecast(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,alerts,current&units=metric&appid=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final daily = data['daily'] as List;
      return daily.map((day) => Weather.fromJson(day)).toList();
    } else {
      return [];
    }
  }
}
