import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/create/audio_file/audio_device.dart';
import 'package:music_player/screens/create/audio_file/audio_google_drive.dart';
import 'package:music_player/screens/create/audio_file/mp3_from_youtube.dart';
import 'package:music_player/screens/storage/file_explorer_screen.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/google_drive_download.dart';
import 'package:music_player/svg/internet_download_svg.dart';

class AudioOptionsScreen extends ConsumerWidget {
  const AudioOptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = ref.watch(textColorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF232226),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Audio File Options',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _OptionButton(
              icon: Icon(Icons.folder, color: textColor),
              label: 'My Device',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AudioDeviceScreen(fileType: AudioFileType.media),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // _OptionButton(
            //   icon: InternetDownloadSvg(
            //     width: 22,
            //     height: 22,
            //     color: textColor,
            //   ),
            //   label: 'Youtube video to MP3',
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => Mp3FromYoutubeScreen(),
            //       ),
            //     );
            //   },
            // ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[700],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
