import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/life_grid_settings.dart';
import '../services/life_grid_service.dart';
import '../widgets/grid_cell.dart';

class LifePage extends StatefulWidget {
  const LifePage({super.key});

  @override
  State<LifePage> createState() => _LifePageState();
}

class _LifePageState extends State<LifePage> {
  final _service = LifeGridService();
  LifeGridSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.loadSettings();
    setState(() {
      _settings = settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_settings!.birthDate == null) {
      return _buildNoBirthDateView();
    }

    return _buildLifeGridView();
  }

  Widget _buildNoBirthDateView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '请先在设置中设置出生日期',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角设置按钮',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeGridView() {
    final now = DateTime.now();
    final birthDate = _settings!.birthDate!;
    final targetAge = _settings!.targetAge;

    final progress = _service.getLifeProgress(birthDate, targetAge, now);
    final totalMonths = progress['totalMonths'] as int;
    final passedMonths = progress['passedMonths'] as int;
    final remainingMonths = progress['remainingMonths'] as int;
    final percentage = (progress['percentage'] as double) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('已过', '$passedMonths', '个月'),
                    _buildStatItem('剩余', '$remainingMonths', '个月'),
                    _buildStatItem('进度', '${percentage.toStringAsFixed(1)}%', ''),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '目标年龄: $targetAge 岁',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Life grid - each row is one year (12 months)
          ...List.generate(targetAge, (yearIndex) {
            return _buildYearRow(yearIndex, passedMonths);
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildYearRow(int yearIndex, int passedMonths) {
    final yearStartMonth = yearIndex * 12;
    final yearEndMonth = yearStartMonth + 12;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          // Age label
          SizedBox(
            width: 36,
            child: Text(
              '$yearIndex岁',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          // 12 months
          Expanded(
            child: Row(
              children: List.generate(12, (monthIndex) {
                final monthNumber = yearStartMonth + monthIndex;
                final isPassed = monthNumber < passedMonths;
                final isCurrent = monthNumber == passedMonths;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: GridCell(
                      isPassed: isPassed,
                      isCurrent: isCurrent,
                      size: 12,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
