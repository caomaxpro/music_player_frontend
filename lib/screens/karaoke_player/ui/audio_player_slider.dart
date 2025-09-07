import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/widgets/custom_slider.dart';

class AudioPlayerSlider extends StatefulWidget {
  final AudioPlayer player;
  final String title;
  final Widget icon;

  const AudioPlayerSlider({
    super.key,
    required this.player,
    required this.title,
    required this.icon,
  });

  @override
  State<AudioPlayerSlider> createState() => _AudioPlayerSliderState();
}

class _AudioPlayerSliderState extends State<AudioPlayerSlider> {
  double _volume = 0.5;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayerState? _playerState;

  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration?> _durationSubscription;
  late final StreamSubscription<PlayerState> _playerStateSubscription;
  late final StreamSubscription<double> _volumeSubscription;

  @override
  void initState() {
    super.initState();

    _positionSubscription = widget.player.positionStream.listen((pos) {
      if (mounted) {
        setState(() => _position = pos);
      }
    });

    _durationSubscription = widget.player.durationStream.listen((dur) {
      if (mounted && dur != null) {
        setState(() => _duration = dur);
      }
    });

    _playerStateSubscription = widget.player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _playerState = state);
      }
    });

    _volumeSubscription = widget.player.volumeStream.listen((v) {
      if (mounted) {
        setState(() => _volume = v);
      }
    });

    _volume = widget.player.volume;
    _duration = widget.player.duration ?? Duration.zero;
    _position = widget.player.position;
  }

  @override
  void dispose() {
    // Cancel all subscriptions to avoid memory leaks
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _playerStateSubscription.cancel();
    _volumeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 1, child: widget.icon),
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Icon(Icons.volume_down_outlined, color: Colors.white70, size: 28),
              Expanded(
                child: CustomSlider(
                  value: _volume,
                  min: 0,
                  max: 1,
                  onChanged: (v) {
                    setState(() => _volume = v);
                    widget.player.setVolume(v);
                  },
                  barColor: Colors.white70,
                  trackHeight: 18,
                  trackWidth: 200,
                  outlineColor: Colors.white70,
                  thumbColor: Colors.white70,
                  thumbIcon: Icon(Icons.mic, color: Colors.white70, size: 32),
                  thumbIconSize: 12,
                ),
              ),
              Icon(Icons.volume_up_outlined, color: Colors.white70, size: 28),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
