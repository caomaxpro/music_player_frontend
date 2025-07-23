import 'package:flutter/material.dart';
import 'package:music_player/widgets/custom_function_bar.dart';

class FunctionBar extends StatefulWidget {
  const FunctionBar({super.key});

  @override
  State<FunctionBar> createState() => _FunctionBarState();
}

class _FunctionBarState extends State<FunctionBar> {
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
              label: 'Delete Many',
              icon: Icons.delete_sweep,
              onTap: () => setState(() => message = 'Delete Many pressed'),
            ),
            FunctionBarAction(
              label: 'Delete All',
              icon: Icons.delete_forever,
              onTap: () => setState(() => message = 'Delete All pressed'),
            ),
          ],
        ),
        FunctionBarAction(
          label: 'Create',
          icon: Icons.add,
          onTap: () => setState(() => message = 'Create pressed'),
        ),
        FunctionBarAction(
          label: 'Edit',
          icon: Icons.edit,
          subActions: [
            FunctionBarAction(
              label: 'Edit Title',
              icon: Icons.title,
              onTap: () => setState(() => message = 'Edit Title pressed'),
            ),
            FunctionBarAction(
              label: 'Edit Content',
              icon: Icons.text_fields,
              onTap: () => setState(() => message = 'Edit Content pressed'),
            ),
          ],
        ),
      ],
      onClose: () => setState(() => showBar = false),
    );
  }
}
