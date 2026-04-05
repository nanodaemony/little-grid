import 'package:flutter_test/flutter_test.dart';
import 'package:app/tools/drink_plan/models/drink_record.dart';

void main() {
  group('DrinkRecord', () {
    test('should create DrinkRecord with all fields', () {
      final record = DrinkRecord(
        id: 1,
        date: '2026-03-24',
        mark: '🧋',
        createdAt: DateTime(2026, 3, 24, 10, 30),
        updatedAt: DateTime(2026, 3, 24, 10, 30),
      );

      expect(record.id, 1);
      expect(record.date, '2026-03-24');
      expect(record.mark, '🧋');
    });

    test('should convert to map correctly', () {
      final createdAt = DateTime(2026, 3, 24, 10, 30);
      final record = DrinkRecord(
        date: '2026-03-24',
        mark: 'asset:milk_tea',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      final map = record.toMap();

      expect(map['date'], '2026-03-24');
      expect(map['mark'], 'asset:milk_tea');
      expect(map['created_at'], createdAt.millisecondsSinceEpoch);
    });

    test('should create from map correctly', () {
      final createdAt = DateTime(2026, 3, 24, 10, 30);
      final map = {
        'id': 1,
        'date': '2026-03-24',
        'mark': '🧋',
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': createdAt.millisecondsSinceEpoch,
      };

      final record = DrinkRecord.fromMap(map);

      expect(record.id, 1);
      expect(record.date, '2026-03-24');
      expect(record.mark, '🧋');
      expect(record.createdAt, createdAt);
    });

    test('should support copyWith', () {
      final record = DrinkRecord(
        id: 1,
        date: '2026-03-24',
        mark: '🧋',
        createdAt: DateTime(2026, 3, 24),
        updatedAt: DateTime(2026, 3, 24),
      );

      final updated = record.copyWith(mark: '☕');

      expect(updated.mark, '☕');
      expect(updated.date, record.date);
      expect(updated.id, record.id);
    });

    test('round-trip toMap/fromMap preserves data', () {
      final createdAt = DateTime(2026, 3, 24, 10, 30);
      final original = DrinkRecord(
        id: 1,
        date: '2026-03-24',
        mark: '🧋',
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      final map = original.toMap();
      final restored = DrinkRecord.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.date, original.date);
      expect(restored.mark, original.mark);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });
  });
}
