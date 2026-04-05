import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import 'models/life_grid_settings.dart';
import 'services/life_grid_service.dart';
import 'widgets/settings_dialog.dart';
import 'pages/week_month_page.dart';
import 'pages/year_page.dart';
import 'pages/life_page.dart';
import 'pages/custom_page.dart';

class LifeGridMainPage extends StatefulWidget {
  const LifeGridMainPage({super.key});

  @override
  State<LifeGridMainPage> createState() => _LifeGridMainPageState();
}

class _LifeGridMainPageState extends State<LifeGridMainPage>
    with SingleTickerProviderStateMixin {
  final _service = LifeGridService();
  LifeGridSettings _settings = LifeGridSettings();
  bool _isLoading = true;
  TabController? _tabController;

  // Tab definitions with their IDs and labels
  static const Map<String, String> _tabLabels = {
    'week_month': '周/月',
    'year': '年',
    'life': '人生',
    'custom': '自定义',
  };

  // Tab IDs in default order
  static const List<String> _defaultTabOrder = ['week_month', 'year', 'life', 'custom'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
    _initTabController();
  }

  void _initTabController() {
    final visibleTabs = _getVisibleTabs();
    if (visibleTabs.isEmpty) {
      _tabController?.dispose();
      _tabController = null;
      return;
    }

    // Calculate initial tab index
    int initialIndex = _settings.activeTabIndex;
    if (initialIndex >= visibleTabs.length) {
      initialIndex = 0;
    }

    _tabController?.dispose();
    _tabController = TabController(
      length: visibleTabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );

    // Listen for tab changes to save active index
    _tabController!.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      _saveActiveTabIndex(_tabController!.index);
    }
  }

  Future<void> _saveActiveTabIndex(int index) async {
    final updatedSettings = _settings.copyWith(activeTabIndex: index);
    await _service.saveSettings(updatedSettings);
    setState(() {
      _settings = updatedSettings;
    });
  }

  List<String> _getVisibleTabs() {
    final visibleTabs = <String>[];
    final tabOrder = _settings.tabOrder.isEmpty ? _defaultTabOrder : _settings.tabOrder;

    for (final tabId in tabOrder) {
      switch (tabId) {
        case 'week_month':
          if (_settings.showWeekMonth) visibleTabs.add(tabId);
          break;
        case 'year':
          if (_settings.showYear) visibleTabs.add(tabId);
          break;
        case 'life':
          if (_settings.showLife) visibleTabs.add(tabId);
          break;
        case 'custom':
          if (_settings.showCustom) visibleTabs.add(tabId);
          break;
      }
    }

    return visibleTabs;
  }

  List<Tab> _buildTabs() {
    final visibleTabs = _getVisibleTabs();
    return visibleTabs.map((tabId) {
      return Tab(text: _tabLabels[tabId] ?? tabId);
    }).toList();
  }

  List<Widget> _buildTabViews() {
    final visibleTabs = _getVisibleTabs();
    return visibleTabs.map((tabId) {
      switch (tabId) {
        case 'week_month':
          return const WeekMonthPage();
        case 'year':
          return const YearPage();
        case 'life':
          return const LifePage();
        case 'custom':
          return const CustomPage();
        default:
          return const SizedBox.shrink();
      }
    }).toList();
  }

  Future<void> _showSettings() async {
    final result = await SettingsDialog.show(context);
    if (result == true) {
      // Reload settings if changes were saved
      await _loadSettings();
    }
  }

  Widget _buildNoTabsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tab_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '所有标签页已隐藏',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请在设置中启用至少一个标签页',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            label: const Text('打开设置'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomEncouragement() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: AppColors.primary,
          ),
          SizedBox(width: 8),
          Text(
            '一寸光阴一寸金',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final visibleTabs = _getVisibleTabs();
    final hasVisibleTabs = visibleTabs.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('人生进度'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            tooltip: '设置',
          ),
        ],
        bottom: hasVisibleTabs
            ? TabBar(
                controller: _tabController,
                tabs: _buildTabs(),
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: hasVisibleTabs
                ? TabBarView(
                    controller: _tabController,
                    children: _buildTabViews(),
                  )
                : _buildNoTabsView(),
          ),
          _buildBottomEncouragement(),
        ],
      ),
    );
  }
}
