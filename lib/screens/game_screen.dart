import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/score_display.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_grid.dart';
import '../services/database_helper.dart';
import '../models/score.dart';

enum Difficulty { easy, medium, hard }

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class GameControls extends StatelessWidget {
  final bool isPaused;
  final bool isDarkMode;
  final VoidCallback onPausePressed;
  final VoidCallback onThemeToggle;
  final VoidCallback onRestart;
  final VoidCallback onDifficultyChange;
  final Difficulty currentDifficulty;

  const GameControls({
    Key? key,
    required this.isPaused,
    required this.isDarkMode,
    required this.onPausePressed,
    required this.onThemeToggle,
    required this.onRestart,
    required this.onDifficultyChange,
    required this.currentDifficulty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: onPausePressed,
          ),
          IconButton(
            icon: Icon(
              Icons.speed,
              color: _getDifficultyColor(),
            ),
            onPressed: onDifficultyChange,
            tooltip: 'Current: ${currentDifficulty.toString().split('.').last}',
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: onThemeToggle,
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (currentDifficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final int rows = 20;
  final int columns = 20;
  late double gridSize;
  List<Offset> snake = [const Offset(10, 10)];
  Offset food = const Offset(5, 5);
  Offset? bigFood;
  String direction = 'right';
  int score = 0;
  int highScore = 0;
  bool isDarkMode = true;
  bool isPaused = false;
  int foodEaten = 0;
  Timer? timer;
  final AudioPlayer player = AudioPlayer();
  Difficulty difficulty = Difficulty.easy;  // Default to easy
  
  late AnimationController _foodAnimationController;
  late Animation<double> _foodAnimation;

  // Base speed is 300ms for easy, doubles for each difficulty level
  final Map<Difficulty, int> speedSettings = {
    Difficulty.easy: 300,    // Base speed: 300ms
    Difficulty.medium: 150,  // Double speed: 150ms
    Difficulty.hard: 75,     // Quadruple speed: 75ms
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadHighScore();
    _startGame();
  }

  void _setupAnimations() {
    _foodAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _foodAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _foodAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    gridSize = min(screenWidth, screenHeight) / max(rows, columns);
  }

  Future<void> _loadHighScore() async {
    try {
      final scores = await DatabaseHelper.instance.getTopScores(limit: 1);
      if (scores.isNotEmpty) {
        setState(() {
          highScore = scores.first.score;
        });
      }
    } catch (e) {
      debugPrint('Error loading high score: $e');
      setState(() {
        highScore = 0;
      });
    }
  }

  void _startGame() {
    timer?.cancel();
    setState(() {
      snake = [const Offset(10, 10)];
      direction = 'right';
      score = 0;
      foodEaten = 0;
      isPaused = false;
      _spawnFood();
    });
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    // Get base speed from difficulty setting
    final baseSpeed = speedSettings[difficulty]!;
    // Increase speed with score, but maintain the relative difficulty differences
    final speedIncrease = (score * 2); // Small increase per score
    final duration = max(30, baseSpeed - speedIncrease); // Minimum 30ms to keep game playable
    
    timer = Timer.periodic(
      Duration(milliseconds: duration),
      (Timer t) {
        if (!isPaused) {
          _moveSnake();
        }
      },
    );
  }

  void _changeDifficulty(Difficulty newDifficulty) {
    setState(() {
      difficulty = newDifficulty;
      if (!isPaused) {
        _startTimer();  // Restart timer with new speed
      }
    });
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Difficulty'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'EASY (${speedSettings[Difficulty.easy]}ms)',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              selected: difficulty == Difficulty.easy,
              leading: const Icon(Icons.speed, color: Colors.green),
              onTap: () {
                _changeDifficulty(Difficulty.easy);
                Navigator.pop(context);
                _startGame();
              },
            ),
            ListTile(
              title: Text(
                'MEDIUM (${speedSettings[Difficulty.medium]}ms)',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              selected: difficulty == Difficulty.medium,
              leading: const Icon(Icons.speed, color: Colors.orange),
              onTap: () {
                _changeDifficulty(Difficulty.medium);
                Navigator.pop(context);
                _startGame();
              },
            ),
            ListTile(
              title: Text(
                'HARD (${speedSettings[Difficulty.hard]}ms)',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              selected: difficulty == Difficulty.hard,
              leading: const Icon(Icons.speed, color: Colors.red),
              onTap: () {
                _changeDifficulty(Difficulty.hard);
                Navigator.pop(context);
                _startGame();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _spawnFood() {
    final random = Random();
    bool validPosition;
    do {
      food = Offset(
        random.nextInt(columns).toDouble(),
        random.nextInt(rows).toDouble(),
      );
      validPosition = !snake.contains(food);
    } while (!validPosition);

    foodEaten++;
    if (foodEaten % 5 == 0) {
      _spawnBigFood();
    }
  }

  void _spawnBigFood() {
    final random = Random();
    bool validPosition;
    do {
      bigFood = Offset(
        random.nextInt(columns).toDouble(),
        random.nextInt(rows).toDouble(),
      );
      validPosition = !snake.contains(bigFood!);
    } while (!validPosition);

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => bigFood = null);
      }
    });
  }

  void _moveSnake() {
    if (isPaused) return;

    setState(() {
      final head = snake.last;
      late Offset newHead;

      switch (direction) {
        case 'up':
          newHead = Offset(head.dx, head.dy - 1);
          break;
        case 'down':
          newHead = Offset(head.dx, head.dy + 1);
          break;
        case 'left':
          newHead = Offset(head.dx - 1, head.dy);
          break;
        case 'right':
          newHead = Offset(head.dx + 1, head.dy);
          break;
      }

      newHead = Offset(
        newHead.dx < 0 ? columns - 1 : (newHead.dx >= columns ? 0 : newHead.dx),
        newHead.dy < 0 ? rows - 1 : (newHead.dy >= rows ? 0 : newHead.dy),
      );

      if (snake.contains(newHead)) {
        _gameOver();
        return;
      }

      if (newHead == food) {
        snake.add(newHead);
        score++;
        player.play(AssetSource('audio/eat.mp3'));
        _spawnFood();
        _startTimer(); // Update speed when score changes
      } else if (bigFood != null && newHead == bigFood) {
        snake.add(newHead);
        score += 5;
        player.play(AssetSource('audio/eat.mp3'));
        setState(() => bigFood = null);
        _startTimer(); // Update speed when score changes
      } else {
        snake.add(newHead);
        snake.removeAt(0);
      }
    });
  }

  void _gameOver() {
    timer?.cancel();
    player.play(AssetSource('audio/game_over.mp3'));
    if (score > highScore) {
      highScore = score;
      DatabaseHelper.instance.insertScore(Score(
        score: score,
        date: DateTime.now().toIso8601String(),
      ));
    }
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: $score'),
            Text('High Score: $highScore'),
            Text('Difficulty: ${difficulty.toString().split('.').last}'),
          ],
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 18,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDifficultyDialog();
            },
            child: const Text(
              'Change Difficulty',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text(
              'Play Again',
              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ScoreDisplay(
              score: score,
              highScore: highScore,
              isDarkMode: isDarkMode,
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 && direction != 'up') {
                      setState(() => direction = 'down');
                    } else if (details.delta.dy < 0 && direction != 'down') {
                      setState(() => direction = 'up');
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 && direction != 'left') {
                      setState(() => direction = 'right');
                    } else if (details.delta.dx < 0 && direction != 'right') {
                      setState(() => direction = 'left');
                    }
                  },
                  child: GameGrid(
                    rows: rows,
                    columns: columns,
                    gridSize: gridSize,
                    isDarkMode: isDarkMode,
                    snake: snake,
                    food: food,
                    bigFood: bigFood,
                    foodAnimation: _foodAnimation,
                  ),
                ),
              ),
            ),
            GameControls(
              isPaused: isPaused,
              isDarkMode: isDarkMode,
              currentDifficulty: difficulty,
              onPausePressed: () {
                setState(() {
                  isPaused = !isPaused;
                  if (isPaused) {
                    timer?.cancel();
                  } else {
                    _startTimer();
                  }
                });
              },
              onThemeToggle: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
              onRestart: _startGame,
              onDifficultyChange: _showDifficultyDialog,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _foodAnimationController.dispose();
    player.dispose();
    super.dispose();
  }
}