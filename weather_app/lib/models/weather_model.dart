class WeatherModel {
  final DateTime time;
  final double temperature;
  final String icon;
  final String location;

  WeatherModel({
    required this.time,
    required this.temperature,
    required this.icon,
    required this.location,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String location) {
    return WeatherModel(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true).toLocal(),
      temperature: (json['main']['temp'] as num).toDouble(),
      icon: json['weather'][0]['icon'] as String,
      location: location,
    );
  }
}