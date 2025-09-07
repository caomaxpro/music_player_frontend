import 'package:flutter_riverpod/flutter_riverpod.dart';

final isRecordingProvider = StateProvider<bool>((ref) => false);
final startRecordingTime = StateProvider<int?>((ref) => 0);
final endRecordingTime = StateProvider<int?>((ref) => 0);

final recorderStartTimeProvider = StateProvider<DateTime?>(
  (ref) => DateTime.now(),
);
final audioPlayerStartTimeProvider = StateProvider<DateTime?>(
  (ref) => DateTime.now(),
);
