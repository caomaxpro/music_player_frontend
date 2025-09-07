import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/main.dart';
import 'package:music_player/models/recording.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/karaoke_player/state/karaoke_player_state.dart';
import 'package:music_player/screens/karaoke_track/utils/karaoke_track_helper.dart';
import 'package:music_player/services/recorder_handler.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/handler_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_dialog.dart';
import 'package:music_player/widgets/custom_text_input.dart';
import 'package:uuid/v4.dart';

Future<int?> getAudioDurationMs(String filePath) async {
  final player = AudioPlayer();
  try {
    await player.setFilePath(filePath);
    final duration = player.duration;
    await player.dispose();
    return duration?.inMilliseconds;
  } catch (e) {
    await player.dispose();
    return null;
  }
}

Future<void> saveRecording({
  required RecorderHandler recorderHandler,
  required WidgetRef ref,
  required int currentVocalPosition,
  required String title,
}) async {
  Song currentAudioFile = ref.read(currentAudioFileProvider);

  // SET endTime BEFORE using it

  final filePath = await recorderHandler.stop();
  debugPrint("Recording stopped. File saved at: $filePath");

  if (filePath != null) {
    final startTime = ref.read(startRecordingTime);
    final endTime = ref.read(endRecordingTime);

    debugPrint("startTime: $startTime");
    debugPrint("endTime: $endTime");

    // Check startTime is not null and logic is valid
    if (endTime! > startTime!) {
      SongHandler songHandler = SongHandler();
      Song? song = songHandler.getSongById(currentAudioFile.id);
      final recordingUuid = UuidV4().generate();

      if (song != null) {
        /* 

        */
        final audioStartTime = ref.read(audioPlayerStartTimeProvider);
        final recorderStartTime = ref.read(recorderStartTimeProvider);

        debugPrint('audioStartTime: $audioStartTime');
        debugPrint('recorderStartTime: $recorderStartTime');

        Duration clipPart = audioStartTime!.difference(recorderStartTime!);
        debugPrint('clipPart (ms): ${clipPart.inMilliseconds}');

        final rawRecordingMs = await getAudioDurationMs(filePath);
        debugPrint('rawRecordingMs: $rawRecordingMs');

        // final clippedRecordingPath = await clipAudio(
        //   inputPath: filePath,
        //   startMs: 0,
        //   endMs: rawRecordingMs!,
        //   storagePath: currentAudioFile.storagePath,
        //   outputFileName: "clipped_recording_$recordingUuid",
        // );

        // debugPrint('clippedRecordingPath: $clippedRecordingPath');

        // final clippedRecordingMs = await getAudioDurationMs(
        //   clippedRecordingPath!,
        // );
        // debugPrint('clippedRecordingMs: $clippedRecordingMs');

        // Clip instrumental file
        final clipedPath = await clipAudio(
          inputPath: currentAudioFile.instrumentalPath,
          startMs: startTime,
          endMs: startTime + rawRecordingMs!,
          storagePath: currentAudioFile.storagePath,
          outputFileName: "clipped_instr_$recordingUuid",
        );

        final rawClippedMs = await getAudioDurationMs(clipedPath!);
        debugPrint('rawClipMs: $rawClippedMs');

        final recording = Recording(
          title: title,
          path: filePath,
          clipedPath: clipedPath,
          start: startTime,
          end: endTime,
          durationMs: rawRecordingMs,
          createdDate: DateTime.now(),
        );

        // Link recording to song
        recording.song.target = song;

        // Save to ObjectBox
        final recordingBox = objectBox.store.box<Recording>();
        recordingBox.put(recording);

        debugPrint('Recording created and linked to song: ${song.title}');
      } else {
        debugPrint('Song not found with id: ${currentAudioFile.id}');
      }
    } else {
      debugPrint('Invalid recording times: start=$startTime, end=$endTime');
    }
  } else {
    debugPrint('Recording file path is null');
  }

  // Set recording state to false
  ref.read(isRecordingProvider.notifier).state = false;
}

Future<void> discardRecording({
  required RecorderHandler recorderHandler,
  required WidgetRef ref,
}) async {
  // Stop the recorder without saving
  final filePath = await recorderHandler.stop();

  if (filePath != null) {
    // Delete the recorded file
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Recording file deleted: $filePath');
      }
    } catch (e) {
      debugPrint('Error deleting recording file: $e');
    }
  }

  // Just set recording state to false without saving
  ref.read(isRecordingProvider.notifier).state = false;

  debugPrint('Recording discarded');
}

Future<void> showSaveRecordingDialog(
  WidgetRef ref,
  BuildContext context,
) async {
  // ignore: use_build_context_synchronously
  final titleController = TextEditingController();

  final recorderHandler = ref.read(recorderHandlerProvider);
  final audioPosition = ref.read(audioPositionProvider);

  final textColor = ref.read(textColorProvider);
  final screenWidth = MediaQuery.of(context).size.width;

  CustomDialog.show(
    context,
    title: "Save Recording",
    content: Column(
      children: [
        CustomTextInput(
          title: "Recording title",
          placeholder: "Enter a title for the recording...",
          controller: titleController,
          backgroundColor: Colors.grey[700]?.withAlpha(80),
          textColor: textColor,
          width: screenWidth * .88,
          height: 45,
          padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
          border: Border(bottom: BorderSide(width: 2, color: textColor)),
          borderRadius: BorderRadius.all(Radius.circular(0)),
          cursorColor: textColor,
        ),
      ],
    ),
    onConfirm: () async {
      await saveRecording(
        recorderHandler: recorderHandler,
        ref: ref,
        currentVocalPosition: audioPosition,
        title: titleController.text,
      );
    },
    onCancel: () async {
      await discardRecording(ref: ref, recorderHandler: recorderHandler);
    },
  );
}
