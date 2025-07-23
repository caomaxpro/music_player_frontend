import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/main.dart';
import 'package:music_player/screens/karaoke/karaoke.dart';
import 'package:music_player/screens/music_player/ui/sound_wave.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/utils/fetch_amplitude_data.dart';

class SongController extends ConsumerStatefulWidget {
  const SongController({super.key});

  @override
  ConsumerState<SongController> createState() => _SongControllerState();
}

class _SongControllerState extends ConsumerState<SongController> {
  double _sliderValue = 0.0;
  bool _isDragging = false;
  bool _isPlaying = false;
  bool _isAnalyzingAmp = false;
  List<double> amplitudeData = List.generate(
    100,
    (index) =>
        Random().nextDouble() * 0.8 + 0.2, // Random values between 0.2 and 1.0
  );

  Map<String, dynamic>? currentAudioFile;
  String? filePath;
  double? duration; // Thêm biến duration

  @override
  void initState() {
    super.initState();
    final currentAudioFile = ref.read(currentAudioFileProvider);
    filePath = currentAudioFile["filePath"];

    debugPrint("[FILE PATH]: $filePath");

    // Load audio file to audio_handler
    if (filePath != "") {
      audioHandler.customAction('load', {
        'paths': [filePath!],
      });
    }

    // _initializeAmplitudeData();
    _initializeDuration();

    // Listen to playback state
    audioHandler.playbackState.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    audioHandler.playbackState.listen((state) async {
      if (!_isDragging && mounted) {
        setState(() {
          _sliderValue = state.updatePosition.inSeconds.toDouble();
        });

        // Kiểm tra nếu bài hát đã kết thúc
        final currentPosition = state.updatePosition.inSeconds.toDouble();
        final totalDuration = duration ?? 0.0;

        if (currentPosition >= totalDuration && totalDuration > 0) {
          debugPrint(
            '[SongController] Song ended. Pausing player and handling end.',
          );

          // Tạm dừng player
          await audioHandler.customAction('pause');

          // Gọi handleAudioFileEnd để xử lý logic khi bài hát kết thúc
          await audioHandler.customAction('handleAudioFileEnd');
        }
      }
    });
  }

  Future<void> _initializeDuration() async {
    try {
      final result = await audioHandler.customAction('getDuration');
      setState(() {
        duration = (result as int).toDouble();
      });
    } catch (e) {
      debugPrint('Error fetching duration: $e');
      setState(() {
        duration = 0.0; // Default to 0 if there's an error
      });
    }
  }

  Future<void> _initializeAmplitudeData() async {
    try {
      // Kiểm tra nếu `amplitude` rỗng hoặc không tồn tại
      final currentAudioFile = ref.watch(currentAudioFileProvider);
      final amplitude = currentAudioFile['amplitude'];

      if (amplitude != null && amplitude.isNotEmpty) {
        debugPrint('Amplitude data already exists. Skipping fetch.');
        setState(() => _isAnalyzingAmp = false);
        amplitudeData = List<double>.from(amplitude); // Sử dụng dữ liệu hiện có
        return;
      }

      // Kiểm tra trạng thái kết nối internet
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('No internet connection. Skipping amplitude fetch.');
        setState(() => _isAnalyzingAmp = false);
        return;
      }

      if (filePath != null) {
        debugPrint('Fetching amplitude data for file: $filePath');
        final data = await fetchAmplitude(filePath!);

        // 1. Lưu dữ liệu RMS vào `currentAudioFileProvider`
        final currentAudioFile = ref.watch(currentAudioFileProvider);

        // final currentAudioFile = ref.watch(audioStateProvider).currentAudioFile;

        ref.read(currentAudioFileProvider.notifier).state = {
          ...currentAudioFile,
          'amplitude': data,
        };

        // 2. Cập nhật `audioFilesProvider`
        // final audioFiles = ref.read(audioFilesProvider);
        // final updatedAudioFiles =
        //     audioFiles.map((file) {
        //       if (file['id'] == currentAudioFile['id']) {
        //         return {
        //           ...file,
        //           'amplitude': data, // Ghi đè dữ liệu amplitude
        //         };
        //       }
        //       return file;
        //     }).toList();

        // ref.read(audioFilesProvider.notifier).state = updatedAudioFiles;

        // 3. Lưu dữ liệu RMS vào cơ sở dữ liệu
        final songHandler = SongHandler();
        songHandler.updateSong(
          ref: ref,
          id: currentAudioFile['id'],
          updatedFields: {'amplitude': jsonEncode(data)},
        );

        setState(() {
          amplitudeData = data;
          _isAnalyzingAmp = false;
        });
        debugPrint('Amplitude data fetched and saved successfully.');
      } else {
        debugPrint('No file path available in currentAudioFileProvider.');
        setState(() => _isAnalyzingAmp = false);
      }
    } catch (e) {
      debugPrint('Error initializing amplitude data: $e');
      setState(() => _isAnalyzingAmp = false);
    } finally {
      debugPrint('Amplitude data initialization process completed.');
    }
  }

  String _formatTime(double seconds) {
    final min = seconds ~/ 60;
    final sec = (seconds % 60).floor();
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isAnalyzingAmp)
          const Center(child: CircularProgressIndicator())
        else
          SoundWaveSlider(
            value: _sliderValue,
            onChanged: (v) {
              setState(() => _sliderValue = v);
              audioHandler.customAction('seek', {'position': v.toInt()});
            },
            onChangeStart: (v) {
              setState(() => _isDragging = true); // Start dragging
            },
            onChangeEnd: (v) async {
              setState(() => _isDragging = false); // Stop dragging
              await audioHandler.customAction('seek', {'position': v.toInt()});
            },
            max: duration ?? 0.0, // Sử dụng duration
            rms: amplitudeData,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(_sliderValue),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              _formatTime(duration ?? 0.0), // Sử dụng duration
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.repeat), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.skip_previous, size: 36),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 56,
              ),
              onPressed: () async {
                if (!_isPlaying) {
                  if (filePath != null) {
                    // Kiểm tra nếu bài hát đã kết thúc
                    final playbackState = audioHandler.playbackState.value;
                    final currentPosition =
                        playbackState.updatePosition.inSeconds.toDouble();
                    final totalDuration = duration ?? 0.0;

                    if (currentPosition >= totalDuration && totalDuration > 0) {
                      debugPrint(
                        '[SongController] Song ended. Restarting from the beginning.',
                      );
                      // Đặt lại vị trí phát về 0
                      await audioHandler.customAction('seek', {'position': 0});
                    }

                    // Bắt đầu phát
                    await audioHandler.customAction('play', {
                      'playlist': [filePath],
                      'loop': true, // Optional: Enable looping
                      'vol': 1.0, // Optional: Set volume (0.0 to 1.0)
                    });
                  }
                } else {
                  if (filePath != null) {
                    audioHandler.customAction('pause');
                  }
                }

                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.skip_next, size: 36),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.mic_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const KaraokeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
