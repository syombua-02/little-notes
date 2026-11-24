import 'package:flutter/material.dart';

import '../models/ink_stroke.dart';

class InkPainter extends CustomPainter {
  final List<InkStroke> strokes;

  InkPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      double opacity = 1;

      if (stroke.tool == InkTool.highlighter) {
        opacity = 0.30;
      }

      if (stroke.tool == InkTool.pencil) {
        opacity = 0.65;
      }

      final paint = Paint()
        ..color = stroke.color.withValues(alpha: opacity)
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      final points = stroke.points;

      if (points.length == 1) {
        canvas.drawCircle(
          points.first,
          stroke.width / 2,
          Paint()
            ..color = paint.color
            ..isAntiAlias = true,
        );

        continue;
      }

      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        final previous = points[i - 1];
        final current = points[i];

        final midpoint = Offset(
          (previous.dx + current.dx) / 2,
          (previous.dy + current.dy) / 2,
        );

        path.quadraticBezierTo(
          previous.dx,
          previous.dy,
          midpoint.dx,
          midpoint.dy,
        );
      }

      path.lineTo(points.last.dx, points.last.dy);

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InkPainter oldDelegate) {
    return true;
  }
}
