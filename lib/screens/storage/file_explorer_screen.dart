import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/storage/files_screen.dart';
import 'package:music_player/screens/storage/text_files_screen.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_scaffold.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dart:io';

enum AudioFileType { media, text }

class FileExplorerScreen extends ConsumerStatefulWidget {
  final AudioFileType fileType;

  const FileExplorerScreen({super.key, required this.fileType});

  @override
  ConsumerState<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends ConsumerState<FileExplorerScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  Map<String, List<SongModel>> folderMap = {};
  Map<String, List<FileSystemEntity>> textFolderMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _requestAndScan();
  }

  Future<void> _requestAndScan() async {
    if (widget.fileType == AudioFileType.media) {
      final status = await _audioQuery.permissionsStatus();
      if (!status) {
        await _audioQuery.permissionsRequest();
      }
      await _scanMedia();
    } else {
      await _scanTextFiles();
    }
  }

  Future<void> _scanMedia() async {
    setState(() => loading = true);
    final List<SongModel> files = await _audioQuery.querySongs();
    final filtered = files.where(
      (f) =>
          (f.duration ?? 0) >= 60000 &&
          (f.duration ?? 0) <= 600000 &&
          (f.fileExtension == 'mp3' || f.fileExtension == 'wav'),
    );

    final Map<String, List<SongModel>> tempMap = {};
    for (final song in filtered) {
      final folder = File(song.data).parent.path;
      tempMap.putIfAbsent(folder, () => []).add(song);
    }

    await Future.delayed(const Duration(seconds: 1)); // Delay for 3 seconds

    setState(() {
      folderMap = tempMap;
      loading = false;
    });
  }

  Future<void> _scanTextFiles() async {
    setState(() => loading = true);
    final List<Directory> dirs = [
      Directory('/storage/emulated/0/Documents'),
      Directory('/storage/emulated/0/Download'),
    ];
    final Map<String, List<FileSystemEntity>> tempMap = {};
    for (final dir in dirs) {
      if (await dir.exists()) {
        try {
          final files =
              dir
                  .listSync(recursive: true)
                  .where(
                    (f) => f is File && f.path.toLowerCase().endsWith('.txt'),
                  )
                  .toList();
          for (final file in files) {
            final folder = File(file.path).parent.path;
            tempMap.putIfAbsent(folder, () => []).add(file);
          }
        } catch (_) {}
      }
    }

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      textFolderMap = tempMap;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ref.read(bgColorProvider);
    final textColor = ref.read(textColorProvider);

    // Chọn map và folders phù hợp
    final isMedia = widget.fileType == AudioFileType.media;
    final folderMapToUse = isMedia ? folderMap : textFolderMap;
    final folders = folderMapToUse.keys.toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: textColor),
        title: Text('Folders', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child:
            loading
                ? Container(
                  key: const ValueKey('loading'),
                  color: backgroundColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor.withAlpha(100),
                      ),
                      backgroundColor: backgroundColor.withAlpha(100),
                      strokeWidth: 4,
                    ),
                  ),
                )
                : (folders.isEmpty
                    ? Center(
                      key: const ValueKey('empty'),
                      child: Text(
                        isMedia
                            ? 'No media files found.'
                            : 'No text files found.',
                        style: TextStyle(color: textColor),
                      ),
                    )
                    : Padding(
                      key: const ValueKey('content'),
                      padding: const EdgeInsets.all(0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                            ),
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          final folderName = folder.split('/').last;
                          final fileCount = folderMapToUse[folder]?.length ?? 0;
                          return InkWell(
                            onTap: () {
                              if (isMedia) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => FolderFilesScreen(
                                          folderName: folder,
                                          files: folderMap[folder]!,
                                        ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => TextFilesScreen(
                                          folderName: folder,
                                          files: textFolderMap[folder]!,
                                          backgroundColor: backgroundColor,
                                          textColor: textColor,
                                        ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open_rounded,
                                  size: 48,
                                  color: textColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  folderName,
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
                                  '$fileCount files',
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
                    )),
      ),
    );
  }
}
