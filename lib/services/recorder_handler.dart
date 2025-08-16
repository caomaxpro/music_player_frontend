import 'package:record/record.dart';

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
  Future<bool> start({String path = 'karaoke_record.m4a'}) async {
    if (await requestPermission()) {
      await _recorder.start(config, path: path);
      _filePath = path;
      return true;
    }
    return false;
  }

  /// Dừng ghi âm, trả về đường dẫn file ghi âm (nếu có)
  Future<String?> stop() async {
    final path = await _recorder.stop();
    _filePath = path;
    return path;
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
