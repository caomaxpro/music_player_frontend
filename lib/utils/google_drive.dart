// import 'dart:io';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/drive/v3.dart' as ga;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'src/web_wrapper.dart' as web;

// const _scopes = [ga.DriveApi.driveReadonlyScope];

// class GoogleDrive {
//   final GoogleSignIn googleSignIn = GoogleSignIn.instance;

//   unawaited()

//   Future<GoogleSignInAccount?> signIn() async {
//     return await googleSignIn.signIn();
//   }

//   Future<List<ga.File>> listFiles({
//     required GoogleSignInAccount account,
//     required String mimeType, // e.g. 'audio/', 'image/', or exact type
//   }) async {
//     // Get authentication tokens
//     final GoogleSignInAuthentication authData = await account.authentication;
//     final client = auth.authenticatedClient(
//       http.Client(),
//       auth.AccessCredentials(
//         auth.AccessToken(
//           'Bearer',
//           authData.idToken!,
//           DateTime.now().add(const Duration(hours: 1)),
//         ),
//         null,
//         _scopes,
//       ),
//     );
//     final driveApi = ga.DriveApi(client);

//     // Filter files by mimeType (e.g. "mimeType contains 'audio/'")
//     final fileList = await driveApi.files.list(
//       q: "mimeType contains '$mimeType' and trashed = false",
//       $fields: "files(id, name, mimeType, size, webViewLink)",
//       spaces: 'drive',
//     );
//     return fileList.files ?? [];
//   }

//   /// Download file content and save to local, return local file path
//   Future<String> downloadFile({
//     required GoogleSignInAccount account,
//     required String fileId,
//     required String fileName,
//   }) async {
//     final authData = await account.authentication;
//     final client = auth.authenticatedClient(
//       http.Client(),
//       auth.AccessCredentials(
//         auth.AccessToken(
//           'Bearer',
//           authData.idToken!,
//           DateTime.now().add(const Duration(hours: 1)),
//         ),
//         null,
//         [ga.DriveApi.driveReadonlyScope],
//       ),
//     );
//     final driveApi = ga.DriveApi(client);

//     final media =
//         await driveApi.files.get(
//               fileId,
//               downloadOptions: ga.DownloadOptions.fullMedia,
//             )
//             as ga.Media;

//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/$fileName');
//     final sink = file.openWrite();
//     await sink.addStream(media.stream);
//     await sink.close();
//     return file.path;
//   }
// }
