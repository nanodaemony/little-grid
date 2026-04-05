import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/life_grid/models/life_grid_settings.dart';

void main() {
  group('LifeGridSettings', () {
    test('should create with default values', () {
      final settings = LifeGridSettings();

      expect(settings.showWeekMonth, true);
      expect(settings.showYear, true);
      expect(settings.showLife, true);
      expect(settings.showCustom, true);
      expect(settings.tabOrder, ['week_month', 'year', 'life', 'custom']);
      expect(settings.targetAge, 80);
      expect(settings.activeTabIndex, 0);
    });

    test('should serialize to JSON', () {
      final settings = LifeGridSettings(
        showWeekMonth: false,
        showYear: true,
        targetAge: 100,
      );

      final json = settings.toJson();

      expect(json['showWeekMonth'], false);
      expect(json['showYear'], true);
      expect(json['targetAge'], 100);
    });

    test('should deserialize from JSON', () {
      final json = {
        'showWeekMonth': false,
        'showYear': true,
        'showLife': false,
        'showCustom': true,
        'tabOrder': ['year', 'life'],
        'birthDate': '1990-01-01',
        'targetAge': 100,
        'activeTabIndex': 1,
      };

      final settings = LifeGridSettings.fromJson(json);

      expect(settings.showWeekMonth, false);
      expect(settings.showLife, false);
      expect(settings.targetAge, 100);
      expect(settings.activeTabIndex, 1);
    });

    test('should handle null birthDate', () {
      final settings = LifeGridSettings();
      expect(settings.birthDate, isNull);
    });
  });
}
