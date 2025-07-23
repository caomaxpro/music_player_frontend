import 'package:flutter_riverpod/flutter_riverpod.dart';

// State for audio files fetched from local storage
final audioFilesProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

// State for the current playlist
final currentPlaylistProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

// State for the currently playing audio file
final currentAudioFileProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {
    'id': 0,
    'title': "",
    'artist': "",
    'duration': 0,
    'filePath': "",
    'audioImgUri': "",
    'lyrics': "",
    'isExpanded': false,
    'isOnlineSearch': false,
  },
);

final internetConnectionProvider = StateProvider<bool>((ref) => false);
