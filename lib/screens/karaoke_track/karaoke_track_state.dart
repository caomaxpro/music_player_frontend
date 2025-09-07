import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State for audio files fetched from local storag
enum KaraokeTrackFunction { deleteMany, delete, sort, edit, filter }

final karaokeTrackProvider = StateProvider<KaraokeTrackFunction?>(
  (ref) => null,
);

final selectedRecordingIdProvider = StateProvider<List<int>>((ref) => []);

class PlaybackState {
  bool isPlaying;
  int positionMs; // vị trí playback hiện tại (milliseconds)

  PlaybackState({this.isPlaying = false, this.positionMs = 0});

  Map<String, dynamic> toJson() {
    return {'isPlaying': isPlaying, 'positionMs': positionMs};
  }
}

final playStatesProvider = StateProvider<Map<int, PlaybackState>>((ref) => {});

void printPlayStatesAsJson(Map<int, PlaybackState> playStates) {
  final jsonMap = playStates.map(
    (key, value) => MapEntry(key.toString(), {
      'isPlaying': value.isPlaying,
      'positionMs': value.positionMs,
    }),
  );
  debugPrint(jsonEncode(jsonMap));
}
