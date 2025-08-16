import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/create/lyrics/lyrics_options.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

import 'package:google_drive_file_picker/google_drive_file_picker.dart';

class AudioGoogleDriveScreen extends StatefulWidget {
  const AudioGoogleDriveScreen({super.key});

  @override
  State<AudioGoogleDriveScreen> createState() => _AudioGoogleDriveScreenState();
}

class _AudioGoogleDriveScreenState extends State<AudioGoogleDriveScreen> {
  String fileName = '';
  String filePath = "";

  final GoogleDriveController controller = GoogleDriveController();
  File? _file;

  void _handleUpload() async {
    // TODO: Thay thế bằng logic upload thực tế từ Google Drive
    final file = await controller.getFileFromGoogleDrive(context: context);

    if (file != null) {
      setState(() {
        _file = file;
      });
    }
  }

  void _handleRemove() {
    setState(() {
      fileName = "";
    });
  }

  @override
  void initState() {
    controller.setAPIKey(apiKey: 'AIzaSyA9SkhWwmRR_NsZeGxVg9kbiUVlKkpz0g8');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFF232226),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Google Drive',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Google Drive',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload an audio file from Google Drive',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'The selected audio file must be\nless than 10 MB in size',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  CustomIconButton(
                    label: "Upload from Drive",
                    onPressed: _handleUpload,
                    width: 200,
                    borderWidth: 2,
                    borderRadius: 5,
                    verticalPadding: 0,
                    horizontalPadding: 0,
                    borderColor: Colors.green,
                    backgroundColor: const Color.fromARGB(75, 99, 166, 102),
                  ),
                ],
              ),
            ),
            if (fileName.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_done, color: Colors.blue[400], size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fileName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CustomIconButton(
                      label: 'Remove',
                      height: 35,
                      borderWidth: 2,
                      borderRadius: 5,
                      horizontalPadding: 4,
                      onPressed: _handleRemove,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ButtonToLyrics(filePath: filePath, fileName: fileName),
            ],
          ],
        ),
      ),
    );
  }
}

class ButtonToLyrics extends ConsumerWidget {
  final String filePath;
  final String fileName;

  const ButtonToLyrics({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomIconButton(
      label: "Set Audio File",
      onPressed: () {
        // set to state
        Song updatedAudioFile = ref
            .read(currentAudioFileProvider)
            .copyWith(filePath: filePath);

        // update state
        ref.read(currentAudioFileProvider.notifier).state = updatedAudioFile;

        // update db
        SongHandler songHandler = SongHandler();
        songHandler.updateSongInDB(updatedSong: updatedAudioFile);

        // navigate to lyrics options screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LyricsOptionsScreen()),
        );
      },
    );
  }
}
