import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  List<WeatherModel>? _weatherData;
  bool _isLoading = false;
  String? _error;
  String _location = 'Hanoi'; // Default location

  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _weatherService.getWeatherByLocation(_location);
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _searchLocation() {
    setState(() {
      _location = _locationController.text.trim();
    });
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Weather Forecast'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Enter location (e.g., Hanoi, London)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchLocation,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _error != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  '$_error',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchWeather,
                                child: const Text('Retry'),
                              ),
                            ],
                          )
                        : _weatherData == null || _weatherData!.isEmpty
                            ? const Text('No data available')
                            : ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: _weatherData!.length,
                                itemBuilder: (context, index) {
                                  final weather = _weatherData![index];
                                  return Card(
                                    child: ListTile(
                                      leading: Image.network(
                                        'http://openweathermap.org/img/wn/${weather.icon}@2x.png',
                                        width: 50,
                                        height: 50,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.error),
                                      ),
                                      title: Text(
                                        '${weather.time.hour.toString().padLeft(2, '0')}:00 - ${weather.temperature.toStringAsFixed(1)}°C - ${weather.location}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        weather.time.toString().substring(0, 16),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}