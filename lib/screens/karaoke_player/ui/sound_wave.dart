import 'package:flutter/material.dart';

class SoundWaveSlider extends StatelessWidget {
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final List<double> rms;
  final Color highlightColor; // <--- Add this
  final Color backgroundColor; // <--- Add this

  const SoundWaveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    required this.max,
    required this.rms,
    this.highlightColor = Colors.deepPurple, // <--- Default highlight
    this.backgroundColor = const Color(0xFFD1C4E9), // <--- Default bg
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soundwave track with animation
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: value / max),
              duration: const Duration(
                milliseconds: 50,
              ), // Adjust duration for smoothness
              builder: (context, progress, child) {
                return CustomPaint(
                  painter: SoundWavePainter(
                    progress: progress,
                    rms: rms,
                    highlightColor: highlightColor,
                    backgroundColor: backgroundColor,
                  ),
                );
              },
            ),
          ),
          // Transparent slider for thumb & interaction
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackShape: const _NoTrackShape(),
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              onChanged: onChanged,
              onChangeStart: onChangeStart, // Pass onChangeStart to the Slider
              onChangeEnd: onChangeEnd, // Pass onChangeEnd to the Slider
            ),
          ),
        ],
      ),
    );
  }
}

class _NoTrackShape extends SliderTrackShape {
  const _NoTrackShape();
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    // Do not paint default track
  }
}

class SoundWavePainter extends CustomPainter {
  final double progress;
  final List<double> rms;
  final Color highlightColor;
  final Color backgroundColor;

  SoundWavePainter({
    this.progress = 0.0,
    required this.rms,
    required this.highlightColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBg =
        Paint()
          ..color = backgroundColor
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.square;
    final paintFg =
        Paint()
          ..color = highlightColor
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.square;

    final barCount = rms.length;
    final barWidth = size.width / (barCount * 2 - 1);
    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth * 2;
      // scale rms value to bar height (0.3~1.0 of size.height)
      final barHeight = size.height * (0.3 + 0.7 * rms[i].clamp(0.0, 1.0));
      final isActive = (i / barCount) < progress;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - barHeight),
        isActive ? paintFg : paintBg,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SoundWavePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.rms != rms ||
      oldDelegate.highlightColor != highlightColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
