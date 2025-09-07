import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? contentColor;
  final double borderRadius;
  final double elevation;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final TextStyle? buttonTextStyle;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.backgroundColor,
    this.titleColor,
    this.contentColor,
    this.borderRadius = 16,
    this.elevation = 2,
    this.titleStyle,
    this.contentStyle,
    this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBgColor =
        backgroundColor ?? Color.fromRGBO(49, 49, 49, 1.0);
    final Color effectiveTitleColor = titleColor ?? Colors.black;
    final Color effectiveContentColor = contentColor ?? Colors.black87;

    return Dialog(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      backgroundColor: effectiveBgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style:
                  titleStyle ??
                  TextStyle(
                    color: effectiveTitleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Content
            content,
            const SizedBox(height: 24),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      textStyle:
                          buttonTextStyle ??
                          const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (onCancel != null) onCancel!();
                      Navigator.of(context).pop(false);
                    },
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle:
                          buttonTextStyle ??
                          const TextStyle(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (onConfirm != null) onConfirm!();
                      Navigator.of(context).pop(true);
                    },
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Static helper to show this dialog easily
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required Widget content,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? backgroundColor,
    Color? titleColor,
    Color? contentColor,
    double borderRadius = 16,
    double elevation = 2,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
    TextStyle? buttonTextStyle,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Color.fromRGBO(0, 0, 0, 0.4),
      builder:
          (context) => CustomDialog(
            title: title,
            content: content,
            confirmText: confirmText,
            cancelText: cancelText,
            onConfirm: onConfirm,
            onCancel: onCancel,
            backgroundColor: backgroundColor,
            titleColor: titleColor,
            contentColor: contentColor,
            borderRadius: borderRadius,
            elevation: elevation,
            titleStyle: titleStyle,
            contentStyle: contentStyle,
            buttonTextStyle: buttonTextStyle,
          ),
    );
  }
}
