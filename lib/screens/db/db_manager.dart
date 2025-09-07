import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_scaffold.dart';

class SongDbManagerScreen extends ConsumerStatefulWidget {
  const SongDbManagerScreen({super.key});

  @override
  ConsumerState<SongDbManagerScreen> createState() =>
      _SongDbManagerScreenState();
}

class _SongDbManagerScreenState extends ConsumerState<SongDbManagerScreen> {
  final SongHandler songHandler = SongHandler();

  late List<Song> songs;

  @override
  void initState() {
    super.initState();
    songs = songHandler.getAllSongs();
  }

  void _refreshSongs() {
    setState(() {
      songs = songHandler.getAllSongs();
    });
  }

  void _deleteSong(int id) {
    songHandler.deleteSong(id);
    _refreshSongs();
  }

  void _deleteAllSongs() {
    songHandler.box.removeAll();
    _refreshSongs();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = ref.watch(textColorProvider);
    final backgroundColor = ref.watch(bgColorProvider);

    return CustomScaffold(
      title: "Song DB Manager",
      appBar: AppBar(
        title: Text(
          'Song DB Manager',
          style: TextStyle(color: textColor, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _refreshSongs,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.red),
            tooltip: 'Delete All',
            onPressed:
                songs.isEmpty
                    ? null
                    : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete All Songs'),
                              content: const Text(
                                'Are you sure you want to delete all songs?',
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        _deleteAllSongs();
                      }
                    },
          ),
        ],
      ),
      body:
          songs.isEmpty
              ? Center(
                child: Text(
                  'No songs found.',
                  style: TextStyle(color: textColor, fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
                    title: Text(song.title ?? 'Untitled'),
                    subtitle: Text(song.artist ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSong(song.id),
                    ),
                  );
                },
              ),
    );
  }
}
