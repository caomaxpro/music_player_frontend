import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/recording.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';

// Xóa một bản ghi âm khỏi một audio file
void deleteSongFromLibrary({required Song song, required WidgetRef ref}) {
  final songList = ref.read(audioFilesProvider).toList();
  songList.removeWhere((s) => s.uuid == song.uuid);
  ref.read(audioFilesProvider.notifier).state = songList;
  SongHandler songHandler = SongHandler();
  songHandler.deleteSong(song.id);
}

// Xóa nhiều bản ghi âm khỏi một audio file
void deleteManySongsFromLibrary({
  required List<int> songIds,
  required WidgetRef ref,
}) {
  final songList = ref.read(audioFilesProvider).toList();
  final filteredList =
      songList.where((song) => songIds.contains(song.id)).toList();
  ref.read(audioFilesProvider.notifier).state = filteredList;

  SongHandler songHandler = SongHandler();
  songHandler.deleteManySongsByIds(songIds);
}

// Xóa toàn bộ recordings của một audio file
void deleteAllSongsFromLibrary({
  required WidgetRef ref,
  required String audioFileUuid,
}) {
  ref.read(audioFilesProvider.notifier).state = [];
  SongHandler songHandler = SongHandler();
  songHandler.deleteAllSongs();
}

// Sắp xếp recordings của một audio file theo trường bất kỳ
enum SongSortField { title, createdDate }

void sortSongsInLibrary({
  required WidgetRef ref,
  required SongSortField field,
  bool ascending = true,
}) {
  final songList = ref.read(audioFilesProvider).toList();
  songList.sort((a, b) {
    int cmp;
    switch (field) {
      case SongSortField.title:
        cmp = a.title.compareTo(b.title);
        break;
      case SongSortField.createdDate:
        cmp = a.createdDate.compareTo(b.createdDate);
        break;
    }
    return ascending ? cmp : -cmp;
  });
  ref.read(audioFilesProvider.notifier).state = songList;
}

void filterSongsByTitle({required WidgetRef ref, required String text}) {
  final songList = ref.read(audioFilesProvider).toList();

  if (text != "") {
    final query = text.trim().toLowerCase();

    final filteredResults =
        songList
            .where((song) => song.title.toLowerCase().contains(query))
            .toList();

    ref.read(audioFilesProvider.notifier).state = filteredResults;
  } else {
    SongHandler songHandler = SongHandler();
    ref.read(audioFilesProvider.notifier).state = songHandler.getAllSongs();
  }
}
