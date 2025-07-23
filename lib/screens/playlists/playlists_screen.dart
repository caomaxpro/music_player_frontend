import 'package:flutter/material.dart';
import 'package:music_player/screens/playlists/ui/function_bar.dart';
import 'package:music_player/screens/playlists/ui/playlists.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      body: Column(
        children: [FunctionBar(), Expanded(child: PlaylistsWidget())],
      ),
    );
  }
}
