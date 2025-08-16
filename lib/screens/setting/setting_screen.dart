import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Audio Settings'),
              subtitle: const Text('Manage audio preferences'),
              onTap: () {
                // Navigate to audio settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theme Settings'),
              subtitle: const Text('Customize app appearance'),
              onTap: () {
                // Navigate to theme settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: const Text('Learn more about the app'),
              onTap: () {
                // Navigate to about screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
