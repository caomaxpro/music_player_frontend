import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/create/lyrics/ui/lyrics_preview_table.dart';
import 'package:music_player/screens/create/lyrics/utils/convert_lrc_to_json.dart';
import 'package:music_player/screens/create/set_karaoke_button.dart';
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

class AudioTextDeviceScreen extends ConsumerStatefulWidget {
  static const String routeName = "audioTextDevice";

  const AudioTextDeviceScreen({super.key});

  @override
  ConsumerState<AudioTextDeviceScreen> createState() =>
      _AudioTextDeviceScreenState();
}

class _AudioTextDeviceScreenState extends ConsumerState<AudioTextDeviceScreen> {
  String fileName = "";
  String filePath = "";
  String fileContent = "";
  bool isShowInfo = false;
  bool isShowError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createStateProvider.notifier).state = CreateState.lyrics;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if the screen is being revisited
    if (ModalRoute.of(context)?.isCurrent == true) {
      // Run your desired function here
      ref.read(createStateProvider.notifier).state = CreateState.lyrics;
    }
  }

  Future<void> _handleUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'lrc', 'json', 'doc'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      final ext = file.name.split('.').last.toLowerCase();

      if (!['txt', 'lrc', 'json', 'doc'].contains(ext)) {
        setState(() {
          isShowError = true;
          errorMessage = "Invalid text file type selected";
        });
        return;
      }

      if (file.size < 1 * 1024 * 1024) {
        setState(() {
          fileName = _shortenFileName(file.name);
          filePath = file.path ?? "";
        });

        String fileContent = "";
        switch (ext) {
          case 'txt':
          case 'lrc':
          case 'json':
          case 'doc':
            if (file.bytes != null) {
              fileContent = String.fromCharCodes(file.bytes!);
            } else if (file.path != null) {
              fileContent = await File(file.path!).readAsString();
            }
            break;
          default:
            fileContent = "";
        }

        // Parse LRC or text file to JSON lyrics if needed
        // fileContent = jsonEncode(
        //   parseLrcLyrics(splitLrcMetaAndLyrics(fileContent)["lyrics"]!),
        // );

        final Song updatedFile = ref
            .read(currentAudioFileProvider)
            .copyWith(timestampLyrics: fileContent);
        ref.read(currentAudioFileProvider.notifier).state = updatedFile;
      } else {
        setState(() {
          isShowError = true;
          errorMessage = "File size must be less than 1MB";
        });
      }
    }
  }

  void _handleRemove() {
    setState(() {
      final Song updatedFile = ref
          .read(currentAudioFileProvider)
          .copyWith(filePath: "", timestampLyrics: "");
      ref.read(currentAudioFileProvider.notifier).state = updatedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;
    bool adjustTimestamp = ref.watch(adjustTimestampProvider);
    Song currentAudioFile = ref.watch(currentAudioFileProvider);

    return CustomScaffold(
      title: "My Device - Text File",
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
                if (currentAudioFile.timestampLyrics.isEmpty)
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
                          'Upload a text file from local storage',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'The selected text file must be less than 1 MB in size',
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
                if (currentAudioFile.timestampLyrics.isNotEmpty) ...[
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
                            _extractFileNameFromFilePath(fileName),
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
                  SizedBox(height: 16),
                  Row(
                    children: [
                      //   SizedBox(width: 5),
                      Text(
                        "Adjust lyrics to audio",
                        style: TextStyle(fontSize: 18, color: textColor),
                      ),
                      Spacer(),
                      CustomIconButton(
                        width: 25,
                        height: 25,
                        borderWidth: 0,
                        padding: EdgeInsets.all(0),
                        icon:
                            !adjustTimestamp
                                ? Icon(
                                  Icons.check_box_outline_blank_outlined,
                                  size: 28,
                                  color: textColor,
                                )
                                : Icon(
                                  Icons.check_box_outlined,
                                  size: 28,
                                  color: textColor,
                                ),
                        onPressed: () {
                          ref.read(adjustTimestampProvider.notifier).state =
                              !adjustTimestamp;
                        },
                      ),

                      SizedBox(width: 5),
                    ],
                  ),
                ],
                if (currentAudioFile.timestampLyrics.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Expanded(
                    child: LyricsPreviewTable(
                      lyrics: currentAudioFile.timestampLyrics,
                      textColor: textColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  SetKaraokeButton(),
                ],
                if (currentAudioFile.timestampLyrics.isEmpty)
                  Expanded(
                    child: Center(
                      child: Transform.scale(
                        scale: 3,
                        alignment: Alignment.center,
                        child: LyricsFileSvg(),
                      ),
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
