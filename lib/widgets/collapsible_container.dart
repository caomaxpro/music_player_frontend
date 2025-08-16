import 'package:flutter/material.dart';
import 'package:music_player/screens/create/lyrics/utils/convert_lrc_to_json.dart';

class CollapsibleText extends StatefulWidget {
  final List<Widget>? content;

  const CollapsibleText({super.key, this.content});

  @override
  State<CollapsibleText> createState() => _CollapsibleTextState();
}

class _CollapsibleTextState extends State<CollapsibleText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    Widget contentWidget =
        widget.content != null
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.content!,
            )
            : const SizedBox();

    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            firstChild: SizedBox(
              height: 150,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SingleChildScrollView(child: contentWidget),
                ),
              ),
            ),
            secondChild: contentWidget,
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          SizedBox(
            width: getScreenWidth(context) * .95,
            child: IconButton(
              icon: Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 28,
              ),
              onPressed: () => setState(() => expanded = !expanded),
            ),
          ),
        ],
      ),
    );
  }
}
