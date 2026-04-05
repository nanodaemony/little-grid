import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:littlegrid/tools/life_grid/models/life_grid_settings.dart';
import 'package:littlegrid/tools/life_grid/models/custom_progress.dart';
import 'package:littlegrid/tools/life_grid/services/life_grid_service.dart';

void main() {
  group('LifeGridService', () {
    late LifeGridService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = LifeGridService();
      await service.init();
    });

    tearDown(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should load default settings', () async {
      final settings = await service.loadSettings();

      expect(settings.showWeekMonth, true);
      expect(settings.targetAge, 80);
    });

    test('should save and load settings', () async {
      final settings = LifeGridSettings(targetAge: 100);
      await service.saveSettings(settings);

      final loaded = await service.loadSettings();
      expect(loaded.targetAge, 100);
    });

    test('should add custom progress', () async {
      final progress = CustomProgress(
        name: 'Test',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 10),
      );

      await service.addCustomProgress(progress);
      final progresses = await service.loadCustomProgresses();

      expect(progresses.length, 1);
      expect(progresses.first.name, 'Test');
    });

    test('should delete custom progress', () async {
      final progress = CustomProgress(
        name: 'Test',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 10),
      );

      await service.addCustomProgress(progress);
      await service.deleteCustomProgress(progress.id);

      final progresses = await service.loadCustomProgresses();
      expect(progresses.isEmpty, true);
    });

    test('should calculate week progress', () {
      final now = DateTime(2026, 3, 25); // Wednesday
      final result = service.getWeekProgress(now);

      expect(result['currentDay'], 3); // 3rd day of week
      expect(result['totalDays'], 7);
    });

    test('should calculate month progress', () {
      final now = DateTime(2026, 3, 25);
      final result = service.getMonthProgress(now);

      expect(result['currentDay'], 25);
      expect(result['totalDays'], 31); // March has 31 days
    });

    test('should calculate year progress', () {
      final now = DateTime(2026, 3, 25);
      final result = service.getYearProgress(now);

      expect(result['currentDay'], 31 + 28 + 31 + 25); // ~84th day
      expect(result['totalDays'], 365); // 2026 is not leap year
    });

    test('should calculate life progress', () {
      final birthDate = DateTime(1990, 1, 1);
      final now = DateTime(2026, 3, 25);
      final targetAge = 80;

      final result = service.getLifeProgress(birthDate, targetAge, now);

      expect(result['totalMonths'], 80 * 12); // 960 months
      expect(result['passedMonths'] > 0, true);
    });
  });
}
