import 'ink_stroke.dart';

enum PaperType { blank, lined, dotted, grid }

class NotebookPage {
  final String id;
  PaperType paperType;
  List<InkStroke> strokes;

  NotebookPage({
    required this.id,
    this.paperType = PaperType.lined,
    List<InkStroke>? strokes,
  }) : strokes = strokes ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paperType': paperType.name,
      'strokes': strokes.map((stroke) => stroke.toJson()).toList(),
    };
  }

  factory NotebookPage.fromJson(Map<String, dynamic> json) {
    return NotebookPage(
      id: json['id'] as String,
      paperType: PaperType.values.byName(json['paperType'] as String),
      strokes: (json['strokes'] as List)
          .map(
            (stroke) => InkStroke.fromJson(Map<String, dynamic>.from(stroke)),
          )
          .toList(),
    );
  }
}
