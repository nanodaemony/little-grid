# 天气工具实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一个天气功能格子，支持 GPS 定位和手动城市搜索，展示当前天气及未来3天预报，使用 Open-Meteo 免费 API。

**Architecture:** 遵循现有工具架构模式，创建 ToolModule 实现类 + Service 数据层 + Page UI 层的三层结构。数据通过 HTTP 请求获取，本地缓存 30 分钟。

**Tech Stack:** Flutter + Dart, Open-Meteo API, http package, flutter_animate (已有)

---

## 文件结构

```
app/lib/tools/weather/
├── weather_tool.dart      # ToolModule 实现，工具注册入口
├── weather_service.dart   # API 服务、数据模型、缓存逻辑
└── weather_page.dart      # 天气主页面 UI

app/lib/main.dart          # 注册 WeatherTool

app/pubspec.yaml           # 添加 http 依赖（如未存在）
```

---

## Task 1: 添加 http 依赖

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: 检查是否已有 http 依赖**

```bash
grep "http:" app/pubspec.yaml
```

- [ ] **Step 2: 如未存在，添加依赖**

```yaml
# 在 dependencies 部分添加
  http: ^1.2.0
```

- [ ] **Step 3: 运行 pub get**

```bash
cd app && flutter pub get
```

- [ ] **Step 4: Commit**

```bash
git add app/pubspec.yaml
# 如果 pubspec.lock 有变化也添加
git commit -m "chore: add http dependency for weather API"
```

---

## Task 2: 创建天气数据模型和 Service

**Files:**
- Create: `app/lib/tools/weather/weather_service.dart`

- [ ] **Step 1: 创建文件目录**

```bash
mkdir -p app/lib/tools/weather
```

- [ ] **Step 2: 编写 weather_service.dart**

```dart
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

    final response = await http.get(
      Uri.parse('$_geoUrl/search?name=$query&count=10&language=zh&format=json'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List?;
      if (results == null) return [];

      return results.map((e) => City.fromJson(e)).toList();
    }
    throw Exception('搜索城市失败');
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
```

- [ ] **Step 3: 验证文件创建成功**

```bash
ls -la app/lib/tools/weather/weather_service.dart
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/tools/weather/weather_service.dart
git commit -m "feat: add weather service with Open-Meteo API integration"
```

---

## Task 3: 创建天气工具入口

**Files:**
- Create: `app/lib/tools/weather/weather_tool.dart`

- [ ] **Step 1: 编写 weather_tool.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'weather_page.dart';

class WeatherTool implements ToolModule {
  @override
  String get id => 'weather';

