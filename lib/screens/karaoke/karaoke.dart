import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/api/api_instance.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/services/song_handler.dart';
import 'dart:convert';

import 'package:music_player/state/audio_state.dart';
import 'package:music_player/utils/datatype_converter.dart';
import 'package:music_player/utils/response_handler.dart';
import 'package:music_player/widgets/collapsible_container.dart';
import 'package:music_player/screens/create/lyrics/utils/convert_lrc_to_json.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ui/audio_file_card.dart';
import 'ui/lyrics_card.dart';
import 'ui/karaoke_output.dart';
import 'package:path/path.dart' as path;

class KaraokeScreen extends ConsumerStatefulWidget {
  const KaraokeScreen({super.key});

  @override
  ConsumerState<KaraokeScreen> createState() => _KaraokeScreenState();
}

class _KaraokeScreenState extends ConsumerState<KaraokeScreen> {
  late String lyrics;

  late bool storagePath;
  late SongHandler songHandler;

  // data status
  late bool isKaraokeReady;

  late Song currentAudioFile;

  @override
  void initState() {
    super.initState();
    currentAudioFile = ref.read(currentAudioFileProvider);
    songHandler = SongHandler();
    isKaraokeReady = checkKaraokeConditions();
  }

  // init karaoke screen
  /* 
    check if we need to send a request to backend?
    - check 3 requirements:
     + vocalPath ?
     + instrumentalPath ?
     + amplitude ?
     + timestampLyrics ?
   */

  bool checkKaraokeConditions() {
    if (currentAudioFile.vocalPath != '' &&
        currentAudioFile.instrumentalPath != "" &&
        currentAudioFile.amplitude != "" &&
        currentAudioFile.timestampLyrics != "") {
      return true;
    }

    return false;
  }

  Future<void> handleServerResponse(Map<String, dynamic> response) async {
    final adjustedTimestamp = response['adjusted_timestamp'];

    // debugPrint(
    //   "[Debug] Type of adjustedTimestamp: ${adjustedTimestamp.runtimeType}",
    // );
    // debugPrint("[Debug] Value of adjustedTimestamp: $adjustedTimestamp");

    final computedAmplitude = response['computed_amplitude'];

    debugPrint(
      "[Debug] Type of computedAmplitude: ${computedAmplitude.runtimeType}",
    );
    debugPrint("[Debug] Value of computedAmplitude: $computedAmplitude");

    final zipBase64 = response['zip_file'];

    // step 1: save and unzip the compressed file
    // step 2: extract file paths to vocals, and instrumentals from the compressed file

    final storagePath = await saveAndUnzipFile(zipBase64, 'karaoke_result.zip');

    debugPrint("[Karaoke]: $storagePath");

    final updatedAudioFile = ref
        .read(currentAudioFileProvider)
        .copyWith(
          vocalPath: storagePath!["vocal"],
          instrumentalPath: storagePath["accompaniment"],
          amplitude: computedAmplitude.toString(),
          timestampLyrics: adjustedTimestamp.toString(),
        );

    // step 3: save file paths to db
    songHandler.updateSongInDB(updatedSong: updatedAudioFile);

    debugPrint('Adjusted Timestamp: $adjustedTimestamp');
    debugPrint('Computed Amplitude: $computedAmplitude');

    setState(() {
      isKaraokeReady = true;
    });
  }

