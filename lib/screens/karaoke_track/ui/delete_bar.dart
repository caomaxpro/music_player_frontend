import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_state.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_buttons.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/custom_svg.dart';
import 'package:music_player/svg/delete_all_svg.dart';
import 'package:music_player/svg/delete_many_svg.dart';

class DeleteBar extends ConsumerWidget {
  final VoidCallback? onDeleteMany;
  final VoidCallback? onDeleteAll;
  final VoidCallback? onClose;

  const DeleteBar({
    super.key,
    this.onDeleteMany,
    this.onDeleteAll,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = ref.watch(textColorProvider);
    final currentAudioFile = ref.watch(currentAudioFileProvider);

    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width, // Set width to 100% of screen
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    if (currentAudioFile.recordings.toList().length > 1)
                      FunctionButton(
                        label: 'Delete Many',
                        icon: CustomSvg(
                          rawSvg: deleteManySvg,
                          svgHeight: 23,
                          svgWidth: 20,
                          viewBoxHeight: 26,
                          viewBoxWidth: 24,
                          color: Colors.redAccent,
                        ),
                        function: KaraokeTrackFunction.deleteMany,
                        onPressed: () {
                          ref.read(karaokeTrackProvider.notifier).state =
                              KaraokeTrackFunction.deleteMany;
                          ref.read(selectedRecordingIdProvider.notifier).state =
                              [];
                        },
                      ),
                    FunctionButton(
                      label: 'Delete All',
                      icon: CustomSvg(
                        rawSvg: deleteAllSvg,
                        svgHeight: 23,
                        viewBoxWidth: 24,
                        viewBoxHeight: 26,
                        color: Colors.redAccent,
                      ),
                      function: KaraokeTrackFunction.delete,
                      onPressed: onDeleteAll,
                    ),
                  ],
                ),
                CloseIconButton(
                  onPressed: () {
                    ref.read(karaokeTrackProvider.notifier).state = null;
                  },
                  color: textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
