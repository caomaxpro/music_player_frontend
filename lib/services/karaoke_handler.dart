import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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

  DualAudioHandler() {
    _vocalPlayer.playerStateStream.listen((state) {
      _vocalStateController.add(state);
      // Update vocal playback state
    });
    _vocalPlayer.positionStream.listen((position) {
      _vocalPositionController.add(position);
    });

    _instrumentalPlayer.playerStateStream.listen((state) {
      // Update instrumental playback state
    });

    _init();
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
    await testAsset();

    // test loading
    await loadVocal(defaultVocalPath);
    await loadInstrumental(defaultInstrumentalPath);
  }

  Future<void> loadVocal(String path) async {
    if (path.startsWith('audio/')) {
      // Load from assets
      debugPrint('Loading asset: $path');
      await _vocalPlayer.setAudioSource(AudioSource.asset(path));
    } else if (path.startsWith('file://') || path.startsWith('/')) {
      // Load from local storage
      await _vocalPlayer.setAudioSource(AudioSource.uri(Uri.parse(path)));
    } else if (path.startsWith('http')) {
      // Load from network
      await _vocalPlayer.setAudioSource(AudioSource.uri(Uri.parse(path)));
    } else {
      throw Exception('Unsupported vocal path: $path');
    }
  }

  Future<void> loadInstrumental(String path) async {
    if (path.startsWith('audio/')) {
      await _instrumentalPlayer.setAudioSource(AudioSource.asset(path));
    } else if (path.startsWith('file://') || path.startsWith('/')) {
      await _instrumentalPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(path)),
      );
    } else if (path.startsWith('http')) {
      await _instrumentalPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(path)),
      );
    } else {
      throw Exception('Unsupported instrumental path: $path');
    }
  }

  Future<void> playBoth() async {
    await Future.wait([_vocalPlayer.play(), _instrumentalPlayer.play()]);
  }

  Future<void> pauseBoth() async {
    await Future.wait([_vocalPlayer.pause(), _instrumentalPlayer.pause()]);
  }

  Future<void> seekBoth(Duration position) async {
    await Future.wait([
      _vocalPlayer.seek(position),
      _instrumentalPlayer.seek(position),
    ]);
  }

  Future<void> setVocalVolume(double volume) async {
    await _vocalPlayer.setVolume(volume);
  }

  Future<void> setInstrumentalVolume(double volume) async {
    await _instrumentalPlayer.setVolume(volume);
  }

  Future<void> pauseVocal() async {
    await _vocalPlayer.pause();
  }

  Future<void> pauseInstrumental() async {
    await _instrumentalPlayer.pause();
  }

  // Clean up controllers
  @override
  Future<void> close() async {
    await _vocalPositionController.close();
    await _vocalStateController.close();
  }

  // Add more controls as needed (seek, stop, etc.)
}
