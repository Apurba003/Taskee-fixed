class Todo {
  final int id;
  final String title;
  final bool isCompleted;
  final DateTime dueAt;

  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.dueAt,
  });

  Todo copyWith({int? id, String? title, bool? isCompleted, DateTime? dueAt}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueAt: dueAt ?? this.dueAt,
    );
  }
}
