import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// State for audio files fetched from local storage
enum LibraryFunction { deleteMany, delete, sort, edit, filter }

final functionProvider = StateProvider<LibraryFunction?>((ref) => null);

void setLibraryFunction(WidgetRef ref, LibraryFunction? value) {
  ref.read(functionProvider.notifier).state = value;
}
