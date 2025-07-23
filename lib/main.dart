import 'dart:async';
import 'dart:io';
import 'dart:math' as developer;

import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:music_player/screens/karaoke/karaoke.dart';
import 'package:music_player/services/audio_handler.dart';
import 'package:music_player/utils/response_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/music_list/music_list_screen.dart';
import 'screens/music_player/music_player_screen.dart';
import 'screens/playlists/playlists_screen.dart';
import 'objectbox.g.dart';
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

  await initializeAppStorage();

  audioHandler =
      await initAudioService(); // Ensure this completes before running the app

  await initializeObjectBox();

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainTabScreen(),
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

  static const List<Widget> _screens = <Widget>[
    MusicListScreen(),
    PlaylistsScreen(),
    // KaraokeScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.library_music),
      label: 'Music List',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.queue_music), label: 'Playlists'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
