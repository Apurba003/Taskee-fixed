import 'package:bloc/bloc.dart';

import '../../domain/entities/todo.dart';
import '../../domain/models/todo_list_model.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/cancel_task_notification.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_all_todos.dart';
import '../../domain/usecases/schedule_task_notification.dart';
import '../../domain/usecases/toggle_complete_todo.dart';
import '../../domain/usecases/undo_deleted_todo.dart';
import '../../domain/usecases/update_todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetAllTodos getAllTodos;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final ToggleCompleteTodo toggleCompleteTodo;
  final DeleteTodo deleteTodo;
  final UndoDeletedTodo undoDeletedTodo;
  final ScheduleTaskNotification scheduleTaskNotification;
  final CancelTaskNotification cancelTaskNotification;

  TodoBloc({
    required this.getAllTodos,
    required this.addTodo,
    required this.updateTodo,
    required this.toggleCompleteTodo,
    required this.deleteTodo,
    required this.undoDeletedTodo,
    required this.scheduleTaskNotification,
    required this.cancelTaskNotification,
  }) : super(TodoLoadingState()) {
    on<TodoStartedEvent>(_onStarted);
    on<TodoItemAddedEvent>(_onItemAdded);
    on<TodoItemUpdatedEvent>(_onItemUpdated);
    on<TodoItemToggleCompletedEvent>(_onItemToggleCompleted);
    on<TodoItemDeletedEvent>(_onItemDeleted);
    on<TodoItemUndoDeletedEvent>(_onItemUndoDeleted);
  }

  void _onStarted(TodoStartedEvent event, Emitter<TodoState> emit) {
    emit(TodoLoadingState());
    try {
      _emitLoaded(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemAdded(
    TodoItemAddedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      // Storage assigns the real id. The reminder must use that id,
      // otherwise it can never be cancelled later.
      final newId = await addTodo(event.todo);
      await _syncReminder(event.todo.copyWith(id: newId));
      _emitLoaded(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemUpdated(
    TodoItemUpdatedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await updateTodo(event.todo);
      await _syncReminder(event.todo);
      _emitLoaded(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemToggleCompleted(
    TodoItemToggleCompletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await toggleCompleteTodo(event.todo);
      // event.todo still holds the state from before the toggle.
      await _syncReminder(
        event.todo.copyWith(isCompleted: !event.todo.isCompleted),
      );
      _emitLoaded(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemDeleted(
    TodoItemDeletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    // Leave the loaded state first. The swiped row must be removed from the
    // tree, otherwise Dismissible throws.
    emit(TodoLoadingState());
    try {
      await deleteTodo(event.id);
      await cancelTaskNotification(event.id);
      _emitLoaded(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemUndoDeleted(
    TodoItemUndoDeletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final newId = await undoDeletedTodo(event.todo);
      await _syncReminder(event.todo.copyWith(id: newId));
      _emitLoaded(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  void _emitLoaded(Emitter<TodoState> emit) {
    emit(TodoLoadedState(TodoListModel(todoList: getAllTodos())));
  }

  /// Cancels the old reminder, then schedules a new one only if the task is
  /// still open. A notification failure (for example, permission denied)
  /// must not hide a task that was already saved, so errors are ignored here.
  Future<void> _syncReminder(Todo todo) async {
    try {
      await cancelTaskNotification(todo.id);
      if (!todo.isCompleted) {
        await scheduleTaskNotification(todo);
      }
    } catch (_) {
      // Reminder is best-effort; the task itself is already stored.
    }
  }
}
