import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/audio_file_svg.dart';
import 'package:music_player/widgets/custom_scaffold.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FolderFilesScreen extends ConsumerWidget {
  final String folderName;
  final List<SongModel> files;

  const FolderFilesScreen({
    super.key,
    required this.folderName,
    required this.files,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = ref.read(bgColorProvider);
    final textColor = ref.read(textColorProvider);

    return CustomScaffold(
      title: "Files",
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return InkWell(
              onTap: () {
                final updatedFile = ref
                    .read(currentAudioFileProvider)
                    .copyWith(filePath: file.data);

                ref.read(currentAudioFileProvider.notifier).state = updatedFile;

                // SongHandler songHandler = SongHandler();
                // final existingSong = songHandler.getSongById(updatedFile.id);
                // if (existingSong != null) {
                //   songHandler.updateSongInDB(updatedSong: updatedFile);
                // }

                int count = 0;
                Navigator.popUntil(context, (route) {
                  return count++ == 2; // Pops back 2 screens
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(scale: 1.5, child: AudioFileSvg()),
                  const SizedBox(height: 15),
                  Text(
                    file.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    file.fileExtension,
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor.withAlpha(200),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
