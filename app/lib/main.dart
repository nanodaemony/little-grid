import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/services/debug_log_service.dart';
import 'core/services/tool_registry.dart';
import 'core/ui/theme.dart';
import 'pages/debug_page.dart';
import 'pages/grid_page.dart';
import 'pages/profile_page.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'tools/coin/coin_tool.dart';
import 'tools/dice/dice_tool.dart';
import 'tools/card/card_tool.dart';
import 'tools/todo/todo_tool.dart';
import 'tools/calculator/calculator_tool.dart';
import 'tools/calendar/calendar_tool.dart';
import 'tools/weather/weather_tool.dart';
import 'tools/gomoku/gomoku_tool.dart';
import 'tools/alarm/alarm_tool.dart';
import 'tools/canvas/canvas_tool.dart';
import 'tools/pomodoro/pomodoro_tool.dart';
import 'tools/pomodoro/services/pomodoro_service.dart';
import 'tools/snake/snake_tool.dart';
import 'tools/qrcode/qrcode_tool.dart';
import 'tools/sudoku/sudoku_tool.dart';
import 'tools/account/account_tool.dart';
import 'tools/random/random_tool.dart';
import 'tools/drink_plan/drink_plan_tool.dart';
import 'tools/housemoneycalc/housemoneycalc_tool.dart';
import 'tools/rmbconvertor/rmbconvertor_tool.dart';
import 'tools/big_wheel/big_wheel_tool.dart';
import 'tools/life_grid/life_grid_tool.dart';
import 'tools/anniversary/anniversary_tool.dart';
import 'tools/handscrollingtext/handscrollingtext_tool.dart';
import 'tools/clock/clock_tool.dart';
import 'tools/bookshelf/bookshelf_tool.dart';
import 'tools/bookshelf/providers/bookshelf_provider.dart';
import 'tools/bmi/bmi_tool.dart';
import 'tools/game2048/game2048_tool.dart';
import 'tools/salary_calculator/salary_calculator_tool.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册工具
  ToolRegistry.register(CoinTool());
  ToolRegistry.register(DiceTool());
  ToolRegistry.register(CardTool());
  ToolRegistry.register(TodoTool());
  ToolRegistry.register(CalculatorTool());
  ToolRegistry.register(CalendarTool());
  ToolRegistry.register(WeatherTool());
  ToolRegistry.register(GomokuTool());
  ToolRegistry.register(AlarmTool());
  ToolRegistry.register(CanvasTool());
  ToolRegistry.register(PomodoroTool());
  ToolRegistry.register(SnakeTool());
  ToolRegistry.register(QRCodeTool());
  ToolRegistry.register(SudokuTool());
  ToolRegistry.register(AccountTool());
  ToolRegistry.register(RandomTool());
  ToolRegistry.register(DrinkPlanTool());
  ToolRegistry.register(HouseMoneyCalcTool());
  ToolRegistry.register(RmbConvertorTool());
  ToolRegistry.register(BigWheelTool());
  ToolRegistry.register(LifeGridTool());
  ToolRegistry.register(AnniversaryTool());
  ToolRegistry.register(HandScrollingTextTool());
  ToolRegistry.register(ClockTool());
  ToolRegistry.register(BookshelfTool());
  ToolRegistry.register(BMITool());
  ToolRegistry.register(Game2048Tool());
  ToolRegistry.register(SalaryCalculatorTool());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroService()..loadSettings()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookshelfProvider()),
        ChangeNotifierProvider(create: (_) => DebugLogService()),
      ],
      child: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小方格',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final _pages = const [
    GridPage(),
    ProfilePage(),
    DebugPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化应用状态（工具配置 + 头像）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: '格子',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'debug',
          ),
        ],
      ),
    );
  }
}
