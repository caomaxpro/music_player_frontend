import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CreateState { init, infor, audioFile, lyrics, ready, complete }

final createStateProvider = StateProvider<CreateState>(
  (ref) => CreateState.init,
);

final adjustTimestampProvider = StateProvider<bool>((ref) => false);
