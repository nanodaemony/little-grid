import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/todo/todo_models.dart';

void main() {
  group('TodoItem', () {
    test('should create TodoItem with default values', () {
      final todo = TodoItem(title: 'Test Todo');

      expect(todo.title, 'Test Todo');
      expect(todo.isCompleted, false);
      expect(todo.priority, TodoPriority.medium);
    });

    test('should convert to and from map', () {
      final todo = TodoItem(
        id: 1,
        title: 'Test Todo',
        isCompleted: true,
        priority: TodoPriority.high,
        notes: 'Test notes',
      );

      final map = todo.toMap();
      final restored = TodoItem.fromMap(map);

      expect(restored.id, todo.id);
      expect(restored.title, todo.title);
      expect(restored.isCompleted, todo.isCompleted);
      expect(restored.priority, todo.priority);
      expect(restored.notes, todo.notes);
    });
  });
}
