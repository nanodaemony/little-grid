import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/usage_service.dart';
import 'models/loan_enums.dart';
import 'models/loan_params.dart';
import 'models/repayment_result.dart';
import 'models/repayment_schedule.dart';
import 'services/mortgage_calculator.dart';

class HouseMoneyCalcPage extends StatefulWidget {
  const HouseMoneyCalcPage({super.key});

  @override
  State<HouseMoneyCalcPage> createState() => _HouseMoneyCalcPageState();
}

class _HouseMoneyCalcPageState extends State<HouseMoneyCalcPage>
    with SingleTickerProviderStateMixin {
  late LoanParams _params;
  int _currentStep = 1;
  RepaymentResult? _result;

  // Expanded years tracking for repayment schedule
  final Set<int> _expandedYears = {};

  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _providentAmountController =
      TextEditingController();
  final TextEditingController _fixedRateController = TextEditingController();
  final TextEditingController _lprRateController = TextEditingController();
  final TextEditingController _basisPointsController = TextEditingController();

  // Tab controller for step 3
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('housemoneycalc');
    _tabController = TabController(length: 3, vsync: this);
    _initDefaultParams();
  }

  void _initDefaultParams() {
    _params = const LoanParams(
      repaymentMethod: RepaymentMethod.equalInterest,
      loanType: LoanType.commercial,
      commercialAmount: 0,
      providentAmount: 0,
      loanTermYears: 30,
      rateType: InterestRateType.fixed,
      fixedRate: 4.2,
    );
    _fixedRateController.text = '4.2';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _providentAmountController.dispose();
    _fixedRateController.dispose();
    _lprRateController.dispose();
    _basisPointsController.dispose();
    UsageService.recordExit('housemoneycalc');
    super.dispose();
  }

  void _goToStep(int step) {
    if (step >= 1 && step <= 3) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  void _calculate() {
    try {
      final result = MortgageCalculator.calculate(_params);
      setState(() {
        _result = result;
        _currentStep = 3;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('计算错误: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('房贷计算器'),
        bottom: _currentStep == 3
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '概览', icon: Icon(Icons.dashboard)),
                  Tab(text: '还款计划', icon: Icon(Icons.table_chart)),
                  Tab(text: '图表', icon: Icon(Icons.bar_chart)),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),
          // Main content
          Expanded(
            child: _buildStepContent(),
          ),
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepDot(1, '选择方式'),
          _buildStepLine(1),
          _buildStepDot(2, '输入信息'),
          _buildStepLine(2),
          _buildStepDot(3, '计算结果'),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return GestureDetector(
      onTap: () => _goToStep(step),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : isCompleted
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                      : Colors.grey.shade300,
              border: Border.all(
                color: isActive || isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      '$step',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int beforeStep) {
    final isCompleted = _currentStep > beforeStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isCompleted
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repayment method section
          _buildSectionTitle('选择还款方式'),
          const SizedBox(height: 12),
          _buildRepaymentMethodSelector(),
          const SizedBox(height: 32),
          // Loan type section
          _buildSectionTitle('选择贷款类型'),
          const SizedBox(height: 12),
          _buildLoanTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loan amount
          _buildSectionTitle('贷款金额'),
          const SizedBox(height: 12),
          _buildAmountInput(),
          if (_params.loanType == LoanType.combined) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('公积金贷款金额'),
            const SizedBox(height: 12),
            _buildProvidentAmountInput(),
          ],
          const SizedBox(height: 32),
          // Loan term
          _buildSectionTitle('贷款期限'),
          const SizedBox(height: 12),
          _buildTermSelector(),
          const SizedBox(height: 32),
          // Interest rate
          _buildSectionTitle('贷款利率'),
          const SizedBox(height: 12),
          _buildRateSelector(),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    if (_result == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '请先完成前两步并计算',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Overview tab
        _buildOverviewTab(),
        // Repayment schedule tab
        _buildScheduleTab(),
        // Charts tab
        _buildChartsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewCard(
            '首月月供',
            '${_result!.firstMonthPayment.toStringAsFixed(2)}元',
            Icons.payment,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildOverviewCard(
            '末月月供',
            '${_result!.lastMonthPayment.toStringAsFixed(2)}元',
            Icons.trending_down,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildOverviewCard(
            '还款总额',
            '${_result!.totalPayment.toStringAsFixed(2)}元',
            Icons.account_balance_wallet,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildOverviewCard(
            '支付利息',
            '${_result!.totalInterest.toStringAsFixed(2)}元',
            Icons.money_off,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildOverviewCard(
            '贷款本金',
            '${_result!.totalPrincipal.toStringAsFixed(2)}元',
            Icons.savings,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    if (_result == null) return const SizedBox.shrink();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _result!.yearlyData.length,
      itemBuilder: (context, index) {
        final yearData = _result!.yearlyData[index];
        final isExpanded = _expandedYears.contains(yearData.year);
        return Column(
          children: [
            _buildYearCard(yearData, isExpanded),
            if (isExpanded) _buildMonthList(yearData),
          ],
        );
      },
    );
  }

  Widget _buildYearCard(YearlyData yearData, bool isExpanded) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedYears.remove(yearData.year);
            } else {
              _expandedYears.add(yearData.year);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '第${yearData.year}年',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '年度还款: ${_formatShortAmount(yearData.yearPayment)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '本金: ${_formatShortAmount(yearData.yearPrincipal)} | 利息: ${_formatShortAmount(yearData.yearInterest)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthList(YearlyData yearData) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: yearData.monthlyData.map((monthData) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${monthData.monthInYear}月',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${monthData.payment.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '本: ${monthData.principal.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '息: ${monthData.interest.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatShortAmount(double amount) {
    if (amount >= 10000) {
      final wan = amount / 10000;
      return '${wan.toStringAsFixed(wan == wan.toInt() ? 0 : 1)}万';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildChartsTab() {
    if (_result == null) {
      return const Center(
        child: Text('暂无数据'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pie Chart Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '本金与利息占比',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildPieChart(),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.green, '本金'),
                      const SizedBox(width: 24),
                      _buildLegendItem(Colors.orange, '利息'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Line Chart Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '月供趋势',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: _buildLineChart(),
                  ),
                  const SizedBox(height: 8),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.blue, '月供金额'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final principal = _result!.totalPrincipal;
    final interest = _result!.totalInterest;
    final total = principal + interest;
    final principalPercent = total > 0 ? (principal / total * 100) : 0;
    final interestPercent = total > 0 ? (interest / total * 100) : 0;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: principal,
            title: '${principalPercent.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: interest,
            title: '${interestPercent.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final monthlyData = _result!.monthlyData;
    if (monthlyData.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    // Sample every 12 months to avoid too many points
    final sampledData = <MonthlyData>[];
    for (int i = 0; i < monthlyData.length; i += 12) {
      sampledData.add(monthlyData[i]);
    }
    // Always include the last month
    if (monthlyData.isNotEmpty && (monthlyData.length - 1) % 12 != 0) {
      sampledData.add(monthlyData.last);
    }

    final spots = sampledData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.payment / 1000);
    }).toList();

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final yPadding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 5).ceilToDouble(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}k',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sampledData.length) {
                  final month = sampledData[index].month;
                  final year = (month / 12).ceil();
                  if (month % 12 == 1 || index == 0) {
                    return Text(
                      '${year}年',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: spots.length - 1.0,
        minY: (minY - yPadding).clamp(0, double.infinity),
        maxY: maxY + yPadding,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.grey.shade800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < sampledData.length) {
                  final month = sampledData[index].month;
                  return LineTooltipItem(
                    '第${month}期\n${_formatShortAmount(spot.y * 1000)}元',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  );
                }
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}k',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 1)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToStep(_currentStep - 1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('上一步'),
                ),
              ),
            if (_currentStep > 1) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep == 1 ? 2 : 1,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 2) {
                    _goToStep(_currentStep + 1);
                  } else if (_currentStep == 2) {
                    _calculate();
                  } else {
                    // Reset and start over
                    setState(() {
                      _currentStep = 1;
                      _result = null;
                      _initDefaultParams();
                      _amountController.clear();
                      _providentAmountController.clear();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _currentStep == 1
                      ? '下一步'
                      : _currentStep == 2
                          ? '开始计算'
                          : '重新计算',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRepaymentMethodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionCard(
            title: RepaymentMethod.equalInterest.label,
            subtitle: RepaymentMethod.equalInterest.description,
            isSelected: _params.repaymentMethod == RepaymentMethod.equalInterest,
            onTap: () => setState(() {
              _params = _params.copyWith(
                repaymentMethod: RepaymentMethod.equalInterest,
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOptionCard(
            title: RepaymentMethod.equalPrincipal.label,
            subtitle: RepaymentMethod.equalPrincipal.description,
            isSelected:
                _params.repaymentMethod == RepaymentMethod.equalPrincipal,
            onTap: () => setState(() {
              _params = _params.copyWith(
                repaymentMethod: RepaymentMethod.equalPrincipal,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanTypeSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                title: LoanType.commercial.label,
                subtitle: '纯商业贷款',
                isSelected: _params.loanType == LoanType.commercial,
                onTap: () => setState(() {
                  _params = _params.copyWith(loanType: LoanType.commercial);
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                title: LoanType.provident.label,
                subtitle: '纯公积金贷款',
                isSelected: _params.loanType == LoanType.provident,
                onTap: () => setState(() {
                  _params = _params.copyWith(loanType: LoanType.provident);
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          title: LoanType.combined.label,
          subtitle: '商业贷款+公积金贷款',
          isSelected: _params.loanType == LoanType.combined,
          onTap: () => setState(() {
            _params = _params.copyWith(loanType: LoanType.combined);
          }),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: (value) {
        final amount = double.tryParse(value) ?? 0;
        setState(() {
          _params = _params.copyWith(commercialAmount: amount);
        });
      },
      decoration: InputDecoration(
        hintText: '请输入贷款金额',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixText: '万元',
        prefixIcon: const Icon(Icons.account_balance),
      ),
    );
  }

  Widget _buildProvidentAmountInput() {
    return TextField(
      controller: _providentAmountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: (value) {
        final amount = double.tryParse(value) ?? 0;
        setState(() {
          _params = _params.copyWith(providentAmount: amount);
        });
      },
      decoration: InputDecoration(
        hintText: '请输入公积金贷款金额',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixText: '万元',
        prefixIcon: const Icon(Icons.savings),
      ),
    );
  }

  Widget _buildTermSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _params.loanTermYears,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: List.generate(30, (index) => index + 1).map((year) {
            return DropdownMenuItem<int>(
              value: year,
              child: Text('$year年 (${year * 12}期)'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _params = _params.copyWith(loanTermYears: value);
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildRateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rate type toggle
        Row(
          children: [
            Expanded(
              child: _buildRateTypeButton(
                InterestRateType.fixed,
                InterestRateType.fixed.label,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRateTypeButton(
                InterestRateType.lprFloating,
                InterestRateType.lprFloating.label,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Rate input
        if (_params.rateType == InterestRateType.fixed)
          _buildFixedRateInput()
        else
          _buildLprRateInput(),
      ],
    );
  }

  Widget _buildRateTypeButton(InterestRateType type, String label) {
    final isSelected = _params.rateType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _params = _params.copyWith(rateType: type);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFixedRateInput() {
    return TextField(
      controller: _fixedRateController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: (value) {
        final rate = double.tryParse(value);
        setState(() {
          _params = _params.copyWith(fixedRate: rate);
        });
      },
      decoration: InputDecoration(
        labelText: '固定利率',
        hintText: '请输入年利率',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixText: '%',
        prefixIcon: const Icon(Icons.percent),
      ),
    );
  }

  Widget _buildLprRateInput() {
    return Column(
      children: [
        TextField(
          controller: _lprRateController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onChanged: (value) {
            final rate = double.tryParse(value);
            setState(() {
              _params = _params.copyWith(lprRate: rate);
            });
          },
          decoration: InputDecoration(
            labelText: 'LPR基准',
            hintText: '例如: 3.95',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixText: '%',
            prefixIcon: const Icon(Icons.trending_up),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _basisPointsController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[+-]?\d*\.?\d{0,2}')),
          ],
          onChanged: (value) {
            final bp = double.tryParse(value);
            setState(() {
              _params = _params.copyWith(basisPoints: bp);
            });
          },
          decoration: InputDecoration(
            labelText: '基点调整',
            hintText: '例如: -0.3 或 +0.2',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixText: '%',
            prefixIcon: const Icon(Icons.adjust),
            helperText: '正数表示上浮，负数表示下浮',
          ),
        ),
      ],
    );
  }
}
