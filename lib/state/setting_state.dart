import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// State for audio files fetched from local storage
final bgColorProvider = StateProvider<Color>(
  (ref) => Color.fromRGBO(49, 49, 49, 1.0),
);

final textColorProvider = StateProvider<Color>(
  (ref) => Color.fromRGBO(229, 229, 229, 1.0),
);

final cardColorProvider = StateProvider<Color>(
  (ref) => Color.fromRGBO(96, 96, 96, 0.41),
);

final thumbColorProvider = StateProvider<Color>(
  (ref) => Color.fromRGBO(96, 96, 96, 1),
);

final buttonColorProvider = StateProvider<Color>(
  (ref) => Color.fromRGBO(96, 96, 96, 0.67),
);
