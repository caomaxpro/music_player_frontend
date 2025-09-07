import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/create/lyrics/ui/input_instruction.dart';
import 'package:music_player/screens/create/lyrics/ui/lyrics_preview_table.dart';
import 'package:music_player/screens/create/lyrics/ui/lyrics_textarea_card.dart';
import 'package:music_player/screens/create/set_karaoke_button.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/create_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/lyrics_file_svg.dart';
import 'package:music_player/screens/create/lyrics/utils/convert_lrc_to_json.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_message_card.dart';

// Giả sử bạn đã có các provider cho lyrics, previewLines, onCreateTrack
final lyricsProvider = Provider<String>((ref) => '');
final previewLinesProvider = Provider<List<Map<String, String>>>((ref) => []);
final onCreateTrackProvider = Provider<VoidCallback?>((ref) => null);

class LyricsManuallyScreen extends ConsumerStatefulWidget {
  static const String routeName = "lyricManual";

  const LyricsManuallyScreen({super.key});

  @override
  ConsumerState<LyricsManuallyScreen> createState() =>
      _LyricsManuallyScreenState();
}

class _LyricsManuallyScreenState extends ConsumerState<LyricsManuallyScreen> {
  late TextEditingController _lyricsController;
  bool showInstruction = false;
  bool showLyricsPreview = false;
  bool showErrMsg = false;
  String errorMsg = '';
  bool onLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createStateProvider.notifier).state = CreateState.lyrics;
    });

    _lyricsController = TextEditingController();
    _lyricsController.addListener(() {
      setState(() {});
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

  @override
  void dispose() {
    _lyricsController.dispose();
    super.dispose();
  }

  void _submitHandler() {
    final lrcLyrics = _lyricsController.text;

    if (lrcLyrics.isEmpty) {
      setState(() {
        errorMsg = 'This field cannot be empty.';
        showErrMsg = true;
      });
    } else if (!isValidLrcFormat(lrcLyrics)) {
      setState(() {
        errorMsg = 'This is not a valid LRC format.';
        _lyricsController.text = "";
        showErrMsg = true;
      });
    } else {
      setState(() {
        onLoading = true; // trigger loading animation
      });
      // Remove timer here, handle preview in onLoadingDone callback
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbColor = ref.read(thumbColorProvider);
    final textColor = ref.read(textColorProvider);
    final cardColor = ref.read(cardColorProvider);
    final currentAudioFile = ref.watch(currentAudioFileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF232226),
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
      body: Container(
        // width: 350,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!showLyricsPreview) ...[
              Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white70, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Lyrics',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      showInstruction
                          ? Icons.close_outlined
                          : Icons.help_outline,
                      color: textColor,
                      size: 26,
                    ),
                    onPressed: () {
                      setState(() {
                        showInstruction = !showInstruction;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (showErrMsg) ...[
                CustomMessageCard(
                  message: "This is not a valid LRC.",
                  type: MessageType.error,
                  duration: Duration(hours: 1),
                  onDismissed: () {
                    setState(() {
                      showErrMsg = false;
                    });
                  },
                ),
                const SizedBox(height: 8),
              ],

              // Lyrics box
              if (!showInstruction)
                LyricsTextareaCard(
                  controller: _lyricsController,
                  textColor: textColor,
                  onSubmit: _submitHandler,
                  onLoading: onLoading,
                  onLoadingDone: () {
                    setState(() {
                      onLoading = false;

                      showLyricsPreview = true;

                      // set audio state
                      Song updatedAudioFile = ref
                          .read(currentAudioFileProvider)
                          .copyWith(timestampLyrics: _lyricsController.text);
                      ref.read(currentAudioFileProvider.notifier).state =
                          updatedAudioFile;
                    });
                  },
                ),

              if (showInstruction) InstructionWidget(),
            ],

            // const SizedBox(height: 16),
            // Lyrics Preview
            if (showLyricsPreview) ...[
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: LyricsFileSvg(svgWidth: 20, svgHeight: 32),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Lyrics Preview',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  CustomIconButton(
                    icon: Icon(Icons.edit, color: textColor, size: 18),
                    height: 30,
                    width: 30,
                    borderWidth: 2,
                    borderRadius: 50,
                    verticalPadding: 0,
                    horizontalPadding: 0,
                    onPressed: () {
                      setState(() {
                        showLyricsPreview = false;
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 16),

              // const SizedBox(height: 16),
              Expanded(
                child: LyricsPreviewTable(
                  lyrics: currentAudioFile.timestampLyrics,
                  textColor: textColor,
                ),
              ),

              const SizedBox(height: 16),

              // Convert back to List<Map<String, dynamic>>
              // final List<dynamic> decoded = jsonDecode(jsonString);
              // final List<Map<String, dynamic>> lyricsList =
              //     decoded.map((e) => Map<String, dynamic>.from(e)).toList();
              SetKaraokeButton(),
            ],
          ],
        ),
      ),
    );
  }
}
