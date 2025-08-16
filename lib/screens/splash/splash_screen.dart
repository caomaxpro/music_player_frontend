import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_player/screens/splash/ui/microphone.dart';
import 'package:music_player/state/setting_state.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = ref.watch(bgColorProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(child: AnimatedSvgRect()),
    );
  }
}
