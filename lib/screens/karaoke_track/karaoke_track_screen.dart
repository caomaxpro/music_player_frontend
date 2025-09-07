import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/recording.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_state.dart';
import 'package:music_player/screens/karaoke_track/ui/delete_bar.dart';
import 'package:music_player/screens/karaoke_track/ui/delete_many_bar.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_function.dart';
import 'package:music_player/screens/karaoke_track/ui/sortby_bar.dart';
import 'package:music_player/screens/karaoke_track/utils/karaoke_track_helper.dart';
import 'package:music_player/screens/karaoke_track/widget/karaoke_track_info.dart';
import 'package:music_player/screens/karaoke_track/widget/karaoke_track_recording_list.dart';
import 'package:music_player/services/karaoke_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/handler_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_dialog.dart';
import 'package:music_player/widgets/custom_scaffold.dart';

class KaraokeTrackScreen extends ConsumerStatefulWidget {
  final String folderPath;

  static const String routeName = "karaokeTrack";

  const KaraokeTrackScreen({super.key, required this.folderPath});

  @override
  ConsumerState<KaraokeTrackScreen> createState() => _KaraokeTrackScreenState();
}

class _KaraokeTrackScreenState extends ConsumerState<KaraokeTrackScreen> {
  late DualAudioHandler audioHandler;
  StreamSubscription<void>? _playbackCompletionSubscription;

  @override
  void initState() {
    super.initState();
    audioHandler = ref.read(dualAudioHandlerProvider);

    _playbackCompletionSubscription = audioHandler.playbackCompletedStream
        .listen((_) {
          _onPlaybackCompleted();
        });
  }

  @override
  void dispose() {
    _playbackCompletionSubscription?.cancel();
    audioHandler.stopBoth();
    super.dispose();
  }

  void _onPlaybackCompleted() {
    if (mounted) {
      ref.read(playStatesProvider.notifier).update((state) {
        final newState = Map<int, PlaybackState>.from(state);
        newState.updateAll(
          (key, value) => PlaybackState(isPlaying: false, positionMs: 0),
        );
        return newState;
      });
      audioHandler.stopBoth();
      debugPrint(
        'Playback completed - all play states reset and audio stopped',
      );
    }
  }

  void _togglePlayPause(Recording recording) async {
    try {
      final playStates = ref.read(playStatesProvider);
      final playingEntry = playStates.entries.firstWhere(
        (e) => e.value.isPlaying,
        orElse:
            () => MapEntry(-1, PlaybackState(isPlaying: false, positionMs: 0)),
      );
      final isAnyPlaying = playingEntry.key != -1;
      final playingId = isAnyPlaying ? playingEntry.key : null;

      // Nếu đang play và thao tác đúng vào recording đó => pause
      if (isAnyPlaying && playingId == recording.id) {
        final position = audioHandler.vocalPlayer.position.inMilliseconds;
        await audioHandler.pauseBoth();
        ref.read(playStatesProvider.notifier).update((state) {
          final newState = Map<int, PlaybackState>.from(state);
          newState[recording.id] = PlaybackState(
            isPlaying: false,
            positionMs: position,
          );
          return newState;
        });
        debugPrint('Paused recording: ${recording.path}');
        return;
      }

      // Nếu đang play recording khác => pause và lưu vị trí, chuyển trạng thái sang false
      if (isAnyPlaying && playingId != recording.id) {
        final playingPosition =
            audioHandler.vocalPlayer.position.inMilliseconds;
        ref.read(playStatesProvider.notifier).update((state) {
          final newState = Map<int, PlaybackState>.from(state);
          newState[playingId!] = PlaybackState(
            isPlaying: false,
            positionMs: playingPosition,
          );
          return newState;
        });
        await audioHandler.stopBoth();
      }

      // Play recording được thao tác
      final seekPosition = playStates[recording.id]?.positionMs ?? 0;
      await audioHandler.loadVocal(recording.path);
      if (recording.clipedPath.isNotEmpty) {
        await audioHandler.loadInstrumental(recording.clipedPath);
      } else {
        final currentAudioFile = ref.read(currentAudioFileProvider);
        await audioHandler.loadInstrumental(currentAudioFile.instrumentalPath);
      }
      await audioHandler.playBoth();
      if (seekPosition > 0) {
        await audioHandler.seekBoth(Duration(milliseconds: seekPosition));
      }
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
      debugPrint('Playing recording: ${recording.path}');
    } catch (e) {
      debugPrint('Error in _togglePlayPause: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioFiles = ref.watch(audioFilesProvider);
    final currentAudioFile = ref.watch(currentAudioFileProvider);
    final textColor = ref.read(textColorProvider);
    final bgColor = ref.read(bgColorProvider);
    final karaokeTrackFunction = ref.watch(karaokeTrackProvider);
    final selectedIds = ref.watch(selectedRecordingIdProvider);
    final playStates = ref.watch(playStatesProvider);

    return CustomScaffold(
      title: "Karaoke Track",
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KaraokeTrackInfo(
              currentAudioFile: currentAudioFile,
              textColor: textColor,
              bgColor: bgColor,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Recordings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(height: 8),
            if (currentAudioFile.recordings.toList().isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (karaokeTrackFunction == null) KaraokeTrackFunctionBar(),
                    if (karaokeTrackFunction == KaraokeTrackFunction.delete)
                      DeleteBar(
                        onDeleteAll: () {
                          CustomDialog.show(
                            context,
                            title: "Delete All Recordings",
                            content: const Text(
                              "Are you sure that you want to delete all recordings?",
                            ),
                            onConfirm: () {
                              deleteAllRecordings(ref);
                            },
                          );
                        },
                      ),
                    if (karaokeTrackFunction == KaraokeTrackFunction.sort)
                      SortByBar(),
                    if (karaokeTrackFunction == KaraokeTrackFunction.deleteMany)
                      DeleteManyBar(),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            KaraokeTrackRecordingsList(
              currentAudioFile: currentAudioFile,
              textColor: textColor,
              karaokeTrackFunction: karaokeTrackFunction,
              selectedIds: selectedIds,
              ref: ref,
            ),
          ],
        ),
      ),
    );
  }
}
