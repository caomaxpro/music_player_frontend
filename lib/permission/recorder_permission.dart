import 'package:permission_handler/permission_handler.dart';

Future<void> requestMicPermission() async {
  await Permission.microphone.request();
}
