import 'package:flutter/material.dart';

class CustomTextarea extends StatelessWidget {
  final String? hintText;
  final int maxLines;
  final int minLines;
  final TextEditingController? controller;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle; // Property for hint text styling
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final String? errorText; // Property for error message
  final TextStyle? errorTextStyle; // Property for error text styling
  final bool showError; // New flag to toggle error messages

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
    this.showError = false, // Default to false
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
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            minLines: minLines,
            style:
                textStyle ?? const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              hintText: hintText ?? 'Enter text here...',
              hintStyle:
                  hintTextStyle ??
                  TextStyle(color: Colors.grey.shade500), // Apply hintTextStyle
              border: InputBorder.none,
            ),
          ),
        ),
        if (showError &&
            errorText != null) // Show error only if showError is true
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText!,
              style:
                  errorTextStyle ??
                  TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ), // Default error text style
            ),
          ),
      ],
    );
  }
}
