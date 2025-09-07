import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class FunctionButton extends ConsumerWidget {
  final String label;
  final Widget icon;
  final dynamic function;
  final VoidCallback? onPressed;

  const FunctionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.function,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomIconButton(
      label: label,
      icon: icon,
      onPressed: () {
        if (onPressed == null) {
          ref.read(karaokeTrackProvider.notifier).state = function;
        }
        if (onPressed != null) {
          onPressed!();
        }
      },
      horizontalPadding: 10,
      borderWidth: 0,
      backgroundColor: const Color.fromARGB(255, 97, 96, 96),
    );
  }
}

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
    return CustomIconButton(
      icon: Icon(
        Icons.close,
        color: color ?? Colors.white,
        size: (size ?? 30) * 0.73,
      ),
      onPressed: onPressed,
      width: size ?? 30,
      height: size ?? 30,
      borderRadius: borderRadius ?? 50,
      borderWidth: 0,
      backgroundColor: const Color.fromARGB(255, 97, 96, 96),
      padding: EdgeInsets.zero,
    );
  }
}
