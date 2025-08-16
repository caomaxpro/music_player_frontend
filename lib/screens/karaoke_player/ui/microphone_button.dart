import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/services/karaoke_handler.dart';
import 'package:music_player/svg/microphone_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:rxdart/rxdart.dart';

class MicrophonePlayPauseButton extends StatelessWidget {
  final DualAudioHandler audioHandler;

  const MicrophonePlayPauseButton({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
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
                    : Icon(Icons.pause),
          ),
          onPressed: () async {
            final vocalPlayer = audioHandler.vocalPlayer;
            final instrumentalPlayer = audioHandler.instrumentalPlayer;

            // Kiểm tra nếu đã hết bài (processingState == completed)
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
              }
            }
          },
        );
      },
    );
  }
}
