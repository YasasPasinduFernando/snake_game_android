import 'package:flutter/material.dart';

class GameControls extends StatelessWidget {
  final bool isPaused;
  final bool isDarkMode;
  final VoidCallback onPausePressed;
  final VoidCallback onThemeToggle;
  final VoidCallback onRestart;

  const GameControls({
    Key? key,
    required this.isPaused,
    required this.isDarkMode,
    required this.onPausePressed,
    required this.onThemeToggle,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: isPaused ? Icons.play_arrow : Icons.pause,
            onPressed: onPausePressed,
          ),
          _buildControlButton(
            icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
            onPressed: onThemeToggle,
          ),
          _buildControlButton(
            icon: Icons.replay,
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkMode ? Colors.white : Colors.black,
          size: 32,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
