import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/services/karaoke_handler.dart';
import 'package:music_player/services/recorder_handler.dart';
import 'package:music_player/state/handler_state.dart';
import 'package:music_player/svg/microphone_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_dialog.dart';
import 'package:music_player/widgets/custom_text_input.dart';
import 'package:rxdart/rxdart.dart';
import 'package:music_player/screens/karaoke_player/ui/helper/karaoke_player_helper.dart';

class MicrophonePlayPauseButton extends ConsumerStatefulWidget {
  final DualAudioHandler audioHandler;

  const MicrophonePlayPauseButton({super.key, required this.audioHandler});

  @override
  ConsumerState<MicrophonePlayPauseButton> createState() =>
      _MicrophonePlayPauseButtonState();
}

class _MicrophonePlayPauseButtonState
    extends ConsumerState<MicrophonePlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    final audioHandler = widget.audioHandler;
    return StreamBuilder<bool>(
      stream: Rx.combineLatest2(
        audioHandler.vocalPlayer.playingStream,
        audioHandler.instrumentalPlayer.playingStream,
        (bool v, bool i) => v && i,
      ),
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return CustomIconButton(
          width: 50,
          height: 50,
          borderRadius: 50,
          icon: Transform.scale(
            scale: .9,
            child:
                !isPlaying
                    ? MicrophoneSvg(viewBoxHeight: 22, viewBoxWidth: 20)
                    : const Icon(Icons.pause),
          ),
          onPressed: () async {
            final vocalPlayer = audioHandler.vocalPlayer;
            final instrumentalPlayer = audioHandler.instrumentalPlayer;

            final isVocalCompleted =
                vocalPlayer.processingState == ProcessingState.completed;
            final isInstrumentalCompleted =
                instrumentalPlayer.processingState == ProcessingState.completed;

            if (isVocalCompleted || isInstrumentalCompleted) {
              await vocalPlayer.seek(Duration.zero);
              await instrumentalPlayer.seek(Duration.zero);
              await audioHandler.playBoth();
            } else {
              final isPlaying =
                  vocalPlayer.playing || instrumentalPlayer.playing;
              if (!isPlaying) {
                await audioHandler.playBoth();
              } else {
                await audioHandler.pauseBoth();

                final recorderHandler = ref.read(recorderHandlerProvider);

                if (await recorderHandler.isRecording()) {
                  // ignore: use_build_context_synchronously
                  await showSaveRecordingDialog(ref, context);
                }
              }
            }
          },
        );
      },
    );
  }
}
