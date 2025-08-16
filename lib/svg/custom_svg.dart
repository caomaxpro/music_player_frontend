import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvg extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final String rawSvg; // Chuỗi SVG thô, bao gồm cả <svg ...>...</svg>

  const CustomSvg({
    super.key,
    this.width = 142,
    this.height = 174,
    this.color = const Color(0xFFCDCDCD),
    required this.rawSvg,
  });

  @override
  Widget build(BuildContext context) {
    // Thay width, height, viewBox trong thẻ <svg ...>
    String svg = rawSvg
        .replaceAll(RegExp(r'width="[^"]*"'), 'width="$width"')
        .replaceAll(RegExp(r'height="[^"]*"'), 'height="$height"')
        .replaceAll(RegExp(r'viewBox="[^"]*"'), 'viewBox="0 0 $width $height"');

    // Thay tất cả fill="..." trong path thành màu mong muốn
    svg = svg.replaceAll(
      RegExp(r'fill="[^"]*"'),
      'fill="${_colorToHex(color)}"',
    );

    return SvgPicture.string(
      svg,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
