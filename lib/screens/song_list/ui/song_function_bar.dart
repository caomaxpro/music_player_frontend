import 'package:flutter/material.dart';
import 'package:music_player/widgets/custom_function_bar.dart';

class SongsListFunctionBar extends StatefulWidget {
  const SongsListFunctionBar({super.key});

  @override
  State<SongsListFunctionBar> createState() => _SongsListFunctionBarState();
}

class _SongsListFunctionBarState extends State<SongsListFunctionBar> {
  bool showBar = true;
  String message = 'No action yet';

  @override
  Widget build(BuildContext context) {
    return CustomFunctionBar(
      actions: [
        FunctionBarAction(
          label: 'Delete',
          icon: Icons.delete,
          subActions: [
            FunctionBarAction(
              label: 'Delete All',
              icon: Icons.delete_forever,
              onTap: () => setState(() => message = 'Delete All pressed'),
            ),
            FunctionBarAction(
              label: 'Delete Many',
              icon: Icons.delete_sweep,
              onTap: () => setState(() => message = 'Delete Many pressed'),
            ),
          ],
        ),
        FunctionBarAction(
          label: 'Add',
          icon: Icons.add,
          onTap: () {
            // TODO: Add function here later
          },
        ),
      ],
      onClose: () => setState(() => showBar = false),
    );
  }
}
