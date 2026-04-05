import 'package:flutter_test/flutter_test.dart';
import 'package:app/tools/drink_plan/services/drink_plan_service.dart';
import 'package:app/tools/drink_plan/models/drink_record.dart';
import 'package:app/core/services/database_service.dart';

void main() {
  group('DrinkPlanService', () {
    setUpAll(() async {
      await DatabaseService.database;
    });

    tearDown(() async {
      final db = await DatabaseService.database;
      await db.delete('drink_records');
      await db.delete('drink_plan_settings');
    });

    test('should add and retrieve record', () async {
      final record = DrinkRecord(
        date: '2026-03-24',
        mark: '🧋',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await DrinkPlanService.addRecord(record);
      final retrieved = await DrinkPlanService.getRecordByDate('2026-03-24');

      expect(retrieved, isNotNull);
      expect(retrieved!.mark, '🧋');
    });

    test('should get records by month', () async {
      await DrinkPlanService.addRecord(DrinkRecord(
        date: '2026-03-01',
        mark: '🧋',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await DrinkPlanService.addRecord(DrinkRecord(
        date: '2026-03-15',
        mark: '☕',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final records = await DrinkPlanService.getRecordsByMonth(2026, 3);

      expect(records.length, 2);
    });

    test('should delete record', () async {
      await DrinkPlanService.addRecord(DrinkRecord(
        date: '2026-03-24',
        mark: '🧋',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await DrinkPlanService.deleteRecord('2026-03-24');
      final retrieved = await DrinkPlanService.getRecordByDate('2026-03-24');

      expect(retrieved, isNull);
    });

    test('should save and retrieve settings', () async {
      await DrinkPlanService.saveSettings(0.5);
      final opacity = await DrinkPlanService.getBackgroundOpacity();

      expect(opacity, 0.5);
    });
  });
}
