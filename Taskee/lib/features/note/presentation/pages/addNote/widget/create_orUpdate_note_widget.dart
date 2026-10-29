import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskee/app/extension/size_extension.dart';
import 'package:taskee/app/extension/widget_padding_extension.dart';
import 'package:taskee/app/helper/title_field_validator.dart';
import 'package:taskee/features/note/domain/entities/note.dart';
import 'package:taskee/features/note/presentation/bloc/note_bloc.dart';
import 'package:taskee/features/note/presentation/bloc/note_event.dart';
import 'package:taskee/features/widget/app_button.dart';

class CreateOrUpdateNoteWidget extends StatefulWidget {
  final Note? note;
  const CreateOrUpdateNoteWidget({super.key, this.note});

  @override
  State<CreateOrUpdateNoteWidget> createState() =>
      _CreateOrUpdateNoteWidgetState();
}

class _CreateOrUpdateNoteWidgetState extends State<CreateOrUpdateNoteWidget> {
  late final TextEditingController _noteController;
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.note?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = widget.note != null;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _form,
            child: ListView(
              shrinkWrap: true,
              children: [
                30.kH,
                const Text('Write a Note'),
                10.kH,
                TextFormField(
                  key: const Key('addTodo_title_textFormField'),
                  controller: _noteController,
                  maxLines: 5,

                  validator: noteFieldValidator,
                ),

                30.kH,

                AppButton(
                  text: isUpdating ? 'Update Note' : 'Create Note',
                  onTap: () {
                    if (_form.currentState!.validate()) {
                      if (isUpdating) {
                        _updateNote();
                      } else {
                        _addNote();
                      }
                      if (context.mounted) context.pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 20),
    );
  }

  void _addNote() {
    final note = Note(
      id: 0,
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );
    context.read<NoteBloc>().add(NoteItemAddedEvent(note));
  }

  void _updateNote() {
    final original = widget.note!;
    final note = Note(
      id: original.id,
      note: _noteController.text.trim(),
      // Keep the original creation time when editing.
      createdAt: original.createdAt,
    );
    context.read<NoteBloc>().add(NoteItemUpdatedEvent(note));
  }
}
