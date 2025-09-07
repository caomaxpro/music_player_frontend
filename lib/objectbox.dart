// TODO Implement this library.
import 'package:flutter/material.dart';

import 'objectbox.g.dart'; // Generated file
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store);

  static Future<ObjectBox> create() async {
    final dir = await getApplicationDocumentsDirectory();

    debugPrint('ObjectBox database path: ${dir.path}/objectbox');

    // final objectBoxDir = Directory('${dir.path}/objectbox');
    // if (await objectBoxDir.exists()) {
    //   await objectBoxDir.delete(recursive: true);
    // }

    final store = await openStore(directory: dir.path);
    return ObjectBox._create(store);
  }
}
