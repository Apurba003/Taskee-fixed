import 'package:flutter_test/flutter_test.dart';
import 'package:taskee/app/helper/title_field_validator.dart';

void main() {
  group('todoFieldValidator', () {
    test('rejects null, empty and whitespace-only titles', () {
      expect(todoFieldValidator(null), 'Please enter a title');
      expect(todoFieldValidator(''), 'Please enter a title');
      expect(todoFieldValidator('   '), 'Please enter a title');
    });

    test('rejects titles longer than 50 characters', () {
      expect(
        todoFieldValidator('a' * 51),
        'Title cannot be longer than 50 characters',
      );
      expect(todoFieldValidator('a' * 50), isNull);
    });

    test('accepts a normal title', () {
      expect(todoFieldValidator('Buy milk'), isNull);
    });
  });

  group('noteFieldValidator', () {
    test('rejects empty and whitespace-only notes', () {
      expect(noteFieldValidator(null), 'Your note is empty');
      expect(noteFieldValidator('  '), 'Your note is empty');
    });

    test('accepts a note with text', () {
      expect(noteFieldValidator('Meeting notes'), isNull);
    });
  });
}
