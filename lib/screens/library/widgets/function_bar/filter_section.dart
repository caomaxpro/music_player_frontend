import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/karaoke_track/ui/karaoke_track_buttons.dart';
import 'package:music_player/screens/library/helper/library_helper.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_text_input.dart';

class FilterSection extends ConsumerStatefulWidget {
  final String? initialTitle;
  final String? initialArtist;
  final bool sortNewestFirst;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onArtistChanged;
  final ValueChanged<bool>? onSortOrderChanged;
  final VoidCallback? onFilter;
  final VoidCallback? onClose;

  const FilterSection({
    super.key,
    this.initialTitle,
    this.initialArtist,
    this.sortNewestFirst = true,
    this.onTitleChanged,
    this.onArtistChanged,
    this.onSortOrderChanged,
    this.onFilter,
    this.onClose,
  });

  @override
  ConsumerState<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends ConsumerState<FilterSection> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late bool _newestFirst;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _artistController = TextEditingController(text: widget.initialArtist ?? '');
    _newestFirst = widget.sortNewestFirst;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = ref.watch(textColorProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 14,
                children: [
                  FunctionButton(
                    label: 'Filter',
                    icon: Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.green, // màu riêng cho Filter
                    ),
                    function: LibraryFunction.filter,
                    onPressed: () {
                      filterSongsByTitle(ref: ref, text: _titleController.text);

                      ref.read(functionProvider.notifier).state = null;
                    },
                  ),

                  CloseIconButton(
                    onPressed: () {
                      ref.read(functionProvider.notifier).state = null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  CustomTextInput(
                    title: 'Title',
                    placeholder: 'Karaoke title ...',
                    backgroundColor: Colors.grey[700]?.withAlpha(120),
                    textColor: textColor,
                    controller: _titleController,
                    width: screenWidth * .88,
                    height: 45,
                    padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                    border: Border(
                      bottom: BorderSide(color: textColor, width: 2),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                    cursorColor: textColor,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
