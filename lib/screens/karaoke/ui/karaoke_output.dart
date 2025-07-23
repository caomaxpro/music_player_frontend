/* 
  After processing original files

  + separate the audio file into vocals and instrumentals
  + save instrumentals on device's storage
  + align text with audio -> return text with timestamp per word
 */

import 'package:flutter/material.dart';

class KaraokeOutputCard extends StatefulWidget {
  final Function(bool)
  onSwitchAudio; // Callback khi người dùng chuyển giữa original và instrumental
  final Function(bool)
  onToggleRecording; // Callback khi người dùng bật/tắt ghi âm
  final String
  transcribedText; // Kết quả đã được transcribe từ DB (kèm timestamp)
  final String songTitle; // Tiêu đề bài hát

  const KaraokeOutputCard({
    super.key,
    required this.onSwitchAudio,
    required this.onToggleRecording,
    required this.transcribedText,
    required this.songTitle,
  });

  @override
  // ignore: library_private_types_in_public_api
  _KaraokeOutputCardState createState() => _KaraokeOutputCardState();
}

class _KaraokeOutputCardState extends State<KaraokeOutputCard> {
  bool isInstrumental = false; // Trạng thái: original hoặc instrumental
  bool isRecording = false; // Trạng thái: ghi âm bật/tắt

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề bài hát
            Text(
              widget.songTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Waveform giả lập (placeholder)
            Container(
              height: 50,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Waveform Placeholder',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Các nút điều khiển
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nút chuyển đổi chế độ âm thanh
                IconButton(
                  icon: Icon(
                    isInstrumental ? Icons.music_note : Icons.audiotrack,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      isInstrumental = !isInstrumental;
                    });
                    widget.onSwitchAudio(isInstrumental);
                  },
                ),
                // Nút phát nhạc (placeholder)
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.green),
                  onPressed: () {
                    // TODO: Thêm logic phát nhạc
                    print('Play button pressed');
                  },
                ),
                // Nút bật/tắt ghi âm
                IconButton(
                  icon: Icon(
                    isRecording ? Icons.mic : Icons.mic_off,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      isRecording = !isRecording;
                    });
                    widget.onToggleRecording(isRecording);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lời bài hát kèm timestamp
            Text(
              'Lyrics:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.transcribedText,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
