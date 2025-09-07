import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/screens/karaoke_player/state/karaoke_player_state.dart';

class DualAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _vocalPlayer = AudioPlayer();
  final AudioPlayer _instrumentalPlayer = AudioPlayer();

  AudioPlayer get vocalPlayer => _vocalPlayer;
  AudioPlayer get instrumentalPlayer => _instrumentalPlayer;

  // test paths
  final String defaultVocalPath = 'audio/vocals.mp3';
  final String defaultInstrumentalPath = 'audio/accompaniment.mp3';

  // Stream controllers for playback time and state
  final StreamController<Duration> _vocalPositionController =
      StreamController.broadcast();
  final StreamController<PlayerState> _vocalStateController =
      StreamController.broadcast();

  Stream<Duration> get vocalPositionStream => _vocalPositionController.stream;
  Stream<PlayerState> get vocalStateStream => _vocalStateController.stream;

  final StreamController<void> _playbackCompletedController =
      StreamController<void>.broadcast();

  Stream<void> get playbackCompletedStream =>
      _playbackCompletedController.stream;

  DualAudioHandler() {
    // Set up player state listeners
    _vocalPlayer.playerStateStream.listen((state) {
      _vocalStateController.add(state);
    });

    _vocalPlayer.positionStream.listen((position) {
      _vocalPositionController.add(position);
    });

    _instrumentalPlayer.playerStateStream.listen((state) {
      // Update instrumental playback state if needed
    });

    // Setup completion listeners - THIS WAS MISSING!
    _setupCompletionListeners();

    // Uncomment if you want to test with default assets
    // _init();
  }

  // Setup completion listeners method
  void _setupCompletionListeners() {
    // Listen to vocal player completion
    _vocalPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        debugPrint('Vocal playback completed');
        _onPlaybackCompleted();
      }
    });

    // Listen to instrumental player completion
    _instrumentalPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        debugPrint('Instrumental playback completed');
        _onPlaybackCompleted();
      }
    });
  }

  void _onPlaybackCompleted() {
    debugPrint('Playback completed - emitting event');
    // Emit completion event
    _playbackCompletedController.add(null);
  }

  Future<void> testAsset() async {
    try {
      await rootBundle.load('audio/vocals.mp3');
      debugPrint('Asset vocals.mp3 loaded successfully!');
    } catch (e) {
      debugPrint('Failed to load asset: $e');
    }
  }

  Future<void> _init() async {
    // await testAsset();
    // test loading
    await loadVocal(defaultVocalPath);
    await loadInstrumental(defaultInstrumentalPath);
  }

  Future<void> loadVocal(String path, {Duration? initialPosition}) async {
    try {
      if (path.isEmpty) {
        throw Exception('Vocal path cannot be empty');
      }

      AudioSource source;
      if (path.startsWith('audio/')) {
        debugPrint('Loading vocal asset: $path');
        source = AudioSource.asset(path);
      } else if (path.startsWith('file://') || path.startsWith('/')) {
        debugPrint('Loading vocal from file: $path');
        source = AudioSource.uri(Uri.parse(path));
      } else if (path.startsWith('http')) {
        debugPrint('Loading vocal from URL: $path');
        source = AudioSource.uri(Uri.parse(path));
      } else {
        throw Exception('Unsupported vocal path: $path');
      }

      await _vocalPlayer.setAudioSource(
        source,
        initialPosition: initialPosition ?? Duration.zero,
      );
    } catch (e) {
      debugPrint('Error loading vocal: $e');
      rethrow;
    }
  }

  Future<void> loadInstrumental(
    String path, {
    Duration? initialPosition,
  }) async {
    try {
      if (path.isEmpty) {
        throw Exception('Instrumental path cannot be empty');
      }

      AudioSource source;
      if (path.startsWith('audio/')) {
        debugPrint('Loading instrumental asset: $path');
        source = AudioSource.asset(path);
      } else if (path.startsWith('file://') || path.startsWith('/')) {
        debugPrint('Loading instrumental from file: $path');
        source = AudioSource.uri(Uri.parse(path));
      } else if (path.startsWith('http')) {
        debugPrint('Loading instrumental from URL: $path');
        source = AudioSource.uri(Uri.parse(path));
      } else {
        throw Exception('Unsupported instrumental path: $path');
      }

      await _instrumentalPlayer.setAudioSource(
        source,
        initialPosition: initialPosition ?? Duration.zero,
      );
    } catch (e) {
      debugPrint('Error loading instrumental: $e');
      rethrow;
    }
  }

  Future<void> playBoth({WidgetRef? ref}) async {
    try {
      await Future.wait([_vocalPlayer.play(), _instrumentalPlayer.play()]);

      debugPrint(
        "AudioHandler: started at ${DateTime.now().toIso8601String()}",
      );
      debugPrint('Both players started');

      ref?.read(audioPlayerStartTimeProvider.notifier).state = DateTime.now();
    } catch (e) {
      debugPrint('Error playing both: $e');
      rethrow;
    }
  }

  Future<void> playVocal() async {
    try {
      await _vocalPlayer.play();
      debugPrint('Vocal player started');
    } catch (e) {
      debugPrint('Error playing vocal: $e');
      rethrow;
    }
  }

  Future<void> playInstrumental() async {
    try {
      await _instrumentalPlayer.play();
      debugPrint('Instrumental player started');
    } catch (e) {
      debugPrint('Error playing instrumental: $e');
      rethrow;
    }
  }

  Future<void> pauseBoth() async {
    try {
      await Future.wait([_vocalPlayer.pause(), _instrumentalPlayer.pause()]);
      debugPrint('Both players paused');
    } catch (e) {
      debugPrint('Error pausing both: $e');
      rethrow;
    }
  }

  Future<void> stopBoth() async {
    try {
      await Future.wait([_vocalPlayer.stop(), _instrumentalPlayer.stop()]);
      debugPrint('Both players stopped');
    } catch (e) {
      debugPrint('Error stopping both: $e');
      rethrow;
    }
  }

  Future<void> seekBoth(Duration position) async {
    try {
      await Future.wait([
        _vocalPlayer.seek(position),
        _instrumentalPlayer.seek(position),
      ]);
      debugPrint('Both players seeked to: $position');
    } catch (e) {
      debugPrint('Error seeking both: $e');
      rethrow;
    }
  }

  Future<void> seekInstrumental(Duration position) async {
    try {
      await _instrumentalPlayer.seek(position);
      debugPrint('Instrumental player seeked to: $position');
    } catch (e) {
      debugPrint('Error seeking instrumental: $e');
      rethrow;
    }
  }

  Future<void> setVocalVolume(double volume) async {
    try {
      await _vocalPlayer.setVolume(volume.clamp(0.0, 1.0));
      debugPrint('Vocal volume set to: $volume');
    } catch (e) {
      debugPrint('Error setting vocal volume: $e');
      rethrow;
    }
  }

  Future<void> setInstrumentalVolume(double volume) async {
    try {
      await _instrumentalPlayer.setVolume(volume.clamp(0.0, 1.0));
      debugPrint('Instrumental volume set to: $volume');
    } catch (e) {
      debugPrint('Error setting instrumental volume: $e');
      rethrow;
    }
  }

  Future<void> pauseVocal() async {
    try {
      await _vocalPlayer.pause();
      debugPrint('Vocal player paused');
    } catch (e) {
      debugPrint('Error pausing vocal: $e');
      rethrow;
    }
  }

  Future<void> pauseInstrumental() async {
    try {
      await _instrumentalPlayer.pause();
      debugPrint('Instrumental player paused');
    } catch (e) {
      debugPrint('Error pausing instrumental: $e');
      rethrow;
    }
  }

  // Get current playback states
  bool get isVocalPlaying => _vocalPlayer.playing;
  bool get isInstrumentalPlaying => _instrumentalPlayer.playing;
  bool get isBothPlaying => isVocalPlaying && isInstrumentalPlaying;

  // Get current positions
  Duration get vocalPosition => _vocalPlayer.position;
  Duration get instrumentalPosition => _instrumentalPlayer.position;

  // Get durations
  Duration? get vocalDuration => _vocalPlayer.duration;
  Duration? get instrumentalDuration => _instrumentalPlayer.duration;

  // Clean up controllers
  Future<void> dispose() async {
    try {
      debugPrint('Disposing DualAudioHandler');

      // Stop and dispose of the audio players
      await stopBoth();
      await _vocalPlayer.dispose();
      await _instrumentalPlayer.dispose();

      // Close the stream controllers
      await _vocalPositionController.close();
      await _vocalStateController.close();
      await _playbackCompletedController.close();

      debugPrint('DualAudioHandler disposed successfully');
    } catch (e) {
      debugPrint('Error disposing DualAudioHandler: $e');
    }
  }
}
