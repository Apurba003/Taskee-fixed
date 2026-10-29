import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasource/todo_local_datasource.dart';
import '../mappers/todo_mapper.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  TodoRepositoryImpl(this.localDataSource);

  @override
  Future<int> addTodo(Todo todo) => localDataSource.save(todo.toHiveModel());

  @override
  Future<void> toggleCompleteTodo(Todo todo) {
    return localDataSource.update(
      todo.id,
      todo.copyWith(isCompleted: !todo.isCompleted).toHiveModel(),
    );
  }

  @override
  Future<void> deleteTodo(int id) => localDataSource.delete(id);

  @override
  List<Todo> getTodoList() {
    return localDataSource.getAll().map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> updateTodo(Todo todo) {
    return localDataSource.update(todo.id, todo.toHiveModel());
  }
}
