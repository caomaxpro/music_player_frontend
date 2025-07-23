import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/main.dart';
import 'package:music_player/screens/music_player/music_player_screen.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player/utils/data_processor.dart';

class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing StorageScreen...');
    Future(() {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      debugPrint('Initializing data...');
      final songHandler = SongHandler();

      // Check if the database has data
      final songsInDatabase = songHandler.getAllSongs();
      debugPrint('Songs in database: ${songsInDatabase.length}');

      if (songsInDatabase.isNotEmpty) {
        // Fetch data from database to state
        debugPrint('Fetching data from database to state...');
        await DataProcessing.fetchDatabaseToState(ref);
      } else {
        // Fetch data from local storage and save to database
        debugPrint('Fetching data from local storage...');
        await DataProcessing.fetchLocalStorageToDatabase(context, _audioQuery);
        debugPrint('Fetching data from database to state...');
        await DataProcessing.fetchDatabaseToState(ref);
      }

      setState(() {
        _isLoading = false;
      });
      debugPrint('Data initialization complete.');
    } catch (e) {
      debugPrint('Error in _initializeData: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    debugPrint('Refreshing data...');
    setState(() {
      _isLoading = true;
    });

    // Fetch data from local storage and save to database
    await DataProcessing.fetchLocalStorageToDatabase(context, _audioQuery);
    debugPrint('Local storage data saved to database.');
    await DataProcessing.fetchDatabaseToState(ref);
    debugPrint('Database data fetched to Riverpod.');

    setState(() {
      _isLoading = false;
    });
    debugPrint('Data refresh complete.');
  }

  @override
  Widget build(BuildContext context) {
    // Watch the audioFiles from audioStateProvider
    final audioFiles = ref.watch(audioFilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await refreshData();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : audioFiles.isEmpty
              ? const Center(child: Text('No MP3 files found.'))
              : ListView.builder(
                itemCount: audioFiles.length,
                itemBuilder: (context, index) {
                  final song = audioFiles[index];
                  return GestureDetector(
                    onTap: () async {
                      // Stop the audio player
                      await audioHandler.customAction('pause');
                      await audioHandler.customAction('load', {
                        'paths': [
                          song['filePath'] as String,
                        ], // Ensure the data type is String
                      });

                      // Update the current audio file in the state
                      ref.read(currentAudioFileProvider.notifier).state = song;

                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MusicPlayerScreen(),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(song["title"]),
                      subtitle: Text(song["artist"]),
                      trailing: const Icon(Icons.play_circle_fill),
                    ),
                  );
                },
              ),
    );
  }
}
