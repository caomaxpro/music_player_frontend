import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class KaraokeTrackInfo extends ConsumerWidget {
  final Song currentAudioFile;
  final Color textColor;
  final Color bgColor;

  const KaraokeTrackInfo({
    super.key,
    required this.currentAudioFile,
    required this.textColor,
    required this.bgColor,
  });

  String formatDate(DateTime date) {
    final day = DateFormat('d').format(date);
    final suffix = _getDaySuffix(int.parse(day));
    final formattedDate = DateFormat("d'$suffix' MMM, yyyy").format(date);
    return formattedDate;
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Track Image
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 180,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
              child: Image.file(
                File(currentAudioFile.imagePath),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 15,
              bottom: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor.withAlpha(140),
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Text(
                  currentAudioFile.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 0),
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 8,
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Artist: ${currentAudioFile.artist.isNotEmpty ? currentAudioFile.artist : "None"}",
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Created At: ${formatDate(currentAudioFile.createdDate)}",
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      child: CustomIconButton(
                        label: "Karaoke",
                        labelFontSize: 16,
                        backgroundColor: const Color.fromARGB(255, 97, 96, 96),
                        width: MediaQuery.of(context).size.width * .9,
                        height: 45,
                        borderWidth: 0,
                        onPressed: () {
                          Navigator.pushNamed(context, "karaokePlayer");
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
