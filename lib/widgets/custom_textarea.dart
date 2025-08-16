import 'package:flutter/material.dart';

class CustomTextarea extends StatelessWidget {
  final String? hintText;
  final int maxLines;
  final int minLines;
  final TextEditingController? controller;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final String? errorText;
  final TextStyle? errorTextStyle;
  final bool showError;
  final double? borderWidth;
  final double? borderRadius;
  final double cursorWidth;
  final Color? cursorColor;

  const CustomTextarea({
    super.key,
    this.hintText,
    this.maxLines = 500,
    this.minLines = 5,
    this.controller,
    this.textStyle,
    this.hintTextStyle,
    this.padding,
    this.backgroundColor,
    this.errorText,
    this.errorTextStyle,
    this.showError = false,
    this.borderWidth,
    this.borderRadius,
    this.cursorWidth = 2,
    this.cursorColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          padding: padding ?? const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey.shade200,
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
            border:
                (borderWidth ?? 1) > 0
                    ? Border.all(
                      color: Colors.grey.shade400,
                      width: borderWidth ?? 1,
                    )
                    : null,
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            minLines: minLines,
            cursorWidth: cursorWidth,
            cursorColor: cursorColor,
            cursorOpacityAnimates: true,
            cursorHeight: 20,
            style:
                textStyle ?? const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              hintText: hintText ?? 'Enter text here...',
              hintStyle:
                  hintTextStyle ?? TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
            ),
          ),
        ),
        if (showError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText!,
              style:
                  errorTextStyle ??
                  const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
