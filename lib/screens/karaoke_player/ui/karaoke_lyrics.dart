import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_player/services/karaoke_handler.dart';

class LyricsWidget extends StatefulWidget {
  final DualAudioHandler audioHandler;

  const LyricsWidget({super.key, required this.audioHandler});

  @override
  State<LyricsWidget> createState() => _LyricsWidgetState();
}

class _LyricsWidgetState extends State<LyricsWidget> {
  static const double _itemHeight = 45; // Đặt chiều cao cố định cho mỗi item

  final List<List<dynamic>> lyrics = const [
    [
      [14160, 17530], // 00:14.16 - 00:17.53
      "I'm sitting here in the boring room",
    ],
    [
      [17530, 20840], // 00:17.53 - 00:20.84
      "It's just another rainy Sunday afternoon",
    ],
    [
      [20840, 24140], // 00:20.84 - 00:24.14
      "I'm wasting my time, I got nothing to do",
    ],
    [
      [24140, 27220], // 00:24.14 - 00:27.22
      "I'm hanging around, I'm waiting for you",
    ],
    [
      [27220, 29520], // 00:27.22 - 00:29.52
      "But nothing ever happens, and I wonder",
    ],
    [
      [33770, 37680], // 00:33.77 - 00:37.68
      "I'm driving around in my car",
    ],
    [
      [37680, 41000], // 00:37.68 - 00:41.00
      "I'm driving too fast, I'm driving too far",
    ],
    [
      [41000, 44440], // 00:41.00 - 00:44.44
      "I'd like to change my point of view",
    ],
    [
      [44440, 47500], // 00:44.44 - 00:47.50
      "I feel so lonely, I'm waiting for you",
    ],
    [
      [47500, 49970], // 00:47.50 - 00:49.97
      "But nothing ever happens, and I wonder",
    ],
    [
      [54470, 57860], // 00:54.47 - 00:57.86
      "I wonder how, I wonder why",
    ],
    [
      [57860, 60970], // 00:57.86 - 01:00.97
      "Yesterday you told me 'bout the blue, blue sky",
    ],
    [
      [60970, 63860], // 01:00.97 - 01:03.86
      "And all that I can see is just another lemon tree",
    ],
    [
      [67570, 71030], // 01:07.57 - 01:11.03
      "I'm turning my head up and down",
    ],
    [
      [71030, 74500], // 01:11.03 - 01:14.50
      "I'm turning, turning, turning, turning, turning around",
    ],
    [
      [74500, 77140], // 01:14.50 - 01:16.88
      "And all that I can see is just another lemon tree",
    ],
    [
      [80630, 81400], // 01:20.63 - 01:21.40
      "Sing!",
    ],
    [
      [81400, 84150], // 01:21.40 - 01:24.15
      "Dap-dadada-dadpm-didap-da",
    ],
    [
      [86820, 90000], // 01:26.82 - 01:30.00
      "Dadada-dadpm-didap-da",
    ],
    [
      [90000, 93400], // 01:30.00 - 01:34.00
      "Dap-didili-da",
    ],
    [
      [93400, 97740], // 01:34.14 - 01:37.74
      "I'm sitting here, I miss the power",
    ],
    [
      [97740, 101210], // 01:37.74 - 01:41.21
      "I'd like to go out, taking a shower",
    ],
    [
      [101210, 104660], // 01:41.21 - 01:44.66
      "But there's a heavy cloud inside my head",
    ],
    [
      [104660, 107780], // 01:44.66 - 01:47.78
      "I feel so tired, put myself into bed",
    ],
    [
      [107780, 110250], // 01:47.78 - 01:50.25
      "Well, nothing ever happens, and I wonder",
    ],
    [
      [114360, 117980], // 01:54.36 - 01:57.98
      "Isolation is not good for me",
    ],
    [
      [121790, 124830], // 02:01.79 - 02:04.83
      "Isolation, well, I don't want to sit on the lemon tree",
    ],
    [
      [128270, 131750], // 02:08.27 - 02:11.75
      "I'm steppin' around in the desert of joy",
    ],
    [
      [131750, 134880], // 02:11.75 - 02:14.88
      "Baby, anyhow I'll get another toy",
    ],
    [
      [134880, 137810], // 02:14.88 - 02:17.81
      "And everything will happen, and you wonder",
    ],
    [
      [142140, 146220], // 02:21.14 - 02:25.22
      "I wonder how, I wonder why",
    ],
    [
      [146220, 149120], // 02:25.22 - 02:28.12
      "Yesterday you told me 'bout the blue, blue sky",
    ],
    [
      [149120, 153488], // 02:28.12 - 02:34.88
      "And all that I can see is just another lemon tree",
    ],
    [
      [153488, 157827], // 02:34.88 - 02:38.27
      "I'm turning my head up and down",
    ],
    [
      [157827, 161164], // 02:38.27 - 02:41.64
      "I'm turning, turning, turning, turning, turning around",
    ],
    [
      [161164, 164435], // 02:41.64 - 02:44.35
      "And all that I can see is just another lemon tree",
    ],
    [
      [164435, 164636], // 02:44.35 - 02:46.36
      "And I wonder, wonder",
    ],
    [
      [164636, 164835], // 02:46.36 - 02:48.35
      "I wonder how, I wonder why",
    ],
    [
      [164835, 165164], // 02:48.35 - 02:51.64
      "Yesterday you told me 'bout the blue, blue sky",
    ],
    [
      [165164, 165490], // 02:51.64 - 02:54.90
      "And all that I can see (ah, dip, dip, dip)",
    ],
    [
      [165490, 166806], // 02:54.90 - 02:58.06
      "And all that I can see (ah, dip, dip, dip)",
    ],
    [
      [166806, 171071], // 03:01.71 - 03:10.71
      "And all that I can see is just a yellow lemon tree",
    ],
  ];

