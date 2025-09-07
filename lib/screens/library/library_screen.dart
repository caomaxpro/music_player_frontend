import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/recording.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/create/infor/infor_screen.dart';
import 'package:music_player/screens/create/set_karaoke_button.dart';
import 'package:music_player/screens/karaoke_player/helper/response_handler.dart';
import 'package:music_player/screens/library/helper/library_helper.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/screens/library/ui/library_track_list.dart';
import 'package:music_player/screens/library/widgets/function_bar/delete_bar.dart';
import 'package:music_player/screens/library/widgets/function_bar/delete_many_bar.dart';
import 'package:music_player/screens/library/ui/library_recent_track_list.dart';
import 'package:music_player/screens/library/widgets/function_bar/edit_bar.dart';
import 'package:music_player/screens/library/widgets/function_bar/filter_section.dart';
import 'package:music_player/screens/library/widgets/function_bar/function_bar.dart';
import 'package:music_player/screens/library/widgets/function_bar/sortby_bar.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/create_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/microphone_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_scaffold.dart';
import 'package:objectbox/objectbox.dart';

Future<void> _fetchSongs(WidgetRef ref) async {
  SongHandler songHandler = SongHandler();
  final allSongs = songHandler.getAllSongs();
  final songs = allSongs.length > 10 ? allSongs.sublist(0, 10) : allSongs;
  ref.read(audioFilesProvider.notifier).state = songs;

  // return songs;
}

class LibraryScreen extends ConsumerStatefulWidget {
  static const String routeName = 'library';

  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  // ignore: prefer_typing_uninitialized_variables
  late bool allTrackSectionExpanded = false;
  late List<Song> tracks;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSongs(ref);
      ref.read(createStateProvider.notifier).state = CreateState.init;
    });

    // setState(() async {
    //   tracks = await _fetchSongs(ref);
    // });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.microtask(() {
      // Check if the screen is being revisited
      // ignore: use_build_context_synchronously
      if (ModalRoute.of(context)?.isCurrent == true) {
        // Run your desired function here
        ref.read(createStateProvider.notifier).state = CreateState.init;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioFiles = ref.watch(audioFilesProvider);
    final textColor = ref.watch(textColorProvider);
    final function = ref.watch(functionProvider);

    return CustomScaffold(
      title: "Karaoke Tracks",
      body: SafeArea(
        child: KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisibility) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.headphones, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Karaoke Tracks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                if (audioFiles.isNotEmpty) ...[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child:
                        allTrackSectionExpanded
                            ? const SizedBox.shrink()
                            : AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  SizedBox(height: 24),
                                  RecentTracksSection(),
                                ],
                              ),
                            ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Library Track List',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        if (function == null) FunctionBar(),
                        if (function == LibraryFunction.edit) EditBar(),
                        if (function == LibraryFunction.delete)
                          DeleteBar(
                            onDeleteAll: () async {
                              ref.read(audioFilesProvider.notifier).state = [];

                              // delete all folders in provided app storage folder

                              // KaraokeService karaokeService = KaraokeService();

                              if (appStorageFolder.existsSync()) {
                                final subDirectories =
                                    appStorageFolder
                                        .listSync()
                                        .whereType<Directory>();
                                for (final dir in subDirectories) {
                                  try {
                                    await dir.delete(recursive: true);
                                    debugPrint('Deleted folder: ${dir.path}');
                                  } catch (e) {
                                    debugPrint(
                                      'Failed to delete folder: ${dir.path}, Error: $e',
                                    );
                                  }
                                }
                              } else {
                                debugPrint(
                                  'App storage folder does not exist.',
                                );
                              }

                              SongHandler songHandler = SongHandler();
                              songHandler.deleteAllSongs();
                            },
                          ),
                        if (function == LibraryFunction.sort) SortByBar(),
                        if (function == LibraryFunction.filter) FilterSection(),
                        if (function == LibraryFunction.deleteMany)
                          DeleteManyBar(),
                      ],
                    ),
                  ),
                ),

                if (audioFiles.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        "There is no track",
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                  ),

                if (audioFiles.isNotEmpty) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LibraryTrackList(),
                    ),
                  ),
                ],

                if (!isKeyboardVisibility)
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 10),
                    child: SetKaraokeButton(
                      onPressed: () {
                        // change create state to info
                        ref.read(createStateProvider.notifier).state =
                            CreateState.infor;

                        // set current audio file to empty
                        Song song =
                            Song(); // Create a Song with an empty ToMany<Recording>

                        ref.read(currentAudioFileProvider.notifier).state =
                            song;

                        Navigator.pushNamed(context, InforScreen.routeName);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
