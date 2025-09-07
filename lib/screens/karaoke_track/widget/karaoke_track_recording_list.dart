// --- PART 2: Recordings List Widget ---
import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/recording.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/karaoke_player/ui/sound_wave.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_screen.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_state.dart';
import 'package:music_player/screens/karaoke_track/utils/karaoke_track_helper.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/handler_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

String formatTime(int milliseconds) {
  final ms = milliseconds % 1000;
  final seconds = (milliseconds ~/ 1000) % 60;
  final minutes = (milliseconds ~/ 1000) ~/ 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}.'
      '${ms.toString().padLeft(3, '0')}';
}

class KaraokeTrackRecordingsList extends ConsumerStatefulWidget {
  final Song currentAudioFile;
  final Color textColor;
  final KaraokeTrackFunction? karaokeTrackFunction;
  final List<int> selectedIds;
  final WidgetRef ref;

  const KaraokeTrackRecordingsList({
    super.key,
    required this.currentAudioFile,
    required this.textColor,
    required this.karaokeTrackFunction,
    required this.selectedIds,
    required this.ref,
  });

  @override
  ConsumerState<KaraokeTrackRecordingsList> createState() =>
      _KaraokeTrackRecordingsListState();
}

class _KaraokeTrackRecordingsListState
    extends ConsumerState<KaraokeTrackRecordingsList> {
  final rms = List.generate(100, (i) => Random().nextDouble());
  StreamSubscription<Duration>? _positionSubscription;

  // playback position
  int currentRecordingId = -1;
  bool recordingPlaying = false;
  int recordingPosition = 0;
  double safeDuration = 1.0;

  @override
  void initState() {
    super.initState();
    final audioHandler = ref.read(dualAudioHandlerProvider);

    Future.microtask(() {
      final currentAudioFile = ref.read(currentAudioFileProvider);
      final recordings = currentAudioFile.recordings.toList();
      final Map<int, PlaybackState> initialStates = {
        for (var r in recordings)
          r.id: PlaybackState(isPlaying: false, positionMs: 0),
      };

      ref.read(playStatesProvider.notifier).state = initialStates;
    });

    _positionSubscription = audioHandler.vocalPlayer.positionStream.listen((
      position,
    ) {
      setState(() {
        recordingPosition = position.inMilliseconds;
      });
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _togglePlayPause(Recording recording) async {
    final audioHandler = ref.read(dualAudioHandlerProvider);
    final playStates = ref.read(playStatesProvider);

    debugPrint("Play State: ");
    printPlayStatesAsJson(playStates);

    final playingEntry = playStates.entries.firstWhere(
      (e) => e.value.isPlaying,
      orElse:
          () => MapEntry(-1, PlaybackState(isPlaying: false, positionMs: 0)),
    );
    final isAnyPlaying = playingEntry.key != -1;
    final playingId = isAnyPlaying ? playingEntry.key : null;

    debugPrint('TogglePlayPause called for recording.id=${recording.id}');
    debugPrint('playStates BEFORE: ${playStates[recording.id]?.isPlaying}');
    debugPrint("Playingid $playingId, isAnyPlaying $isAnyPlaying");

    // Nếu đang play và thao tác đúng vào recording đó => pause
    if (isAnyPlaying && playingId == recording.id) {
      final position = audioHandler.vocalPlayer.position.inMilliseconds;
      final isPlaying = audioHandler.vocalPlayer.playing;

      ref.read(playStatesProvider.notifier).update((state) {
        final newState = Map<int, PlaybackState>.from(state);
        newState[recording.id] = PlaybackState(
          isPlaying: !isPlaying,
          positionMs: position,
        );
        return newState;
      });

      if (isPlaying) {
        await audioHandler.pauseBoth();
      } else {
        await audioHandler.playBoth();
      }

      debugPrint(
        'playStates AFTER PAUSE: ${playStates[recording.id]?.isPlaying}',
      );
      debugPrint('Paused recording: ${recording.path}, position: $position');
      return;
    }

    // Nếu đang play recording khác => pause và lưu vị trí, chuyển trạng thái sang false
    if (isAnyPlaying && playingId != recording.id) {
      final playingPosition = audioHandler.vocalPlayer.position.inMilliseconds;
      ref.read(playStatesProvider.notifier).update((state) {
        final newState = Map<int, PlaybackState>.from(state);
        newState[playingId!] = PlaybackState(
          isPlaying: false,
          positionMs: playingPosition,
        );
        return newState;
      });
      debugPrint(
        'playStates AFTER STOP: ${playStates[recording.id]?.isPlaying}',
      );
      await audioHandler.stopBoth();
      debugPrint(
        'Stopped previous recording: $playingId, position: $playingPosition',
      );
    }

    debugPrint("current recording id ${recording.id}, playingId $playingId");

    // Play recording được thao tác
    final seekPosition = playStates[recording.id]?.positionMs ?? 0;
    await audioHandler.loadVocal(
      recording.path,
      initialPosition: Duration(milliseconds: seekPosition),
    );

    final vocalDuration = audioHandler.vocalPlayer.duration;
    if (vocalDuration != null && vocalDuration.inMilliseconds > 0) {
      setState(() {
        safeDuration = vocalDuration.inMilliseconds.toDouble();
      });
    }

    if (recording.clipedPath.isNotEmpty) {
      await audioHandler.loadInstrumental(
        recording.clipedPath,
        initialPosition: Duration(milliseconds: seekPosition),
      );
    } else {
      final currentAudioFile = ref.read(currentAudioFileProvider);
      await audioHandler.loadInstrumental(currentAudioFile.instrumentalPath);
    }

    // if (seekPosition > 0 && recording.id != playingId) {
    //   await audioHandler.seekBoth(Duration(milliseconds: seekPosition));
    //   debugPrint('Seek to position: $seekPosition');
    // }
    ref.read(playStatesProvider.notifier).update((state) {
      final newState = Map<int, PlaybackState>.from(state);
      newState.updateAll(
        (key, value) =>
            PlaybackState(isPlaying: false, positionMs: value.positionMs),
      );
      newState[recording.id] = PlaybackState(
        isPlaying: true,
        positionMs: seekPosition,
      );
      return newState;
    });
    debugPrint('playStates AFTER PLAY: ${playStates[recording.id]?.isPlaying}');
    debugPrint(
      'Playing recording: ${recording.path}, seekPosition: $seekPosition',
    );

    await audioHandler.playBoth();
  }

  @override
  Widget build(BuildContext context) {
    final List<Recording> recordings =
        widget.currentAudioFile.recordings.toList().reversed.toList();

    final audioHandler = ref.watch(dualAudioHandlerProvider);
    final vocalDuration = audioHandler.vocalPlayer.duration;
    double safeDuration =
        vocalDuration != null ? vocalDuration.inMilliseconds.toDouble() : 1.0;

    final playStates = ref.watch(playStatesProvider);

    final karaokeTrack = ref.watch(karaokeTrackProvider);

    debugPrint('build: playStates = $playStates');

    return Expanded(
      child: ListView.builder(
        itemCount: recordings.length,
        itemBuilder: (context, index) {
          final recording = recordings[index];
          final recordingName = recording.title;
          final playbackState = playStates[recording.id];
          final bool isPlaying = playbackState?.isPlaying ?? false;
          final int audioPosition = playbackState?.positionMs ?? 0;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromARGB(255, 97, 96, 96).withAlpha(100),
            ),
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            padding: EdgeInsets.only(left: 10, right: 10, top: 15),
            height: (currentRecordingId == recording.id) ? 150 : 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mic,
                      size: 24,
                      color:
                          (currentRecordingId == recording.id &&
                                  recordingPlaying)
                              ? Colors.green
                              : widget.textColor,
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 250,
                      child: Text(
                        recordingName,
                        style: TextStyle(fontSize: 16, color: widget.textColor),
                      ),
                    ),
                    Spacer(),
                    if (widget.karaokeTrackFunction !=
                        KaraokeTrackFunction.sort)
                      CustomIconButton(
                        icon: Icon(
                          (() {
                            switch (widget.karaokeTrackFunction) {
                              case KaraokeTrackFunction.deleteMany:
                                return widget.selectedIds.contains(recording.id)
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank;
                              case KaraokeTrackFunction.delete:
                                return Icons.delete;
                              case KaraokeTrackFunction.sort:
                                return Icons.sort;
                              case null:
                              default:
                                return (currentRecordingId == recording.id &&
                                        recordingPlaying)
                                    ? Icons.pause
                                    : Icons.play_arrow_outlined;
                            }
                          })(),
                          color:
                              (() {
                                switch (widget.karaokeTrackFunction) {
                                  case KaraokeTrackFunction.deleteMany:
                                    return widget.selectedIds.contains(
                                          recording.id,
                                        )
                                        ? Colors.blue
                                        : Colors.grey;
                                  case KaraokeTrackFunction.delete:
                                    return const Color.fromARGB(
                                      255,
                                      223,
                                      58,
                                      47,
                                    );
                                  case KaraokeTrackFunction.sort:
                                    return Colors.orange;
                                  case null:
                                  default:
                                    return (currentRecordingId ==
                                                recording.id &&
                                            recordingPlaying)
                                        ? Colors.green
                                        : widget.textColor;
                                }
                              })(),
                          size: 24,
                        ),
                        width: 33,
                        height: 33,
                        borderRadius: 50,
                        borderWidth: 0,
                        backgroundColor:
                            (() {
                              switch (widget.karaokeTrackFunction) {
                                case KaraokeTrackFunction.deleteMany:
                                  return Colors.transparent;
                                case KaraokeTrackFunction.delete:
                                  return Colors.transparent;
                                case KaraokeTrackFunction.sort:
                                  return Colors.orange.withAlpha(100);
                                case null:
                                default:
                                  return (currentRecordingId == recording.id &&
                                          recordingPlaying)
                                      ? Colors.green.withAlpha(100)
                                      : Colors.grey.withAlpha(50);
                              }
                            })(),
                        onPressed: () async {
                          switch (widget.karaokeTrackFunction) {
                            case KaraokeTrackFunction.delete:
                              deleteRecording(recording, widget.ref);
                              break;
                            case KaraokeTrackFunction.deleteMany:
                              List<int> cSelectedIds =
                                  widget.selectedIds.toList();
                              if (widget.selectedIds.contains(recording.id)) {
                                cSelectedIds.remove(recording.id);
                                widget
                                    .ref
                                    .read(selectedRecordingIdProvider.notifier)
                                    .state = cSelectedIds;
                              } else {
                                cSelectedIds.add(recording.id);
                                widget
                                    .ref
                                    .read(selectedRecordingIdProvider.notifier)
                                    .state = cSelectedIds;
                              }
                              break;
                            case KaraokeTrackFunction.sort:
                              break;
                            default:
                              final playStates = ref.read(playStatesProvider);

                              // If pressing a different recording
                              if (currentRecordingId != recording.id) {
                                final prevRecordingId = currentRecordingId;
                                final prevPosition = recordingPosition;

                                setState(() {
                                  currentRecordingId = recording.id;
                                  recordingPlaying = true;
                                  recordingPosition =
                                      playStates[recording.id]?.positionMs ?? 0;
                                });

                                ref.read(playStatesProvider.notifier).update((
                                  state,
                                ) {
                                  final newState = Map<int, PlaybackState>.from(
                                    state,
                                  );

                                  // Save playback time to previous recording
                                  if (prevRecordingId != -1 &&
                                      newState.containsKey(prevRecordingId)) {
                                    newState[prevRecordingId] = PlaybackState(
                                      isPlaying: false,
                                      positionMs: prevPosition,
                                    );
                                  }

                                  // Set playback time and play state for current recording
                                  newState[recording.id] = PlaybackState(
                                    isPlaying: true,
                                    positionMs: recordingPosition,
                                  );

                                  return newState;
                                });

                                // Load and play the new recording from the saved position
                                await audioHandler.loadVocal(
                                  recording.path,
                                  initialPosition: Duration(
                                    milliseconds: recordingPosition,
                                  ),
                                );
                                if (recording.clipedPath.isNotEmpty) {
                                  await audioHandler.loadInstrumental(
                                    recording.clipedPath,
                                    initialPosition: Duration(
                                      milliseconds: recordingPosition,
                                    ),
                                  );
                                } else {
                                  final currentAudioFile = ref.read(
                                    currentAudioFileProvider,
                                  );
                                  await audioHandler.loadInstrumental(
                                    currentAudioFile.instrumentalPath,
                                  );
                                }

                                final vocalDuration =
                                    audioHandler.vocalPlayer.duration;
                                if (vocalDuration != null &&
                                    vocalDuration.inMilliseconds > 0) {
                                  setState(() {
                                    safeDuration =
                                        vocalDuration.inMilliseconds.toDouble();
                                  });
                                }

                                await Future.delayed(
                                  const Duration(milliseconds: 400),
                                );

                                await audioHandler.playBoth();
                              }
                              // If pressing the same recording, toggle play/pause
                              else {
                                setState(() {
                                  recordingPlaying = !recordingPlaying;
                                });

                                if (recordingPlaying) {
                                  await audioHandler.playVocal();
                                } else {
                                  await audioHandler.pauseBoth();
                                }

                                ref.read(playStatesProvider.notifier).update((
                                  state,
                                ) {
                                  final newState = Map<int, PlaybackState>.from(
                                    state,
                                  );
                                  newState[recording.id] = PlaybackState(
                                    isPlaying: recordingPlaying,
                                    positionMs: recordingPosition,
                                  );
                                  return newState;
                                });
                              }
                              break;
                          }
                        },
                      ),
                  ],
                ),

                if (currentRecordingId == recording.id) ...[
                  SizedBox(height: 15),
                  SoundWaveSlider(
                    value: recordingPosition.toDouble().clamp(
                      0.0,
                      safeDuration,
                    ),
                    max: safeDuration,
                    rms: rms,
                    highlightColor: Colors.green,
                    backgroundColor: Colors.grey.withAlpha(80),
                    onChangeStart: (value) {
                      audioHandler.pauseBoth();
                    },
                    onChanged: (value) {
                      setState(() {
                        recordingPosition = value.toInt();
                      });
                    },
                    onChangeEnd: (value) {
                      final seekMs = value.toInt();
                      // Chỉ seek nếu recording này đang được play
                      ref.read(playStatesProvider.notifier).update((state) {
                        final newState = Map<int, PlaybackState>.from(state);
                        newState[recording.id] = PlaybackState(
                          isPlaying: false,
                          positionMs: seekMs,
                        );
                        return newState;
                      });

                      setState(() {
                        recordingPlaying = false;
                      });

                      audioHandler.seekBoth(Duration(milliseconds: seekMs));
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        formatTime(recordingPosition),
                        style: TextStyle(color: widget.textColor),
                      ),
                      Spacer(),
                      Text(
                        formatTime(recording.durationMs),
                        style: TextStyle(color: widget.textColor),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
