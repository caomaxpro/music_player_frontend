import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:music_player/api/api_instance.dart';

// Global variable to store the app's storage directory

late final Directory appStorageFolder;

class KaraokeService {
  final ApiService apiService = ApiService();

  KaraokeService();

  Future<void> initializeAppStorage() async {
    try {
      // Get the application's documents directory
      final directory = await getApplicationDocumentsDirectory();

      // Define the default storage folder for the app
      appStorageFolder = Directory('${directory.path}/karaoke_app_storage');

      // Check if the folder exists, if not, create it
      if (!appStorageFolder.existsSync()) {
        await appStorageFolder.create(recursive: true);
        debugPrint('App storage folder created at: ${appStorageFolder.path}');
      } else {
        debugPrint(
          'App storage folder already exists at: ${appStorageFolder.path}',
        );
      }
    } catch (e) {
      debugPrint('Error initializing app storage: $e');
    }
  }

  Future<Map<String, String>?> saveAndUnzipFile(
    String base64String,
    String zipFileName,
    String folderName,
  ) async {
    try {
      // Decode the base64 string
      final decodedBytes = base64Decode(base64String);

      // Get folder name from zipFileName (remove extension)
      final folderPath = '${appStorageFolder.path}/$folderName';

      final folderDir = Directory(folderPath);

      // If folder exists, delete it and its contents
      if (await folderDir.exists()) {
        await folderDir.delete(recursive: true);
        debugPrint('Existing folder deleted: $folderPath');
      }

      // Create the folder
      await folderDir.create(recursive: true);

      // Write the zip file to the folder (optional, can skip if not needed)
      final zipFilePath = '$folderPath/$zipFileName';
      final zipFile = File(zipFilePath);
      await zipFile.writeAsBytes(decodedBytes);

      // Unzip the file
      final archive = ZipDecoder().decodeBytes(decodedBytes);

      // Map to store filenames and their paths
      final extractedFilesMap = <String, String>{};

      for (final file in archive) {
        final filePath = '$folderPath/${file.name}';
        debugPrint('[saveAndUnzipFile] Extracting: ${file.name} to $filePath');
        if (file.isFile) {
          final outFile = File(filePath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          debugPrint('[saveAndUnzipFile] File extracted: $filePath');

          String fileName = file.name.split("_")[0];

          // add file paths to a map
          extractedFilesMap[fileName] = filePath;
        }
      }

      debugPrint('All files extracted successfully.');

      // Delete the zip file after extraction
      if (zipFile.existsSync()) {
        await zipFile.delete();
        debugPrint('Zip file deleted: $zipFilePath');
      }

      // Return the map of filenames and paths
      return extractedFilesMap;
    } catch (e) {
      debugPrint('Error saving and unzipping file: $e');
      return null; // Return null in case of an error
    }
  }

  Future<Map<String, dynamic>> overlayVoice({
    required String trackUuid,
    required File recordedFile,
    required File instrumentalFile,
    required int recordingStart,
    required int recordingEnd,
  }) async {
    // set overlay voice endpoint
    final String endpoint = 'overlay_voice';

    // Prepare FormData for multipart request
    final formData = FormData.fromMap({
      'trackUuid': trackUuid,
      'recordedFile': await MultipartFile.fromFile(recordedFile.path),
      'instrumentalFile': await MultipartFile.fromFile(instrumentalFile.path),
      'recordingStart': recordingStart,
      'recordingEnd': recordingEnd,
    });

    // Debug formData fields
    debugPrint('formData fields:');
    for (var field in formData.fields) {
      debugPrint('  ${field.key}: ${field.value}');
    }
    debugPrint('formData files:');
    for (var file in formData.files) {
      debugPrint('  ${file.key}: ${file.value.filename}');
    }

    try {
      final response = await apiService.post(endpoint, formData: formData);
      debugPrint(
        'processKaraoke response: $response',
      ); // response is already a Map

      if (response.containsKey('zip_file')) {
        final extractedFiles = await saveAndUnzipFile(
          response['zip_file'],
          response['zip_name'],
          trackUuid,
        );

        debugPrint('processKaraoke response: $extractedFiles');

        Map<String, String> returnedValue = {...?extractedFiles};

        // Use extractedFiles as needed
        return returnedValue;
      } else {
        debugPrint('Response does not contain zip file info.');
        return {};
      }
    } catch (e) {
      debugPrint('Error in processKaraoke: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processKaraoke({
    required String trackUuid,
    required File audioFile,
  }) async {
    final String endpoint = 'karaoke_process';

    // Prepare FormData for multipart request
    final formData = FormData.fromMap({
      'trackUuid': trackUuid,
      'audioFile': await MultipartFile.fromFile(audioFile.path),
    });

    // Debug formData fields
    debugPrint('formData fields:');
    for (var field in formData.fields) {
      debugPrint('  ${field.key}: ${field.value}');
    }
    debugPrint('formData files:');
    for (var file in formData.files) {
      debugPrint('  ${file.key}: ${file.value.filename}');
    }

    // Tạm thời không gửi request, chỉ trả về thông tin debug
    // return {'audioFile': audioFile.path, 'timestampLyrics': timestampLyrics};

    try {
      final response = await apiService.post(endpoint, formData: formData);
      debugPrint(
        'processKaraoke response: $response',
      ); // response is already a Map

      if (response.containsKey('zip_file')) {
        final extractedFiles = await saveAndUnzipFile(
          response['zip_file'],
          response['zip_name'],
          trackUuid,
        );

        debugPrint('processKaraoke response: $extractedFiles');

        Map<String, String> returnedValue = {
          ...?extractedFiles,
          "computed_amplitude": response["computed_amplitude"],
        };

        // Use extractedFiles as needed
        return returnedValue;
      } else {
        debugPrint('Response does not contain zip file info.');
        return {};
      }
    } catch (e) {
      debugPrint('Error in processKaraoke: $e');
      rethrow;
    }
  }
}
