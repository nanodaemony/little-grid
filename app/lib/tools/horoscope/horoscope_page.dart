import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'horoscope_service.dart';
import 'models/zodiac_sign.dart';
import 'models/horoscope_data.dart';
import 'widgets/zodiac_selector.dart';
import 'widgets/fortune_card.dart';
import 'widgets/fortune_item.dart';

class HoroscopePage extends StatefulWidget {
  const HoroscopePage({super.key});

  @override
  State<HoroscopePage> createState() => _HoroscopePageState();
}

class _HoroscopePageState extends State<HoroscopePage> {
  bool _isLoading = false;
  String? _error;
  ZodiacSign? _selectedSign;
  String _currentType = 'today'; // 'today' or 'week'
  HoroscopeData? _todayData;
  HoroscopeData? _weekData;

  @override
  void initState() {
    super.initState();
    _loadDefaultZodiac();
  }

  /// 加载默认星座
  Future<void> _loadDefaultZodiac() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('horoscope_default_zodiac');
      if (savedId != null) {
        final sign = ZodiacSign.fromId(savedId);
        if (sign != null) {
          setState(() => _selectedSign = sign);
          _loadHoroscope();
          return;
        }
      }
    } catch (e) {
      debugPrint('Load default zodiac failed: $e');
    }
    // 没有默认星座，保持 null
  }

  /// 保存默认星座
  Future<void> _saveDefaultZodiac(ZodiacSign sign) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('horoscope_default_zodiac', sign.id);
    } catch (e) {
      debugPrint('Save default zodiac failed: $e');
    }
  }

  /// 加载运势
  Future<void> _loadHoroscope({bool force = false}) async {
    if (_selectedSign == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 加载今日和本周
      final today = await HoroscopeService.getHoroscope(_selectedSign!, 'today');
      final week = await HoroscopeService.getHoroscope(_selectedSign!, 'week');

      if (mounted) {
        setState(() {
          _todayData = today;
          _weekData = week;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '获取运势失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// 显示星座选择器
  void _showZodiacSelector() {
    ZodiacSelector.show(
      context,
      onSelected: (sign) {
        setState(() => _selectedSign = sign);
        _saveDefaultZodiac(sign);
        _loadHoroscope(force: true);
      },
    );
  }

  /// 获取当前显示的数据
  HoroscopeData? get _currentData {
    return _currentType == 'today' ? _todayData : _weekData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('星座运势'),
        actions: [
          if (_selectedSign != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : () => _loadHoroscope(force: true),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadHoroscope(force: true),
        child: _selectedSign == null
            ? _buildNoSelection()
            : _buildContent(),
      ),
    );
  }

  /// 未选择星座的占位
  Widget _buildNoSelection() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_outline,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                '选择你的星座',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '点击下方按钮开始',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _showZodiacSelector,
                icon: const Icon(Icons.search),
                label: const Text('选择星座'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 主内容
  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 星座选择栏
            _buildZodiacBar(),
            const SizedBox(height: 20),
            // 日期切换 Tab
            _buildTypeTab(),
            const SizedBox(height: 20),
            // 加载状态
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadHoroscope(force: true),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              )
            else if (_currentData != null) ...[
              // 综合运势卡片
              FortuneCard(data: _currentData!),
              const SizedBox(height: 24),
              // 分项运势
              Text(
                '分项运势',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              FortuneItem(
                category: 'love',
                score: _currentData!.loveScore,
                desc: _currentData!.loveDesc,
                index: 0,
              ),
              FortuneItem(
                category: 'career',
                score: _currentData!.careerScore,
                desc: _currentData!.careerDesc,
                index: 1,
              ),
              FortuneItem(
                category: 'wealth',
                score: _currentData!.wealthScore,
                desc: _currentData!.wealthDesc,
                index: 2,
              ),
              FortuneItem(
                category: 'health',
                score: _currentData!.healthScore,
                desc: _currentData!.healthDesc,
                index: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 星座选择栏
  Widget _buildZodiacBar() {
    return GestureDetector(
      onTap: _showZodiacSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              _selectedSign!.icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedSign!.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _selectedSign!.dateRange,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// 日期切换 Tab
  Widget _buildTypeTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: '今日',
              isSelected: _currentType == 'today',
              onTap: () {
                setState(() => _currentType = 'today');
              },
            ),
          ),
          Expanded(
            child: _TabButton(
              title: '本周',
              isSelected: _currentType == 'week',
              onTap: () {
                setState(() => _currentType = 'week');
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 按钮
class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
