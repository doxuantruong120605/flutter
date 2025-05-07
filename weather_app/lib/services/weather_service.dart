import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = 'b07a09c00d80f8971bdd6549757642ca';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';
  static const String _geoUrl = 'https://api.openweathermap.org/geo/1.0/direct';

  Future<List<WeatherModel>> getWeatherByLocation(String locationName) async {
    try {
      // Get coordinates from location name
      final geoResponse = await http.get(
        Uri.parse('$_geoUrl?q=$locationName&limit=1&appid=$_apiKey'),
      );

      if (geoResponse.statusCode != 200) {
        throw Exception('Failed to geocode location: ${geoResponse.statusCode} - ${geoResponse.body}');
      }

      final geoData = jsonDecode(geoResponse.body);
      if (geoData.isEmpty) {
        throw Exception('Location not found: $locationName');
      }

      final lat = geoData[0]['lat'] as double;
      final lon = geoData[0]['lon'] as double;

      // Get weather forecast
      final weatherResponse = await http.get(
        Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
      );

      if (weatherResponse.statusCode == 200) {
        final data = jsonDecode(weatherResponse.body);
        if (data['cod'] != null && data['cod'].toString() != '200') {
          throw Exception('API error: ${data['message']} (Code: ${data['cod']})');
        }
        if (data['list'] == null) {
          throw Exception('No forecast data available in response');
        }
        final hourly = data['list'] as List<dynamic>;
        return hourly
            .take(24)
            .map((item) => WeatherModel.fromJson(item as Map<String, dynamic>, locationName))
            .toList();
      } else {
        throw Exception('Failed to load weather data: ${weatherResponse.statusCode} - ${weatherResponse.body}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }
}