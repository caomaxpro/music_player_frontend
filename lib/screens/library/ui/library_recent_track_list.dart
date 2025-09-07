import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/setting_state.dart';

class RecentTracksSection extends ConsumerStatefulWidget {
  const RecentTracksSection({super.key});

  @override
  ConsumerState<RecentTracksSection> createState() =>
      _RecentTracksSectionState();
}

class _RecentTracksSectionState extends ConsumerState<RecentTracksSection> {
  @override
  Widget build(BuildContext context) {
    final bgColor = ref.read(bgColorProvider);

    final tracks = ref.watch(audioFilesProvider);

    final sortedTracks = [...tracks]
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));

    final recentTracks =
        sortedTracks.length > 4 ? sortedTracks.sublist(0, 4) : sortedTracks;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recently Created Tracks',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70, // slightly larger than item height for padding
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recentTracks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder:
                  (context, index) => Container(
                    width: 100,
                    height: 60,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      image:
                          recentTracks[index].imagePath.isNotEmpty
                              ? DecorationImage(
                                image: FileImage(
                                  File(recentTracks[index].imagePath),
                                ),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      color: Colors.black.withAlpha(150),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        recentTracks[index].title,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 0,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
