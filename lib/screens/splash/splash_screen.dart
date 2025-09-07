import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/library/library_screen.dart';
import 'package:music_player/screens/splash/ui/microphone.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_karaoke_loading.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = ref.watch(bgColorProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: CustomLoadingWidget(
          loadingTime: 60000,
          onLoadingEnd: () {
            Navigator.pushNamed(context, LibraryScreen.routeName);
          },
        ),
      ),
    );
  }
}
