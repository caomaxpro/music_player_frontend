import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const CustomScaffold({
    super.key,
    required this.title,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  static const Color backgroundColor = Color.fromRGBO(49, 49, 49, 1.0);
  static const Color textColor = Color.fromRGBO(229, 229, 229, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBar ??
          AppBar(
            iconTheme: const IconThemeData(color: textColor),
            title: Text(title, style: const TextStyle(color: textColor)),
            backgroundColor: backgroundColor,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
