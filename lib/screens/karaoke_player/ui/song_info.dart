import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';

class SongInfo extends ConsumerStatefulWidget {
  final String title;
  final String artist;

  const SongInfo({super.key, required this.title, required this.artist});

  @override
  _SongInfoState createState() => _SongInfoState();
}

class _SongInfoState extends ConsumerState<SongInfo> {
  String? lyrics;
  String? albumArtUrl;
  bool isLoading = false;
  String? errorMessage;
  bool? internetConnection;

  @override
  void initState() {
    super.initState();
    internetConnection = ref.read(internetConnectionProvider);

    // Fetch data from local state
    final currentAudioFile = ref.read(currentAudioFileProvider);
    lyrics = currentAudioFile.lyrics;
    albumArtUrl = currentAudioFile.audioImgUri;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final currentAudioFile = ref.watch(currentAudioFileProvider);

    // Use default values if data is not available
    final title = currentAudioFile.title ?? 'Unknown Title';
    final artist = currentAudioFile.artist ?? 'Unknown Artist';
    final albumArtUrl = currentAudioFile.audioImgUri;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child:
              (albumArtUrl?.isNotEmpty ?? false)
                  ? Image.network(
                    albumArtUrl!,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  )
                  : Image.asset(
                    'assets/images/default_album_art.png', // Default album art
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          artist,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
