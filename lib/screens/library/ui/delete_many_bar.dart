import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/screens/library/ui/sortby_bar.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/delete_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class DeleteSingleBar extends ConsumerWidget {
  final int itemCount;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  const DeleteSingleBar({
    super.key,
    required this.itemCount,
    this.onDelete,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = ref.watch(textColorProvider);

    return Row(
      children: [
        Text(
          '$itemCount Item${itemCount != 1 ? "s" : ""}',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        const Spacer(),
        CustomIconButton(
          label: 'Delete',
          labelColor: textColor,
          icon: DeleteSvg(width: 24, height: 26, color: textColor),
          onPressed: onDelete,
          horizontalPadding: 8,
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
