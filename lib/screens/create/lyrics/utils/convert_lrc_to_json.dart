import 'dart:convert';
import 'dart:io';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/karaoke_player/helper/karaoke_player_helper.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:path_provider/path_provider.dart';

// clean lrc data and convert file to .json

/* 
  clean lrc data and convert to this text format

  title: <Song Title>,
  artist: <Song Artist>,
  album: <Song Album>,
  length: <Song Length>,
  lyrics:
    00:00:00 Line 1
    00:10:00 Line 2
 */

void setLyricsState(String lyrics, WidgetRef ref) {
  // fetch and process lrc
  final rawData = splitLrcMetaAndLyrics(lyrics);

  final parsedLyrics = parseLrcLyrics(rawData["lyrics"]!);

  final jsonConvertedLyrics = convertLyricsToJson(parsedLyrics);

  // debugPrint(
  //   "[Lyrics Manually] ${jsonConvertedLyrics.toString()}",
  // );

  Song updatedFile = ref
      .read(currentAudioFileProvider)
      .copyWith(timestampLyrics: jsonEncode(jsonConvertedLyrics));

  ref.read(currentAudioFileProvider.notifier).state = updatedFile;

  debugPrint("[Lyrics Manually]: Updated File ${updatedFile.toMap()}");
}

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

String extractLyrics(List<List<String>> listLines) {
  // Ghép tất cả lyric (cột 2) thành 1 chuỗi, mỗi dòng cách nhau bằng \n
  return listLines.map((line) => line[1]).join('\n');
}

Map<String, String> splitLrcMetaAndLyrics(String lrcText) {
  final lines = lrcText.split('\n');
  final bufferMeta = StringBuffer();
  final bufferLyrics = StringBuffer();

  final metaReg = RegExp(r'^\[(id|ar|al|ti|length):', caseSensitive: false);

  for (final line in lines) {
    if (metaReg.hasMatch(line.trim())) {
      bufferMeta.writeln(line.trim());
    } else if (line.trim().isNotEmpty) {
      bufferLyrics.writeln(line.trim());
    }
  }

  return {
    'meta': bufferMeta.toString().trim(),
    'lyrics': bufferLyrics.toString().trim(),
  };
}

List<List<String>> parseLrcMeta(String metaText) {
  final result = <List<String>>[];
  final metaReg = RegExp(r'^\[(\w+):\s*(.*?)\s*\]$');
  for (final line in metaText.split('\n')) {
    final match = metaReg.firstMatch(line.trim());
    if (match != null) {
      final key = match.group(1)!.toLowerCase();
      final value = match.group(2)!;
      String label;
      switch (key) {
        case 'ti':
          label = 'Title';
          break;
        case 'ar':
          label = 'Artist';
          break;
        case 'al':
          label = 'Album';
          break;
        case 'length':
          label = 'Length';
          break;
        default:
          label = key;
      }
      debugPrint('parseLrcMeta: [$label, $value]'); // Debug print
      result.add([label, value]);
    }
  }
  debugPrint('parseLrcMeta result: $result'); // Debug print
  return result;
}

List<List<String>> parseLrcLyrics(String lyricsRaw) {
  final result = <List<String>>[];
  final lines = lyricsRaw.split('\n');

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    // [MM:SS.xx]Lyric
    final matchLrc = RegExp(
      r'^\[(\d{2}):(\d{2})\.(\d+)\](.*)$',
    ).firstMatch(trimmed);

    if (matchLrc != null) {
      final min = int.parse(matchLrc.group(1)!);
      final sec = int.parse(matchLrc.group(2)!);
      final timestamp =
          '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
      final lyric = matchLrc.group(4)!.trim();
      result.add([timestamp, lyric]);
      continue;
    }

    // 00:00:00 Lyric
    final matchStd = RegExp(
      r'^(\d{2}:\d{2}:\d{2})\s+(.*)$',
    ).firstMatch(trimmed);
    if (matchStd != null) {
      result.add([matchStd.group(1)!, matchStd.group(2)!]);
      continue;
    }

    // Nếu không có timestamp, gán mặc định
    result.add(['00:00:00', trimmed]);
  }

  return result;
}

