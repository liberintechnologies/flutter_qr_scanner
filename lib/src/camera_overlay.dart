import 'package:flutter/material.dart';

class CameraOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black.withOpacity(0.5);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRect(
            Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: size.width,
              height: size.height,
            ),
          ),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(size.width / 2, size.height / 2),
                width: size.shortestSide * 0.8,
                height: size.shortestSide * 0.8,
              ),
              const Radius.circular(8),
            ),
          )
          ..close(),
      ),
      paint,
    );

    final paint2 = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.shortestSide * 0.8,
          height: size.shortestSide * 0.8,
        ),
        const Radius.circular(8),
      ),
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
