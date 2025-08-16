import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final guitarSvgString = '''
<svg width="32" height="34" viewBox="0 0 32 34" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M32.2695 2.72949C32.3473 2.80765 32.4216 2.88754 32.4951 2.96387L32.3174 3.16113L32.1777 3.31445L31.5576 3.89453L31.1631 4.26367L30.7686 4.63184L29.2861 6.01758L29.3428 6.07617L26.2373 9.16699L22.6309 12.7559L21.5176 13.8643L21.5693 13.9512C21.5592 13.9579 21.5496 13.9639 21.541 13.9697C21.4116 14.0569 21.2915 14.1535 21.2002 14.2295C21.0091 14.3887 20.7871 14.5924 20.5615 14.8066C20.1028 15.2423 19.536 15.8123 18.9893 16.3818C18.4425 16.9514 17.8957 17.5418 17.4775 18.0195C17.2717 18.2547 17.0768 18.4856 16.9248 18.6836C16.852 18.7785 16.7618 18.9006 16.6807 19.0312C16.6413 19.0946 16.5796 19.1983 16.5215 19.3271C16.4947 19.3866 16.3786 19.6358 16.3428 19.9844C16.3385 19.9976 16.3347 20.0152 16.3271 20.0361C16.2843 20.1556 16.2124 20.322 16.1191 20.5068C16.0268 20.69 15.9285 20.8597 15.8428 20.9902C15.8042 21.0489 15.7739 21.0903 15.7539 21.1162C15.2355 21.5623 14.4017 21.5607 13.8232 20.9053C13.5701 20.6184 13.4764 20.1711 13.666 19.6719C13.8558 19.1724 14.243 18.8592 14.6738 18.7949C15.3906 18.6879 15.947 18.4089 16.5527 17.9268C17.0566 17.5256 17.6998 16.8978 18.6113 15.9873C19.2161 15.3831 19.7736 14.8038 20.1865 14.3545C20.3901 14.133 20.5745 13.9258 20.7158 13.7549C20.7831 13.6735 20.8658 13.5708 20.9404 13.4639C20.9513 13.4483 20.9634 13.428 20.9785 13.4053L21.042 13.4443L22.1553 12.3369L25.7734 8.73633L29.3906 5.13574L30.5645 3.96777L30.5879 3.94629L30.9814 3.57812L32.082 2.54785C32.1432 2.60777 32.2073 2.66697 32.2695 2.72949Z" fill="#CDCDCD" stroke="#CDCDCD" stroke-width="4"/>
</svg>
''';

class GuitarSvg extends StatelessWidget {
  final double svgWidth;
  final double svgHeight;
  final double viewBoxWidth;
  final double viewBoxHeight;
  final Color color;

  const GuitarSvg({
    super.key,
    this.svgWidth = 32,
    this.svgHeight = 34,
    this.viewBoxWidth = 32,
    this.viewBoxHeight = 34,
    this.color = const Color(0xFFCDCDCD),
  });

  @override
  Widget build(BuildContext context) {
    String svg = guitarSvgString
        .replaceAll(RegExp(r'width="[^"]*"'), 'width="$svgWidth"')
        .replaceAll(RegExp(r'height="[^"]*"'), 'height="$svgHeight"')
        .replaceAll(
          RegExp(r'viewBox="[^"]*"'),
          'viewBox="0 0 $viewBoxWidth $viewBoxHeight"',
        )
        .replaceAll(RegExp(r'fill="[^"]*"'), 'fill="${_colorToHex(color)}"')
        .replaceAll(
          RegExp(r'stroke="[^"]*"'),
          'stroke="${_colorToHex(color)}"',
        );

    return SvgPicture.string(
      svg,
      width: svgWidth,
      height: svgHeight,
      fit: BoxFit.cover,
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
