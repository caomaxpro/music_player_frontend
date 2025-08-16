import 'package:flutter/material.dart';

class KaraokeControls extends StatelessWidget {
  final bool isRecording;
  final ValueChanged<bool> onRecordingChanged;
  final double vocalVolume;
  final ValueChanged<double> onVocalVolumeChanged;
  final double instrumentalVolume;
  final ValueChanged<double> onInstrumentalVolumeChanged;
  final Widget lyrics;

  const KaraokeControls({
    super.key,
    required this.isRecording,
    required this.onRecordingChanged,
    required this.vocalVolume,
    required this.onVocalVolumeChanged,
    required this.instrumentalVolume,
    required this.onInstrumentalVolumeChanged,
    required this.lyrics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recording toggle
        Row(
          children: [
            const Icon(Icons.mic, color: Colors.white70),
            const SizedBox(width: 8),
            const Text('Recording', style: TextStyle(color: Colors.white70)),
            const Spacer(),
            Switch(
              value: isRecording,
              onChanged: onRecordingChanged,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Vocal volume
        Row(
          children: [
            const Icon(Icons.record_voice_over, color: Colors.white70),
            const SizedBox(width: 8),
            const Text('Vocal', style: TextStyle(color: Colors.white70)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.volume_down, color: Colors.white70),
            Expanded(
              child: Slider(
                value: vocalVolume,
                min: 0,
                max: 1,
                onChanged: onVocalVolumeChanged,
              ),
            ),
            const Icon(Icons.volume_up, color: Colors.white70),
          ],
        ),
        const SizedBox(height: 16),

        // Instrumental volume
        Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white70),
            const SizedBox(width: 8),
            const Text('Instrumental', style: TextStyle(color: Colors.white70)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.volume_down, color: Colors.white70),
            Expanded(
              child: Slider(
                value: instrumentalVolume,
                min: 0,
                max: 1,
                onChanged: onInstrumentalVolumeChanged,
              ),
            ),
            const Icon(Icons.volume_up, color: Colors.white70),
          ],
        ),
        const SizedBox(height: 16),

        // Lyrics section
        ExpansionTile(
          title: const Text('Lyrics', style: TextStyle(color: Colors.white70)),
          children: [
            lyrics,
          ],
        ),
      ],
    );
  }
}