  int currentLine = 0;
  StreamSubscription<Duration>? _positionSub;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Lắng nghe vị trí phát của vocalPlayer
    _positionSub = widget.audioHandler.vocalPlayer.positionStream.listen((
      position,
    ) {
      final ms = position.inMilliseconds;
      // Debug print playback time in mm:ss.SSS
      final minutes = position.inMinutes
          .remainder(60)
          .toString()
          .padLeft(2, '0');
      final seconds = position.inSeconds
          .remainder(60)
          .toString()
          .padLeft(2, '0');
      final millis = (position.inMilliseconds % 1000).toString().padLeft(
        3,
        '0',
      );
      debugPrint('Playback time millisecond: $ms');
      debugPrint('Playback time: $minutes:$seconds.$millis');

      int idx = lyrics.lastIndexWhere(
        (line) => ms >= line[0][0] && ms < line[0][1],
      );
      // Nếu playback đã vượt qua dòng cuối, luôn highlight dòng cuối
      if (idx == -1 && ms >= lyrics.last[0][1]) {
        idx = lyrics.length - 1;
      }
      if (idx != -1 && idx != currentLine) {
        setState(() {
          currentLine = idx;
        });
        // Cuộn đến dòng hiện tại và căn giữa nó
        _scrollToCurrentLine(idx);
      }
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240, // Điều chỉnh chiều cao nếu cần
      child: ListView.builder(
        controller: _scrollController,
        itemCount: lyrics.length,
        itemBuilder: (context, idx) {
          final currentTimestamp =
              widget.audioHandler.vocalPlayer.position.inMilliseconds;

          double fontSize = 15.0;
          FontWeight fontWeight = FontWeight.normal;
          Color color = Colors.white54;

          if (lyrics[0][0][0] <= currentTimestamp) {
            final bool highlight = idx == currentLine;
            final bool nearHighlight =
                idx == currentLine - 1 || idx == currentLine + 1;

            if (highlight) {
              fontSize = 17.2;
              fontWeight = FontWeight.bold;
              color = Colors.yellow;
            } else if (nearHighlight) {
              fontSize = 16.6;
              fontWeight = FontWeight.w600;
              color = Colors.white54;
            } else {
              fontSize = 15.0;
              fontWeight = FontWeight.normal;
              color = Colors.white54;
            }
          }

          return SizedBox(
            height: _itemHeight,
            child: Center(
              child: Text(
                lyrics[idx][1],
                style: TextStyle(
                  color: color,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  void _scrollToCurrentLine(int idx) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final target = (idx * _itemHeight) - 80.0;
        _scrollController.animateTo(
          target.clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}
