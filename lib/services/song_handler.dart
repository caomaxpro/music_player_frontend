import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/main.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/objectbox.g.dart';
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
        songs
            .map((song) {
              if (song.id == id) {
                final updatedSong = Song(
                  id: song.id,
                  title: updatedFields['title'] ?? song.title,
                  artist: updatedFields['artist'] ?? song.artist,
                  duration: updatedFields['duration'] ?? song.duration,
                  filePath: updatedFields['filePath'] ?? song.filePath,
                  imagePath: updatedFields['audioImgUri'] ?? song.imagePath,
                  lyrics: updatedFields['lyrics'] ?? song.lyrics,
                  amplitude: updatedFields['amplitude'] ?? song.amplitude,
                  vocalPath: updatedFields['vocalPath'] ?? song.vocalPath,
                  instrumentalPath:
                      updatedFields['instrumentalPath'] ??
                      song.instrumentalPath,
                );

                ref.read(currentAudioFileProvider.notifier).state = updatedSong;

                return updatedSong; // Cập nhật các trường
              }
              return song;
            })
            .toList()
            .cast<Song>();
  }

  void updateSongInDB({required Song updatedSong}) {
    final song = box.get(updatedSong.id); // Find song by ID
    if (song != null) {
      // Update all fields from updatedSong
      song.title = updatedSong.title;
      song.artist = updatedSong.artist;
      song.duration = updatedSong.duration;
      song.filePath = updatedSong.filePath;
      song.vocalPath = updatedSong.vocalPath;
      song.instrumentalPath = updatedSong.instrumentalPath;
      song.imagePath = updatedSong.imagePath;
      song.lyrics = updatedSong.lyrics;
      song.amplitude = updatedSong.amplitude;
      song.timestampLyrics = updatedSong.timestampLyrics;
      song.storagePath = updatedSong.storagePath;
      song.uuid = updatedSong.uuid;
      song.createdDate = updatedSong.createdDate;
      song.recentDate = updatedSong.recentDate;

      // Handle ToMany relationship for recordings
      song.recordings.clear();
      song.recordings.addAll(updatedSong.recordings);

      // Save the updated object
      box.put(song);
      debugPrint('Song updated for ID: ${updatedSong.id}');
    } else {
      debugPrint('Song with ID ${updatedSong.id} not found in database.');
    }
  }

  // void updateSong({
  //   required WidgetRef ref,
  //   required int id,
  //   required Map<String, dynamic> updatedFields,
  // }) {
  //   updateSongInDB(id: id, fields: updatedFields);
  //   updateSongInState(ref, id, updatedFields);
  // }

  /// Delete: Xóa một bài hát theo ID
  bool deleteSong(int id) {
    return box.remove(id);
  }

  void deleteManySongsByIds(List<int> ids) {
    final songsToDelete = box.query(Song_.id.oneOf(ids)).build().find();
    for (final song in songsToDelete) {
      box.remove(song.id);
    }
  }

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
          songs.where((song) => song.id != id).toList();

      // Nếu bài hát hiện tại là bài hát vừa bị xóa, đặt trạng thái `currentAudioFileProvider` về mặc định
      final currentAudioFile = ref.read(currentAudioFileProvider);
      if (currentAudioFile.id == id) {
        ref.read(currentAudioFileProvider.notifier).state = Song();
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
    ref.read(currentAudioFileProvider.notifier).state = Song();

    debugPrint('All songs and related files deleted successfully.');
  }

  /// Delete: Xóa tất cả bài hát
  void deleteAllSongs() {
    box.removeAll();
  }
}
