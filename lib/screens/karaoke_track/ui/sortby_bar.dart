import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/karaoke_track/karaoke_track_state.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_buttons.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_function.dart'
    hide FunctionButton;
import 'package:music_player/screens/karaoke_track/utils/karaoke_track_helper.dart';

class SortByBar extends ConsumerStatefulWidget {
  final VoidCallback? onSortByTitle;
  final VoidCallback? onSortByDate;
  final VoidCallback? onClose;

  const SortByBar({
    super.key,
    this.onSortByTitle,
    this.onSortByDate,
    this.onClose,
  });

  @override
  ConsumerState<SortByBar> createState() => _SortByBarState();
}

class _SortByBarState extends ConsumerState<SortByBar> {
  bool ascendingSortTitle = false;
  bool ascendingDate = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = Colors.white;

    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                FunctionButton(
                  label: 'Sort by title',
                  icon: Icon(
                    ascendingSortTitle
                        ? MaterialCommunityIcons.sort_alphabetical_descending
                        : MaterialCommunityIcons.sort_alphabetical_ascending,
                    color: textColor,
                    size: 22,
                  ),
                  function: KaraokeTrackFunction.sort,
                  onPressed: () {
                    setState(() {
                      ascendingSortTitle = !ascendingSortTitle;
                    });
                    if (widget.onSortByTitle != null) {
                      widget.onSortByTitle!();
                    } else {
                      sortRecordings(
                        ref: ref,
                        field: RecordingSortField.title,
                        ascending: !ascendingSortTitle,
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                FunctionButton(
                  label: 'Sort by date',
                  icon: Icon(
                    ascendingDate
                        ? MaterialCommunityIcons.sort_calendar_descending
                        : MaterialCommunityIcons.sort_calendar_ascending,
                    color: textColor,
                    size: 22,
                  ),
                  function: KaraokeTrackFunction.sort,
                  onPressed: () {
                    setState(() {
                      ascendingDate = !ascendingDate;
                    });
                    if (widget.onSortByDate != null) {
                      widget.onSortByDate!();
                    } else {
                      sortRecordings(
                        ref: ref,
                        field: RecordingSortField.createdDate,
                        ascending: !ascendingDate,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          CloseIconButton(
            onPressed: () {
              ref.read(karaokeTrackProvider.notifier).state = null;
              if (widget.onClose != null) widget.onClose!();
            },
            color: textColor,
          ),
        ],
      ),
    );
  }
}
