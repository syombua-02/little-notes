import 'package:flutter/material.dart';

enum InkTool { pen, pencil, highlighter, eraser }

class InkStroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final InkTool tool;

  InkStroke({
    required this.points,
    required this.color,
    required this.width,
    required this.tool,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((point) {
        return {'x': point.dx, 'y': point.dy};
      }).toList(),
      'color': color.toARGB32(),
      'width': width,
      'tool': tool.name,
    };
  }

  factory InkStroke.fromJson(Map<String, dynamic> json) {
    return InkStroke(
      points: (json['points'] as List).map((point) {
        return Offset(
          (point['x'] as num).toDouble(),
          (point['y'] as num).toDouble(),
        );
      }).toList(),
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
      tool: InkTool.values.byName(json['tool'] as String),
    );
  }
}
