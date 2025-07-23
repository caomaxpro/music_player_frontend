import 'package:flutter/material.dart';
import 'package:music_player/permission/local_storage_permission.dart';
import 'package:music_player/screens/storage/storage_screen.dart';
import 'package:music_player/services/song_handler.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRecentPlaylists() {
    // Placeholder for recent playlists
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder:
            (context, index) => Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text('Playlist ${index + 1}')),
            ),
      ),
    );
  }

  Widget _buildRecentPlaySongs() {
    // Placeholder for recent play songs
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder:
          (context, index) => ListTile(
            leading: const Icon(Icons.music_note),
            title: Text('Song ${index + 1}'),
            subtitle: const Text('Artist name'),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {},
          ),
    );
  }

  Widget _buildStorageFiles() {
    // Placeholder for storage files
    return ListTile(
      leading: const Icon(Icons.folder),
      title: const Text('Local Storage'),
      subtitle: const Text('Browse files on device'),
      onTap: () async {
        debugPrint('Requesting storage permission...');
        bool hasPermission = await requestStoragePermission(context);
        debugPrint('Storage permission granted: $hasPermission');

        if (hasPermission) {
          debugPrint('Navigating to StorageScreen...');
          Navigator.of(
            // ignore: use_build_context_synchronously
            context,
          ).push(MaterialPageRoute(builder: (_) => const StorageScreen()));
        } else {
          debugPrint('Storage permission denied.');
          if (mounted) {
            // Check if widget is still in the tree
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Storage permission is required to access music files',
                ),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildGoogleDrive() {
    // Placeholder for Google Drive
    return ListTile(
      leading: const Icon(Icons.cloud),
      title: const Text('Google Drive'),
      subtitle: const Text('Browse files on Google Drive'),
      onTap: () {
        // TODO: Implement navigation to Google Drive
      },
    );
  }

  Widget _buildCleanDataOption() {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text('Clean Data'),
      subtitle: const Text('Delete all data from ObjectBox'),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm Clean Data'),
                content: const Text(
                  'Are you sure you want to delete all data? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );

        if (confirm == true) {
          final songHandler = SongHandler();
          songHandler.deleteAllSongs(); // Gọi phương thức xóa toàn bộ dữ liệu
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data has been deleted.'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
          debugPrint('All data in ObjectBox has been cleared.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music List')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search music...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            // Recent Playlists
            // _buildSectionTitle('Recent Playlists'),
            _buildRecentPlaylists(),
            // Recent Play Songs
            _buildSectionTitle('Recent Play Songs'),
            _buildRecentPlaySongs(),
            // Storage Files
            _buildSectionTitle('Storage'),
            _buildStorageFiles(),
            _buildGoogleDrive(),
            _buildSectionTitle('Options'),
            _buildCleanDataOption(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
