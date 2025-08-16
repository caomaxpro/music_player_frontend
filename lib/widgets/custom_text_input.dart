import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String title;
  final String placeholder;
  final TextStyle? titleStyle; // Thêm style cho title
  final TextStyle? contentStyle; // Thêm style cho content
  final Color? backgroundColor;
  final Color? textColor;
  final TextEditingController? controller;

  const CustomTextInput({
    super.key,
    required this.title,
    required this.placeholder,
    this.titleStyle,
    this.contentStyle,
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
              titleStyle ??
              Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor ?? Colors.black,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: textColor ?? Colors.white, // Custom border color
              width: 2, // Custom border width
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            style: contentStyle ?? TextStyle(color: textColor ?? Colors.black),
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
