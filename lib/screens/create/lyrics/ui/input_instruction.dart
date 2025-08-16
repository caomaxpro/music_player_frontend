import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/search_lyric_icon.dart';
import 'package:url_launcher/url_launcher.dart';

final instructionMsg = '''
Enter lyrics in LRC format:

Each line must start with a timestamp: [mm:ss.xx]Lyric text

Optional metadata at the top:[ar: Artist] [ti: Title] [al: Album] [length: mm:ss]

Example:

[ar: <artist name>]   
[ti: <song’s title>]   
[00:14.16]<line 1>   
[00:17.53<line 2>''';

class InstructionWidget extends ConsumerWidget {
  const InstructionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = ref.read(textColorProvider);
    final thumbColor = ref.read(thumbColorProvider);
    final cardColor = ref.read(cardColorProvider);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          // color: thumbColor,
          border: Border.all(width: 2, color: textColor),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          spacing: 0,
          children: [
            Container(
              // decoration: BoxDecoration(color: thumbColor),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  instructionMsg.trim(),
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ),
            // const SizedBox(height: 5),
            Container(
              height: 65,
              decoration: BoxDecoration(color: cardColor),
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: InkWell(
                onTap: () {
                  launchUrl(Uri.parse("https://www.lyricsify.com/lyrics"));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SearchLyricsSvg(),
                    const SizedBox(width: 10),
                    Text(
                      "Search Lyrics Online",
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_sharp, size: 35, color: textColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
