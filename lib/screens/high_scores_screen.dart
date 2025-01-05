import 'package:flutter/material.dart';

class HighScoresScreen extends StatelessWidget {
  final bool isDarkMode;

  const HighScoresScreen({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'High Scores',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Center(
        child: Text(
          'High Scores will be displayed here.',
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
