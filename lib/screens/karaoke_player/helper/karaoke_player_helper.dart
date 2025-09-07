// Dạng input: List<List<String>> với mỗi phần tử là [timestamp, lyric]
// Ví dụ: [
//   ["00:01.00", "Hello world"],
//   ["00:05.00", "Welcome to karaoke"],
//   ...
// ]
// Ví dụ: [
//   [["00:01.00", "00:05.00"], "Hello world"],
//   [["00:05.00", "....."], "Welcome to karaoke"],
//   ...
// ]

List<List<dynamic>> convertLyrics(List<List<dynamic>> input) {
  final List<List<dynamic>> result = [];
  for (int i = 0; i < input.length; i++) {
    final start = input[i][0];
    // Tìm end time là timestamp của dòng tiếp theo (nếu có), hoặc "....."
    // Nếu dòng tiếp theo trống thì bỏ qua luôn, tìm tiếp dòng sau nữa
    String end = ".....";
    for (int j = i + 1; j < input.length; j++) {
      if (input[j][1].trim().isNotEmpty) {
        end = input[j][0];
        break;
      }
    }
    // Nếu lyric không rỗng thì thêm vào result
    if (input[i][1].trim().isNotEmpty) {
      result.add([
        [timeStringToMilliseconds(start), timeStringToMilliseconds(end)],
        input[i][1],
      ]);
    }
  }
  return result;
}

List<List<dynamic>> convertJsonToLyricBlocks(List<Map<String, dynamic>> json) {
  final List<List<dynamic>> result = [];
  for (final item in json) {
    final start = item["start"]?.toString() ?? "";
    final end = item["end"]?.toString() ?? "";
    final lyric = item["lyric"]?.toString() ?? "";
    result.add([
      [start, end],
      lyric,
    ]);
  }
  return result;
}

List<Map<String, dynamic>> convertLyricsToJson(List<List<String>> input) {
  final List<Map<String, dynamic>> result = [];
  for (int i = 0; i < input.length; i++) {
    final start = input[i][0];
    String end = ".....";
    for (int j = i + 1; j < input.length; j++) {
      if (input[j][1].trim().isNotEmpty) {
        end = input[j][0];
        break;
      }
    }
    if (input[i][1].trim().isNotEmpty) {
      result.add({"start": start, "end": end, "lyric": input[i][1]});
    }
  }
  return result;
}

int timeStringToMilliseconds(String time) {
  // Hỗ trợ định dạng "mm:ss.SS" hoặc "mm:ss.SSS"
  final parts = time.split(':');

  if (parts.length != 2) return 0;
  final minute = int.tryParse(parts[0]) ?? 0;
  final secParts = parts[1].split('.');
  final second = int.tryParse(secParts[0]) ?? 0;
  final ms =
      secParts.length > 1 ? int.tryParse(secParts[1].padRight(3, '0')) ?? 0 : 0;
  return minute * 60000 + second * 1000 + ms;
}
