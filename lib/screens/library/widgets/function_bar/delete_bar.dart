import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/custom_svg.dart';
import 'package:music_player/svg/delete_all_svg.dart';
import 'package:music_player/svg/delete_many_svg.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_buttons.dart'; // import FunctionButton, CloseIconButton

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
    final audioFiles = ref.watch(audioFilesProvider);

    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    if (audioFiles.length > 1)
                      FunctionButton(
                        label: 'Delete Many',
                        icon: CustomSvg(
                          rawSvg: deleteManySvg,
                          svgHeight: 20,
                          viewBoxWidth: 26,
                          viewBoxHeight: 26,
                          color: Colors.redAccent,
                        ),
                        function: LibraryFunction.deleteMany,
                        onPressed: () {
                          ref.read(functionProvider.notifier).state =
                              LibraryFunction.deleteMany;
                        },
                      ),
                    FunctionButton(
                      label: 'Delete All',
                      icon: CustomSvg(
                        rawSvg: deleteAllSvg,
                        svgHeight: 20,
                        viewBoxWidth: 24,
                        viewBoxHeight: 26,
                        color: Colors.redAccent,
                      ),
                      function: null,
                      onPressed: onDeleteAll,
                    ),
                  ],
                ),
                CloseIconButton(
                  onPressed: () {
                    ref.read(functionProvider.notifier).state = null;
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
