/* 
  - Allow users to pick audio files from local storage or online
    + If they want to use local storage: check the db, if it's not empty then use data from there
      - Why? Because: App => states => db => local storage
    
    + If users want to pick a file from online storage: Google Drive, then they can access their files - filter all files to just .mp3, ...
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/state/audio_state.dart';

class AudioFilePickerCard extends ConsumerStatefulWidget {
  final Function(String) onFileSelected;

  const AudioFilePickerCard({super.key, required this.onFileSelected});

  @override
  ConsumerState<AudioFilePickerCard> createState() =>
      _AudioFilePickerCardState();
}

class _AudioFilePickerCardState extends ConsumerState<AudioFilePickerCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Watch the currentAudioFile state from audioStateProvider
    final currentAudioFile = ref.watch(currentAudioFileProvider);

    return Center(
      child: SizedBox(
        width: screenWidth * 0.95,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select audio file',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentAudioFile['title'] != ""
                    ? 'Selected File: ${currentAudioFile['title']}'
                    : 'No Audio File Selected',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _showLocalAudioDialog(context, ref);
                    },
                    icon: const Icon(Icons.folder),
                    label: const Text('Local files'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _pickFromGoogleDrive(context);
                    },
                    icon: const Icon(Icons.cloud),
                    label: const Text('Google Drive'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocalAudioDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final audioFiles = ref.watch(audioFilesProvider);

              return AlertDialog(
                title: const Text('Select Local Audio File'),
                content: SizedBox(
                  width: double.maxFinite,
                  child:
                      audioFiles.isEmpty
                          ? const Text(
                            'No audio files found in local database.',
                          )
                          : Scrollbar(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: audioFiles.length,
                              itemBuilder: (context, index) {
                                final file = audioFiles[index];
                                return ListTile(
                                  title: Text(file['title'] ?? 'Unknown'),
                                  subtitle: Text(file['artist'] ?? ''),
                                  trailing: Text('${file['duration']}s'),
                                  onTap: () {
                                    ref
                                        .read(currentAudioFileProvider.notifier)
                                        .state = file;
                                    Navigator.pop(context);
                                    widget.onFileSelected(file['filePath']);
                                  },
                                );
                              },
                            ),
                          ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _pickFromGoogleDrive(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Google Drive'),
            content: const Text('This feature is under development.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
