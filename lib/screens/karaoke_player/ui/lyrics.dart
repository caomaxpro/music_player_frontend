import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/state/audio_state.dart';

class SongLyrics extends ConsumerWidget {
  const SongLyrics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the currentAudioFileProvider to get the current song
    final currentAudioFile = ref.watch(currentAudioFileProvider);

    // Get the lyrics from the current song
    final lyrics =
        currentAudioFile.lyrics.isNotEmpty
            ? currentAudioFile.lyrics
            : 'No lyrics available';

    // Get the device's width
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(2),
      width: deviceWidth * 0.9,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 254, 252, 252),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lyrics',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(lyrics, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
