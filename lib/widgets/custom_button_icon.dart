import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final String? label;
  final Widget? icon; // Cho phép icon là null
  final VoidCallback? onPressed;
  final Color? labelColor;
  final double? labelFontSize; // Add this line for label font size
  final double? width;
  final double? height;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? leftPadding;
  final double? rightPadding;
  final double? topPadding;
  final double? bottomPadding;
  final double? borderRadius;
  final double? borderWidth;
  final bool textFirst;
  final Color? backgroundColor;
  final Color? borderColor; // <-- add this line
  final EdgeInsetsGeometry? padding; // Thêm dòng này

  const CustomIconButton({
    this.label,
    this.icon,
    this.onPressed,
    this.labelColor,
    this.labelFontSize, // Add this line for label font size
    this.width,
    this.height,
    this.horizontalPadding,
    this.verticalPadding,
    this.leftPadding,
    this.rightPadding,
    this.topPadding,
    this.bottomPadding,
    this.padding, // Thêm dòng này
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
    // Ưu tiên padding tổng nếu truyền vào, nếu không thì dùng các padding riêng lẻ
    final EdgeInsetsGeometry buttonPadding =
        padding ??
        EdgeInsets.only(
          left: leftPadding ?? horizontalPadding ?? 0,
          right: rightPadding ?? horizontalPadding ?? 0,
          top: topPadding ?? verticalPadding ?? 0,
          bottom: bottomPadding ?? verticalPadding ?? 0,
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
          style: TextStyle(
            color: labelColor ?? Colors.white,
            fontSize: labelFontSize ?? 14, // Use labelFontSize here
          ),
        ),
      );
    } else if (textFirst) {
      button = OutlinedButton(
        style: style,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label!,
              style: TextStyle(
                color: labelColor ?? Colors.white,
                fontSize: labelFontSize ?? 14, // Use labelFontSize here
              ),
            ),
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
          style: TextStyle(
            color: labelColor ?? Colors.white,
            fontSize: labelFontSize ?? 14, // Use labelFontSize here
          ),
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
