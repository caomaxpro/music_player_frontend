import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/create/infor/infor_screen.dart';
import 'package:music_player/screens/create/set_karaoke_button.dart';
import 'package:music_player/screens/library/ui/all_tracks.dart';
import 'package:music_player/screens/library/ui/delete_many_bar.dart';
import 'package:music_player/screens/library/ui/recent_tracks.dart';
import 'package:music_player/state/create_state.dart';
import 'package:music_player/svg/microphone_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  // ignore: prefer_typing_uninitialized_variables
  late bool allTrackSectionExpanded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF313131),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.headphones, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Karaoke Tracks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child:
                  allTrackSectionExpanded
                      ? const SizedBox.shrink()
                      : AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SizedBox(height: 24),
                            RecentTracksSection(),
                          ],
                        ),
                      ),
            ),

            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AllTracksSection(
                  expanded: allTrackSectionExpanded,
                  onExpandChanged: (expanded) {
                    setState(() {
                      allTrackSectionExpanded = expanded;
                    });
                  },
                ),
              ),
            ),

            Container(
              alignment: Alignment.center,
              child: CustomIconButton(
                borderWidth: 2,
                height: 40,
                width: MediaQuery.of(context).size.width * 0.9,
                // horizontalPadding: 10,
                borderRadius: 12,
                backgroundColor: Colors.grey[600],
                onPressed: () {
                  ref.read(createStateProvider.notifier).state =
                      CreateState.infor;
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: 'Create Karaoke Track',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
