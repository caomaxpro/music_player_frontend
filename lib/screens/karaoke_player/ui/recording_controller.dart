import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

class RecordingController extends StatelessWidget {
  final bool isRecording;
  final ValueChanged<bool> onChanged;

  const RecordingController({
    super.key,
    required this.isRecording,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Icon(Icons.mic_none_sharp, color: Colors.white70, size: 30),
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
                    onChanged: onChanged,
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
