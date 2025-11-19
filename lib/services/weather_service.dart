import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'http://api.weatherapi.com/v1';
  static const String _apiKey = '732e9a7199da4f47a2e91756252007';

  Future<WeatherModel?> fetchWeather(String cityName) async {
    final url = Uri.parse(
      '$_baseUrl/forecast.json?key=$_apiKey&q=$cityName&days=7&aqi=yes&alerts=no',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherModel.fromJson(data);
    } else {
      print('Failed to load weather: ${response.statusCode}');
      return null;
    }
  }

  Future<List<String>> searchCities(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse('$_baseUrl/search.json?key=$_apiKey&q=$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['name'] as String).toList();
    } else {
      return [];
    }
  }
}
