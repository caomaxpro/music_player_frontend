import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/create/lyrics/utils/convert_lrc_to_json.dart';
import 'package:music_player/screens/karaoke_player/helper/karaoke_player_helper.dart';
import 'package:music_player/services/karaoke_handler.dart';
import 'package:music_player/state/audio_state.dart';

class LyricsWidget extends ConsumerStatefulWidget {
  final DualAudioHandler audioHandler;

  const LyricsWidget({super.key, required this.audioHandler});

  @override
  ConsumerState<LyricsWidget> createState() => _LyricsWidgetState();
}

class _LyricsWidgetState extends ConsumerState<LyricsWidget> {
  static const double _itemHeight = 45; // Đặt chiều cao cố định cho mỗi item

  List<List<dynamic>> lyrics = [];
  int currentLine = 0;
  StreamSubscription<Duration>? _positionSub;
  final ScrollController _scrollController = ScrollController();
  bool _isDataLoaded = false; // Flag để theo dõi trạng thái load dữ liệu

  @override
  void initState() {
    super.initState();

    final currentAudioFile = ref.read(currentAudioFileProvider);

    debugPrint('Raw Data: ${currentAudioFile.timestampLyrics}');

    try {
      final splitData = splitLrcMetaAndLyrics(currentAudioFile.timestampLyrics);
      debugPrint('Split Data: ${splitData.runtimeType}');
      debugPrint('Lyrics Data: ${splitData['lyrics']}');

      if (splitData['lyrics'] is String) {
        lyrics = convertLyrics(parseLrcLyrics(splitData['lyrics']!));
        debugPrint("[Karaoke Player]: $lyrics");

        // Đánh dấu dữ liệu đã load xong
        setState(() {
          _isDataLoaded = true;
        });

        // Cuộn về đầu sau khi widget được xây dựng
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
      } else {
        debugPrint('Error: lyrics is not a List<dynamic>');
      }
    } catch (e) {
      debugPrint('Error parsing lyrics: $e');
    }

    // Listen to the position stream
    _positionSub = widget.audioHandler.vocalPlayer.positionStream.listen((
      position,
    ) {
      final ms = position.inMilliseconds;

      int idx = lyrics.lastIndexWhere(
        (line) => ms >= line[0][0] && ms < line[0][1],
      );
      if (idx == -1 && ms >= lyrics.last[0][1]) {
        idx = lyrics.length - 1;
      }
      if (idx != -1 && idx != currentLine) {
        setState(() {
          currentLine = idx;
        });
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
    if (!_isDataLoaded) {
      // Hiển thị loading nếu dữ liệu chưa load xong
      return const Center(child: CircularProgressIndicator());
    }

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
