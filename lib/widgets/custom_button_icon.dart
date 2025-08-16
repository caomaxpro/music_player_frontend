import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final String? label;
  final Widget? icon; // Cho phép icon là null
  final VoidCallback? onPressed;
  final Color? labelColor;
  final double? width;
  final double? height;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? borderRadius;
  final double? borderWidth;
  final bool textFirst;
  final Color? backgroundColor;
  final Color? borderColor; // <-- add this line

  const CustomIconButton({
    this.label,
    this.icon, // Cho phép null
    this.onPressed,
    this.labelColor,
    this.width,
    this.height,
    this.horizontalPadding,
    this.verticalPadding,
    this.borderRadius,
    this.borderWidth,
    this.textFirst = false,
    this.backgroundColor, // <-- add this line
    this.borderColor, // <-- add this line
    super.key,
  });

  // Thay đổi cách đặt background để không bị tràn ra ngoài border
  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry buttonPadding = EdgeInsets.symmetric(
      horizontal: horizontalPadding ?? 0,
      vertical: verticalPadding ?? 0,
    );

    final double effectiveBorderRadius = borderRadius ?? 10;
    final double effectiveBorderWidth = borderWidth ?? 1.0;

    // Sử dụng backgroundColor trong style thay vì Container
    final ButtonStyle style = OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side:
          effectiveBorderWidth == 0
              ? BorderSide.none
              : BorderSide(
                color: borderColor ?? Colors.white,
                width: effectiveBorderWidth,
              ),
      padding: buttonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
      ),
      backgroundColor: backgroundColor, // <-- đặt background ở đây
    );

    Widget button;

    if ((label == null || label!.isEmpty) && icon == null) {
      button = OutlinedButton(
        style: style,
        onPressed: onPressed,
        child: const SizedBox.shrink(),
      );
    } else if ((label == null || label!.isEmpty) && icon != null) {
      button = OutlinedButton(style: style, onPressed: onPressed, child: icon!);
    } else if ((icon == null) && label != null && label!.isNotEmpty) {
      button = OutlinedButton(
        style: style,
        onPressed: onPressed,
        child: Text(
          label!,
          style: TextStyle(color: labelColor ?? Colors.white),
        ),
      );
    } else if (textFirst) {
      button = OutlinedButton(
        style: style,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label!, style: TextStyle(color: labelColor ?? Colors.white)),
            const SizedBox(width: 6),
            icon!,
          ],
        ),
      );
    } else {
      button = OutlinedButton.icon(
        style: style,
        onPressed: onPressed,
        icon: icon!,
        label: Text(
          label!,
          style: TextStyle(color: labelColor ?? Colors.white),
        ),
      );
    }

    // Chỉ bọc Container nếu cần set width/height
    if (width != null || height != null) {
      button = SizedBox(width: width, height: height, child: button);
    }

    return button;
  }
}
