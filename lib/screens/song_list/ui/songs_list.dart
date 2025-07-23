import 'package:flutter/material.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/song_list/songs_screen.dart';

class SongsList extends StatefulWidget {
  final List<Song> songs;
  final String playlistName;

  const SongsList({super.key, required this.songs, required this.playlistName});

  @override
  State<SongsList> createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  late List<Song> songs;

  @override
  void initState() {
    super.initState();
    songs = List<Song>.from(widget.songs);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      children:
          songs.asMap().entries.map((entry) {
            final song = entry.value;
            return Container(
              key: ValueKey('${song.title}_${song.artist}'),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  // Content chiếm 90%
                  Flexible(
                    flex: 9,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        // TODO: Navigate to song detail/player if needed
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.music_note),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  song.artist,
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
                  // Drag icon chiếm 10%
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
          final item = songs.removeAt(oldIndex);
          songs.insert(newIndex, item);
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
