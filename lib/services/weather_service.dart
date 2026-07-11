import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// تفسير رمز حالة الطقس القياسي (WMO) إلى وصف وأيقونة مناسبة.
class WeatherCondition {
  final String descriptionAr;
  final String descriptionEn;
  final IconData icon;
  const WeatherCondition(this.descriptionAr, this.descriptionEn, this.icon);
}

WeatherCondition weatherConditionFor(int code) {
  if (code == 0) return const WeatherCondition('صافٍ', 'Clear sky', Icons.wb_sunny);
  if (code == 1) return const WeatherCondition('صافٍ غالبًا', 'Mainly clear', Icons.wb_sunny);
  if (code == 2) return const WeatherCondition('غائم جزئيًا', 'Partly cloudy', Icons.wb_cloudy);
  if (code == 3) return const WeatherCondition('غائم', 'Overcast', Icons.cloud);
  if (code == 45 || code == 48) return const WeatherCondition('ضباب', 'Fog', Icons.foggy);
  if (code >= 51 && code <= 57) {
    return const WeatherCondition('رذاذ خفيف', 'Drizzle', Icons.grain);
  }
  if (code >= 61 && code <= 67) {
    return const WeatherCondition('أمطار', 'Rain', Icons.water_drop);
  }
  if (code >= 71 && code <= 77) {
    return const WeatherCondition('ثلوج', 'Snow', Icons.ac_unit);
  }
  if (code >= 80 && code <= 82) {
    return const WeatherCondition('زخات مطر', 'Rain showers', Icons.water_drop);
  }
  if (code == 85 || code == 86) {
    return const WeatherCondition('زخات ثلج', 'Snow showers', Icons.ac_unit);
  }
  if (code >= 95) {
    return const WeatherCondition('عاصفة رعدية', 'Thunderstorm', Icons.thunderstorm);
  }
  return const WeatherCondition('غير معروف', 'Unknown', Icons.help_outline);
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });
}

class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final DateTime sunrise;
  final DateTime sunset;
  final List<DailyForecast> daily;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
    required this.daily,
  });
}

/// خدمة طقس حقيقية عبر Open-Meteo (مجانية بالكامل، بدون أي مفتاح API).
class WeatherService {
  WeatherService._internal();
  static final WeatherService instance = WeatherService._internal();

  Future<WeatherData?> fetchNablusWeather() async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=32.2211&longitude=35.2608'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code,sunrise,sunset'
        '&timezone=auto',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = json.decode(res.body);
      final current = data['current'];
      final daily = data['daily'];

      final dailyTimes = List<String>.from(daily['time']);
      final dailyMax = List<num>.from(daily['temperature_2m_max']);
      final dailyMin = List<num>.from(daily['temperature_2m_min']);
      final dailyCode = List<num>.from(daily['weather_code']);

      return WeatherData(
        temperature: (current['temperature_2m'] as num).toDouble(),
        feelsLike: (current['apparent_temperature'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        sunrise: DateTime.parse(daily['sunrise'][0]),
        sunset: DateTime.parse(daily['sunset'][0]),
        daily: List.generate(
          dailyTimes.length,
          (i) => DailyForecast(
            date: DateTime.parse(dailyTimes[i]),
            maxTemp: dailyMax[i].toDouble(),
            minTemp: dailyMin[i].toDouble(),
            weatherCode: dailyCode[i].toInt(),
          ),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
