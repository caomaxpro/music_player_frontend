import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/screens/karaoke_player/ui/audio_player_slider.dart';
import 'package:music_player/screens/karaoke_player/ui/karaoke_lyrics.dart';
import 'package:music_player/screens/karaoke_player/ui/microphone_button.dart';
import 'package:music_player/screens/karaoke_player/ui/recording_controller.dart';
import 'package:music_player/screens/karaoke_player/ui/sound_wave.dart';
import 'package:music_player/services/karaoke_handler.dart';
import 'package:music_player/svg/guitar_svg.dart';
import 'package:music_player/svg/lyrics_file_svg.dart';
import 'package:music_player/svg/microphone_svg.dart';
import 'package:music_player/svg/vocal_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:rxdart/rxdart.dart';

class KaraokePlayerScreen extends StatefulWidget {
  const KaraokePlayerScreen({super.key});

  @override
  State<KaraokePlayerScreen> createState() => _KaraokePlayerScreenState();
}

class _KaraokePlayerScreenState extends State<KaraokePlayerScreen> {
  bool isRecording = false;
  double vocalVolume = 0.5;
  double instrumentalVolume = 0.5;
  double soundWaveValue = 0.0;
  final double soundWaveMax = 100.0;
  final Random _random = Random();
  late List<double> rms;

  late DualAudioHandler audioHandler;
  bool expandLyrics = true;

  StreamSubscription<Duration>? _positionSub;

  String _formatDuration(Duration? d) {
    if (d == null) return "--:--";
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    rms = List.generate(100, (i) => 0.3 + 0.7 * _random.nextDouble());
    audioHandler = DualAudioHandler(); // Or inject/get from provider
    audioHandler.setVocalVolume(vocalVolume);

    // Listen to position changes and update soundWaveValue
    _positionSub = audioHandler.vocalPlayer.positionStream.listen((position) {
      final duration = audioHandler.vocalPlayer.duration;
      if (duration != null && duration.inMilliseconds > 0) {
        final value =
            (position.inMilliseconds / duration.inMilliseconds) * soundWaveMax;
        if (mounted) {
          setState(() {
            soundWaveValue = value.clamp(0, soundWaveMax);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white70),
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
                      await audioHandler.playBoth();
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
                RecordingController(
                  isRecording: isRecording,
                  onChanged: (value) {
                    setState(() => isRecording = value);
                  },
                ),
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
                          fontSize: 16,
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
              Expanded(child: LyricsWidget(audioHandler: audioHandler)),
            ],
          ),
        ),
      ),
    );
  }
}
