String? todoFieldValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter a title';
  }
  if (value.trim().length > 50) {
    return 'Title cannot be longer than 50 characters';
  }
  return null;
}

String? noteFieldValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Your note is empty';
  }
  return null;
}
