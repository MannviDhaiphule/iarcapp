import 'package:flutter/material.dart';

/// Paints a subtle tactical grid pattern on the screen background.
class TacticalGridPainter extends CustomPainter {
  /// Creates a [TacticalGridPainter].
  const TacticalGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A2A).withValues(alpha: 0.4)
      ..strokeWidth = 0.5;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A full-size tactical grid widget for use as a background layer.
class TacticalGrid extends StatelessWidget {
  /// Creates a [TacticalGrid].
  const TacticalGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: CustomPaint(
        painter: TacticalGridPainter(),
      ),
    );
  }
}
