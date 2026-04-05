import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:littlegrid/providers/app_provider.dart';
import 'package:littlegrid/widgets/app_drawer.dart';
import 'package:littlegrid/pages/settings_page.dart';

void main() {
  group('AppDrawer', () {
    Widget buildTestWidget({required Widget child}) {
      return ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: MaterialApp(
          home: Scaffold(
            drawer: child,
            body: Container(),
          ),
        ),
      );
    }

    testWidgets('renders drawer with header and menu items', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const AppDrawer()),
      );

      // Open drawer
      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // Verify header elements
      expect(find.text('用户'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Verify menu items
      expect(find.text('设置'), findsOneWidget);
      expect(find.text('关于'), findsOneWidget);
      expect(find.text('反馈'), findsOneWidget);

      // Verify version
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('can edit nickname', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const AppDrawer()),
      );

      // Open drawer
      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // Tap nickname to edit
      await tester.tap(find.text('用户'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('修改昵称'), findsOneWidget);

      // Enter new nickname
      await tester.enterText(find.byType(TextField), '新昵称');

      // Tap save
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // Verify nickname updated
      expect(find.text('新昵称'), findsOneWidget);
    });

    testWidgets('opens avatar picker when tapping avatar', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const AppDrawer()),
      );

      // Open drawer
      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // Tap avatar (find the first GestureDetector in the header)
      final avatarGesture = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byWidgetPredicate((widget) {
          return widget is GestureDetector;
        }),
      );

      // Tap the avatar gesture detector
      await tester.tap(avatarGesture.first);
      await tester.pumpAndSettle();

      // Verify bottom sheet appears with options
      expect(find.text('更换头像'), findsOneWidget);
      expect(find.text('从相册选择'), findsOneWidget);
      expect(find.text('选择默认头像'), findsOneWidget);
    });

    testWidgets('displays usage stats', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const AppDrawer()),
      );

      // Open drawer
      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // Verify stats text (format: "已使用 X 个工具")
      expect(find.textContaining('已使用'), findsOneWidget);
      expect(find.textContaining('个工具'), findsOneWidget);
    });

    testWidgets('navigates to settings page', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const AppDrawer()),
      );

      // Open drawer
      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // Tap settings
      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();

      // Verify drawer is closed and navigated to SettingsPage
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });
}
