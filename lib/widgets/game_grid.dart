import 'package:flutter/material.dart';

class GameGrid extends StatelessWidget {
  final int rows;
  final int columns;
  final double gridSize;
  final bool isDarkMode;
  final List<Offset> snake;
  final Offset food;
  final Offset? bigFood;
  final Animation<double> foodAnimation;

  const GameGrid({
    Key? key,
    required this.rows,
    required this.columns,
    required this.gridSize,
    required this.isDarkMode,
    required this.snake,
    required this.food,
    required this.bigFood,
    required this.foodAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: columns * gridSize,
      height: rows * gridSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
            ? [Color(0xFF2D2D2D), Color(0xFF1A1A1A)]
            : [Color(0xFFE8E8E8), Color(0xFFF5F5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Grid lines
            CustomPaint(
              painter: GridPainter(
                rows: rows,
                columns: columns,
                gridSize: gridSize,
                isDarkMode: isDarkMode,
              ),
              size: Size(columns * gridSize, rows * gridSize),
            ),
            // Snake segments
            ...snake.map((segment) => _buildSnakeSegment(segment)),
            // Food
            _buildFood(),
            // Big food
            if (bigFood != null) _buildBigFood(),
          ],
        ),
      ),
    );
  }

  Widget _buildSnakeSegment(Offset position) {
    final isHead = position == snake.last;
    return Positioned(
      left: position.dx * gridSize,
      top: position.dy * gridSize,
      child: Container(
        width: gridSize,
        height: gridSize,
        decoration: BoxDecoration(
          color: isHead ? Colors.greenAccent : Colors.green,
          borderRadius: BorderRadius.circular(
            isHead ? gridSize / 2 : gridSize / 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: isHead ? 10 : 5,
              spreadRadius: isHead ? 2 : 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFood() {
    return AnimatedBuilder(
      animation: foodAnimation,
      builder: (context, child) {
        return Positioned(
          left: food.dx * gridSize,
          top: food.dy * gridSize,
          child: Transform.scale(
            scale: foodAnimation.value,
            child: Container(
              width: gridSize,
              height: gridSize,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBigFood() {
    return Positioned(
      left: bigFood!.dx * gridSize - (gridSize * 0.25),
      top: bigFood!.dy * gridSize - (gridSize * 0.25),
      child: Container(
        width: gridSize * 1.5,
        height: gridSize * 1.5,
        decoration: BoxDecoration(
          color: Colors.purple,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final double gridSize;
  final bool isDarkMode;

  GridPainter({
    required this.rows,
    required this.columns,
    required this.gridSize,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (var i = 0; i <= columns; i++) {
      canvas.drawLine(
        Offset(i * gridSize, 0),
        Offset(i * gridSize, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (var i = 0; i <= rows; i++) {
      canvas.drawLine(
        Offset(0, i * gridSize),
        Offset(size.width, i * gridSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}