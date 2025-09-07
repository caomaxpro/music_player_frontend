import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/karaoke_player/helper/response_handler.dart';
import 'package:music_player/screens/karaoke_player/state/karaoke_player_state.dart';
import 'package:record/record.dart';
import 'package:uuid/v4.dart';

class RecorderHandler {
  final AudioRecorder _recorder = AudioRecorder();
  String? _filePath;

  final config = RecordConfig(
    encoder: AudioEncoder.aacLc,
    bitRate: 128000,
    sampleRate: 44100,
  );

  /// Xin quyền microphone, trả về true nếu được cấp quyền
  Future<bool> requestPermission() async {
    return await _recorder.hasPermission();
  }

  /// Bắt đầu ghi âm, trả về true nếu thành công
  Future<bool> start({String? folderName, WidgetRef? ref}) async {
    if (await requestPermission()) {
      // get storage directory from app storage folder

      folderName =
          (folderName == null || folderName.isEmpty)
              ? "karaoke_record.m4a"
              : folderName;

      final fileId = UuidV4().generate();

      String storagePath =
          "${appStorageFolder.path}/$folderName/recording_$fileId";

      await _recorder.start(config, path: storagePath);

      _filePath = storagePath;

      debugPrint(
        "RecorderHandler: started at ${DateTime.now().toIso8601String()}",
      );

      ref?.read(recorderStartTimeProvider.notifier).state = DateTime.now();

      return true;
    }
    return false;
  }

  /// Dừng ghi âm, trả về đường dẫn file ghi âm (nếu có)
  Future<String?> stop() async {
    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop();
        debugPrint("Recording stopped. Path returned: $path");
        debugPrint(
          "File exists: ${path != null ? File(path).existsSync() : false}",
        );
        return path;
      } else {
        debugPrint("Recorder was not recording");
        return null;
      }
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      return null;
    }
  }

  /// Tạm dừng ghi âm (nếu cần)
  Future<void> pause() async {
    await _recorder.pause();
  }

  /// Tiếp tục ghi âm sau khi pause
  Future<void> resume() async {
    await _recorder.resume();
  }

  /// Kiểm tra có đang ghi âm không
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// Lấy đường dẫn file ghi âm hiện tại (nếu có)
  String? get filePath => _filePath;

  /// Hủy tài nguyên nếu cần (không bắt buộc với package record)
  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
