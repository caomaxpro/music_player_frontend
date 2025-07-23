import 'dart:convert';

String listToString(List<List<String>> list) {
  return jsonEncode(list);
}

List<List<String>> stringToList(String stringData) {
  final parsedData = jsonDecode(stringData) as List<dynamic>;
  return parsedData.map((e) => List<String>.from(e)).toList();
}
