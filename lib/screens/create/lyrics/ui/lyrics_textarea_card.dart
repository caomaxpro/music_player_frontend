import 'package:flutter/material.dart';
import 'package:music_player/widgets/custom_textarea.dart';
import 'package:music_player/widgets/custom_button_icon.dart';

class LyricsTextareaCard extends StatefulWidget {
  final TextEditingController controller;
  final Color textColor;
  final VoidCallback onSubmit;
  final bool onLoading;
  final VoidCallback? onLoadingDone;

  const LyricsTextareaCard({
    super.key,
    required this.controller,
    required this.textColor,
    required this.onSubmit,
    required this.onLoading,
    this.onLoadingDone,
  });

  @override
  State<LyricsTextareaCard> createState() => _LyricsTextareaCardState();
}

class _LyricsTextareaCardState extends State<LyricsTextareaCard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _heightController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _heightAnimation;

  bool _isFading = false;
  bool _isShrinking = false;
  bool _isProgressing = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _heightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _heightAnimation = Tween<double>(begin: 220, end: 60).animate(
      CurvedAnimation(parent: _heightController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant LyricsTextareaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onLoading && !oldWidget.onLoading) {
      _playFadeThenShrink();
    } else if (!widget.onLoading && oldWidget.onLoading) {
      _resetAnimations();
    }
  }

  void _playFadeThenShrink() async {
    setState(() {
      _isFading = true;
      _isShrinking = false;
      _isProgressing = false;
    });
    await _fadeController.forward();
    setState(() {
      _isFading = false;
      _isShrinking = true;
      _isProgressing = false;
    });
    await _heightController.forward();
    setState(() {
      _isShrinking = false;
      _isProgressing = true;
    });
    await _progressController.forward();
    setState(() {
      _isProgressing = false;
    });
    if (mounted) {
      widget.onLoadingDone?.call();
    }
  }

  void _resetAnimations() {
    _fadeController.reset();
    _heightController.reset();
    _progressController.reset();
    setState(() {
      _isFading = false;
      _isShrinking = false;
      _isProgressing = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _heightController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeController,
        _heightController,
        _progressController,
      ]),
      builder: (context, child) {
        final showRedBar =
            _fadeAnimation.value >= 1.0 && _heightAnimation.value <= 60;
        final maxWidth = MediaQuery.of(context).size.width;
        double redBarWidth =
            showRedBar ? maxWidth * _progressController.value : 0;

        return Container(
          width: double.infinity,
          height: _heightAnimation.value,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: widget.textColor),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Main content with fade
              Opacity(
                opacity: 1.0 - _fadeAnimation.value,
                child:
                    (_fadeAnimation.value < 1.0)
                        ? Column(
                          children: [
                            CustomTextarea(
                              controller: widget.controller,
                              hintText: "Enter lyrics here...",
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: widget.textColor,
                              ),
                              hintTextStyle: TextStyle(
                                fontSize: 16,
                                color: widget.textColor.withAlpha(190),
                              ),
                              padding: const EdgeInsets.only(
                                left: 12,
                                top: 5,
                                right: 10,
                              ),
                              backgroundColor: Colors.transparent,
                              borderRadius: 5,
                              borderWidth: 0,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.only(
                                right: 8,
                                bottom: 5,
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: CustomIconButton(
                                  label: "Submit",
                                  borderWidth: 2,
                                  labelColor: widget.textColor,
                                  onPressed: widget.onSubmit,
                                ),
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
              // Progress bar (red bar)
              if (showRedBar) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 60,
                    width: redBarWidth,
                    color: Colors.grey.withAlpha(190),
                  ),
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Center(
                    child: Text(
                      "Loading...",
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
