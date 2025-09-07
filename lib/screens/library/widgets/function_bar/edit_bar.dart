import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_buttons.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class EditBar extends ConsumerWidget {
  final VoidCallback? onDeleteMany;
  final VoidCallback? onDeleteAll;
  final VoidCallback? onClose;

  const EditBar({super.key, this.onDeleteMany, this.onDeleteAll, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = ref.watch(textColorProvider);

    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width, // Set width to 100% of screen
      child: Row(
        children: [
          Expanded(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                Row(
                  spacing: 8,
                  children: [
                    FunctionButton(
                      label: 'Edit',
                      icon: Icon(
                        Icons.edit,
                        color: Colors.orangeAccent, // màu riêng cho Edit
                      ),
                      function: LibraryFunction.edit,
                      onPressed: () {
                        ref.read(functionProvider.notifier).state =
                            LibraryFunction.edit;
                      },
                    ),
                  ],
                ),
                SizedBox(width: 10),
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
