import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int rows = 20;
  final int columns = 20;
  final int gridSize = 20;
  List<Offset> snake = [Offset(10, 10)];
  Offset food = Offset(5, 5);
  String direction = 'right';
  int score = 0;
  int highScore = 0;
  bool isDarkMode = true;
  late Timer timer;
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadHighScore();
    startGame();
  }

  void startGame() {
    score = 0;
    snake = [Offset(10, 10)];
    direction = 'right';
    spawnFood();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(
      Duration(milliseconds: max(100, 300 - score * 10)),
      (_) => moveSnake(),
    );
  }

  void spawnFood() {
    final Random random = Random();
    setState(() {
      food = Offset(
        random.nextInt(columns).toDouble(),
        random.nextInt(rows).toDouble(),
      );
    });
  }

  void moveSnake() {
    setState(() {
      final head = snake.last;
      Offset newHead;

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
        default:
          newHead = Offset(head.dx + 1, head.dy);
      }

      if (newHead == food) {
        snake.add(newHead);
        score++;
        timer.cancel();
        startTimer();
        spawnFood();
        player.play(AssetSource('audio/eat.mp3'));
      } else if (snake.contains(newHead) ||
          newHead.dx < 0 ||
          newHead.dy < 0 ||
          newHead.dx >= columns ||
          newHead.dy >= rows) {
        timer.cancel();
        player.play(AssetSource('audio/game_over.mp3'));
        showGameOverDialog();
      } else {
        snake.add(newHead);
        snake.removeAt(0);
      }
    });
  }

  void showGameOverDialog() {
    updateHighScore();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Your score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void updateHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      setState(() {
        highScore = score;
      });
      await prefs.setInt('highScore', highScore);
    }
  }

  void loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0) changeDirection('down');
          if (details.delta.dy < 0) changeDirection('up');
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) changeDirection('right');
          if (details.delta.dx < 0) changeDirection('left');
        },
        child: Center(
          child: Container(
            width: columns * gridSize.toDouble(),
            height: rows * gridSize.toDouble(),
            child: Stack(
              children: [
                for (var pos in snake)
                  Positioned(
                    left: pos.dx * gridSize,
                    top: pos.dy * gridSize,
                    child: Container(
                      width: gridSize.toDouble(),
                      height: gridSize.toDouble(),
                      color: Colors.green,
                    ),
                  ),
                Positioned(
                  left: food.dx * gridSize,
                  top: food.dy * gridSize,
                  child: Container(
                    width: gridSize.toDouble(),
                    height: gridSize.toDouble(),
                    color: Colors.red,
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Text(
                    'Score: $score',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Text(
                    'High Score: $highScore',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void changeDirection(String newDirection) {
    if ((direction == 'up' && newDirection == 'down') ||
        (direction == 'down' && newDirection == 'up') ||
        (direction == 'left' && newDirection == 'right') ||
        (direction == 'right' && newDirection == 'left')) {
      return;
    }
    setState(() {
      direction = newDirection;
    });
  }
}








// Big Food Feature
Offset? bigFood;
int foodEaten = 0;

void spawnBigFood() {
  final random = Random();
  bigFood = Offset(
    random.nextInt(columns).toDouble(),
    random.nextInt(rows).toDouble(),
  );
  Timer(Duration(seconds: 10), () {
    setState(() {
      bigFood = null;
    });
  });
}

void checkBigFoodCollision() {
  if (bigFood != null && snake.last == bigFood) {
    snake.add(snake.last);
    snake.add(snake.last); // Increase size more
    score += 10; // Bigger score
    foodEaten = 0; // Reset counter
    bigFood = null; // Remove big food
  }
}

void moveSnake() {
  // Existing code...
  foodEaten++;
  if (foodEaten == 5) {
    spawnBigFood();
  }
  checkBigFoodCollision();
}
