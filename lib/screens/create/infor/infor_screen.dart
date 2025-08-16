import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/create/audio_file/audio_options.dart';
import 'package:music_player/screens/create/set_karaoke_button.dart';
import 'package:music_player/screens/karaoke/karaoke.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_message_card.dart';
import 'package:music_player/widgets/custom_scaffold.dart';
import 'package:music_player/widgets/custom_text_input.dart';
import 'package:music_player/widgets/error_msg_card.dart';

class InforScreen extends ConsumerStatefulWidget {
  const InforScreen({super.key});

  @override
  ConsumerState<InforScreen> createState() => _InforScreenState();
}

class _InforScreenState extends ConsumerState<InforScreen> {
  String imagePath = '';
  late TextEditingController titleController;
  late TextEditingController artistController;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    artistController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = ref.read(bgColorProvider);
    final textColor = ref.read(textColorProvider);

    return CustomScaffold(
      title: "Karaoke DB Manager",
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (errorMsg != null) ...[
                  CustomMessageCard(
                    duration: const Duration(seconds: 30),
                    message: errorMsg!,
                    type: MessageType.error,
                    onDismissed: () {
                      setState(() {
                        errorMsg = null;
                      });
                    },
                  ),

                  SizedBox(height: 16),
                ],

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextInput(
                          title: 'Title',
                          placeholder: 'Karaoke title ...',
                          backgroundColor: Colors.grey[700],
                          textColor: textColor,
                          controller: titleController,
                        ),
                        const SizedBox(height: 24),
                        CustomTextInput(
                          title: 'Artist',
                          placeholder: 'Artist ...',
                          backgroundColor: Colors.grey[700],
                          textColor: textColor,
                          controller: artistController,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Karaoke Album',
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
                              const Icon(
                                Icons.upload,
                                color: Colors.white54,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Upload a picture',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'The uploaded photo must be\nless than 2 MB in size',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[500],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () async {
                                  final result = await FilePicker.platform
                                      .pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['jpg', 'png'],
                                        allowMultiple: false,
                                      );

                                  if (result != null &&
                                      result.files.single.path != null) {
                                    final _imagePath =
                                        result.files.single.path!;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Selected: $imagePath'),
                                      ),
                                    );
                                    setState(() {
                                      imagePath = _imagePath;
                                    });
                                  }
                                },
                                child: const Text('Upload'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child:
                      !isKeyboardVisible
                          ? AnimatedSlide(
                            offset: const Offset(0, 0.2),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOut,
                            child: SetKaraokeButton(
                              onPressed: () {
                                if (titleController.text.trim().isEmpty) {
                                  setState(() {
                                    errorMsg = "Title cannot be empty!";
                                  });
                                  return;
                                }
                                final newSong = ref
                                    .read(currentAudioFileProvider)
                                    .copyWith(
                                      title: titleController.text,
                                      artist: artistController.text,
                                      audioImgUri: imagePath,
                                    );

                                ref
                                    .read(currentAudioFileProvider.notifier)
                                    .state = newSong;

                                // SongHandler songHandler = SongHandler();
                                // songHandler.createSong(newSong);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AudioOptionsScreen(),
                                  ),
                                );
                              },
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
