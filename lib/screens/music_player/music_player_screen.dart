import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/music_player/ui/lyrics.dart';
import 'package:music_player/screens/music_player/ui/song_info.dart';
import 'package:music_player/screens/music_player/ui/song_controller.dart';
import '../../state/audio_state.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentAudioFile = ref.read(currentAudioFileProvider);
      debugPrint('Current audio file: $currentAudioFile');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MusicPlayerScreen...');
    final currentAudioFile = ref.watch(currentAudioFileProvider);
    debugPrint('Current Audio File: $currentAudioFile');

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      backgroundColor: const Color.fromARGB(255, 254, 252, 252),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SongInfo(
              title: currentAudioFile["title"] ?? "Unknown Title",
              artist: currentAudioFile["artist"] ?? "Unknown Artist",
            ),
            const SizedBox(height: 32),
            SongController(),
            const SizedBox(height: 24),
            SongLyrics(),
          ],
        ),
      ),
    );
  }
}
