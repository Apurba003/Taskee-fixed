import '../entities/todo.dart';

abstract class TodoRepository {
  List<Todo> getTodoList();

  /// Stores the task and returns the id that storage assigned to it.
  Future<int> addTodo(Todo todo);
  Future<void> toggleCompleteTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(int id);
}
