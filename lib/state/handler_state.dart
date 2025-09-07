import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/services/karaoke_handler.dart';
import 'package:music_player/services/recorder_handler.dart';

// this is to ensure the app only use one handler the whole time, no need to create new handlers

final dualAudioHandlerProvider = StateProvider<DualAudioHandler>(
  (ref) => DualAudioHandler(),
);
final recorderHandlerProvider = StateProvider<RecorderHandler>(
  (ref) => RecorderHandler(),
);

final positionSubscriptionProvider =
    StateProvider<StreamSubscription<Duration>?>((ref) => null);

final audioPositionProvider = StateProvider<int>((ref) => 0);
