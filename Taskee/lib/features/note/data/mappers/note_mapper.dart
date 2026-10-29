import 'package:taskee/features/note/data/model/note_hive_model.dart';
import 'package:taskee/features/note/domain/entities/note.dart';

extension NoteHiveModelToDomain on NoteHiveModel {
  Note toDomain() {
    // Keep the stored creation time. Using DateTime.now() here made every
    // note look like it was created today.
    return Note(id: id, note: note, createdAt: createdAt);
  }
}

extension NoteDomainToHiveModel on Note {
  NoteHiveModel toHiveModel() {
    return NoteHiveModel(id: id, note: note, createdAt: createdAt);
  }
}
