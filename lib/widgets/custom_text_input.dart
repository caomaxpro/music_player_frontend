import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String title;
  final String placeholder;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final TextEditingController? controller;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding; // Tổng padding
  final double? leftPadding;
  final double? rightPadding;
  final double? topPadding;
  final double? bottomPadding;
  final BoxBorder? border; // border tổng chung
  final BorderRadius? borderRadius; // Add this line
  final Color? cursorColor;

  const CustomTextInput({
    super.key,
    required this.title,
    required this.placeholder,
    this.titleStyle,
    this.contentStyle,
    this.backgroundColor,
    this.textColor,
    this.controller,
    this.width,
    this.height,
    this.padding,
    this.leftPadding,
    this.rightPadding,
    this.topPadding,
    this.bottomPadding,
    this.border,
    this.borderRadius, // Add this line
    this.cursorColor,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry effectivePadding =
        padding ??
        EdgeInsets.only(
          left: leftPadding ?? 12,
          right: rightPadding ?? 12,
          top: topPadding ?? 0,
          bottom: bottomPadding ?? 0,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              titleStyle ??
              Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor ?? Colors.black,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey.shade200,
            borderRadius:
                borderRadius ??
                BorderRadius.circular(8), // Use custom or default
            border: border,
          ),
          padding: effectivePadding,
          child: TextField(
            controller: controller,
            style: contentStyle ?? TextStyle(color: textColor ?? Colors.black),
            cursorColor: cursorColor ?? Colors.black,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: TextStyle(
                color: textColor?.withAlpha(100),
                height: 4,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
