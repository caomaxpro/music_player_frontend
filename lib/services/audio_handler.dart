import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => SimpleAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
}

class SimpleAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  SimpleAudioHandler() {
    // Listen to player state and update playback state
    _player.playerStateStream.listen((state) {
      playbackState.add(
        playbackState.value.copyWith(
          playing: state.playing,
          processingState:
              {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[state.processingState]!,
        ),
      );
    });

    // Listen to position updates and broadcast to clients
    _player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    debugPrint('[AudioHandler] customAction: $name, extras: $extras');

    switch (name) {
      case 'load':
        final paths =
            (extras?['paths'] as List<dynamic>?)
                ?.cast<String>(); // Expect a list of paths
        if (paths != null && paths.isNotEmpty) {
          debugPrint('[AudioHandler] Loading audio files: $paths');
          try {
            // Map paths to AudioSources
            final audioSources =
                paths.map<AudioSource>((path) {
                  if (path.startsWith('http://') ||
                      path.startsWith('https://')) {
                    return AudioSource.uri(Uri.parse(path));
                  } else if (path.startsWith('asset:///')) {
                    final assetPath = path.replaceFirst(
                      'asset:///',
                      'lib/assets/audio_files/',
                    );
                    return AudioSource.asset(assetPath);
                  } else {
                    return AudioSource.uri(Uri.file(path));
                  }
                }).toList();

            // Set the audio source (single or playlist)
            if (audioSources.length == 1) {
              await _player.setAudioSource(audioSources.first); // Single song
            } else {
              await _player.setAudioSource(
                // ignore: deprecated_member_use
                ConcatenatingAudioSource(children: audioSources), // Playlist
              );
            }

            debugPrint('[AudioHandler] Audio files loaded successfully.');
          } catch (e) {
            debugPrint('[AudioHandler] Failed to load audio files: $e');
          }
        } else {
          debugPrint('[AudioHandler] Load action requires at least one path');
        }
        break;

      case 'play':
        final loop = extras?['loop'] as bool? ?? false;
        final vol = (extras?['vol'] as num?)?.toDouble() ?? 1.0;

        if (_player.sequence.isEmpty) {
          debugPrint(
            '[AudioHandler] No audio files loaded. Please load a playlist first.',
          );
          return;
        }

        if (_player.playing) {
          debugPrint('[AudioHandler] Player is already playing.');
          return;
        }

        if (_player.processingState == ProcessingState.ready) {
          debugPrint('[AudioHandler] Resuming playback.');
          await _player.play();
          return;
        }

        // Nếu player không ở trạng thái sẵn sàng, kiểm tra và phát từ bài hiện tại
        debugPrint('[AudioHandler] Starting playback.');
        await _player.setLoopMode(loop ? LoopMode.all : LoopMode.off);
        await _player.setVolume(vol);
        await _player.play();
        break;

      case 'pause':
        if (_player.playing) {
          await _player.pause();
        }
        break;

      case 'stop':
        if (_player.playing ||
            _player.processingState != ProcessingState.idle) {
          await _player.stop();
        }
        break;

      case 'seek':
        final position = extras?['position'] as int?;
        if (position != null) {
          debugPrint('[AudioHandler] Seeking to position: $position seconds');
          final wasPlaying = _player.playing; // Check if the audio was playing
          if (wasPlaying) {
            await _player.pause(); // Pause before seeking
          }
          await _player.seek(Duration(seconds: position));
          if (wasPlaying) {
            await _player.play(); // Resume playback a fter seeking
          }
        } else {
          debugPrint('[AudioHandler] Seek action requires a position');
        }
        break;

      case 'getPosition':
        final currentPosition = _player.position.inSeconds;
        debugPrint('[AudioHandler] Current position: $currentPosition seconds');
        break;

      case 'getDuration':
        final duration = _player.duration;
        if (duration != null) {
          debugPrint(
            '[AudioHandler] Current audio duration: ${duration.inSeconds} seconds',
          );
          return duration.inSeconds; // Return duration in seconds
        } else {
          debugPrint('[AudioHandler] No audio loaded or duration is null');
          return 0; // Return 0 if no audio is loaded
        }

      case 'handleAudioFileEnd':
        final currentIndex = _player.currentIndex;
        final playlistLength = _player.sequence.length;

        if (currentIndex != null && currentIndex < playlistLength - 1) {
          // Chuyển sang bài tiếp theo
          debugPrint('[AudioHandler] Switching to next song');
          await _player.seekToNext();
          await _player.play();
        } else {
          // Dừng player nếu không còn bài hát
          debugPrint(
            '[AudioHandler] No more songs in the playlist. Stopping player.',
          );
          await _player.stop();
        }
        break;
    }
  }
}
