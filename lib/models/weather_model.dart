import 'package:intl/intl.dart';

class WeatherModel {
  final String city;
  final String country;
  final String region;
  final String condition;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windKph;
  final double pressureMb;
  final double uv;
  final bool isDay;
  final String icon;
  final String sunrise;
  final String sunset;
  final double rainfall;
  final int airQuality;
  final List<ForecastHour> hourly;
  final List<ForecastDay> daily;

  WeatherModel({
    required this.city,
    required this.country,
    required this.region,
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windKph,
    required this.pressureMb,
    required this.uv,
    required this.isDay,
    required this.icon,
    required this.sunrise,
    required this.sunset,
    required this.rainfall,
    required this.airQuality,
    required this.hourly,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final forecastList = json['forecast']['forecastday'] as List;

    return WeatherModel(
      city: json['location']['name'],
      country: json['location']['country'],
      region: json['location']['region'],
      temperature: json['current']['temp_c'].toDouble(),
      feelsLike: json['current']['feelslike_c'].toDouble(),
      humidity: json['current']['humidity'],
      windKph: json['current']['wind_kph'].toDouble(),
      pressureMb: json['current']['pressure_mb'].toDouble(),
      uv: json['current']['uv'].toDouble(),
      isDay: json['current']['is_day'] == 1,
      condition: json['current']['condition']['text'],
      icon: json['current']['condition']['icon'],
      sunrise: forecastList[0]['astro']['sunrise'],
      sunset: forecastList[0]['astro']['sunset'],
      rainfall: json['current']['precip_mm'].toDouble(),
      airQuality: json['current']['air_quality']?['pm2_5']?.round() ?? 0,
      hourly: List<ForecastHour>.from(
        forecastList[0]['hour'].map((h) => ForecastHour.fromJson(h)).take(8),
      ),
      daily: forecastList.map((d) => ForecastDay.fromJson(d)).toList(),
    );
  }
}

class ForecastHour {
  final String time;
  final double tempC;
  final String icon;

  ForecastHour({
    required this.time,
    required this.tempC,
    required this.icon,
  });

  factory ForecastHour.fromJson(Map<String, dynamic> json) {
    return ForecastHour(
      time: json['time'].substring(11), // '2024-07-23 15:00' → '15:00'
      tempC: json['temp_c'].toDouble(),
      icon: json['condition']['icon'],
    );
  }
}

class ForecastDay {
  final String date;
  final String dayName;
  final double minTemp;
  final double maxTemp;
  final String icon;

  ForecastDay({
    required this.date,
    required this.dayName,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final parsedDate = DateTime.parse(json['date']);
    return ForecastDay(
      date: json['date'],
      dayName: DateFormat('EEEE').format(parsedDate),
      minTemp: json['day']['mintemp_c'].toDouble(),
      maxTemp: json['day']['maxtemp_c'].toDouble(),
      icon: json['day']['condition']['icon'],
    );
  }
}
