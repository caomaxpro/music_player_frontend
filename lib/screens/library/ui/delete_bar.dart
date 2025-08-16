import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/screens/library/ui/sortby_bar.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/delete_all_svg.dart';
import 'package:music_player/svg/delete_many_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

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

    return SizedBox(
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
                    CustomIconButton(
                      label: 'Delete Many',
                      labelColor: textColor,
                      icon: DeleteManySvg(
                        width: 24,
                        height: 26,
                        color: textColor,
                      ),
                      onPressed: () {
                        ref.read(functionProvider.notifier).state =
                            LibraryFunction.deleteMany;
                      },
                      horizontalPadding: 10,
                    ),
                    CustomIconButton(
                      label: 'Delete All',
                      labelColor: textColor,
                      icon: DeleteAllSvg(
                        width: 22,
                        height: 25,
                        color: textColor,
                      ),
                      onPressed: onDeleteAll,
                      horizontalPadding: 10,
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
