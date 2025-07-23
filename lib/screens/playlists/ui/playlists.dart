import 'package:flutter/material.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/song_list/songs_screen.dart';

class Playlist {
  final String name;
  final int songCount;

  Playlist({required this.name, required this.songCount});
}

class PlaylistsWidget extends StatefulWidget {
  const PlaylistsWidget({super.key});

  @override
  State<PlaylistsWidget> createState() => _PlaylistsWidgetState();
}

class _PlaylistsWidgetState extends State<PlaylistsWidget> {
  List<Playlist> playlists = [
    Playlist(name: 'Chill Vibes', songCount: 12),
    Playlist(name: 'Workout', songCount: 20),
  ];

  // Dummy songs for demo
  final List<Song> demoSongs = [
    Song.withCustomId(
      title: 'Song A',
      artist: 'Artist 1',
      duration: 210,
      filePath: '/storage/emulated/0/Music/song_a.mp3',
      audioImgUri: 'assets/images/song_a.jpg',
      lyrics: 'Lyrics for Song A...',
    ),
    Song.withCustomId(
      title: 'Song B',
      artist: 'Artist 2',
      duration: 180,
      filePath: '/storage/emulated/0/Music/song_b.mp3',
      audioImgUri: 'assets/images/song_b.jpg',
      lyrics: 'Lyrics for Song B...',
    ),
    Song.withCustomId(
      title: 'Song C',
      artist: 'Artist 3',
      duration: 240,
      filePath: '/storage/emulated/0/Music/song_c.mp3',
      audioImgUri: 'assets/images/song_c.jpg',
      lyrics: 'Lyrics for Song C...',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      children:
          playlists.asMap().entries.map((entry) {
            final playlist = entry.value;
            return Container(
              key: ValueKey(playlist.name),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Flexible(
                    flex: 9,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => PlaylistSongsScreen(
                                  playlistName: playlist.name,
                                  songs: demoSongs,
                                ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.playlist_play),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${playlist.songCount} songs',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ReorderableDragStartListener(
                        index: entry.key,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = playlists.removeAt(oldIndex);
          playlists.insert(newIndex, item);
        });
      },
      proxyDecorator:
          (child, index, animation) => Material(
            color: Colors.transparent,
            elevation: 6,
            shadowColor: Colors.black26,
            child: child,
          ),
    );
  }
}
