import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';
import 'auth_style_a/login_page_a.dart';
import 'auth_style_a/register_page_a.dart';
import 'auth_style_a/forgot_password_page_a.dart';
import 'auth_style_b/login_page_b.dart';
import 'auth_style_b/register_page_b.dart';
import 'auth_style_b/forgot_password_page_b.dart';
import 'auth_style_c/login_page_c.dart';
import 'auth_style_c/register_page_c.dart';
import 'auth_style_c/forgot_password_page_c.dart';
import 'auth_new_design/login_page_new.dart';
import 'auth_new_design/register_page_new.dart';
import 'auth_new_design/forgot_password_page_new.dart';

class AuthDesignPage extends StatefulWidget {
  const AuthDesignPage({super.key});

  @override
  State<AuthDesignPage> createState() => _AuthDesignPageState();
}

class _AuthDesignPageState extends State<AuthDesignPage>
    with SingleTickerProviderStateMixin {
  int _selectedStyle = 3;
  late TabController _tabController;

  // 每个风格的三个页面
  final List<List<Widget>> _stylePageSets = [
    // 风格A
    const [
      LoginPageA(),
      RegisterPageA(),
      ForgotPasswordPageA(),
    ],
    // 风格B
    const [
      LoginPageB(),
      RegisterPageB(),
      ForgotPasswordPageB(),
    ],
    // 风格C
    const [
      LoginPageC(),
      RegisterPageC(),
      ForgotPasswordPageC(),
    ],
    // 新设计
    const [
      LoginPageNew(),
      RegisterPageNew(),
      ForgotPasswordPageNew(),
    ],
  ];

  final _styleLabels = ['风格A', '风格B', '风格C', '新设计'];
  final _styleDescriptions = ['经典居中卡片', '标签分割线卡片', '分段卡片组合', '扁平淡色风格'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('认证页面设计'),
      ),
      body: Column(
        children: [
          // Style selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SegmentedButton<int>(
              segments: List.generate(
                4,
                (i) => ButtonSegment<int>(
                  value: i,
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_styleLabels[i]),
                      Text(
                        _styleDescriptions[i],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              selected: {_selectedStyle},
              onSelectionChanged: (selected) {
                setState(() => _selectedStyle = selected.first);
              },
            ),
          ),

          // Page type tabs
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: '登录'),
                Tab(text: '注册'),
                Tab(text: '忘记密码'),
              ],
            ),
          ),

          // Page content - 根据选中的风格和Tab显示对应页面
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 登录页面
                IndexedStack(
                  index: _selectedStyle,
                  children: _stylePageSets.map((set) => set[0]).toList(),
                ),
                // 注册页面
                IndexedStack(
                  index: _selectedStyle,
                  children: _stylePageSets.map((set) => set[1]).toList(),
                ),
                // 忘记密码页面
                IndexedStack(
                  index: _selectedStyle,
                  children: _stylePageSets.map((set) => set[2]).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
