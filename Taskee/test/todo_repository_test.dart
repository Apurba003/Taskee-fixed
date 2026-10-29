import 'package:flutter_test/flutter_test.dart';
import 'package:taskee/features/todo/data/datasource/todo_local_datasource.dart';
import 'package:taskee/features/todo/data/model/todo_hive_model.dart';
import 'package:taskee/features/todo/data/repositorie/todo_repository_impl.dart';
import 'package:taskee/features/todo/domain/entities/todo.dart';

/// In-memory stand-in for the Hive datasource, so these tests need no device.
class FakeTodoLocalDataSource implements TodoLocalDataSource {
  final List<TodoHiveModel> rows = [];
  int _lastId = 0;

  @override
  List<TodoHiveModel> getAll() => List.of(rows);

  @override
  Future<int> save(TodoHiveModel todo) async {
    _lastId++;
    rows.add(
      TodoHiveModel(
        id: _lastId,
        title: todo.title,
        isCompleted: todo.isCompleted,
        dueAt: todo.dueAt,
      ),
    );
    return _lastId;
  }

  @override
  Future<void> update(int id, TodoHiveModel todo) async {
    final index = rows.indexWhere((row) => row.id == id);
    if (index != -1) rows[index] = todo;
  }

  @override
  Future<void> delete(int id) async {
    rows.removeWhere((row) => row.id == id);
  }
}

Todo _newTask(String title) {
  return Todo(
    id: 0,
    title: title,
    isCompleted: false,
    dueAt: DateTime(2030, 1, 1, 9),
  );
}

void main() {
  group('TodoRepositoryImpl', () {
    test('addTodo returns the id assigned by storage', () async {
      final repo = TodoRepositoryImpl(FakeTodoLocalDataSource());

      final first = await repo.addTodo(_newTask('Buy milk'));
      final second = await repo.addTodo(_newTask('Call bank'));

      expect(first, 1);
      expect(second, 2);
    });

    test('the stored task carries the id that addTodo returned', () async {
      final repo = TodoRepositoryImpl(FakeTodoLocalDataSource());

      final id = await repo.addTodo(_newTask('Gym'));

      expect(repo.getTodoList().single.id, id);
      expect(repo.getTodoList().single.title, 'Gym');
    });

    test('toggleCompleteTodo flips the completed flag', () async {
      final repo = TodoRepositoryImpl(FakeTodoLocalDataSource());
      await repo.addTodo(_newTask('Read'));
      final stored = repo.getTodoList().single;

      await repo.toggleCompleteTodo(stored);

      expect(repo.getTodoList().single.isCompleted, isTrue);
      expect(repo.getTodoList().single.id, stored.id);
    });

    test('deleteTodo removes only the given task', () async {
      final repo = TodoRepositoryImpl(FakeTodoLocalDataSource());
      final keepId = await repo.addTodo(_newTask('Keep'));
      final removeId = await repo.addTodo(_newTask('Remove'));

      await repo.deleteTodo(removeId);

      final remaining = repo.getTodoList();
      expect(remaining.length, 1);
      expect(remaining.single.id, keepId);
    });
  });
}