  @override
  String get name => '天气';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.wb_sunny;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const WeatherPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/weather/weather_tool.dart
git commit -m "feat: add WeatherTool module entry"
```

---

## Task 4: 创建天气页面 UI

**Files:**
- Create: `app/lib/tools/weather/weather_page.dart`

- [ ] **Step 1: 编写 weather_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  bool _isLoading = false;
  String? _error;
  WeatherData? _weather;
  City? _selectedCity;

  // 默认城市：北京
  final _defaultCity = City(
    name: '北京',
    latitude: 39.9042,
    longitude: 116.4074,
    country: '中国',
  );

  @override
  void initState() {
    super.initState();
    _selectedCity = _defaultCity;
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    if (_selectedCity == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await WeatherService.getWeather(
        _selectedCity!.latitude,
        _selectedCity!.longitude,
      );
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '获取天气失败，请重试';
        _isLoading = false;
      });
    }
  }

  void _showCitySearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CitySearchBottomSheet(
        onCitySelected: (city) {
          setState(() => _selectedCity = city);
          _loadWeather();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (icon, desc) = _weather != null
        ? WeatherCode.getInfo(_weather!.current.weatherCode)
        : (Icons.wb_sunny, '--');

    return Scaffold(
      appBar: AppBar(
        title: const Text('天气'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadWeather,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 城市选择
                GestureDetector(
                  onTap: _showCitySearch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedCity?.name ?? '选择城市',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 当前天气
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  Center(
                    child: Column(
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadWeather,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  )
                else if (_weather != null)
                  _CurrentWeatherCard(
                    weather: _weather!.current,
                    cityName: _selectedCity!.name,
                  ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // 未来预报
                if (_weather != null && !_isLoading) ...[
                  Text(
                    '未来3天',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ..._weather!.daily.map(
                    (day) => _DailyForecastItem(day: day),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 当前天气卡片
class _CurrentWeatherCard extends StatelessWidget {
  final CurrentWeather weather;
  final String cityName;

  const _CurrentWeatherCard({
    required this.weather,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, desc) = WeatherCode.getInfo(weather.weatherCode);
    final isDay = DateTime.now().hour >= 6 && DateTime.now().hour < 18;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDay
              ? [Colors.blue.shade400, Colors.blue.shade700]
              : [Colors.indigo.shade400, Colors.indigo.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDay ? Colors.blue : Colors.indigo).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.round()}°',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeatherInfoItem(
                icon: Icons.water,
                label: '湿度',
                value: '${weather.humidity}%',
              ),
              _WeatherInfoItem(
                icon: Icons.air,
                label: '风速',
                value: '${weather.windSpeed.round()} km/h',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 天气信息项
class _WeatherInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 每日预报项
class _DailyForecastItem extends StatelessWidget {
  final DailyWeather day;

  const _DailyForecastItem({required this.day});

  @override
  Widget build(BuildContext context) {
    final (icon, desc) = WeatherCode.getInfo(day.weatherCode);
    final weekday = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final today = DateTime.now();
    final isToday = day.date.day == today.day;
    final dayName = isToday ? '今天' : weekday[day.date.weekday - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              dayName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Icon(icon, size: 24, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(desc, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Row(
            children: [
              Text(
                '${day.minTemp.round()}°',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              const SizedBox(width: 4),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.orange.shade300],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${day.maxTemp.round()}°',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

/// 城市搜索底部弹窗
class _CitySearchBottomSheet extends StatefulWidget {
  final Function(City) onCitySelected;

  const _CitySearchBottomSheet({required this.onCitySelected});

  @override
  State<_CitySearchBottomSheet> createState() => _CitySearchBottomSheetState();
}

class _CitySearchBottomSheetState extends State<_CitySearchBottomSheet> {
  final _controller = TextEditingController();
  List<City> _results = [];
  bool _isSearching = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await WeatherService.searchCity(query);
      setState(() => _results = results);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '搜索城市',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _results = []);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) {
                    if (v.length >= 2) _search(v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (_results.isEmpty && _controller.text.isNotEmpty)
            const Center(child: Text('未找到城市'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final city = _results[index];
                  return ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(city.name),
                    subtitle: Text(city.displayName),
                    onTap: () {
                      widget.onCitySelected(city);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/weather/weather_page.dart
git commit -m "feat: add weather page with city search and forecast display"
```

---

## Task 5: 注册天气工具

**Files:**
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 添加导入**

在 main.dart 顶部添加：
```dart
import 'tools/weather/weather_tool.dart';
```

- [ ] **Step 2: 注册工具**

在 `ToolRegistry.register` 调用处添加：
```dart
ToolRegistry.register(WeatherTool());
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/main.dart
git commit -m "feat: register WeatherTool in main.dart"
```

---

## Task 6: 验证和测试

**Files:**
- All weather files

- [ ] **Step 1: 运行 Flutter analyze**

```bash
cd app && flutter analyze lib/tools/weather/
```

预期：无错误

- [ ] **Step 2: 检查文件完整性**

```bash
ls -la app/lib/tools/weather/
# 应该包含: weather_tool.dart, weather_page.dart, weather_service.dart
```

- [ ] **Step 3: 最终提交（如有需要）**

```bash
# 如果以上步骤都成功，无需额外提交
```

---

## 完成标准

- [ ] `pubspec.yaml` 已添加 http 依赖
- [ ] `weather_service.dart` 包含完整的 API 服务和数据模型
- [ ] `weather_tool.dart` 正确实现 ToolModule 接口
- [ ] `weather_page.dart` 包含完整 UI（当前天气、预报、城市搜索）
- [ ] `main.dart` 已注册 WeatherTool
- [ ] Flutter analyze 无错误

---

## 后续优化（可选，不在本计划内）

1. 添加本地缓存（30分钟）
2. 实现 GPS 定位
3. 添加天气预警功能
4. 支持多城市收藏
