import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/create/lyrics/lyrics_options.dart';
import 'package:music_player/screens/create/set_karaoke_button.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/create_state.dart';
import 'package:music_player/svg/lyrics_file_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_message_card.dart';
import 'package:music_player/widgets/custom_scaffold.dart';

String _shortenFileName(String name) {
  if (name.length > 20) {
    final ext = name.contains('.') ? '.${name.split('.').last}' : '';
    final base = name.substring(0, name.length - ext.length);
    if (base.length > 15) {
      return '${base.substring(0, 12)}...$ext';
    }
  }
  return name;
}

String _extractFileNameFromFilePath(String filePath) {
  if (filePath.isNotEmpty) {
    return _shortenFileName(filePath.split("/").last);
  }
  return "";
}

class AudioMediaDeviceScreen extends ConsumerStatefulWidget {
  static const String routeName = "audioMediaDevice";

  const AudioMediaDeviceScreen({super.key});

  @override
  ConsumerState<AudioMediaDeviceScreen> createState() =>
      _AudioMediaDeviceScreenState();
}

class _AudioMediaDeviceScreenState
    extends ConsumerState<AudioMediaDeviceScreen> {
  String fileName = "";
  String filePath = "";
  bool isShowInfo = false;
  bool isShowError = false;
  String errorMessage = "";

  SongHandler songHandler = SongHandler();

  Future<void> _handleUpload() async {
    debugPrint('[AudioMediaDeviceScreen] _handleUpload START');

    final result = await FilePicker.platform.pickFiles(withData: true);

    // debugPrint('[AudioMediaDeviceScreen] FilePicker result: $result');

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      debugPrint(
        '[AudioMediaDeviceScreen] Picked file: ${file.name}, size: ${file.size}',
      );

      final ext = file.name.split('.').last.toLowerCase();

      if (!['mp3', 'wav'].contains(ext)) {
        debugPrint('[AudioMediaDeviceScreen] Invalid file type: $ext');
        setState(() {
          isShowError = true;
          errorMessage = "Invalid audio file type selected";
        });
        return;
      }

      if (file.size < 10 * 1024 * 1024) {
        setState(() {
          fileName = _shortenFileName(file.name);
          filePath = file.path ?? "";
        });

        debugPrint(
          '[AudioMediaDeviceScreen] Valid file, updating state with path: $filePath',
        );

        final Song updatedFile = ref
            .read(currentAudioFileProvider)
            .copyWith(filePath: filePath);

        ref.read(currentAudioFileProvider.notifier).state = updatedFile;
      } else {
        debugPrint('[AudioMediaDeviceScreen] File too large: ${file.size}');
        setState(() {
          isShowError = true;
          errorMessage = "File size must be less than 10MB";
        });
      }
    }

    debugPrint('[AudioMediaDeviceScreen] _handleUpload END');
  }

  void _handleRemove() {
    setState(() {
      final Song updatedFile = ref
          .read(currentAudioFileProvider)
          .copyWith(filePath: "");
      ref.read(currentAudioFileProvider.notifier).state = updatedFile;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createStateProvider.notifier).state = CreateState.audioFile;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if the screen is being revisited
    if (ModalRoute.of(context)?.isCurrent == true) {
      // Run your desired function here
      ref.read(createStateProvider.notifier).state = CreateState.audioFile;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;
    Song currentAudioFile = ref.watch(currentAudioFileProvider);

    debugPrint("[Check current audio file]: ${currentAudioFile.filePath}");

    return CustomScaffold(
      title: "My Device - Audio File",
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'My Device',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Local Storage',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Spacer(),
                    if (!isShowInfo)
                      CustomIconButton(
                        icon: Icon(
                          isShowInfo
                              ? Icons.close
                              : Icons.question_mark_outlined,
                          size: 18,
                          color: textColor,
                        ),
                        width: 28,
                        height: 28,
                        horizontalPadding: 0,
                        verticalPadding: 0,
                        borderRadius: 50,
                        borderWidth: 2,
                        backgroundColor: Colors.white.withAlpha(60),
                        onPressed: () {
                          setState(() {
                            isShowInfo = true;
                          });
                        },
                      ),
                  ],
                ),
                if (isShowInfo) ...[
                  SizedBox(height: 16),
                  CustomMessageCard(
                    message:
                        '''If Google Drive or other cloud file options do not appear in the file picker, please open those apps and log in at least once before trying again.''',
                    type: MessageType.info,
                    duration: Duration(minutes: 30),
                    onDismissed: () {
                      setState(() {
                        isShowInfo = false;
                      });
                    },
                  ),
                ],
                if (isShowError) ...[
                  SizedBox(height: 16),
                  CustomMessageCard(
                    message: errorMessage,
                    type: MessageType.error,
                    duration: Duration(seconds: 10),
                    onDismissed: () {
                      setState(() {
                        isShowError = false;
                      });
                    },
                  ),
                ],
                SizedBox(height: 16),
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
                      Transform.scale(
                        scale: 0.8,
                        alignment: Alignment.center,
                        child: LyricsFileSvg(),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload an audio file from local storage',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'The selected audio file must be\nless than 10 MB in size',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[500],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 8,
                          ),
                        ),
                        onPressed: _handleUpload,
                        child: const Text('Upload'),
                      ),
                    ],
                  ),
                ),
                if (currentAudioFile.filePath.isNotEmpty) ...[
                  SizedBox(height: 16),
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
                        Transform.scale(
                          scale: 0.7,
                          alignment: Alignment.center,
                          child: LyricsFileSvg(
                            svgHeight: 40,
                            svgWidth: 35,
                            viewBoxWidth: 55,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _extractFileNameFromFilePath(
                              currentAudioFile.filePath,
                            ),
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
                ],
                if (currentAudioFile.filePath.isEmpty)
                  Expanded(
                    child: Center(
                      child: Transform.scale(
                        scale: 3,
                        alignment: Alignment.center,
                        child: LyricsFileSvg(),
                      ),
                    ),
                  ),
                if (currentAudioFile.filePath.isNotEmpty) ...[
                  const Spacer(),
                  SetKaraokeButton(
                    onPressed: () {
                      ref.read(createStateProvider.notifier).state =
                          CreateState.lyrics;
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LyricsOptionsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
