import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/library/state/library_state.dart';
import 'package:music_player/screens/library/ui/sortby_bar.dart';
import 'package:music_player/state/setting_state.dart';
import 'package:music_player/widgets/custom_button_icon.dart';
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 14,
            children: [
              CustomIconButton(
                label: 'Filter',
                icon: const Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                horizontalPadding: 10,
                borderWidth: 2,
                onPressed: widget.onFilter,
                labelColor: textColor,
              ),
              CloseIconButton(
                onPressed: () {
                  ref.read(functionProvider.notifier).state = null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextInput(
            title: 'Title',
            placeholder: 'Title...',
            textColor: textColor,
            controller: _titleController,
            backgroundColor: Colors.transparent,
            titleStyle: TextStyle(color: textColor, fontSize: 16),
          ),
          const SizedBox(height: 16),
          CustomTextInput(
            title: 'Artist',
            placeholder: 'Artist...',
            textColor: textColor,
            controller: _artistController,
            backgroundColor: Colors.transparent,
            titleStyle: TextStyle(color: textColor, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            'Created Date',
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _newestFirst,
                onChanged: (value) {
                  setState(() {
                    _newestFirst = value!;
                  });
                  if (widget.onSortOrderChanged != null) {
                    widget.onSortOrderChanged!(_newestFirst);
                  }
                },
                activeColor: textColor,
              ),
              Text(
                'Newest to Oldest',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ],
          ),
          Row(
            children: [
              Radio<bool>(
                value: false,
                groupValue: _newestFirst,
                onChanged: (value) {
                  setState(() {
                    _newestFirst = value!;
                  });
                  if (widget.onSortOrderChanged != null) {
                    widget.onSortOrderChanged!(_newestFirst);
                  }
                },
                activeColor: textColor,
              ),
              Text(
                'Oldest to Newest',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
