import 'package:flutter/material.dart';

class FunctionBarAction {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final List<FunctionBarAction>? subActions;

  FunctionBarAction({
    required this.label,
    required this.icon,
    this.onTap,
    this.subActions,
  });
}

class CustomFunctionBar extends StatefulWidget {
  final List<FunctionBarAction> actions;
  final VoidCallback? onClose;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomFunctionBar({
    super.key,
    required this.actions,
    this.onClose,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<CustomFunctionBar> createState() => _CustomFunctionBarState();
}

class _CustomFunctionBarState extends State<CustomFunctionBar> {
  int? selectedMainIndex;

  @override
  Widget build(BuildContext context) {
    final showSubActions =
        selectedMainIndex != null &&
        widget.actions[selectedMainIndex!].subActions != null &&
        widget.actions[selectedMainIndex!].subActions!.isNotEmpty;

    final barWidth = MediaQuery.of(context).size.width * 0.95;

    return Center(
      child: Container(
        width: barWidth,
        height: 64,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Theme.of(context).cardColor,
          // borderRadius: BorderRadius.circular(8),
          // border: Border.all(color: widget.borderColor ?? Colors.grey.shade300),
        ),
        child: Row(
          children: [
            // Main/Sub actions chiếm 90% nếu có close, 100% nếu không
            SizedBox(
              width: showSubActions ? barWidth * 0.9 - 12 : barWidth - 12,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (!showSubActions)
                      ...widget.actions.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final action = entry.value;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton.icon(
                            icon: Icon(action.icon),
                            label: Text(action.label),
                            onPressed:
                                action.subActions != null &&
                                        action.subActions!.isNotEmpty
                                    ? () =>
                                        setState(() => selectedMainIndex = idx)
                                    : action.onTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        );
                      }),
                    if (showSubActions)
                      ...widget.actions[selectedMainIndex!].subActions!.map((
                        subAction,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton.icon(
                            icon: Icon(subAction.icon),
                            label: Text(subAction.label),
                            onPressed: subAction.onTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            // Close button chỉ hiện khi showSubActions
            if (showSubActions)
              SizedBox(
                width: barWidth * 0.1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => selectedMainIndex = null);
                      widget.onClose?.call();
                    },
                    tooltip: "Close",
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
