import 'package:flutter/material.dart';

class CameraOverlayAnimator extends CustomPainter {
  CameraOverlayAnimator(this._animation) : super(repaint: _animation);

  final Animation<double> _animation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.shortestSide * 0.8,
        height: size.shortestSide * 0.8,
      ),
      const Radius.circular(8),
    );

    const waveAmount = 1;

    if (!_animation.isDismissed) {
      for (int wave = waveAmount - 1; wave >= 0; wave--) {
        roundedRect(canvas, rect, wave + _animation.value, waveAmount, size);
      }
    }
  }

  void roundedRect(
    Canvas canvas,
    RRect rect,
    double animValue,
    int waveAmount,
    Size size,
  ) {
    double opacity = (1.0 - (animValue / waveAmount)).clamp(0.0, 1.0);
    Color color = Color.fromRGBO(255, 255, 255, opacity);

    const pixelMiltiplier = 75;
    final newWidth = rect.width + animValue * pixelMiltiplier;
    final newHeight = rect.height + animValue * pixelMiltiplier;
    final widthIncrease = newWidth / rect.width;
    final heightIncrease = newHeight / rect.height;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: rect.width * widthIncrease,
          height: rect.height * heightIncrease,
        ),
        const Radius.circular(8.0),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
