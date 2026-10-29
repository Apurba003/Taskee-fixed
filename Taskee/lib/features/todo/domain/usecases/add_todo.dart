import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class AddTodo {
  final TodoRepository repository;
  AddTodo(this.repository);

  /// Returns the id assigned to the new task.
  Future<int> call(Todo todo) => repository.addTodo(todo);
}
