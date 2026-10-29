# Changes

This file lists the fixes made to the original Taskee project and what was and was not verified.

## Bugs fixed

### Tasks and reminders
- **New task reminders used the wrong id.** The form created tasks with `id: 0`, while storage assigned the real id. Every reminder was scheduled under id 0, so reminders overwrote each other and could never be cancelled. Storage now returns the new id, and the reminder uses it.
- **Reminder state after edits and toggles.** Un-completing a task did not restore its reminder. Editing a completed task scheduled a reminder again. Both now follow the rule: a reminder exists only while the task is open and due in the future.
- **Reminder failures no longer hide saved tasks.** A notification error (for example, permission denied) used to show the error screen even though the task was saved. Reminder errors are now ignored.
- **Writes are awaited** before the list is reloaded, so the list cannot show stale data.
- **Checking a task no longer flashes a spinner** over the whole list.
- **Deleting a task from its edit screen crashed.** The delete dialog always deleted a note through `widget.note!`, which is null for tasks, and it also switched the home tab to NOTES. It now deletes the task or note that is being edited.
- **Error state** showed debug text (`State: TodoErrorState`). It now shows a message.
- **Greeting** was always "Good Morning". It now depends on the time of day.

### Notes
- **Creation dates were lost.** The mapper ignored the stored date and used `DateTime.now()`, and editing a note reset it too. Both now keep the original date.
- **Date label** compared only the day number, so a date from another month could show as "Today". It now compares year, month and day.
- **Equality bug.** `NoteLoadedState` had empty `props`, so any two loaded states compared equal.
- **Button label** on the note edit screen said "Update Task". It now says "Update Note".
- **Controllers.** The note form created an extra `TextEditingController` and disposed none of them. Both forms now dispose their controller.

### Validation
- Whitespace-only titles and notes were accepted. They are now rejected, and titles are trimmed before saving.
- Typo "You Note is Empety" is now "Your note is empty".

## Platform configuration
- **iOS:** removed `UIBackgroundModes` (`fetch`, `remote-notification`). Local reminders do not need them.
- **iOS:** removed the hardcoded `DEVELOPMENT_TEAM` (the original author's Apple team). Xcode will use the team you select.

## Tests and CI
- `test/` contains pure Dart unit tests for the repository id fix, the validators, the note date mapping and state equality. They need no device.
- `.github/workflows/build.yml` runs the tests, builds a release APK on Ubuntu, and builds an unsigned iOS app on macOS. Each build is uploaded as an artifact.

## Not changed (decisions for the owner)
- **Bundle and application id** are still `com.junaid.taskee` (Android `applicationId`, iOS `PRODUCT_BUNDLE_IDENTIFIER`). Change both to your own unique id before installing on a device you own or publishing.
- **Android release builds** are signed with the debug key, which is fine for sideloading but not for Play Store uploads.
- **Name "Jacobe"** is hardcoded on the home screen.
- **Notes can only be deleted from the edit screen.** Swiping a note card does nothing (`onDelete: () {}`).

## Verification status
Verified in this environment:
- All 71 `.dart` files (including the new tests) parse with the tree-sitter Dart grammar, with no syntax errors.
- Every local import resolves, and every call site of a changed API matches its new signature.
- `Info.plist` and `project.pbxproj` are still well-formed after the edits, and the workflow YAML parses.

Not verified (this environment could not download the Flutter SDK, pub packages, or the Android SDK):
- Type checking and compilation.
- `flutter test` results.
- The APK and iOS builds.
- Behaviour on a real device (notifications, swipe-to-delete, layout).

Run `flutter analyze` and `flutter test` locally, or push to GitHub and check the Actions run, before relying on these changes.
