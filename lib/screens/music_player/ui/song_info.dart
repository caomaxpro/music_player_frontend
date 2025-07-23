import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    // fetchSongData(widget.title, widget.artist);

    internetConnection = ref.read(internetConnectionProvider);
  }

  Future<void> fetchSongData(String title, String artist) async {
    final currentAudioFile = ref.read(currentAudioFileProvider);
    debugPrint('Current audio file (JSON): ${jsonEncode(currentAudioFile)}');
    final isOnlineSearch = currentAudioFile['isOnlineSearch'] ?? false;

    debugPrint('Checking isOnlineSearch field: $isOnlineSearch');

    if (isOnlineSearch) {
      debugPrint('Data already fetched online. Using cached data.');
      setState(() {
        lyrics = currentAudioFile['lyrics'];
        albumArtUrl = currentAudioFile['audioImgUri'];
        isLoading = false;
      });
      return;
    }

    try {
      // Check internet connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception('No internet connection');
      }
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      setState(() {
        errorMessage = 'No internet connection';
        isLoading = false;
      });
      return;
    }

    final query = title;
    final url = Uri.parse(
      'http://192.168.12.101:5000/lyrics?query=${Uri.encodeComponent(query)}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update Riverpod state
        final updatedAudioFile = {
          ...currentAudioFile,
          'title': data["title"] ?? title,
          'artist': data["artist"] ?? artist,
          'audioImgUri': data["song_art_image_url"] ?? '',
          'lyrics': data["lyrics"],
          'isOnlineSearch': true,
        };

        ref.read(currentAudioFileProvider.notifier).state = updatedAudioFile;

        // Update the audioFiles list in the state
        final audioFiles = ref.read(audioFilesProvider);
        final updatedAudioFiles =
            audioFiles.map((file) {
              if (file['id'] == currentAudioFile['id']) {
                return {...file, ...updatedAudioFile};
              }
              return file;
            }).toList();

        ref.read(audioFilesProvider.notifier).state = updatedAudioFiles;

        // Update both db and state
        final songHandler = SongHandler();
        songHandler.updateSong(
          ref: ref,
          id: currentAudioFile['id'] ?? 0,
          updatedFields: {
            "title": updatedAudioFile['title'],
            "artist": updatedAudioFile['artist'],
            "audioImgUri": updatedAudioFile['audioImgUri'],
            "lyrics": updatedAudioFile['lyrics'],
            "isOnlineSearch": true,
          },
        );

        setState(() {
          lyrics = data["lyrics"];
          albumArtUrl = data["song_art_image_url"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Lyrics not found';
          isLoading = false;
        });

        // Update state with default data
        // ref.read(currentAudioFileProvider.notifier).state = {
        //   ...currentAudioFile,
        //   'title': title,
        //   'artist': artist,
        //   'audioImgUri': '',
        //   'lyrics': null,
        // };
      }
    } catch (e) {
      debugPrint('Error fetching song data: $e');
      setState(() {
        errorMessage = 'Error fetching song data: $e';
        isLoading = false;
      });

      // Update state with default data in case of error
      ref.read(currentAudioFileProvider.notifier).state = {
        ...currentAudioFile,
        'title': title,
        'artist': artist,
        'audioImgUri': '',
        'lyrics': null,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentAudioFile = ref.watch(currentAudioFileProvider);

    // Use default values if data is not available
    final title = currentAudioFile['title'] ?? 'Unknown Title';
    final artist = currentAudioFile['artist'] ?? 'Unknown Artist';
    final albumArtUrl = currentAudioFile['audioImgUri'];
    final hasError = errorMessage != null;

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
        // if (hasError)
        //   Text(
        //     errorMessage!,
        //     style: const TextStyle(fontSize: 16, color: Colors.red),
        //     textAlign: TextAlign.center,
        //   ),
      ],
    );
  }
}