String lrcToPlainText(String lrcText) {
  // Extract metadata
  String extractTag(String tag) {
    final match = RegExp(
      r'\[' + tag + r':\s*(.*?)\s*\]',
      caseSensitive: false,
    ).firstMatch(lrcText);
    return match != null ? match.group(1) ?? '' : '';
  }

  final title = extractTag('ti');
  final artist = extractTag('ar');
  final album = extractTag('al');
  final length = extractTag('length');

  // Extract lyrics lines with timestamps
  final lyricLines = <String>[];
  final pattern = RegExp(r'\[(\d+):(\d+\.\d+)\](.*)');
  for (final line in lrcText.split('\n')) {
    final match = pattern.firstMatch(line.trim());
    if (match != null) {
      final m = int.parse(match.group(1)!);
      final s = double.parse(match.group(2)!);
      final lyric = match.group(3)!.trim();
      // Format timestamp as HH:MM:SS
      final totalSeconds = (m * 60 + s).toInt();
      final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
      final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
      lyricLines.add('  $hours:$minutes:$seconds $lyric');
    }
  }

  // Compose result
  return [
    'title: $title,',
    'artist: $artist,',
    'album: $album,',
    'length: $length,',
    'lyrics:',
    ...lyricLines,
  ].join('\n');
}

bool isValidLrcFormat(String lrcText) {
  // Check for at least one timestamped lyric line
  final hasTimestampedLyrics = RegExp(r'\[\d+:\d+\.\d+\].+').hasMatch(lrcText);

  // Return true only if all conditions are met
  return hasTimestampedLyrics;
}

String normalizeTitle(String title) {
  title = title.replaceAll(RegExp(r'[^\w\s]'), '');
  title = removeDiacritics(title);
  title = title.toLowerCase().replaceAll(' ', '_');
  return title;
}

String extractTitle(String lrcText) {
  final tiMatch = RegExp(
    r'\[ti:\s*(.+?)\s*\]',
    caseSensitive: false,
  ).firstMatch(lrcText);
  final arMatch = RegExp(
    r'\[ar:\s*(.+?)\s*\]',
    caseSensitive: false,
  ).firstMatch(lrcText);
  final title = tiMatch != null ? normalizeTitle(tiMatch.group(1)!) : '';
  final artist = arMatch != null ? normalizeTitle(arMatch.group(1)!) : '';
  if (title.isNotEmpty && artist.isNotEmpty) {
    return '${title}_$artist';
  } else if (title.isNotEmpty) {
    return title;
  } else if (artist.isNotEmpty) {
    return artist;
  } else {
    return 'lyrics';
  }
}

String cleanLrcMetadata(String lrcText) {
  final lines = lrcText.trim().split('\n');
  final cleaned = lines.where(
    (line) =>
        !RegExp(
          r'\[(id:|ar:|al:|ti:|length:)',
          caseSensitive: false,
        ).hasMatch(line.trim()),
  );
  return cleaned.join('\n');
}

List<Map<String, dynamic>> lrcToJson(String lrcText) {
  lrcText = cleanLrcMetadata(lrcText);
  final pattern = RegExp(r'\[(\d+):(\d+\.\d+)\](.*)');
  final entries = <Map<String, dynamic>>[];

  for (final line in lrcText.split('\n')) {
    final match = pattern.firstMatch(line.trim());
    if (match != null) {
      final m = int.parse(match.group(1)!);
      final s = double.parse(match.group(2)!);
      final lyric = match.group(3)!.trim();
      final start = (m * 60 + s);
      entries.add({
        'start': double.parse(start.toStringAsFixed(2)),
        'line': lyric,
      });
    }
  }

  // Tính end cho từng dòng
  for (var i = 0; i < entries.length; i++) {
    if (i < entries.length - 1) {
      entries[i]['end'] = entries[i + 1]['start'];
    } else {
      entries[i]['end'] = entries[i]['start'];
    }
  }

  return entries;
}

Future<void> saveLrcJsonToFile(String lrcText) async {
  try {
    // Get the local storage directory
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = directory.path;

    // Generate the file name
    final fileName = '${extractTitle(lrcText)}.json';

    // Convert LRC to JSON
    final entries = lrcToJson(lrcText);

    // Create the file in the local storage directory
    final file = File('$folderPath/$fileName');

    // Write the JSON data to the file
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(entries),
      encoding: utf8,
    );

    print('File saved successfully at: ${file.path}');
  } catch (e) {
    print('Error saving file: $e');
  }
}
