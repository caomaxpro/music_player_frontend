import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/main.dart';
import 'package:music_player/models/recording.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/karaoke_player/state/karaoke_player_state.dart';
import 'package:music_player/screens/karaoke_player/ui/helper/karaoke_player_helper.dart';
import 'package:music_player/screens/karaoke_track/utils/karaoke_track_helper.dart';
import 'package:music_player/services/karaoke_handler.dart';
import 'package:music_player/services/recorder_handler.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/handler_state.dart';
import 'package:music_player/widgets/custom_dialog.dart';
import 'package:music_player/widgets/custom_text_input.dart';
import 'package:uuid/v4.dart';

class RecordingController extends ConsumerStatefulWidget {
  DualAudioHandler dualAudioHandler = DualAudioHandler();

  RecordingController({super.key, required this.dualAudioHandler});

  @override
  ConsumerState<RecordingController> createState() =>
      _RecordingControllerState();
}

class _RecordingControllerState extends ConsumerState<RecordingController> {
  late int currentAudioPosition;
  late StreamSubscription<Duration>? positionSub;

  @override
  void initState() {
    super.initState();

    positionSub = widget.dualAudioHandler.vocalPlayer.positionStream.listen((
      duration,
    ) {
      setState(() {
        currentAudioPosition = duration.inMilliseconds;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    positionSub?.cancel();
  }

  Future<void> _toggleRecording(bool value) async {
    Song currentAudioFile = ref.read(currentAudioFileProvider);
    RecorderHandler recorderHandler = ref.read(recorderHandlerProvider);
    int audioPosition = ref.watch(audioPositionProvider);
    String folderName = currentAudioFile.uuid;

    if (value) {
      // check if audio handler is playing or not, if not then play it

      // Start recording
      // 2. Đợi audio thực sự phát (có thể delay nhỏ hoặc lắng nghe event)
      // 3. Lấy lại vị trí audio hiện tại
      int audioPosition = ref.watch(audioPositionProvider);

      // 4. Bắt đầu ghi âm
      final success = await recorderHandler.start(
        folderName: folderName,
        ref: ref,
      );

      if (success) {
        ref.read(startRecordingTime.notifier).state = currentAudioPosition;
        debugPrint('RecordingController: startTime set to $audioPosition ms');
        ref.read(isRecordingProvider.notifier).state = true;

        await widget.dualAudioHandler.playBoth(ref: ref);
      }
    } else {
      ref.read(endRecordingTime.notifier).state = currentAudioPosition;
      debugPrint('RecordingController: endTime set to $audioPosition ms');
      await widget.dualAudioHandler.pauseBoth();

      // Stop recording - show confirmation dialog
      // ignore: use_build_context_synchronously
      await showSaveRecordingDialog(ref, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(positionSubscriptionProvider);
    bool isRecording = ref.watch(isRecordingProvider);
    Song currentAudioFile = ref.watch(currentAudioFileProvider);

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Icon(
            Icons.mic_none_sharp,
            color: isRecording ? Colors.green : Colors.white70,
            size: 30,
          ),
        ),
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                const Text(
                  'Recording',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    thumbColor: WidgetStateProperty.all<Color>(Colors.white70),
                    activeTrackColor: Colors.white70.withAlpha(80),
                    inactiveTrackColor: Colors.transparent,
                    trackOutlineColor: WidgetStateProperty.all<Color>(
                      Colors.white70,
                    ),
                    value: isRecording,
                    onChanged: (value) => _toggleRecording(value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
