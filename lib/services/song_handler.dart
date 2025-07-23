import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/main.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/state/audio_state.dart';

class SongHandler {
  final box = objectBox.store.box<Song>(); // Lấy Box cho Song

  /// Create: Thêm một bài hát mới vào cơ sở dữ liệu
  int createSong(Song song) {
    return box.put(song);
  }

  /// Create: Thêm nhiều bài hát vào cơ sở dữ liệu
  List<int> createSongs(List<Song> songs) {
    return box.putMany(songs);
  }

  /// Read: Lấy tất cả bài hát
  List<Song> getAllSongs() {
    return box.getAll();
  }

  /// Read: Lấy một bài hát theo ID
  Song? getSongById(int id) {
    return box.get(id);
  }

  void updateSongInState(
    WidgetRef ref,
    int id,
    Map<String, dynamic> updatedFields,
  ) {
    final songs = ref.read(audioFilesProvider);

    // update a song in a list of audio files
    ref.read(audioFilesProvider.notifier).state =
        songs.map((song) {
          if (song["id"] == id) {
            final updatedSong = {...song, ...updatedFields};

            ref.read(currentAudioFileProvider.notifier).state = song;

            return updatedSong; // Cập nhật các trường
          }
          return song;
        }).toList();
  }

  void updateSongInDB({required int id, required Map<String, dynamic> fields}) {
    final song = box.get(id); // Tìm bài hát theo ID
    if (song != null) {
      // Cập nhật các trường nếu có trong `fields`
      song.title = fields['title'] ?? song.title;
      song.artist = fields['artist'] ?? song.artist;
      song.duration = fields['duration'] ?? song.duration;
      song.filePath = fields['filePath'] ?? song.filePath;
      song.audioImgUri = fields['audioImgUri'] ?? song.audioImgUri;
      song.lyrics = fields['lyrics'] ?? song.lyrics;
      song.amplitude = fields['amplitude'] ?? song.amplitude;
      song.isOnlineSearch = fields['isOnlineSearch'] ?? song.isOnlineSearch;
      song.vocalPath = fields["vocalPath"] ?? song.vocalPath;
      song.instrumentalPath =
          fields["instrumentalPath"] ?? song.instrumentalPath;

      // Lưu lại đối tượng đã cập nhật
      box.put(song);
      debugPrint('Fields updated for song with ID: $id');
    } else {
      debugPrint('Song with ID $id not found in database.');
    }
  }

  void updateSong({
    required WidgetRef ref,
    required int id,
    required Map<String, dynamic> updatedFields,
  }) {
    updateSongInDB(id: id, fields: updatedFields);
    updateSongInState(ref, id, updatedFields);
  }

  /// Delete: Xóa một bài hát theo ID
  bool deleteSong(int id) {
    return box.remove(id);
  }

  /* 
    remove all song's related data including audio file path, vocal path, instrumental path and then that song in db
   */
  void cleanSongData(WidgetRef ref, int id) {
    final song = box.get(id); // Lấy bài hát theo ID

    if (song != null) {
      // Trích xuất các đường dẫn
      final pathsToDelete = [
        song.vocalPath,
        song.instrumentalPath,
        song.filePath,
      ];

      // Xóa các file trong hệ thống
      for (final path in pathsToDelete) {
        if (path.isNotEmpty) {
          final file = File(path);
          if (file.existsSync()) {
            file.deleteSync();
            debugPrint('Deleted file: $path');
          } else {
            debugPrint('File not found: $path');
          }
        }
      }

      // Xóa bài hát khỏi cơ sở dữ liệu
      box.remove(id);

      // Cập nhật trạng thái Riverpod
      final songs = ref.read(audioFilesProvider);
      ref.read(audioFilesProvider.notifier).state =
          songs.where((song) => song["id"] != id).toList();

      // Nếu bài hát hiện tại là bài hát vừa bị xóa, đặt trạng thái `currentAudioFileProvider` về mặc định
      final currentAudioFile = ref.read(currentAudioFileProvider);
      if (currentAudioFile["id"] == id) {
        ref.read(currentAudioFileProvider.notifier).state = {
          "id": 0,
          "title": "",
          "artist": "",
          "duration": 0,
          "filePath": "",
          "audioImgUri": "",
          "isOnlineSearch": false,
        };
      }
    } else {
      debugPrint('Song with ID $id not found in database.');
    }
  }

  void cleanAllSongData(WidgetRef ref) {
    final songs = box.getAll(); // Lấy tất cả bài hát

    for (final song in songs) {
      // Trích xuất các đường dẫn
      final pathsToDelete = [
        song.vocalPath,
        song.instrumentalPath,
        song.filePath,
      ];

      // Xóa các file trong hệ thống
      for (final path in pathsToDelete) {
        if (path.isNotEmpty) {
          final file = File(path);
          if (file.existsSync()) {
            file.deleteSync();
            debugPrint('Deleted file: $path');
          } else {
            debugPrint('File not found: $path');
          }
        }
      }
    }

    // Xóa tất cả bài hát khỏi cơ sở dữ liệu
    box.removeAll();

    // Cập nhật trạng thái Riverpod
    ref.read(audioFilesProvider.notifier).state = [];
    ref.read(currentAudioFileProvider.notifier).state = {
      "id": 0,
      "title": "",
      "artist": "",
      "duration": 0,
      "filePath": "",
      "audioImgUri": "",
      "isOnlineSearch": false,
    };

    debugPrint('All songs and related files deleted successfully.');
  }

  /// Delete: Xóa tất cả bài hát
  void deleteAllSongs() {
    box.removeAll();
  }
}
