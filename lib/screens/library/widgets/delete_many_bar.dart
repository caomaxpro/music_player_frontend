import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_buttons.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/screens/library/widgets/function_bar/sortby_bar.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/custom_svg.dart';
import 'package:music_player/svg/delete_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class DeleteSingleBar extends ConsumerWidget {
  final VoidCallback? onClose;

  const DeleteSingleBar({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = ref.watch(textColorProvider);
    final selectedTrackIds = ref.watch(selectedTrackIdsProvider);

    return Row(
      children: [
        Text(
          '${selectedTrackIds.length} Item${selectedTrackIds.length != 1 ? "s" : ""}',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        const Spacer(),
        FunctionButton(
          label: 'Delete',
          icon: CustomSvg(
            rawSvg: deleteSvgString,
            svgHeight: 18,
            viewBoxHeight: 24,
            color: Colors.redAccent, // màu riêng cho Delete
          ),
          function: LibraryFunction.delete,
          onPressed: () {
            ref.read(functionProvider.notifier).state = LibraryFunction.delete;
          },
        ),
        const SizedBox(width: 12),
        CloseIconButton(
          onPressed: () {
            ref.read(functionProvider.notifier).state = null;
          },
          color: textColor,
        ),
      ],
    );
  }
}
