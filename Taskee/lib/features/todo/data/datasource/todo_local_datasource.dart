import '../model/todo_hive_model.dart';

abstract class TodoLocalDataSource {
  List<TodoHiveModel> getAll();

  /// Saves the task under a new id and returns that id.
  Future<int> save(TodoHiveModel todo);
  Future<void> update(int id, TodoHiveModel todo);
  Future<void> delete(int id);
}
