import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<double>> fetchAmplitude(String filePath) async {
  final url = Uri.parse(
    'http://192.168.12.101:5000/amplitude',
  ); // Replace with your server's URL

  try {
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      return (data['rms'] as List).map((e) => e as double).toList();
    } else {
      throw Exception(
        'Failed to fetch amplitude data: ${response.reasonPhrase}',
      );
    }
  } catch (e) {
    throw Exception('Error during amplitude fetch: $e');
  }
}
