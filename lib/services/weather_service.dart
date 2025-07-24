import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const String _apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Weather?> getCurrentWeather(double lat, double lon) async {
    final url = Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    }
    return null;
  }

  Future<List<Weather>> get7DayForecast(double lat, double lon) async {
    final url = Uri.parse('$_baseUrl/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,alerts,current&units=metric&appid=$_apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List daily = data['daily'] ?? [];
      return daily.map((e) => Weather.fromJson(e)).toList();
    }
    return [];
  }
} 