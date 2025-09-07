import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/karaoke_player/karaoke_player_screen.dart';
import 'package:music_player/screens/karaoke_player/ui/helper/karaoke_player_helper.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/create_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/screens/karaoke_player/helper/response_handler.dart';
import 'package:music_player/widgets/custom_karaoke_loading.dart';

class SetKaraokeButton extends ConsumerStatefulWidget {
  final VoidCallback? onPressed;
  const SetKaraokeButton({super.key, this.onPressed});

  @override
  ConsumerState<SetKaraokeButton> createState() => _SetAudioFileButtonState();
}

class _SetAudioFileButtonState extends ConsumerState<SetKaraokeButton> {
  String buttonTitle = "Create Karaoke Track";

  String _getButtonLabel(CreateState progress) {
    switch (progress) {
      case CreateState.init:
        return "Create Karaoke Track";
      case CreateState.audioFile:
      case CreateState.infor:
        return "Next";
      case CreateState.lyrics:
      case CreateState.complete:
        return "Set Karaoke Track";
      default:
        return "Create Karaoke Track";
    }
  }

  Future<void> _handleCreateKaraoke() async {
    final progress = ref.read(createStateProvider);
    final currentAudioFile = ref.read(currentAudioFileProvider);
    final adjustTimestamp = ref.read(adjustTimestampProvider);

    debugPrint('Karaoke processed: ${currentAudioFile.timestampLyrics}');

    if (progress == CreateState.lyrics) {
      // Prepare timestampLyrics (replace with your actual data)
      // TODO: Fill this

      // Estimate processing time (example: duration * 1.2 + 3000 ms)
      // get file duration
      final audioFileDuration = await getAudioDurationMs(
        currentAudioFile.filePath,
      );

      final estimatedMs = (audioFileDuration! * 2).toInt() + 5000;

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierColor: Colors.black.withAlpha((255 * 0.8).toInt()),
        barrierDismissible: false,
        builder:
            (_) => CustomLoadingWidget(
              loadingTime: estimatedMs,
              onLoadingStart: () {},
              onLoadingEnd: () {},
            ),
      );

      final karaokeService = KaraokeService();
      try {
        final result = await karaokeService.processKaraoke(
          trackUuid: currentAudioFile.uuid,
          audioFile: File(currentAudioFile.filePath),
        );

        // display custom loading widget here while waiting for it to process the request

        debugPrint(
          'Data type of result["timestamp_lyrics"]: ${result["timestamp_lyrics"].runtimeType}',
        );
        debugPrint('Karaoke processed: $result');

        Song updatedFile = ref
            .read(currentAudioFileProvider)
            .copyWith(
              amplitude: result["computed_amplitude"],
              vocalPath: result["vocals"],
              instrumentalPath: result["accompaniment"],
            );

        ref.read(currentAudioFileProvider.notifier).state = updatedFile;

        SongHandler songHandler = SongHandler();

        songHandler.createSong(updatedFile);

        // ignore: use_build_context_synchronously
        Navigator.of(context, rootNavigator: true).pop();

        // navigate to karaoke player screen
        // ignore: use_build_context_synchronously
        Navigator.popUntil(context, ModalRoute.withName("library"));

        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, KaraokePlayerScreen.routeName);

        // Handle result (show message, update UI, etc.)
      } catch (e, stackTrace) {
        debugPrint('Error sending karaoke request: $e');
        debugPrint('Stack trace: $stackTrace');
        debugPrint(
          'Occurred in _handleCreateKaraoke method while processing karaoke request.',
        );
        // Handle error (show error message, etc.)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(createStateProvider);
    final currentAudioFile = ref.watch(currentAudioFileProvider);

    return CustomIconButton(
      backgroundColor: const Color.fromARGB(115, 97, 97, 97),
      label: _getButtonLabel(progress),
      width: MediaQuery.of(context).size.width * .9,
      borderWidth: 0,
      onPressed: () async {
        await _handleCreateKaraoke();
        if (widget.onPressed != null) widget.onPressed!();
      },
    );
  }
}
