import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/screens/create/infor/infor_screen.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_screen.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_buttons.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/services/song_handler.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/custom_svg.dart';
import 'package:music_player/svg/delete_svg.dart';
import 'package:music_player/svg/microphone_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class FunctionBar extends ConsumerStatefulWidget {
  const FunctionBar({super.key});

  @override
  ConsumerState<FunctionBar> createState() => _FunctionBarState();
}

class _FunctionBarState extends ConsumerState<FunctionBar> {
  @override
  Widget build(BuildContext context) {
    final audioFiles = ref.watch(audioFilesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 60,
        child: Row(
          spacing: 8,
          children: [
            FunctionButton(
              label: 'Delete',
              icon: CustomSvg(
                rawSvg: deleteSvgString,
                svgHeight: 18,
                viewBoxHeight: 24,
                color: Colors.redAccent, // màu riêng cho Delete
              ),
              function: LibraryFunction.delete,
              onPressed: () {
                ref.read(functionProvider.notifier).state =
                    LibraryFunction.delete;
              },
            ),
            if (audioFiles.length > 1) ...[
              FunctionButton(
                label: 'Sort',
                icon: Icon(
                  Icons.sort_by_alpha_sharp,
                  color: Colors.blueAccent, // màu riêng cho Sort
                ),
                function: LibraryFunction.sort,
                onPressed: () {
                  ref.read(functionProvider.notifier).state =
                      LibraryFunction.sort;
                },
              ),
              FunctionButton(
                label: 'Filter',
                icon: Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.green, // màu riêng cho Filter
                ),
                function: LibraryFunction.filter,
                onPressed: () {
                  ref.read(functionProvider.notifier).state =
                      LibraryFunction.filter;
                },
              ),
            ],
            // FunctionButton(
            //   label: 'Edit',
            //   icon: Icon(
            //     Icons.edit,
            //     color: Colors.orangeAccent, // màu riêng cho Edit
            //   ),
            //   function: LibraryFunction.edit,
            //   onPressed: () {
            //     ref.read(functionProvider.notifier).state =
            //         LibraryFunction.edit;
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
