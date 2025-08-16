import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';

// State for audio files fetched from local storage
final audioFilesProvider = StateProvider<List<Song>>((ref) => []);

final selectedFile = StateProvider<File?>((ref) => null);

// State for the currently playing audio file
final currentAudioFileProvider = StateProvider<Song>((ref) => Song());

final internetConnectionProvider = StateProvider<bool>((ref) => false);

void updateCurrentAudioFile(WidgetRef ref, Song updatedSong) {
  // Update current audio file
  ref.read(currentAudioFileProvider.notifier).state = updatedSong;

  // Update the corresponding item in audioFilesProvider
  final audioFiles = ref.read(audioFilesProvider);
  final updatedList =
      audioFiles.map((song) {
        return song.uuid == updatedSong.uuid ? updatedSong : song;
      }).toList();

  ref.read(audioFilesProvider.notifier).state = updatedList;
}

List<Song> getRecentlyAccessedSongs(WidgetRef ref) {
  final audioFiles = ref.read(audioFilesProvider);
  final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
  return audioFiles
      .where((song) => song.recentDate.isAfter(threeDaysAgo))
      .toList();
}

void sortAudioFilesByCreatedDateNewest(WidgetRef ref) {
  final audioFiles = [...ref.read(audioFilesProvider)];
  audioFiles.sort((a, b) => b.createdDate.compareTo(a.createdDate));
  ref.read(audioFilesProvider.notifier).state = audioFiles;
}

void sortAudioFilesByCreatedDateOldest(WidgetRef ref) {
  final audioFiles = [...ref.read(audioFilesProvider)];
  audioFiles.sort((a, b) => a.createdDate.compareTo(b.createdDate));
  ref.read(audioFilesProvider.notifier).state = audioFiles;
}

void sortAudioFilesByTitleAsc(WidgetRef ref) {
  final audioFiles = [...ref.read(audioFilesProvider)];
  audioFiles.sort((a, b) => a.title.compareTo(b.title));
  ref.read(audioFilesProvider.notifier).state = audioFiles;
}

void sortAudioFilesByTitleDesc(WidgetRef ref) {
  final audioFiles = [...ref.read(audioFilesProvider)];
  audioFiles.sort((a, b) => b.title.compareTo(a.title));
  ref.read(audioFilesProvider.notifier).state = audioFiles;
}

void sortAudioFilesByArtistAsc(WidgetRef ref) {
  final audioFiles = [...ref.read(audioFilesProvider)];
  audioFiles.sort((a, b) => a.artist.compareTo(b.artist));
  ref.read(audioFilesProvider.notifier).state = audioFiles;
}

void sortAudioFilesByArtistDesc(WidgetRef ref) {
  final audioFiles = [...ref.read(audioFilesProvider)];
  audioFiles.sort((a, b) => b.artist.compareTo(a.artist));
  ref.read(audioFilesProvider.notifier).state = audioFiles;
}

void addAudioFile(WidgetRef ref, Song song) {
  final currentList = ref.read(audioFilesProvider);
  ref.read(audioFilesProvider.notifier).state = [...currentList, song];
}

void deleteAudioFiles(WidgetRef ref, List<Song> songs) {
  final audioFiles = ref.read(audioFilesProvider);
  final filteredAudioFiles =
      audioFiles
          .where((file) => !songs.any((deleted) => deleted.uuid == file.uuid))
          .toList();
  ref.read(audioFilesProvider.notifier).state = filteredAudioFiles;
}

void deleteAllAudioFiles(WidgetRef ref) {
  ref.read(audioFilesProvider.notifier).state = [];
}

// Methods for audioFilesProvider
void setAudioFiles(WidgetRef ref, List<Song> songs) {
  ref.read(audioFilesProvider.notifier).state = songs;
}

void clearAudioFiles(WidgetRef ref) {
  ref.read(audioFilesProvider.notifier).state = [];
}

// Methods for currentAudioFileProvider
void setCurrentAudioFile(WidgetRef ref, Song song) {
  ref.read(currentAudioFileProvider.notifier).state = song;
}

void clearCurrentAudioFile(WidgetRef ref) {
  ref.read(currentAudioFileProvider.notifier).state = Song();
}

// Methods for internetConnectionProvider
void setInternetConnection(WidgetRef ref, bool status) {
  ref.read(internetConnectionProvider.notifier).state = status;
}

void clearInternetConnection(WidgetRef ref) {
  ref.read(internetConnectionProvider.notifier).state = false;
}
