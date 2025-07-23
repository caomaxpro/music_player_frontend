import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String title;
  final String placeholder;
  final TextStyle? fontStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final TextEditingController? controller;

  const CustomTextInput({
    super.key,
    required this.title,
    required this.placeholder,
    this.fontStyle,
    this.backgroundColor,
    this.textColor,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              fontStyle ??
              Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor ?? Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            style:
                fontStyle?.copyWith(color: textColor) ??
                TextStyle(color: textColor ?? Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: TextStyle(color: textColor?.withAlpha(100)),
            ),
          ),
        ),
      ],
    );
  }
}
