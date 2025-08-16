import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/create_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class SetKaraokeButton extends ConsumerStatefulWidget {
  final VoidCallback? onPressed;
  const SetKaraokeButton({super.key, this.onPressed});

  @override
  ConsumerState<SetKaraokeButton> createState() => _SetAudioFileButtonState();
}

class _SetAudioFileButtonState extends ConsumerState<SetKaraokeButton> {
  String buttonTitle = "Create Karaoke Track";

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressStateProvider);
    final currentAudioFile = ref.watch(currentAudioFileProvider);

    return CustomIconButton(
      label: "Set Karaoke Track",
      width: MediaQuery.of(context).size.width * .9,
      onPressed: widget.onPressed,
    );
  }
}
