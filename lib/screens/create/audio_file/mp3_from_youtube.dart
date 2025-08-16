import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:music_player/screens/create/audio_file/audio_google_drive.dart';
import 'package:music_player/screens/create/set_karaoke_button.dart';
import 'package:music_player/svg/audio_file_svg.dart';
import 'package:music_player/svg/guitar_svg.dart';
import 'package:music_player/svg/lyrics_file_svg.dart';
import 'package:music_player/screens/create/lyrics/utils/convert_lrc_to_json.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

bool isYoutubeUrlValid(String url) {
  final RegExp youtubeRegex = RegExp(
    r'^(https?\:\/\/)?(www\.youtube\.com|youtu\.be)\/.+$',
    caseSensitive: false,
  );
  return youtubeRegex.hasMatch(url.trim());
}

class Mp3FromYoutubeScreen extends StatefulWidget {
  const Mp3FromYoutubeScreen({super.key});

  @override
  State<Mp3FromYoutubeScreen> createState() => _Mp3FromYoutubeScreenState();
}

class _Mp3FromYoutubeScreenState extends State<Mp3FromYoutubeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  String fileName = '';
  String filePath = "";
  double progress = 0;
  bool isValid = true;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    // Do NOT initialize _progressAnimation here!
  }

  void _startProgressAnimation(double endWidth) {
    _progressAnimation = Tween<double>(
      begin: 0,
      end: endWidth,
    ).animate(_progressController)..addListener(() {
      setState(() {
        progress = _progressAnimation.value;
      });
    });
    _progressController.reset();
    _progressController.forward();
  }

  void _handleDownload() {
    // check if the url is valid

    if (!isYoutubeUrlValid(_urlController.text)) {
      setState(() {
        isValid = false;
      });
    }
    // deactivate the keyboard
    else {
      FocusScope.of(context).unfocus();

      setState(() {
        fileName = 'file_name.mp3';
      });
      final double progressWidth = MediaQuery.of(context).size.width * .9;
      _startProgressAnimation(progressWidth);
    }
  }

  void _handleRemove() {
    setState(() {
      fileName = '';
    });
  }

  void _handleSetLyrics() {
    // TODO: Xử lý chuyển sang màn hình set lyrics
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;

    final infoMsg = '''
        

    ''';

    // what need to check

    return Scaffold(
      backgroundColor: const Color(0xFF232226),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'MP3 From Youtube',
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
                  // crossAxisAlignment: Cros,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Video URLs',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    // const SizedBox(width: 6),
                    CustomIconButton(
                      icon: Icon(
                        Icons.help_outline_outlined,
                        size: 24,
                        color: textColor,
                      ),
                      width: 30,
                      height: 30,
                      horizontalPadding: 0,
                      verticalPadding: 0,
                      borderWidth: 0,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: Colors.grey[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  'How to get Youtube video URL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Text(
                                  '1. Open the Youtube app or website.\n'
                                  '2. Find the video you want to download.\n'
                                  '3. Tap the "Share" button below the video.\n'
                                  '4. Select "Copy link".\n'
                                  '5. Paste the copied link into the text box above.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: progress,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            topRight: Radius.circular(
                              progress != MediaQuery.of(context).size.width * .9
                                  ? 0
                                  : 8,
                            ),
                            bottomRight: Radius.circular(
                              progress != MediaQuery.of(context).size.width * .9
                                  ? 0
                                  : 8,
                            ),
                          ),
                        ),
                        child: SizedBox.shrink(),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .9,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[700]?.withAlpha(160),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: TextField(
                                controller: _urlController,
                                enabled:
                                    progress == 0 ||
                                    progress ==
                                        MediaQuery.of(context).size.width * .9,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Video URLs ....',
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // const SizedBox(width: 8),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[700]?.withAlpha(160),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.search_outlined,
                                color: Colors.white70,
                              ),
                              onPressed: _handleDownload,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isValid) ...[
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      spacing: 8,
                      children: [
                        Icon(Icons.warning_amber_sharp, color: textColor),
                        Text(
                          "Video URLs is not valid.",
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                ],
                if (fileName.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        AudioFileSvg(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            fileName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 0,
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                          onPressed: _handleRemove,
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                if (fileName.isEmpty)
                  Center(
                    child: Transform.scale(
                      scale:
                          7.5, // 1.0 là bình thường, >1.0 là phóng to, <1.0 là thu nhỏ
                      child: AudioFileSvg(),
                    ),
                  ),
                const Spacer(),

                if (fileName.isNotEmpty)
                  ButtonToLyrics(filePath: filePath, fileName: fileName),
              ],
            );
          },
        ),
      ),
    );
  }
}
