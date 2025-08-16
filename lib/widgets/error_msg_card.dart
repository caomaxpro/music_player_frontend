import 'package:flutter/material.dart';

class ErrorMsgCard extends StatefulWidget {
  final String message;
  final VoidCallback? onDismissed;
  final Duration duration; // Add this line

  const ErrorMsgCard({
    super.key,
    required this.message,
    this.onDismissed,
    this.duration = const Duration(seconds: 3), // Default value
  });

  @override
  State<ErrorMsgCard> createState() => _ErrorMsgCardState();
}

class _ErrorMsgCardState extends State<ErrorMsgCard>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    Future.delayed(widget.duration, () {
      // Use custom duration
      if (mounted) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _visible = false;
            });
            widget.onDismissed?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _visible
        ? FadeTransition(
          opacity: ReverseAnimation(_fadeAnimation),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                // spacing: 8, // Remove this line, Row doesn't have spacing
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    widget.message,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        )
        : const SizedBox.shrink();
  }
}
