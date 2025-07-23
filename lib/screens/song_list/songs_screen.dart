import 'package:flutter/material.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/song_list/ui/song_function_bar.dart';
import 'package:music_player/screens/song_list/ui/songs_list.dart';

class PlaylistSongsScreen extends StatelessWidget {
  final String playlistName;
  final List<Song> songs;

  const PlaylistSongsScreen({
    super.key,
    required this.playlistName,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(playlistName)),
      body: Column(
        children: [
          SongsListFunctionBar(),
          Expanded(child: SongsList(songs: songs, playlistName: playlistName)),
        ],
      ),
    );
  }
}
