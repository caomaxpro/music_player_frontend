import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

double _extractSvgValue(String svg, String attr, double fallback) {
  final match = RegExp('$attr="([\\d.]+)"').firstMatch(svg);
  return match != null
      ? double.tryParse(match.group(1) ?? '') ?? fallback
      : fallback;
}

double _extractViewBoxWidth(String svg, double fallback) {
  final match = RegExp(r'viewBox="[^"]*"').firstMatch(svg);
  if (match != null) {
    final parts = match.group(0)!.replaceAll(RegExp(r'[a-z="]'), '').split(' ');
    if (parts.length == 4) return double.tryParse(parts[2]) ?? fallback;
  }
  return fallback;
}

double _extractViewBoxHeight(String svg, double fallback) {
  final match = RegExp(r'viewBox="[^"]*"').firstMatch(svg);
  if (match != null) {
    final parts = match.group(0)!.replaceAll(RegExp(r'[a-z="]'), '').split(' ');
    if (parts.length == 4) return double.tryParse(parts[3]) ?? fallback;
  }
  return fallback;
}

class CustomSvg extends StatelessWidget {
  final String rawSvg; // Chuỗi SVG thô, bao gồm cả <svg ...>...</svg>
  final double svgWidth;
  final double svgHeight;
  final double viewBoxWidth;
  final double viewBoxHeight;
  final double scale;
  final Color color;

  const CustomSvg({
    super.key,
    required this.rawSvg,
    this.svgWidth = 142,
    this.svgHeight = 174,
    this.viewBoxWidth = 142,
    this.viewBoxHeight = 174,
    this.color = const Color(0xFFCDCDCD),
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final double svgWidth =
        (this.svgWidth == 142
            ? _extractSvgValue(rawSvg, 'width', 142)
            : this.svgWidth) *
        scale;
    final double svgHeight =
        (this.svgHeight == 174
            ? _extractSvgValue(rawSvg, 'height', 174)
            : this.svgHeight) *
        scale;
    final double viewBoxWidth =
        (this.viewBoxWidth == 142
            ? _extractViewBoxWidth(rawSvg, 142)
            : this.viewBoxWidth) *
        scale;
    final double viewBoxHeight =
        (this.viewBoxHeight == 174
            ? _extractViewBoxHeight(rawSvg, 174)
            : this.viewBoxHeight) *
        scale;

    String svg = rawSvg
        .replaceAll(RegExp(r'width="[^"]*"'), 'width="$svgWidth"')
        .replaceAll(RegExp(r'height="[^"]*"'), 'height="$svgHeight"')
        .replaceAll(
          RegExp(r'viewBox="[^"]*"'),
          'viewBox="0 0 $viewBoxWidth $viewBoxHeight"',
        );

    svg = svg.replaceAll(
      RegExp(r'fill="[^"]*"'),
      'fill="${_colorToHex(color)}"',
    );

    return SvgPicture.string(
      svg,
      width: svgWidth,
      height: svgHeight,
      fit: BoxFit.cover,
    );
  }

  String _colorToHex(Color color) {
    // ignore: deprecated_member_use
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
