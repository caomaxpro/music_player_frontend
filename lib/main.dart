import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/create/audio_file/audio_device.dart';
import 'package:music_player/screens/create/audio_file/audio_media_device.dart';
import 'package:music_player/screens/create/infor/infor_screen.dart';
import 'package:music_player/screens/create/lyrics/audio_text_device.dart';
import 'package:music_player/screens/create/lyrics/lyrics_manually.dart';
import 'package:music_player/screens/karaoke_player/karaoke_player_screen.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_screen.dart';
import 'package:music_player/screens/library/library_screen.dart';
import 'package:music_player/screens/splash/splash_screen.dart';
import 'package:music_player/screens/storage/file_explorer_screen.dart';
import 'package:music_player/services/audio_handler.dart';
import 'package:music_player/screens/karaoke_player/helper/response_handler.dart';
import 'package:music_player/widgets/custom_karaoke_loading.dart';
import 'package:path_provider/path_provider.dart';
import 'objectbox.dart';
import 'state/audio_state.dart';

late AudioHandler audioHandler;
// One-to-Many: Một playlist có thể chứa nhiều bài hát
late ObjectBox objectBox;

Future<void> deleteDatabase() async {
  final appDir = await getApplicationDocumentsDirectory();
  final objectBoxDir = Directory('${appDir.path}/objectbox');

  if (await objectBoxDir.exists()) {
    await objectBoxDir.delete(recursive: true);
    print('ObjectBox database deleted.');
  } else {
    print('ObjectBox database not found.');
  }
}

Future<void> initializeObjectBox() async {
  try {
    objectBox = await ObjectBox.create();
  } catch (e) {
    print("Schema mismatch detected. Flushing database...");
    await deleteDatabase(); // Delete the database manually
    objectBox = await ObjectBox.create();
    print("Database flushed and reinitialized.");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print(details.exceptionAsString());
      print(details.stack);
    }
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Text(
          'Flutter Error:\n${details.exceptionAsString()}',
          style: TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  };

  KaraokeService karaokeService = KaraokeService();

  await karaokeService.initializeAppStorage();

  audioHandler =
      await initAudioService(); // Ensure this completes before running the app

  await initializeObjectBox();

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // SplashScreen()
  // LyricsManuallyScreen()
  // Mp3FromYoutubeScreen()
  // AudioDeviceScreen()
  /*    
      AudioDeviceScreen(
        fileType: AudioFileType.text,
      ) 
      */
  // InforScreen()
  // LyricsOptionsScreen()
  // LibraryScreen()
  // AudioMediaDeviceScreen()

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainTabScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        LibraryScreen.routeName: (context) => LibraryScreen(),
        InforScreen.routeName: (context) => const InforScreen(),
        AudioMediaDeviceScreen.routeName:
            (context) => const AudioMediaDeviceScreen(),
        AudioTextDeviceScreen.routeName:
            (context) => const AudioTextDeviceScreen(),
        KaraokePlayerScreen.routeName: (context) => const KaraokePlayerScreen(),
        LyricsManuallyScreen.routeName:
            (context) => const LyricsManuallyScreen(),
        KaraokeTrackScreen.routeName:
            (context) => const KaraokeTrackScreen(folderPath: ''),
      },
    );
  }
}

class MainTabScreen extends ConsumerStatefulWidget {
  const MainTabScreen({super.key});

  @override
  ConsumerState<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends ConsumerState<MainTabScreen> {
  int _selectedIndex = 0;

  final List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Listen for internet connection changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription
        .cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      // developer.log('Couldn\'t check connectivity status' as num, error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    final hasInternet = result != ConnectivityResult.none;

    // Update Riverpod state dynamically
    ref.read(internetConnectionProvider.notifier).state = hasInternet;
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
  }

  // static const List<Widget> _screens = <Widget>[MusicListScreen()];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.library_music),
      label: 'Music List',
    ),
    // BottomNavigationBarItem(icon: Icon(Icons.queue_music), label: 'Playlists'),
    // BottomNavigationBarItem(
    //   icon: Icon(Icons.mic),
    //   label: 'Karaoke', // Thêm mục Karaoke
    // ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: _screens[_selectedIndex],
  //     bottomNavigationBar: BottomNavigationBar(
  //       items: _navItems,
  //       currentIndex: _selectedIndex,
  //       onTap: _onItemTapped,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(49, 49, 49, 1.0),
        statusBarColor: Color.fromRGBO(49, 49, 49, 1.0),
      ),
    );

    return Scaffold(
      backgroundColor: Color.fromRGBO(49, 49, 49, 1.0),
      body: SizedBox.expand(child: SplashScreen()),
    );
  }
}