  Future<void> sendKaraokeRequest(
    String filePath,
    String timestampLyrics,
  ) async {
    try {
      // Initialize ApiService
      final apiService = ApiService();

      // Split meta data and lyrics
      final splitedData = splitLrcMetaAndLyrics(timestampLyrics);
      final lyrics = splitedData["lyrics"];
      final parsedLyrics = parseLrcLyrics(lyrics!);

      final formData = FormData.fromMap({
        'audioFile': await MultipartFile.fromFile(
          filePath,
          filename: path.basename(filePath),
        ),
        'timestampLyrics': jsonEncode(parsedLyrics),
      });

      // Debug: Print FormData contents
      //   debugPrint('FormData contents:');
      //   for (var field in formData.fields) {
      //     debugPrint('Field: ${field.key}, Value: ${field.value}');
      //   }
      //   formData.files.forEach((file) {
      //     debugPrint(
      //       'File: ${file.key}, Filename: ${file.filename}, Path: ${file.file.path}',
      //     );
      //   });

      // Call the post method with the correct parameters
      final response = await apiService.post(
        'karaoke_process', // Endpoint
        formData, // FormData containing file and other data
      );

      handleServerResponse(response);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAudioFile = ref.watch(currentAudioFileProvider);
    final internetConnection = ref.watch(internetConnectionProvider);

    // Lấy lyrics mới nhất từ state
    final lyrics = currentAudioFile.timestampLyrics;
    List<List<String>> displayLyrics;

    // check if data in timestamp lyrics is valid or not, if not then change the way it is processed

    debugPrint("[Valid Lyrics] ${currentAudioFile.timestampLyrics}");

    bool isLyricsInLRCFormat = isValidLrcFormat(
      currentAudioFile.timestampLyrics,
    );

    debugPrint("[Valid Lyrics] $isLyricsInLRCFormat");

    // check if the lyrics is in correct format
    if (isLyricsInLRCFormat && currentAudioFile.timestampLyrics != "") {
      final lrcParts = splitLrcMetaAndLyrics(lyrics);
      final meta = lrcParts['meta'] ?? '';
      final lyricsRaw = lrcParts['lyrics'] ?? '';

      final parsedMeta = parseLrcMeta(meta);
      final parsedLyrics = parseLrcLyrics(lyricsRaw);
      displayLyrics = parsedLyrics;
    }
    // if it is not
    else if (!isLyricsInLRCFormat && currentAudioFile.timestampLyrics != "") {
      displayLyrics = stringToList(currentAudioFile.timestampLyrics);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Karaoke Lyrics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  internetConnection ? Icons.wifi : Icons.wifi_off,
                  color: internetConnection ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  internetConnection
                      ? "Internet connected. Karaoke features are available."
                      : "No Internet. Karaoke features require an internet connection.",
                  style: TextStyle(
                    color: internetConnection ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            LyricsPickerCard(
              onLyricsSelected: (filePath) async {
                File file = File(filePath);
                String fileLyrics = await file.readAsString();

                currentAudioFile.lyrics = fileLyrics;
                currentAudioFile.filePath = filePath;

                ref.read(currentAudioFileProvider.notifier).state =
                    currentAudioFile;
              },
              onLyricsEntered: (enteredLyrics) {
                currentAudioFile.lyrics = enteredLyrics;

                ref.read(currentAudioFileProvider.notifier).state =
                    currentAudioFile;
              },
              onTranscribeAudio: (audioFile) {
                debugPrint('Transcribing audio file: ${audioFile.path}');
                // TODO: Send audio file to AI for transcription
              },
            ),
            const SizedBox(height: 16),

            KaraokeLyricsTable(),
            KaraokeButton(
              onPressed: () {
                debugPrint("activate loading button");

                sendKaraokeRequest(
                  currentAudioFile.filePath,
                  currentAudioFile.timestampLyrics,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class KaraokeButton extends ConsumerWidget {
  final VoidCallback onPressed;
  const KaraokeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAudioFile = ref.watch(currentAudioFileProvider);
    final enabled =
        currentAudioFile.filePath.isNotEmpty &&
        currentAudioFile.timestampLyrics.isNotEmpty;

    return Center(
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? Colors.blue : Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Load Karaoke'),
      ),
    );
  }
}

class KaraokeLyricsTable extends ConsumerWidget {
  const KaraokeLyricsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAudioFile = ref.watch(currentAudioFileProvider);
    final lyrics = currentAudioFile.timestampLyrics ?? 'No lyrics available';

    final lrcParts = splitLrcMetaAndLyrics(lyrics);
    final meta = lrcParts['meta'] ?? '';
    final lyricsRaw = lrcParts['lyrics'] ?? '';

    final parsedMeta = parseLrcMeta(meta);
    final parsedLyrics = parseLrcLyrics(lyricsRaw);

    debugPrint("[Timestamp Lyrics]: ${currentAudioFile.timestampLyrics}");

    if (currentAudioFile.timestampLyrics == "") {
      return Container(
        width: getScreenWidth(context) * 0.95,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "No Lyrics Set",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please use the correct LRC format for lyrics input.",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              "Example format:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "[ar: Beatriz Luengo]\n"
                "[al: Carrousel]\n"
                "[ti: Barranquilla]\n"
                "[length: 03:47]\n"
                "[00:02.56]Ahí está\n"
                "[00:04.56]Como las aves que cuando vuelan\n"
                "[00:07.46]Siempre regresan al nido\n"
                "[00:10.92]Ahí está\n"
                "[00:14.25]Como una estrella\n"
                "[00:17.03]Que alumbra a su Colombia querida\n",
                style: TextStyle(fontSize: 14, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Mở link hướng dẫn
                launchUrl(Uri.parse("https://www.lyricsify.com/lyrics"));
              },
              child: const Text(
                "Visit https://www.lyricsify.com/lyrics for lyrics.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: const Text(
                "Note that newly released songs may not yet be updated on the website, so you might need to manually create them.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    return CollapsibleText(
      content: [
        const SizedBox(height: 16),
        Table(
          columnWidths: const {0: FixedColumnWidth(100), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Timestamp',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Lyric',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            for (final lyricRow in parsedLyrics)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      lyricRow[0],
                      style: TextStyle(
                        color:
                            lyricRow[0].isNotEmpty
                                ? Colors.blue
                                : Colors.transparent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      lyricRow[1],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
