import 'package:flutter_test/flutter_test.dart';
import 'package:taskee/features/note/data/mappers/note_mapper.dart';
import 'package:taskee/features/note/data/model/note_hive_model.dart';
import 'package:taskee/features/note/domain/entities/note.dart';
import 'package:taskee/features/note/domain/model/note_list_model.dart';
import 'package:taskee/features/note/presentation/bloc/note_state.dart';

void main() {
  group('NoteHiveModel -> Note mapping', () {
    test('toDomain keeps the stored creation date', () {
      final created = DateTime(2026, 1, 2, 10, 30);

      final note = NoteHiveModel(
        id: 1,
        note: 'Hello',
        createdAt: created,
      ).toDomain();

      expect(note.createdAt, created);
      expect(note.note, 'Hello');
    });
  });

  group('NoteLoadedState', () {
    test('equality follows the contents of the list', () {
      final emptyA = NoteLoadedState(NoteListModel(noteList: const []));
      final emptyB = NoteLoadedState(NoteListModel(noteList: const []));
      final withOne = NoteLoadedState(
        NoteListModel(
          noteList: [Note(id: 1, note: 'x', createdAt: DateTime(2026))],
        ),
      );

      expect(emptyA, equals(emptyB));
      expect(emptyA, isNot(equals(withOne)));
    });
  });
}
