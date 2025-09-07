import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_state.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_buttons.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/svg/delete_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class KaraokeTrackFunctionBar extends ConsumerStatefulWidget {
  const KaraokeTrackFunctionBar({super.key});

  @override
  ConsumerState<KaraokeTrackFunctionBar> createState() =>
      _KaraokeTrackFunctionBarState();
}

class _KaraokeTrackFunctionBarState
    extends ConsumerState<KaraokeTrackFunctionBar> {
  @override
  Widget build(BuildContext context) {
    final currentAudioFile = ref.watch(currentAudioFileProvider);

    return SizedBox(
      height: 60,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            FunctionButton(
              label: 'Delete',
              icon: DeleteSvg(
                svgWidth: 18,
                svgHeight: 23,
                viewBoxWidth: 22,
                viewBoxHeight: 26,
                color: Colors.redAccent,
              ),
              function: KaraokeTrackFunction.delete,
            ),

            if (currentAudioFile.recordings.toList().length > 1)
              FunctionButton(
                label: 'Sort',
                icon: Icon(
                  MaterialCommunityIcons.sort,
                  color: Colors.green,
                  size: 24,
                ),
                function: KaraokeTrackFunction.sort,
              ),
          ],
        ),
      ),
    );
  }
}
