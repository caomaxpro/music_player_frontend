// Tạo thêm màn hình để hiển thị file .txt trong folder
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/create/audio_file/audio_device.dart';
import 'package:music_player/screens/create/lyrics/utils/convert_lrc_to_json.dart';
import 'package:music_player/screens/storage/file_explorer_screen.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/widgets/custom_scaffold.dart';

class TextFilesScreen extends ConsumerWidget {
  final String folderName;
  final List<FileSystemEntity> files;
  final Color backgroundColor;
  final Color textColor;

  const TextFilesScreen({
    super.key,
    required this.folderName,
    required this.files,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            final fileName = file.path.split('/').last;
            return InkWell(
              onTap: () async {
                final ext = file.path.split('.').last.toLowerCase();
                String? content;

                switch (ext) {
                  case "txt":
                  case "json":
                  case "lrc":
                    content = await File(file.path).readAsString();
                    break;
                  case "docx":
                    final bytes = await File(file.path).readAsBytes();
                    content = docxToText(bytes);

                    break;
                  default:
                    content = '[Unsupported file type]';
                    break;
                }

                // debugPrint('''[Text Files Screen]:

                //   $content
                // ''');

                setLyricsState(content, ref);

                int count = 0;
                Navigator.popUntil(context, (route) {
                  return count++ == 2; // Pops back 2 screens
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 45, color: textColor),
                  const SizedBox(height: 8),
                  Text(
                    fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '.txt',
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
