import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/life_grid/models/custom_progress.dart';

void main() {
  group('CustomProgress', () {
    test('should create with required values', () {
      final progress = CustomProgress(
        id: 'test-id',
        name: '本学期',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 7, 1),
      );

      expect(progress.id, 'test-id');
      expect(progress.name, '本学期');
    });

    test('should serialize to JSON', () {
      final progress = CustomProgress(
        id: 'test-id',
        name: '本学期',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 7, 1),
        createdAt: DateTime(2026, 3, 25),
      );

      final json = progress.toJson();

      expect(json['id'], 'test-id');
      expect(json['name'], '本学期');
      expect(json['startDate'], '2026-03-01');
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': 'test-id',
        'name': '本学期',
        'startDate': '2026-03-01',
        'endDate': '2026-07-01',
        'createdAt': '2026-03-25T10:00:00.000',
      };

      final progress = CustomProgress.fromJson(json);

      expect(progress.id, 'test-id');
      expect(progress.name, '本学期');
      expect(progress.startDate.year, 2026);
    });

    test('should calculate total days', () {
      final progress = CustomProgress(
        id: 'test-id',
        name: 'Test',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 10),
      );

      expect(progress.totalDays, 10);
    });
  });
}
