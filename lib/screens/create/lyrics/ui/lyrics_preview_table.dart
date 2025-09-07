import 'package:flutter/material.dart';
import 'package:music_player/screens/create/lyrics/utils/convert_lrc_to_json.dart';

class LyricsPreviewTable extends StatefulWidget {
  final String lyrics;
  final Color textColor;

  const LyricsPreviewTable({
    super.key,
    required this.lyrics,
    required this.textColor,
  });

  @override
  State<LyricsPreviewTable> createState() => _LyricsPreviewTableState();
}

class _LyricsPreviewTableState extends State<LyricsPreviewTable> {
  late List<List<String>> parsedLyrics;

  @override
  void initState() {
    super.initState();
    // Parse the lyrics into a list of timestamp and lyric pairs
    parsedLyrics = parseLrcLyrics(
      splitLrcMetaAndLyrics(widget.lyrics)["lyrics"]!,
    );

    debugPrint("[Audio Lyrics] $parsedLyrics");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          columnWidths: const {0: FixedColumnWidth(120), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Timestamp',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.textColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Text(
                      'Lyric',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Flexible(
          child: Scrollbar(
            thumbVisibility: false,
            child: SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(120),
                  1: FlexColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.top,
                children: [
                  for (int i = 0; i < parsedLyrics.length; i++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: i.isEven ? Colors.grey[850] : Colors.grey[800],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          child: Text(
                            parsedLyrics[i][0],
                            style: TextStyle(
                              color:
                                  parsedLyrics[i][0].isNotEmpty
                                      ? widget.textColor
                                      : Colors.transparent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                            right: 10,
                          ),
                          child: Text(
                            parsedLyrics[i][1],
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
