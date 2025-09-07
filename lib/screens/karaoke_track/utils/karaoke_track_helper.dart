import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/recording.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> clipAudio({
  required String inputPath,
  required int startMs,
  required int endMs,
  String? storagePath,
  String? outputFileName,
}) async {
  try {
    // Check if input file exists
    if (!File(inputPath).existsSync()) {
      debugPrint('Input file does not exist: $inputPath');
      return null;
    }

    // Calculate duration in seconds
    final startSec = startMs / 1000.0;
    final durationSec = (endMs - startMs) / 1000.0;

    // Get directory for output
    if (storagePath == null) {
      final outputDir = await getTemporaryDirectory();
      storagePath = outputDir.path;
    }

    // Ensure output directory exists
    final Directory outputDirectory = Directory(storagePath);
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    // Create output filename
    final outputName =
        outputFileName ?? 'clipped_${DateTime.now().millisecondsSinceEpoch}';
    final outputPath = '$storagePath/$outputName.mp3';

    debugPrint('Input: $inputPath');
    debugPrint('Output: $outputPath');
    debugPrint('Clipping from ${startSec}s for ${durationSec}s');

    // Execute FFmpeg command
    final command =
        '-i "$inputPath" -ss $startSec -t $durationSec -acodec libmp3lame "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final logs = await session.getLogsAsString();

    if (ReturnCode.isSuccess(returnCode)) {
      debugPrint('Successfully clipped audio: $outputPath');
      return outputPath;
    } else {
      debugPrint('FFmpeg failed with return code: $returnCode');
      debugPrint('FFmpeg logs: $logs');
      return null;
    }
  } catch (e) {
    debugPrint('Exception during audio clipping: $e');
    return null;
  }
}

void deleteRecording(Recording recording, WidgetRef ref) {
  // Get the current audio file
  final currentFile = ref.read(currentAudioFileProvider);

  // Remove the recording from the ToMany collection
  currentFile.recordings.removeWhere((r) => r.id == recording.id);

  // Update the provider with the modified file
  ref.read(currentAudioFileProvider.notifier).state = currentFile;

  // Update song list state
  final songList = ref.read(audioFilesProvider).toList();
  final songId = songList.indexWhere((song) => song.uuid == currentFile.uuid);
  if (songId != -1) {
    songList[songId] = currentFile;
    ref.read(audioFilesProvider.notifier).state = songList;
  }

  // Update db as well
  SongHandler songHandler = SongHandler();
  songHandler.updateSongInDB(updatedSong: currentFile);
}

void deleteManyRecordings(List<int> recordingIds, WidgetRef ref) {
  // Get the current audio file
  final currentFile = ref.read(currentAudioFileProvider);

  // Xóa tất cả recordings có id nằm trong recordingIds
  final idsToDelete = recordingIds.toSet();
  currentFile.recordings.removeWhere((r) => idsToDelete.contains(r.id));

  // Update the provider with the modified file
  ref.read(currentAudioFileProvider.notifier).state = currentFile;

  // Update song list state
  final songList = ref.read(audioFilesProvider).toList();
  final songId = songList.indexWhere((song) => song.uuid == currentFile.uuid);
  if (songId != -1) {
    songList[songId] = currentFile;
    ref.read(audioFilesProvider.notifier).state = songList;
  }

  // Update db as well
  SongHandler songHandler = SongHandler();
  songHandler.updateSongInDB(updatedSong: currentFile);
}

void deleteAllRecordings(WidgetRef ref) {
  // Get the current audio file
  final currentFile = ref.read(currentAudioFileProvider);

  // Xóa toàn bộ recordings
  currentFile.recordings.clear();

  // Update the provider with the modified file
  ref.read(currentAudioFileProvider.notifier).state = currentFile;

  // Update song list state
  final songList = ref.read(audioFilesProvider).toList();
  final songId = songList.indexWhere((song) => song.uuid == currentFile.uuid);
  if (songId != -1) {
    songList[songId] = currentFile;
    ref.read(audioFilesProvider.notifier).state = songList;
  }

  // Update db as well
  SongHandler songHandler = SongHandler();
  songHandler.updateSongInDB(updatedSong: currentFile);
}

enum RecordingSortField { title, createdDate }

void sortRecordings({
  required WidgetRef ref,
  required RecordingSortField field,
  bool ascending = true,
}) {
  final currentFile = ref.read(currentAudioFileProvider);

  currentFile.recordings.sort((a, b) {
    int cmp;
    switch (field) {
      case RecordingSortField.title:
        cmp = a.title.compareTo(b.title);
        break;
      case RecordingSortField.createdDate:
        cmp = a.createdDate.compareTo(b.createdDate);
        break;
    }
    return ascending ? cmp : -cmp;
  });

  // Update the provider with the sorted file
  ref.read(currentAudioFileProvider.notifier).state = currentFile;

  // Update song list state
  final songList = ref.read(audioFilesProvider).toList();
  final songId = songList.indexWhere((song) => song.uuid == currentFile.uuid);
  if (songId != -1) {
    songList[songId] = currentFile;
    ref.read(audioFilesProvider.notifier).state = songList;
  }

  // Update db as well
  SongHandler songHandler = SongHandler();
  songHandler.updateSongInDB(updatedSong: currentFile);
}
