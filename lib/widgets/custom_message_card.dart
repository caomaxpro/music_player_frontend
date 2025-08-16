import 'package:flutter/material.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

enum MessageType { success, warning, error, info }

class CustomMessageCard extends StatefulWidget {
  final String message;
  final MessageType type;
  final VoidCallback? onDismissed;
  final Duration duration;

  const CustomMessageCard({
    super.key,
    required this.message,
    this.type = MessageType.info,
    this.onDismissed,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<CustomMessageCard> createState() => _CustomMessageCardState();
}

class _CustomMessageCardState extends State<CustomMessageCard>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Color get _borderColor {
    switch (widget.type) {
      case MessageType.success:
        return Colors.green;
      case MessageType.warning:
        return Colors.orange;
      case MessageType.error:
        return Colors.red;
      case MessageType.info:
      default:
        return Colors.blue;
    }
  }

  IconData get _iconData {
    switch (widget.type) {
      case MessageType.success:
        return Icons.check_circle_rounded;
      case MessageType.warning:
        return Icons.warning_amber_rounded;
      case MessageType.error:
        return Icons.error_rounded;
      case MessageType.info:
      default:
        return Icons.info_rounded;
    }
  }

  Color get _iconColor => _borderColor;

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
    if (widget.message.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _visible
        ? FadeTransition(
          opacity: ReverseAnimation(_fadeAnimation),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: _borderColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(_iconData, color: _iconColor),
                      const SizedBox(width: 8),
                      Text(
                        switch (widget.type) {
                          MessageType.success => "Success",
                          MessageType.warning => "Warning",
                          MessageType.error => "Error",
                          MessageType.info => "Info",
                        },
                        style: TextStyle(
                          color: _iconColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      CustomIconButton(
                        icon: Icon(Icons.close, color: _iconColor, size: 16),
                        borderWidth: 2,
                        verticalPadding: 0,
                        horizontalPadding: 0,
                        width: 24,
                        height: 24,
                        borderRadius: 50,
                        borderColor: _iconColor,
                        onPressed: () {
                          _fadeController.forward();
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              setState(() {
                                _visible = false;
                              });
                              widget.onDismissed?.call();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(color: _iconColor, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        : const SizedBox.shrink();
  }
}
