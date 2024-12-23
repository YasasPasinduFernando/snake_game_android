import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int highScore;
  final bool isDarkMode;

  const ScoreDisplay({
    Key? key,
    required this.score,
    required this.highScore,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildScoreBox('Score: $score', Colors.green),
          _buildScoreBox('High Score: $highScore', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildScoreBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? Colors.white : color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}