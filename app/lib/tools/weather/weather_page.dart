import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
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
    _tryGetCurrentLocation();
    _loadWeather();
  }

  Future<void> _tryGetCurrentLocation() async {
    try {
      // 检查位置服务是否启用
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      // 检查权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // 获取当前位置
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // 反向地理编码获取城市
      final city = await WeatherService.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (city != null && mounted) {
        setState(() => _selectedCity = city);
        _loadWeather();
      }
    } catch (e) {
      debugPrint('定位失败: $e');
    }
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
      debugPrint('Weather error: $e');
      setState(() {
        _error = '获取天气失败: $e';
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
      setState(() => _results = []);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
        );
      }
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
