import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Global variable to store the app's storage directory
late Directory appStorageFolder;

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
) async {
  try {
    // Decode the base64 string
    final decodedBytes = base64Decode(base64String);

    // Define the file path for the zip file inside the global app storage folder
    final zipFilePath = '${appStorageFolder.path}/$zipFileName';

    // Write the decoded bytes to the zip file
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(decodedBytes);

    debugPrint('Zip file saved at: $zipFilePath');

    // Unzip the file
    final archive = ZipDecoder().decodeBytes(decodedBytes);

    // Map to store filenames and their paths
    final extractedFilesMap = <String, String>{};

    for (final file in archive) {
      final filePath = '${appStorageFolder.path}/${file.name}';
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
        debugPrint('File extracted: $filePath');
        extractedFilesMap[file.name] =
            filePath; // Add filename and path to the map
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
