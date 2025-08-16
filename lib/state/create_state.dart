import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';

enum CreateState { init, infor, audioFile, lyrics, ready, complete }

final progressStateProvider = StateProvider<int>((ref) => 0);

final createStateProvider = StateProvider<CreateState>(
  (ref) => CreateState.init,
);
