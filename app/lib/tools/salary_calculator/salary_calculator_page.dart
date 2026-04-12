import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/usage_service.dart';
import 'models/city_config.dart';
import 'models/salary_result.dart';
import 'models/history_item.dart';
import 'services/city_config_service.dart';
import 'services/salary_calculator_service.dart';
import 'services/history_service.dart';
import 'widgets/salary_input_section.dart';
import 'widgets/insurance_section.dart';
import 'widgets/deduction_section.dart';
import 'widgets/result_overview_card.dart';
import 'widgets/monthly_detail_list.dart';
import 'widgets/tax_chart_widget.dart';
import 'widgets/history_section.dart';

class SalaryCalculatorPage extends StatefulWidget {
  const SalaryCalculatorPage({super.key});

  @override
  State<SalaryCalculatorPage> createState() => _SalaryCalculatorPageState();
}

class _SalaryCalculatorPageState extends State<SalaryCalculatorPage> with SingleTickerProviderStateMixin {
  double _salary = 0;
  String _selectedCityId = 'beijing';
  bool _useCustomInsurance = false;
  CityConfig _customCityConfig = CityConfigService.getCity('beijing');
  Map<String, double> _deductions = {};
  SalaryResult? _result;
  List<HistoryItem> _history = [];
  int _viewMode = 0; // 0: 单月, 1: 图表
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('salary_calculator');
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedData();
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    UsageService.recordExit('salary_calculator');
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _salary = prefs.getDouble('salary_last_salary') ?? 0;
      _selectedCityId = prefs.getString('salary_last_city') ?? 'beijing';
      _customCityConfig = CityConfigService.getCity(_selectedCityId);
    });
    if (_salary > 0) {
      _calculate();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('salary_last_salary', _salary);
    await prefs.setString('salary_last_city', _selectedCityId);
  }

  Future<void> _loadHistory() async {
    final history = await HistoryService.loadHistory();
    setState(() {
      _history = history;
    });
  }

  void _calculate() {
    if (_salary <= 0) {
      setState(() {
        _result = null;
      });
      return;
    }

    final cityConfig = _useCustomInsurance ? _customCityConfig : CityConfigService.getCity(_selectedCityId);
    final result = SalaryCalculatorService.calculate(
      preTaxSalary: _salary,
      cityConfig: cityConfig,
      deductions: _deductions,
    );

    setState(() {
      _result = result;
    });
    _saveData();
  }

  Future<void> _saveToHistory() async {
    if (_result == null) return;

    final cityConfig = _useCustomInsurance ? _customCityConfig : CityConfigService.getCity(_selectedCityId);
    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      preTaxSalary: _salary,
      cityName: cityConfig.name,
      afterTaxSalary: _result!.afterTaxSalary,
    );

    await HistoryService.addHistoryItem(item);
    await _loadHistory();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存到历史记录')),
      );
    }
  }

  void _applyHistoryItem(HistoryItem item) {
    setState(() {
      _salary = item.preTaxSalary;
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final cities = CityConfigService.getAllCities();
    final cityIds = cities.map((c) => c.id).toList();
    final cityNames = cities.map((c) => c.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('工资计算器'),
        actions: [
          if (_result != null)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _saveToHistory,
              tooltip: '保存到历史',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SalaryInputSection(
              salary: _salary,
              selectedCityId: _selectedCityId,
              cityNames: cityNames,
              cityIds: cityIds,
              onSalaryChanged: (value) {
                setState(() {
                  _salary = value;
                });
                _calculate();
              },
              onCityChanged: (value) {
                setState(() {
                  _selectedCityId = value;
                  _customCityConfig = CityConfigService.getCity(value);
                });
                _calculate();
              },
              onCalculate: _calculate,
            ),
            const SizedBox(height: 16),
            InsuranceSection(
              cityConfig: _customCityConfig,
              useCustom: _useCustomInsurance,
              onUseCustomChanged: (value) {
                setState(() {
                  _useCustomInsurance = value;
                  if (!value) {
                    _customCityConfig = CityConfigService.getCity(_selectedCityId);
                  }
                });
                _calculate();
              },
              onConfigChanged: (config) {
                setState(() {
                  _customCityConfig = config;
                });
                _calculate();
              },
            ),
            const SizedBox(height: 16),
            DeductionSection(
              deductions: _deductions,
              onDeductionsChanged: (deductions) {
                setState(() {
                  _deductions = deductions;
                });
                _calculate();
              },
            ),
            const SizedBox(height: 16),
            ResultOverviewCard(result: _result),
            if (_result != null) ...[
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '月度明细'),
                  Tab(text: '税额图表'),
                ],
                onTap: (index) {
                  setState(() {
                    _viewMode = index;
                  });
                },
              ),
              const SizedBox(height: 16),
              IndexedStack(
                index: _viewMode,
                children: [
                  MonthlyDetailList(result: _result),
                  TaxChartWidget(result: _result),
                ],
              ),
            ],
            const SizedBox(height: 16),
            HistorySection(
              history: _history,
              onItemTap: _applyHistoryItem,
              onDeleteItem: (id) async {
                await HistoryService.deleteHistoryItem(id);
                await _loadHistory();
              },
              onUpdateLabel: (data) async {
                await HistoryService.updateHistoryLabel(data.$1, data.$2);
                await _loadHistory();
              },
            ),
          ],
        ),
      ),
    );
  }
}
