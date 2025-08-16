import 'package:flutter/material.dart';

class LyricsPreviewTable extends StatelessWidget {
  final List<List<String>> parsedLyrics;
  final Color textColor;

  const LyricsPreviewTable({
    super.key,
    required this.parsedLyrics,
    required this.textColor,
  });

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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Text(
                      'Lyric',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
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
          // Đổi từ Expanded sang Flexible
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
                                      ? textColor
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
                            style: TextStyle(color: textColor, fontSize: 16),
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
