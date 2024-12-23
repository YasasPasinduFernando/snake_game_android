import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(SnakeGame());

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

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
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    score = 0;
    snake = [Offset(10, 10)];
    direction = 'right';
    spawnFood();
    timer = Timer.periodic(Duration(milliseconds: 300), (_) => moveSnake());
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
        spawnFood();
      } else if (snake.contains(newHead) ||
          newHead.dx < 0 ||
          newHead.dy < 0 ||
          newHead.dx >= columns ||
          newHead.dy >= rows) {
        timer.cancel();
        showGameOverDialog();
      } else {
        snake.add(newHead);
        snake.removeAt(0);
      }
    });
  }

  void showGameOverDialog() {
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

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0) {
            changeDirection('down');
          } else if (details.delta.dy < 0) {
            changeDirection('up');
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) {
            changeDirection('right');
          } else if (details.delta.dx < 0) {
            changeDirection('left');
          }
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
