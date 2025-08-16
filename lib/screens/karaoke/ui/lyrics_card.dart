import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/screens/create/lyrics/utils/convert_lrc_to_json.dart';
import 'package:music_player/utils/datatype_converter.dart';
import 'package:music_player/widgets/custom_textarea.dart';

class LyricsPickerCard extends ConsumerStatefulWidget {
  final Function(String) onLyricsSelected;
  final Function(String) onLyricsEntered;
  final Function(File) onTranscribeAudio;

  const LyricsPickerCard({
    super.key,
    required this.onLyricsSelected,
    required this.onLyricsEntered,
    required this.onTranscribeAudio,
  });

  @override
  ConsumerState<LyricsPickerCard> createState() => _LyricsPickerCardState();
}

class _LyricsPickerCardState extends ConsumerState<LyricsPickerCard> {
  String? selectedFileName;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Watch currentAudioFile to trigger rebuild when it changes
    final currentAudioFile = ref.watch(currentAudioFileProvider);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(0),
        width: screenWidth * 0.95,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set lyrics for the song',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You can select lyrics from a file or enter them manually',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                // Allow the user to pick a file
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['txt', 'doc', 'lrc', 'json'],
                );
                if (result != null) {
                  String filePath = result.files.single.path!;
                  String fileName = result.files.single.name;

                  // Validate the file type
                  if (_isValidFileType(filePath)) {
                    setState(() {
                      selectedFileName = fileName;
                      errorMessage = null; // Clear any previous error
                    });
                    widget.onLyricsSelected(filePath);

                    // Update Riverpod state
                    File file = File(filePath);
                    String fileLyrics = await file.readAsString();

                    final updatedCurrentAudioFile = currentAudioFile.copyWith(
                      lyrics: fileLyrics,
                    );

                    ref.read(currentAudioFileProvider.notifier).state =
                        updatedCurrentAudioFile;
                  } else {
                    setState(() {
                      errorMessage =
                          'Invalid file format. Please select a .txt, .doc, .lrc, or .json file.';
                      selectedFileName = null; // Clear the file name
                    });
                  }
                }
              },
              icon: const Icon(Icons.folder),
              label: const Text('Select file from storage'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Set border radius
                ),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                // Allow the user to manually enter lyrics
                _showLyricsInputDialog(context);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Enter lyrics manually'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Set border radius
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  bool _isValidFileType(String filePath) {
    // Check if the file extension is valid
    final validExtensions = ['txt', 'doc', 'lrc', 'json'];
    final fileExtension = filePath.split('.').last.toLowerCase();
    return validExtensions.contains(fileExtension);
  }

  void _showLyricsInputDialog(BuildContext context) {
    TextEditingController lyricsController = TextEditingController();
    bool showError = false; // State to manage error visibility

    String sampleHintText = '''
[id: pshkpfmv] (optional)
[ar: artist name] 
[al: album name] (optional)
[ti: song title] 
[length: 03:53]
[00:27.09]Line 1
[00:29.81]Line 2
''';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.music_note, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Enter Song Lyrics',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Please enter the lyrics for the song below. Ensure the format is correct.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextarea(
                          controller: lyricsController,
                          hintText: sampleHintText,
                          maxLines: 10,
                          minLines: 5,
                          hintTextStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.all(12),
                          errorText:
                              showError
                                  ? "Invalid format! Please follow the .lrc format."
                                  : null, // Show error only if showError is true
                          showError: showError,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showError = !isValidLrcFormat(lyricsController.text);
                        });
                        if (!showError) {
                          Navigator.pop(context);
                          widget.onLyricsEntered(lyricsController.text);

                          final lrcParts = splitLrcMetaAndLyrics(
                            lyricsController.text,
                          );
                          final meta = lrcParts['meta'] ?? '';
                          final lyricsRaw = lrcParts['lyrics'] ?? '';

                          final parsedMeta = parseLrcMeta(meta);
                          final parsedLyrics = parseLrcLyrics(lyricsRaw);

                          /* 
                            parsedLyrics = [
                              [00:00:00, "Line 1"],
                              [00:00:30, "Line 2"]
                            ]

                            Create a method to 
                           */

                          final refinedLyrics = extractLyrics(parsedLyrics);

                          debugPrint("[Refined Lyrics]: $refinedLyrics");

                          final currentAudioFile = ref.read(
                            currentAudioFileProvider,
                          );

                          final updatedAudioFile = currentAudioFile.copyWith(
                            lyrics: refinedLyrics,
                            timestampLyrics: listToString(parsedLyrics),
                          );

                          // Update Riverpod state
                          ref.read(currentAudioFileProvider.notifier).state =
                              updatedAudioFile;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }
}
