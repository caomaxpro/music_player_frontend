import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/create/audio_file/audio_options.dart';
import 'package:music_player/screens/create/set_karaoke_button.dart';
import 'package:music_player/screens/karaoke_player/helper/response_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/create_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_message_card.dart';
import 'package:music_player/widgets/custom_scaffold.dart';
import 'package:music_player/widgets/custom_text_input.dart';
import 'package:uuid/v4.dart';

class InforScreen extends ConsumerStatefulWidget {
  static const String routeName = 'infor';

  const InforScreen({super.key});

  @override
  ConsumerState<InforScreen> createState() => _InforScreenState();
}

class _InforScreenState extends ConsumerState<InforScreen> {
  String imagePath = '';
  String imageTitle = '';
  late TextEditingController titleController;
  late TextEditingController artistController;
  String? errorMsg;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createStateProvider.notifier).state = CreateState.infor;
    });

    final currentAudioFile = ref.read(currentAudioFileProvider);
    titleController = TextEditingController(
      text:
          (currentAudioFile.title.isNotEmpty &&
                  currentAudioFile.title.trim().isNotEmpty)
              ? currentAudioFile.title
              : "",
    );
    artistController = TextEditingController(
      text:
          (currentAudioFile.artist.isNotEmpty &&
                  currentAudioFile.artist.trim().isNotEmpty)
              ? currentAudioFile.artist
              : "",
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if the screen is being revisited
    if (ModalRoute.of(context)?.isCurrent == true) {
      // Run your desired function here
      ref.read(createStateProvider.notifier).state = CreateState.infor;
    }
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
    final screenWidth = MediaQuery.of(context).size.width;

    final currentAudioFile = ref.watch(currentAudioFileProvider);

    return CustomScaffold(
      title: "Track Infor",
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomTextInput(
                          title: 'Title',
                          placeholder: 'Karaoke title ...',
                          backgroundColor: Colors.grey[700]?.withAlpha(80),
                          textColor: textColor,
                          controller: titleController,
                          width: screenWidth * .88,
                          height: 45,
                          padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                          border: Border(
                            bottom: BorderSide(width: 2, color: textColor),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                          cursorColor: textColor,
                          // outlineStyle: OutlineStyle.bottom,
                        ),
                        const SizedBox(height: 24),
                        CustomTextInput(
                          title: 'Artist',
                          placeholder: 'Artist ...',
                          backgroundColor: Colors.grey[700]?.withAlpha(80),
                          textColor: textColor,
                          controller: artistController,
                          width: screenWidth * .88,
                          height: 45,
                          padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                          border: Border(
                            bottom: BorderSide(width: 2, color: textColor),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                          cursorColor: textColor,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Karaoke Album',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (currentAudioFile.imagePath.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700]?.withAlpha(100),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 2,
                                      color: textColor,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: Image.file(
                                            File(
                                              currentAudioFile.imagePath,
                                            ), // optional
                                            fit: BoxFit.cover, // optional
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          height: 60,
                                          width: 150,
                                          child: Text(
                                            imageTitle,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        CustomIconButton(
                                          label: "Remove",
                                          onPressed: () {
                                            final updatedFile = ref
                                                .read(currentAudioFileProvider)
                                                .copyWith(imagePath: "");

                                            ref
                                                .read(
                                                  currentAudioFileProvider
                                                      .notifier,
                                                )
                                                .state = updatedFile;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (currentAudioFile.imagePath.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 8,
                                          ),
                                        ),
                                        onPressed: () async {
                                          final result = await FilePicker
                                              .platform
                                              .pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: [
                                                  'jpg',
                                                  'png',
                                                ],
                                                allowMultiple: false,
                                              );

                                          if (result != null &&
                                              result.files.single.path !=
                                                  null) {
                                            final updatedFile = ref
                                                .read(currentAudioFileProvider)
                                                .copyWith(
                                                  imagePath:
                                                      result.files.single.path,
                                                );

                                            ref
                                                .read(
                                                  currentAudioFileProvider
                                                      .notifier,
                                                )
                                                .state = updatedFile;

                                            setState(() {
                                              imageTitle =
                                                  result.files.single.name;
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

                                final uuidV4 = UuidV4().generate();

                                final newSong = ref
                                    .read(currentAudioFileProvider)
                                    .copyWith(
                                      uuid: uuidV4,
                                      title: titleController.text,
                                      artist: artistController.text,
                                      storagePath:
                                          "${appStorageFolder.path}/$uuidV4",
                                    );

                                ref
                                    .read(currentAudioFileProvider.notifier)
                                    .state = newSong;

                                ref.read(createStateProvider.notifier).state =
                                    CreateState.audioFile;

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
