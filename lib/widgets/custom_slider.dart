import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color barColor;
  final Color outlineColor;
  final double outlineWidth; // <--- Add this
  final double trackHeight; // <--- Add this
  final double trackWidth; // <--- Add this
  final Widget? thumbIcon;
  final double thumbIconSize;
  final Color thumbColor;

  const CustomSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.barColor = Colors.blue,
    this.outlineColor = Colors.white,
    this.outlineWidth = 2, // <--- Default outline width
    this.trackHeight = 4, // <--- Default track height
    this.trackWidth = double.infinity, // <--- Default track width
    this.thumbIcon,
    this.thumbIconSize = 32,
    this.thumbColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: trackWidth,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: trackHeight,
          activeTrackColor: barColor,
          inactiveTrackColor: barColor.withOpacity(0.3),
          trackShape: _CustomTrackShape(
            outlineColor: outlineColor,
            outlineWidth: outlineWidth,
          ),
          overlayColor: outlineColor.withOpacity(0.2),
          thumbShape: _CustomThumbShape(
            thumbIcon ??
                Icon(Icons.circle, size: thumbIconSize, color: Colors.white),
            thumbIconSize,
            thumbColor,
          ),
        ),
        child: Slider(value: value, min: min, max: max, onChanged: onChanged),
      ),
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  final Color outlineColor;
  final double outlineWidth;
  const _CustomTrackShape({
    required this.outlineColor,
    required this.outlineWidth,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    double additionalActiveTrackHeight = 0.0,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    required RenderBox parentBox,
    Offset? secondaryOffset,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required Offset thumbCenter,
  }) {
    super.paint(
      context,
      offset,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      parentBox: parentBox,
      secondaryOffset: secondaryOffset,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
    );

    final trackRect = getPreferredRect(
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    ).shift(offset);

    final paint =
        Paint()
          ..color = outlineColor
          ..strokeWidth = outlineWidth
          ..style = PaintingStyle.stroke;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(trackRect.height / 2)),
      paint,
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final Widget icon;
  final double iconSize;
  final Color thumbColor;
  const _CustomThumbShape(this.icon, this.iconSize, this.thumbColor);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(iconSize, iconSize);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(center.dx - iconSize / 2, center.dy - iconSize / 2);

    // Draw a circular thumb background with custom color
    final thumbPaint =
        Paint()
          ..color = thumbColor
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(iconSize / 2, iconSize / 2),
      iconSize / 2,
      thumbPaint,
    );

    // Draw the icon using an Icon widget and TextPainter
    if (icon is Icon) {
      final iconData = (icon as Icon).icon;
      final iconColor = (icon as Icon).color ?? Colors.white;
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(iconData!.codePoint),
          style: TextStyle(
            fontSize: iconSize * 0.7,
            fontFamily: iconData.fontFamily,
            package: iconData.fontPackage,
            color: iconColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          iconSize / 2 - textPainter.width / 2,
          iconSize / 2 - textPainter.height / 2,
        ),
      );
    }
    canvas.restore();
  }
}
