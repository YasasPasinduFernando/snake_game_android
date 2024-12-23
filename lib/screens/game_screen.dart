import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/score_display.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_grid.dart';
import '../services/database_helper.dart';
import '../models/score.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
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
  
  late AnimationController _foodAnimationController;
  late Animation<double> _foodAnimation;

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
    final duration = max(80, 250 - (score * 8));
    timer = Timer.periodic(
      Duration(milliseconds: duration),
      (Timer t) {
        if (!isPaused) {
          _moveSnake();
        }
      },
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

      // Wrap around screen edges
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
      } else if (bigFood != null && newHead == bigFood) {
        snake.add(newHead);
        score += 5;
        player.play(AssetSource('audio/eat.mp3'));
        setState(() => bigFood = null);
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
        content: Text('Score: $score\nHigh Score: $highScore'),
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