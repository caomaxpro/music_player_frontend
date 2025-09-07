import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/karaoke_player/state/karaoke_player_state.dart';
import 'package:music_player/screens/karaoke_player/ui/audio_player_slider.dart';
import 'package:music_player/screens/karaoke_player/ui/helper/karaoke_player_helper.dart';
import 'package:music_player/screens/karaoke_player/ui/karaoke_lyrics.dart';
import 'package:music_player/screens/karaoke_player/ui/microphone_button.dart';
import 'package:music_player/screens/karaoke_player/ui/recording_controller.dart';
import 'package:music_player/screens/karaoke_player/ui/sound_wave.dart';
import 'package:music_player/screens/library/library_screen.dart';
import 'package:music_player/services/karaoke_handler.dart';
import 'package:music_player/services/recorder_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/create_state.dart';
import 'package:music_player/state/handler_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_dialog.dart';
import 'package:music_player/widgets/custom_text_input.dart';

class KaraokePlayerScreen extends ConsumerStatefulWidget {
  static const String routeName = "karaokePlayer";

  const KaraokePlayerScreen({super.key});

  @override
  ConsumerState<KaraokePlayerScreen> createState() =>
      _KaraokePlayerScreenState();
}

class _KaraokePlayerScreenState extends ConsumerState<KaraokePlayerScreen> {
  bool isRecording = false;
  double vocalVolume = 1;
  double instrumentalVolume = 1;
  double soundWaveValue = 0.0;
  final double soundWaveMax = 100.0;
  final Random _random = Random();
  late List<double> rms;

  bool expandLyrics = true;

  StreamSubscription<Duration>? _positionSub;
  late DualAudioHandler audioHandler; // Thêm biến này

  String _formatDuration(Duration? d) {
    if (d == null) return "--:--";
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    audioHandler = ref.read(dualAudioHandlerProvider); // Lưu lại instance

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createStateProvider.notifier).state = CreateState.complete;
    });

    final currentAudioFile = ref.read(currentAudioFileProvider);

    debugPrint("[Vocal Path]: ${currentAudioFile.vocalPath}");
    debugPrint("[Instrumental Path]: ${currentAudioFile.instrumentalPath}");

    rms =
        (jsonDecode(currentAudioFile.amplitude) as List)
            .map((e) => (e as num).toDouble())
            .toList();

    audioHandler.loadVocal(currentAudioFile.vocalPath);
    audioHandler.loadInstrumental(currentAudioFile.instrumentalPath);
    audioHandler.setVocalVolume(vocalVolume);
    audioHandler.setInstrumentalVolume(instrumentalVolume);

    // Listen to position changes and update soundWaveValue
    _positionSub = audioHandler.vocalPlayer.positionStream.listen((position) {
      final duration = audioHandler.vocalPlayer.duration;
      if (duration != null && duration.inMilliseconds > 0) {
        final value =
            (position.inMilliseconds / duration.inMilliseconds) * soundWaveMax;
        if (mounted) {
          setState(() {
            soundWaveValue = value.clamp(0, soundWaveMax);
            ref.read(audioPositionProvider.notifier).state =
                duration.inMilliseconds;
          });
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if the screen is being revisited
    if (ModalRoute.of(context)?.isCurrent == true) {
      // Run your desired function here
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(createStateProvider.notifier).state = CreateState.complete;
      });
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    audioHandler.stopBoth(); // Dùng biến đã lưu, không dùng ref.read
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.watch(dualAudioHandlerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: Colors.white70,
          onPressed: () {
            Navigator.pushNamed(context, LibraryScreen.routeName);
          },
        ),
        title: const Text(
          'Karaoke',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Sound wave
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SoundWaveSlider(
                    value: soundWaveValue,
                    max: soundWaveMax,
                    rms: rms,
                    onChangeStart: (double v) async {
                      await audioHandler.pauseBoth();

                      // Check if recording is active
                      final isRecording = ref.read(isRecordingProvider);
                      if (isRecording) {
                        // Get current playback time
                        // final playbackTime =
                        //     audioHandler.vocalPlayer.position.inMilliseconds;

                        // Call a method to handle recording interruption
                        // ignore: use_build_context_synchronously
                        await showSaveRecordingDialog(ref, context);
                      }
                    },
                    onChanged: (v) {
                      setState(() => soundWaveValue = v); // chỉ update UI
                    },
                    onChangeEnd: (v) async {
                      final duration = audioHandler.vocalPlayer.duration;
                      if (duration != null && duration.inMilliseconds > 0) {
                        final seekTo = Duration(
                          milliseconds:
                              (v / soundWaveMax * duration.inMilliseconds)
                                  .toInt(),
                        );
                        await audioHandler.vocalPlayer.seek(seekTo);
                        await audioHandler.instrumentalPlayer.seek(seekTo);
                        // await audioHandler.playBoth();
                      }
                    },
                    highlightColor: Colors.white70,
                    backgroundColor: Colors.white70.withAlpha(50),
                  ),
                ),

                // audio playback time
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 9, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(audioHandler.vocalPlayer.position),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDuration(audioHandler.vocalPlayer.duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // Microphone button
                MicrophonePlayPauseButton(audioHandler: audioHandler),

                const SizedBox(height: 24),

                // Recording toggle
                if (expandLyrics) ...[
                  RecordingController(dualAudioHandler: audioHandler),
                  const SizedBox(height: 16),

                  // Vocal volume
                  AudioPlayerSlider(
                    player: audioHandler.vocalPlayer,
                    title: "Vocal",
                    icon: Icon(
                      Icons.record_voice_over_outlined,
                      color: Colors.white70,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Instrumental volume
                  AudioPlayerSlider(
                    player: audioHandler.instrumentalPlayer,
                    title: "Instrument",
                    icon: Icon(
                      Icons.music_note_outlined,
                      color: Colors.white70,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
                // Lyrics section
                GestureDetector(
                  onTap: () => setState(() => expandLyrics = !expandLyrics),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Row(
                      children: [
                        const Text(
                          'Lyrics',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          expandLyrics ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white70,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250, // hoặc giá trị phù hợp với màn hình
                  child: LyricsWidget(audioHandler: audioHandler),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
