import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_state.dart';
import 'package:music_player/screens/karaoke_track/utils/karaoke_track_helper.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/screens/library/widgets/function_bar/sortby_bar.dart'
    hide CloseIconButton;
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/delete_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_dialog.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_buttons.dart';

class DeleteManyBar extends ConsumerWidget {
  final VoidCallback? onClose;

  const DeleteManyBar({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = ref.watch(textColorProvider);
    final bgColor = ref.read(bgColorProvider);
    final selectedRecordingIds = ref.watch(selectedRecordingIdProvider);

    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${selectedRecordingIds.length} Item${selectedRecordingIds.length != 1 ? "s" : ""}',
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          const Spacer(),

          if (selectedRecordingIds.isNotEmpty)
            FunctionButton(
              label: 'Delete',
              icon: DeleteSvg(
                svgWidth: 18,
                svgHeight: 23,
                viewBoxWidth: 22,
                viewBoxHeight: 26,
                color: Colors.redAccent,
              ),
              function: KaraokeTrackFunction.deleteMany,
              onPressed: () {
                debugPrint("on pressed");
                CustomDialog.show(
                  context,
                  title: "Delete Many",
                  content: Text(
                    "Are you sure you want to delete these recordings?",
                  ),
                  onConfirm: () {
                    deleteManyRecordings(selectedRecordingIds, ref);
                    ref.read(karaokeTrackProvider.notifier).state =
                        KaraokeTrackFunction.delete;
                  },
                  onCancel: () {
                    ref.read(selectedRecordingIdProvider.notifier).state = [];
                  },
                );
              },
            ),
          const SizedBox(width: 12),
          CloseIconButton(
            onPressed: () {
              ref.read(karaokeTrackProvider.notifier).state = null;
              if (onClose != null) onClose!();
            },
            color: textColor,
          ),
        ],
      ),
    );
  }
}
