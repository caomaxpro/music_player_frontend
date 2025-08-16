import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import '../state/library_state.dart';

class CloseIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final double? borderRadius;
  final double? borderWidth;

  const CloseIconButton({
    super.key,
    this.onPressed,
    this.color,
    this.size,
    this.borderRadius,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 30,
      height: size ?? 30,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: color ?? Colors.white,
            width: borderWidth ?? 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 50),
          ),
        ),
        onPressed: onPressed,
        child: Icon(
          Icons.close,
          color: color ?? Colors.white,
          size: (size ?? 30) * 0.73,
        ),
      ),
    );
  }
}

class SortByBar extends ConsumerWidget {
  final VoidCallback? onSortByTitle;
  final VoidCallback? onSortByArtist;
  final VoidCallback? onClose;

  const SortByBar({
    super.key,
    this.onSortByTitle,
    this.onSortByArtist,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color textColor = Colors.white;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CustomIconButton(
                  label: 'Sort by title',
                  labelColor: textColor,
                  icon: const Icon(
                    Icons.swap_vert,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: onSortByTitle,
                  horizontalPadding: 8,
                  borderRadius: 8,
                ),
                const SizedBox(width: 8),
                CustomIconButton(
                  label: 'Sort by artist',
                  labelColor: textColor,
                  icon: const Icon(
                    Icons.swap_vert,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: onSortByArtist,
                  horizontalPadding: 8,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
          CloseIconButton(
            onPressed: () {
              ref.read(functionProvider.notifier).state = null;
              if (onClose != null) onClose!();
            },
            color: textColor,
          ),
        ],
      ),
    );
  }
}
