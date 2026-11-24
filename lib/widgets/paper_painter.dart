import 'package:flutter/material.dart';

import '../models/notebook_page.dart';

class PaperPainter extends CustomPainter {
  final PaperType paperType;

  PaperPainter({required this.paperType});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFDAD4CC)
      ..strokeWidth = 0.7;

    const spacing = 28.0;

    switch (paperType) {
      case PaperType.blank:
        break;

      case PaperType.lined:
        for (double y = spacing; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }

        canvas.drawLine(
          const Offset(40, 0),
          Offset(40, size.height),
          Paint()
            ..color = const Color(0xFFD9A5B3)
            ..strokeWidth = 1,
        );
        break;

      case PaperType.grid:
        for (double y = spacing; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }

        for (double x = spacing; x < size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
        }
        break;

      case PaperType.dotted:
        final dotPaint = Paint()..color = const Color(0xFFC9BFB5);

        for (double x = spacing; x < size.width; x += spacing) {
          for (double y = spacing; y < size.height; y += spacing) {
            canvas.drawCircle(Offset(x, y), 1, dotPaint);
          }
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant PaperPainter oldDelegate) {
    return oldDelegate.paperType != paperType;
  }
}
