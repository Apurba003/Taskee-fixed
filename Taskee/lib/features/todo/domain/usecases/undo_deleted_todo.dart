import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class UndoDeletedTodo {
  final TodoRepository repository;
  UndoDeletedTodo(this.repository);

  /// Re-inserts the task and returns its new id.
  Future<int> call(Todo todo) => repository.addTodo(todo);
}
