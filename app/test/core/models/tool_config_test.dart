import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/core/models/tool_config.dart';

void main() {
  group('ToolConfig', () {
    test('should create ToolConfig with default values', () {
      final config = ToolConfig(
        id: 'test',
        name: 'Test Tool',
        category: 'game',
      );

      expect(config.id, 'test');
      expect(config.name, 'Test Tool');
      expect(config.category, 'game');
      expect(config.isPinned, false);
      expect(config.useCount, 0);
      expect(config.gridSize, 1);
    });

    test('should convert to and from map', () {
      final config = ToolConfig(
        id: 'test',
        name: 'Test Tool',
        category: 'game',
        isPinned: true,
        useCount: 5,
        gridSize: 2,
      );

      final map = config.toMap();
      final restored = ToolConfig.fromMap(map);

      expect(restored.id, config.id);
      expect(restored.name, config.name);
      expect(restored.isPinned, config.isPinned);
      expect(restored.useCount, config.useCount);
    });

    test('copyWith should work correctly', () {
      final config = ToolConfig(
        id: 'test',
        name: 'Test Tool',
        category: 'game',
      );

      final updated = config.copyWith(useCount: 10, isPinned: true);

      expect(updated.useCount, 10);
      expect(updated.isPinned, true);
      expect(updated.id, config.id); // unchanged
      expect(updated.name, config.name); // unchanged
    });
  });
}
