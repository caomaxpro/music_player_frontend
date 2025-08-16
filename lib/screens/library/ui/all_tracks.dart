import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/screens/library/ui/delete_bar.dart';
import 'package:music_player/screens/library/ui/delete_many_bar.dart';
import 'package:music_player/screens/library/ui/filter_section.dart';
import 'package:music_player/screens/library/ui/sortby_bar.dart';
import 'package:music_player/state/audio_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/svg/delete_svg.dart';
import 'package:music_player/svg/microphone_svg.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
import 'package:music_player/widgets/custom_loading_button.dart';

typedef ToggleSectionCallback = void Function(bool expanded);

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
      child: Row(
        spacing: 8,
        children: [
          CustomIconButton(
            label: 'Delete',
            icon: DeleteSvg(width: 24, height: 24),
            onPressed: () {
              ref.read(functionProvider.notifier).state =
                  LibraryFunction.delete;
            },
            horizontalPadding: 10,
          ),
          CustomIconButton(
            label: 'Sort',
            icon: Icon(Icons.sort_by_alpha_sharp),
            onPressed: () {
              // Implement sort logic using Riverpod state
              ref.read(functionProvider.notifier).state = LibraryFunction.sort;
            },
            horizontalPadding: 10,
          ),
          CustomIconButton(
            label: 'Filter',
            icon: Icon(Icons.filter_alt_outlined),
            onPressed: () {
              // Implement filter logic using Riverpod state
              ref.read(functionProvider.notifier).state =
                  LibraryFunction.filter;
            },
            horizontalPadding: 10,
          ),
          CustomIconButton(
            label: 'Edit',
            icon: Icon(Icons.edit),
            onPressed: () {
              // Implement filter logic using Riverpod state
              ref.read(functionProvider.notifier).state = LibraryFunction.edit;
            },
            horizontalPadding: 10,
          ),
          // CustomIconButton(
          //   label: 'Edit',
          //   icon: Icon(Icons.edit),
          //   onPressed: () {
          //     // Implement filter logic using Riverpod state
          //   },
          //   horizontalPadding: 10,
          // ),
        ],
      ),
    );
  }
}

class TracksList extends ConsumerWidget {
  final int itemCount;
  final void Function(int index)? onMicrophoneTap;

  const TracksList({super.key, required this.itemCount, this.onMicrophoneTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final function = ref.watch(functionProvider);

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              alignment: Alignment.center,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Row(
                children: [
                  // Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Title', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Artist', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  // Microphone button
                  CustomIconButton(
                    // verticalPadding: 10,
                    icon:
                        function == LibraryFunction.deleteMany
                            ? const Icon(
                              Icons.check_box_outline_blank,
                              color: Colors.white70,
                              size: 24,
                            )
                            : function == LibraryFunction.edit
                            ? const Icon(
                              Icons.edit,
                              color: Colors.white70,
                              size: 24,
                            )
                            : MicrophoneSvg(
                              svgWidth: 24,
                              svgHeight: 24,
                              color: Colors.white70,
                            ),
                    backgroundColor:
                        function == LibraryFunction.deleteMany
                            ? Colors.transparent
                            : Colors.grey[600],
                    height: 40,
                    width: 40,
                    borderWidth: function == LibraryFunction.deleteMany ? 0 : 2,
                    borderRadius: 20,
                    onPressed: () {
                      if (onMicrophoneTap != null) {
                        onMicrophoneTap!(index);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class AllTracksSection extends ConsumerStatefulWidget {
  final bool expanded;
  final ToggleSectionCallback? onExpandChanged;

  const AllTracksSection({
    super.key,
    this.expanded = true,
    this.onExpandChanged,
  });

  @override
  ConsumerState<AllTracksSection> createState() => _AllTracksSectionState();
}

class _AllTracksSectionState extends ConsumerState<AllTracksSection> {
  bool _hideContent = false;

  @override
  void didUpdateWidget(covariant AllTracksSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.expanded && oldWidget.expanded) {
      // Start hiding content when collapsing
      setState(() {
        _hideContent = true;
      });
    }
    if (widget.expanded && !oldWidget.expanded) {
      // Show content immediately when expanding
      setState(() {
        _hideContent = false;
      });
    }
  }

  void _handleOpacityEnd() {
    if (_hideContent && !widget.expanded) {
      // After fade out, trigger collapse
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = ref.read(textColorProvider);
    final function = ref.watch(functionProvider);

    // Tính toán lại chiều cao còn lại cho TrackList khi KHÔNG dùng SingleChildScrollView
    // headerHeight là tổng chiều cao các widget phía trên TrackList (header, padding, ...)
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    // Ví dụ: header (logo + title + padding) ~ 120, các SizedBox ~ 48, button ~ 56
    final double headerHeight =
        306 - 45; // Tổng chiều cao các widget phía trên TrackList
    final double bottomButtonHeight = 60; // Chiều cao dành cho button phía dưới

    double trackListHeight;
    if (widget.expanded) {
      trackListHeight =
          screenHeight -
          topPadding -
          bottomPadding -
          headerHeight -
          bottomButtonHeight;
      if (trackListHeight < 200) trackListHeight = 200;
    } else {
      trackListHeight = 300;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Tracks',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                CustomIconButton(
                  onPressed:
                      widget.onExpandChanged != null
                          ? () => widget.onExpandChanged!(!widget.expanded)
                          : null,
                  icon: Icon(
                    widget.expanded
                        ? Icons.keyboard_arrow_down_outlined
                        : Icons.dashboard_outlined,
                    color: textColor,
                    size: widget.expanded ? 22 : 20,
                  ),
                  textFirst: true,
                  height: 30,
                  width: 30,
                  borderRadius: 50,
                  borderWidth: 2,
                  horizontalPadding: 2,
                  verticalPadding: 2,
                ),
              ],
            ),
            if (widget.expanded)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      constraints.maxHeight -
                      30, // 30 là chiều cao Row tiêu đề, điều chỉnh nếu cần
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      if (function == null) FunctionBar(),
                      if (function == LibraryFunction.edit) FunctionBar(),
                      if (function == LibraryFunction.delete) DeleteBar(),
                      if (function == LibraryFunction.sort) SortByBar(),
                      if (function == LibraryFunction.filter) FilterSection(),
                      if (function == LibraryFunction.deleteMany)
                        DeleteSingleBar(itemCount: 10),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (function != LibraryFunction.filter)
              SizedBox(
                height: trackListHeight,
                child: TracksList(itemCount: 10, onMicrophoneTap: (index) {}),
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label),
    );
  }
}
