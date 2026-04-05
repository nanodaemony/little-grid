import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 天气服务
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1';
  static const String _geoUrl = 'https://geocoding-api.open-meteo.com/v1';

  /// 搜索城市
  static Future<List<City>> searchCity(String query) async {
    if (query.isEmpty) return [];

    final encodedQuery = Uri.encodeQueryComponent(query);
    final response = await http.get(
      Uri.parse('$_geoUrl/search?name=$encodedQuery&count=10&language=zh&format=json'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List?;
      if (results == null) return [];

      return results.map((e) => City.fromJson(e)).toList();
    }
    throw Exception('搜索城市失败: HTTP ${response.statusCode}');
  }

  /// 获取天气数据
  static Future<WeatherData> getWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=4',
      ),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    }
    throw Exception('获取天气失败');
  }

  /// 反向地理编码：根据坐标获取城市信息
  static Future<City?> getCityFromCoordinates(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_geoUrl/get?latitude=$lat&longitude=$lon&language=zh'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['name'] != null) {
        return City.fromJson(data);
      }
    }
    return null;
  }
}

/// 城市数据
class City {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;

  City({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0,
      longitude: json['longitude']?.toDouble() ?? 0,
      country: json['country'],
      admin1: json['admin1'],
    );
  }

  String get displayName {
    final parts = [name];
    if (admin1 != null) parts.add(admin1!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }
}

/// 天气数据
class WeatherData {
  final CurrentWeather current;
  final List<DailyWeather> daily;

  WeatherData({required this.current, required this.daily});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      current: CurrentWeather.fromJson(json['current']),
      daily: (json['daily'] as Map<String, dynamic>)
          .toDailyList()
          .skip(1) // 跳过今天
          .take(3) // 只取未来3天
          .toList(),
    );
  }
}

/// 当前天气
class CurrentWeather {
  final double temperature;
  final int humidity;
  final int weatherCode;
  final double windSpeed;

  CurrentWeather({
    required this.temperature,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: json['temperature_2m']?.toDouble() ?? 0,
      humidity: json['relative_humidity_2m']?.toInt() ?? 0,
      weatherCode: json['weather_code']?.toInt() ?? 0,
      windSpeed: json['wind_speed_10m']?.toDouble() ?? 0,
    );
  }
}

/// 每日天气
class DailyWeather {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;

  DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
  });
}

/// 扩展方法：转换每日数据
extension on Map<String, dynamic> {
  List<DailyWeather> toDailyList() {
    final times = this['time'] as List;
    final codes = this['weather_code'] as List;
    final maxTemps = this['temperature_2m_max'] as List;
    final minTemps = this['temperature_2m_min'] as List;

    return List.generate(times.length, (i) {
      return DailyWeather(
        date: DateTime.parse(times[i]),
        weatherCode: codes[i],
        maxTemp: maxTemps[i].toDouble(),
        minTemp: minTemps[i].toDouble(),
      );
    });
  }
}

/// 天气代码转图标和描述
class WeatherCode {
  static (IconData, String) getInfo(int code) {
    // 晴
    if (code == 0) return (Icons.wb_sunny, '晴');
    // 多云
    if (code >= 1 && code <= 3) return (Icons.wb_cloudy, '多云');
    // 雾
    if (code == 45 || code == 48) return (Icons.cloud, '雾');
    // drizzle
    if (code >= 51 && code <= 55) return (Icons.grain, '毛毛雨');
    // 雨
    if (code >= 61 && code <= 67) return (Icons.water_drop, '雨');
    // 雪
    if (code >= 71 && code <= 77) return (Icons.ac_unit, '雪');
    // 阵雨
    if (code >= 80 && code <= 82) return (Icons.thunderstorm, '阵雨');
    // 雷雨
    if (code >= 95) return (Icons.flash_on, '雷雨');
    // 默认
    return (Icons.cloud_queue, '多云');
  }
}
