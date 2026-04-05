import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/widgets/avatar_picker.dart';

void main() {
  group('AvatarPicker', () {
    testWidgets('shows bottom sheet with options', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await AvatarPicker.show(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      // Tap button to open picker
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify bottom sheet appears
      expect(find.text('更换头像'), findsOneWidget);
      expect(find.text('从相册选择'), findsOneWidget);
      expect(find.text('选择默认头像'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // Verify result is null
      expect(result, isNull);
    });

    test('isDefaultAvatar returns true for default paths', () {
      expect(AvatarPicker.isDefaultAvatar('default:0'), isTrue);
      expect(AvatarPicker.isDefaultAvatar('default:1'), isTrue);
      expect(AvatarPicker.isDefaultAvatar('/path/to/image.jpg'), isFalse);
      expect(AvatarPicker.isDefaultAvatar(null), isFalse);
    });

    test('getDefaultAvatarColor returns correct colors', () {
      // Default colors for indices 0-5
      expect(AvatarPicker.getDefaultAvatarColor('default:0'), Colors.blue);
      expect(AvatarPicker.getDefaultAvatarColor('default:1'), Colors.green);
      expect(AvatarPicker.getDefaultAvatarColor('default:2'), Colors.purple);
      expect(AvatarPicker.getDefaultAvatarColor('default:3'), Colors.orange);
      expect(AvatarPicker.getDefaultAvatarColor('default:4'), Colors.red);
      expect(AvatarPicker.getDefaultAvatarColor('default:5'), Colors.teal);

      // Null or non-default returns grey
      expect(AvatarPicker.getDefaultAvatarColor(null), Colors.grey);
      expect(AvatarPicker.getDefaultAvatarColor('/path/to/image.jpg'), Colors.grey);
    });

    test('getDefaultAvatarColor handles out of range indices', () {
      // Should use modulo to wrap around
      expect(AvatarPicker.getDefaultAvatarColor('default:6'), Colors.blue);
      expect(AvatarPicker.getDefaultAvatarColor('default:12'), Colors.blue);
    });
  });
}
