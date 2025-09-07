import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/create/infor/infor_screen.dart';
import 'package:music_player/screens/karaoke_player/helper/response_handler.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_screen.dart';
import 'package:music_player/screens/library/helper/library_helper.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/screens/library/widgets/function_bar/delete_bar.dart';
import 'package:music_player/screens/library/widgets/function_bar/delete_many_bar.dart';
import 'package:music_player/screens/library/widgets/function_bar/edit_bar.dart';
import 'package:music_player/screens/library/widgets/function_bar/filter_section.dart';
import 'package:music_player/screens/library/widgets/function_bar/function_bar.dart';
import 'package:music_player/screens/library/widgets/function_bar/sortby_bar.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/custom_svg.dart';
import 'package:music_player/svg/delete_svg.dart';
import 'package:music_player/svg/microphone_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_dialog.dart';
import 'package:music_player/widgets/custom_loading_button.dart';

typedef ToggleSectionCallback = void Function(bool expanded);

class TracksList extends ConsumerStatefulWidget {
  final int itemCount;
  final void Function(int index)? onMicrophoneTap;

  const TracksList({super.key, required this.itemCount, this.onMicrophoneTap});

  @override
  ConsumerState<TracksList> createState() => _TracksListState();
}

class _TracksListState extends ConsumerState<TracksList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentAudioFile = ref.watch(currentAudioFileProvider);
    final function = ref.watch(functionProvider);
    final audioFiles = ref.watch(audioFilesProvider);
    final textColor = ref.read(textColorProvider);
    final selectedTrackIds = ref.watch(selectedTrackIdsProvider);

    if (audioFiles.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            "There is no track available",
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: audioFiles.length,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Handle tap event
                        SongHandler songHandler = SongHandler();

                        Song fetchedSong =
                            songHandler.getSongById(audioFiles[index].id)!;

                        ref.read(currentAudioFileProvider.notifier).state =
                            fetchedSong;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => KaraokeTrackScreen(
                                  folderPath: fetchedSong.storagePath,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.grey.withAlpha(100),
                        //   ),
                        width:
                            double
                                .infinity, // Ensure the container takes full width
                        height: 60, // Define a fixed height
                        color:
                            Colors
                                .transparent, // Optional: Add a color for debugging
                        child: Row(
                          children: [
                            // Image Container
                            Container(
                              width: 60,
                              height: 60,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.file(
                                File(audioFiles[index].imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ), // Add spacing between image and text
                            // Track Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    audioFiles[index].title,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    audioFiles[index].artist,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Microphone button
                  CustomIconButton(
                    leftPadding: 0,
                    icon:
                        (() {
                          switch (function) {
                            case LibraryFunction.deleteMany:
                              return selectedTrackIds.contains(
                                    audioFiles[index].id,
                                  )
                                  ? const Icon(
                                    Icons.check_box,
                                    color: Colors.white70,
                                    size: 24,
                                  )
                                  : const Icon(
                                    Icons.check_box_outline_blank,
                                    color: Colors.white70,
                                    size: 24,
                                  );
                            case LibraryFunction.edit:
                              return const Icon(
                                Icons.edit,
                                color: Colors.white70,
                                size: 24,
                              );

                            case LibraryFunction.delete:
                              return CustomSvg(
                                rawSvg: deleteSvgString,
                                svgHeight: 18,
                                viewBoxHeight: 24,
                                color: Colors.redAccent, // màu riêng cho Delete
                              );

                            default:
                              return Container(
                                padding: const EdgeInsets.only(left: 5, top: 2),
                                child: MicrophoneSvg(
                                  svgWidth: 24,
                                  svgHeight: 24,
                                  viewBoxWidth: 24,
                                  viewBoxHeight: 24,
                                  color: Colors.white70,
                                ),
                              );
                          }
                        })(),
                    backgroundColor:
                        function == LibraryFunction.deleteMany
                            ? Colors.transparent
                            : Colors.grey[600],
                    height: 40,
                    width: 40,
                    borderWidth: 0,
                    borderRadius: 20,
                    onPressed: () {
                      switch (function) {
                        case LibraryFunction.deleteMany:
                          final copiedList = List<int>.from(selectedTrackIds);
                          final trackId = audioFiles[index].id;
                          if (copiedList.contains(trackId)) {
                            copiedList.remove(trackId);
                          } else {
                            copiedList.add(trackId);
                          }
                          ref.read(selectedTrackIdsProvider.notifier).state =
                              copiedList;
                          break;

                        case LibraryFunction.edit:
                          // Set currentAudioFile state to selected item
                          ref.read(currentAudioFileProvider.notifier).state =
                              audioFiles[index];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InforScreen(),
                            ),
                          );
                          break;

                        case LibraryFunction.delete:
                          CustomDialog.show(
                            context,
                            title: "Delete Karaoke Track",
                            content: Text(
                              '''Are you sure you want to delete "${audioFiles[index].title}?''',
                            ),
                            onConfirm: () {
                              deleteSongFromLibrary(
                                song: audioFiles[index],
                                ref: ref,
                              );

                              ref.read(functionProvider.notifier).state = null;
                            },
                          );
                          break;

                        case LibraryFunction.sort:
                          // You can add sort logic here if needed
                          break;

                        case LibraryFunction.filter:
                          // You can add filter logic here if needed
                          break;

                        case null:
                          ref.read(currentAudioFileProvider.notifier).state =
                              audioFiles[index];
                          Navigator.pushNamed(context, "karaokePlayer");
                          break;
                      }

                      if (widget.onMicrophoneTap != null) {
                        widget.onMicrophoneTap!(index);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class LibraryTrackList extends ConsumerStatefulWidget {
  const LibraryTrackList({super.key});

  @override
  ConsumerState<LibraryTrackList> createState() => _LibraryTrackListState();
}

class _LibraryTrackListState extends ConsumerState<LibraryTrackList> {
  bool _hideContent = false;

  @override
  void didUpdateWidget(covariant LibraryTrackList oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = ref.read(textColorProvider);
    final function = ref.watch(functionProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              if (function != LibraryFunction.filter)
                SizedBox(
                  height: 400,
                  child: TracksList(itemCount: 10, onMicrophoneTap: (index) {}),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label),
    );
  }
}
