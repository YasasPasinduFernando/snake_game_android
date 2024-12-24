import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'game_screen.dart';
import 'high_scores_screen.dart';

class MenuScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  
  const MenuScreen({
    Key? key,
    required this.onLocaleChange,
  }) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentDotIndex = 0;
  
  // Add list of supported languages
  final List<({String code, String label})> _supportedLanguages = [
    (code: 'en', label: 'English'),
    (code: 'si', label: 'සිංහල'),
    (code: 'ta', label: 'தமிழ்'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentDotIndex = (_currentDotIndex + 1) % 4;
        });
        _controller.reset();
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Add method to handle language cycling
  void _cycleLanguage(bool forward) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    final currentIndex = _supportedLanguages.indexWhere((lang) => lang.code == currentLocale);
    
    if (currentIndex != -1) {
      int newIndex;
      if (forward) {
        newIndex = (currentIndex + 1) % _supportedLanguages.length;
      } else {
        newIndex = (currentIndex - 1 + _supportedLanguages.length) % _supportedLanguages.length;
      }
      widget.onLocaleChange(Locale(_supportedLanguages[newIndex].code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            // Right to left swipe (negative velocity) -> forward
            // Left to right swipe (positive velocity) -> backward
            _cycleLanguage(details.primaryVelocity! < 0);
          }
        },
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: const Color(0xFF00FF00),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageSelector(),
                  const SizedBox(height: 60),
                  _buildSnakeIcon(),
                  const SizedBox(height: 20),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.gameTitle,
                      style: const TextStyle(
                        color: Color(0xFF00FF00),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  _buildMenuButtons(l10n, context),
                  const SizedBox(height: 40),
                  _buildNokiaFrame(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnakeIcon() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _currentDotIndex == index 
                  ? const Color(0xFF00FF00) 
                  : Colors.transparent,
              border: Border.all(
                color: const Color(0xFF00FF00),
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Color(0xFF00FF00), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _buildLanguageOption('English', 'en'),
                _buildLanguageOption('සිංහල', 'si'),
                _buildLanguageOption('தமிழ்', 'ta'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Fixed-width container for the dark mode button
          SizedBox(
            width: 24,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 15,
                height: 20,
                color: Colors.yellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String text, String code) {
    final isSelected = Localizations.localeOf(context).languageCode == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onLocaleChange(Locale(code)),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00FF00) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.black : const Color(0xFF00FF00),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButtons(AppLocalizations l10n, BuildContext context) {
    final buttonData = [
      ('▶', l10n.startGame, () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => const GameScreen()))),
      ('🏆', l10n.highScores, () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HighScoresScreen(isDarkMode: true)))),
      ('ℹ️', l10n.instructions, () => _showInstructions(context, l10n)),
    ];

    return Column(
      children: buttonData.map((data) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMenuButton(
            icon: data.$1,
            text: data.$2,
            onPressed: data.$3,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuButton({
    required String icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF00FF00), width: 1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00FF00),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Fixed-width container for the yellow accent
          SizedBox(
            width: 24,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 15,
                height: 20,
                color: Colors.yellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNokiaFrame() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF00FF00),
          ),
        ),
      ),
    );
  }

  void _showInstructions(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
        title: Text(
          l10n.instructions,
          style: const TextStyle(color: Color(0xFF00FF00)),
        ),
        content: Text(
          l10n.instructionText,
          style: const TextStyle(color: Color(0xFF00FF00)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF00FF00)),
            ),
          ),
        ],
      ),
    );
  }
}