import 'dart:convert';

List<List<dynamic>> lrcToLyricList(
  String lrcContent, {
  int defaultDurationMs = 3000,
}) {
  final RegExp timeExp = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\]');
  final lines = lrcContent.split('\n');
  final List<Map<String, dynamic>> parsed = [];

  for (var line in lines) {
    final matches = timeExp.allMatches(line);
    if (matches.isEmpty) continue;
    final lyric = line.replaceAll(timeExp, '').trim();
    for (final match in matches) {
      final min = int.parse(match.group(1)!);
      final sec = int.parse(match.group(2)!);
      final ms =
          match.group(3) != null
              ? int.parse(match.group(3)!.padRight(3, '0'))
              : 0;
      final startMs = min * 60000 + sec * 1000 + ms;
      parsed.add({'start': startMs, 'lyric': lyric});
    }
  }

  // Sort by start time
  parsed.sort((a, b) => a['start'].compareTo(b['start']));

  // Build result with [start, end], lyric
  final List<List<dynamic>> result = [];
  for (int i = 0; i < parsed.length; i++) {
    final start = parsed[i]['start'];
    final end =
        (i < parsed.length - 1)
            ? parsed[i + 1]['start']
            : start + defaultDurationMs;
    result.add([
      [start, end],
      parsed[i]['lyric'],
    ]);
  }
  return result;
}

String lyricListToJson(List<List<dynamic>> lyricList) {
  final jsonList =
      lyricList.map((item) {
        return {'start': item[0][0], 'end': item[0][1], 'lyric': item[1]};
      }).toList();
  return jsonEncode(jsonList);
}

List<List<dynamic>> jsonToLyricList(String jsonString) {
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map<List<dynamic>>((item) {
    return [
      [item['start'], item['end']],
      item['lyric'],
    ];
  }).toList();
}
