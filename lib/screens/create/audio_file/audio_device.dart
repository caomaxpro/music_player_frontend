import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/create/audio_file/audio_google_drive.dart';
import 'package:music_player/screens/create/lyrics/lyrics_options.dart';
// import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:music_player/screens/create/set_karaoke_button.dart';
import 'package:music_player/screens/storage/file_explorer_screen.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/svg/audio_file_svg.dart';
import 'package:music_player/svg/lyrics_file_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_message_card.dart';
import 'package:music_player/widgets/custom_scaffold.dart';

String _shortenFileName(String name) {
  // Nếu là file txt và tên quá dài thì rút ngắn lại, giữ đuôi .txt
  if (name.endsWith('.txt') && name.length > 20) {
    final ext = '.txt';
    final base = name.substring(0, name.length - ext.length);
    if (base.length > 15) {
      return '${base.substring(0, 12)}...$ext';
    }
  }
  return name;
}

String _extractFileNameFromFilePath(String filePath) {
  if (filePath.isNotEmpty) {
    debugPrint("[Audio Device]: ${filePath.split("/")}");

    return _shortenFileName(filePath.split("/").last);
  }

  return "";
}

class AudioDeviceScreen extends ConsumerStatefulWidget {
  final AudioFileType fileType;

  const AudioDeviceScreen({super.key, required this.fileType});

  @override
  ConsumerState<AudioDeviceScreen> createState() => _AudioDeviceScreenState();
}

class _AudioDeviceScreenState extends ConsumerState<AudioDeviceScreen> {
  String fileName = "";
  String filePath = "";
  bool isShowInfo = false;
  bool isShowError = false;
  String errorMessage = "";

  SongHandler songHandler = SongHandler();

  Future<void> _handleUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      // Check file extension and size here
      final allowedAudioExt = ['mp3', 'wav'];
      final allowedTextExt = ['txt', 'doc', 'json', 'lrc'];
      final ext = file.name.split('.').last.toLowerCase();

      bool isValid = false;
      if (widget.fileType == AudioFileType.media) {
        isValid = allowedAudioExt.contains(ext);
      } else {
        isValid = allowedTextExt.contains(ext);
      }

      if (!isValid) {
        setState(() {
          isShowError = true;
          errorMessage = "Invalid file type selected";
        });

        return;
      }

      if (widget.fileType == AudioFileType.media &&
          file.size < 10 * 1024 * 1024) {
        setState(() {
          fileName = _shortenFileName(file.name);
          filePath = file.path ?? "";
        });
        final Song updatedFile = ref
            .read(currentAudioFileProvider)
            .copyWith(filePath: filePath);
        ref.read(currentAudioFileProvider.notifier).state = updatedFile;
      } else if (widget.fileType == AudioFileType.media &&
          file.size >= 10 * 1024 * 1024) {
        setState(() {
          isShowError = true;
          errorMessage = "File size must be less than 10MB";
        });
      } else if (widget.fileType == AudioFileType.text &&
          file.size < 1 * 1024 * 1024) {
        setState(() {
          fileName = _shortenFileName(file.name);
          filePath = file.path ?? "";
        });
        final Song updatedFile = ref
            .read(currentAudioFileProvider)
            .copyWith(filePath: filePath);
        ref.read(currentAudioFileProvider.notifier).state = updatedFile;
      } else if (widget.fileType == AudioFileType.text &&
          file.size >= 1 * 1024 * 1024) {
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
          .copyWith(filePath: "");

      ref.read(currentAudioFileProvider.notifier).state = updatedFile;
    });
  }

  void _handleSetLyrics() {
    // TODO: Xử lý chuyển sang màn hình set lyrics
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;

    Song currentAudioFile = ref.watch(currentAudioFileProvider);

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
              spacing: 0,
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
                      Text(
                        widget.fileType == AudioFileType.media
                            ? 'Upload an audio file from local storage'
                            : "Upload a text file from local storage",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.fileType == AudioFileType.media
                            ? 'The selected audio file must be\nless than 10 MB in size'
                            : 'The selected text file must be less than 1 MB in size',
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
                          onPressed: () {
                            _handleRemove();
                          },
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
                      if (widget.fileType == AudioFileType.media) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LyricsOptionsScreen(),
                          ),
                        );
                      }

                      if (widget.fileType == AudioFileType.text) {}
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
