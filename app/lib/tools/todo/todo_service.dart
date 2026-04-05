import '../../core/services/database_service.dart';
import 'todo_models.dart';

class TodoService {
  static Future<int> addTodo(TodoItem todo) async {
    final db = await DatabaseService.database;
    return await db.insert('todo_items', todo.toMap());
  }

  static Future<List<TodoItem>> getTodos({bool? isCompleted}) async {
    final db = await DatabaseService.database;

    String? where;
    List<dynamic>? whereArgs;

    if (isCompleted != null) {
      where = 'is_completed = ?';
      whereArgs = [isCompleted ? 1 : 0];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'todo_items',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'priority DESC, created_at DESC',
    );

    return maps.map((map) => TodoItem.fromMap(map)).toList();
  }

  static Future<void> updateTodo(TodoItem todo) async {
    final db = await DatabaseService.database;
    await db.update(
      'todo_items',
      todo.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  static Future<void> toggleComplete(int id, bool isCompleted) async {
    final db = await DatabaseService.database;
    await db.update(
      'todo_items',
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteTodo(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
