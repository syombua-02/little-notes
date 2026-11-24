import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../models/notebook.dart';
import '../../models/notebook_page.dart';
import '../../models/ink_stroke.dart';
import '../../widgets/paper_painter.dart';
import '../../widgets/ink_painter.dart';

class WritingScreen extends StatefulWidget {
  final Notebook notebook;
  final Future<void> Function() onSave;

  const WritingScreen({
    super.key,
    required this.notebook,
    required this.onSave,
  });

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  int currentPageIndex = 0;

  InkTool selectedTool = InkTool.pen;

  Color selectedColor = AppColors.chocolate;

  double penWidth = 3;

  bool stylusOnly = false;
  bool showPages = true;
  bool isSaving = false;
  bool saveFailed = false;

  int? activePointer;
  InkStroke? currentStroke;
  InkTool? activeTool;

  final List<List<InkStroke>> undoHistory = [];
  final List<List<InkStroke>> redoHistory = [];

  final List<Color> inkColors = [
    Colors.black,
    AppColors.chocolate,
    AppColors.burgundy,
    const Color(0xFFD991AA),
    const Color(0xFF53836A),
    const Color(0xFF477C9B),
    const Color(0xFFD3A345),
    const Color(0xFF8059A8),
    const Color(0xFFD94C4C),
  ];

  NotebookPage get currentPage => widget.notebook.pages[currentPageIndex];

  bool get isDrawing => activePointer != null;

  List<InkStroke> copyStrokes() {
    return currentPage.strokes.map((stroke) {
      return InkStroke(
        points: List<Offset>.from(stroke.points),
        color: stroke.color,
        width: stroke.width,
        tool: stroke.tool,
      );
    }).toList();
  }

  void recordHistory() {
    undoHistory.add(copyStrokes());

    if (undoHistory.length > 40) {
      undoHistory.removeAt(0);
    }

    redoHistory.clear();
  }

  Future<void> savePage() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
      saveFailed = false;
    });

    try {
      await widget.onSave();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        saveFailed = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void startDrawing(PointerDownEvent event) {
    if (isDrawing || isSaving) return;

    final isStylus =
        event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus;

    if (stylusOnly && !isStylus) return;

    setState(() {
      activePointer = event.pointer;
      activeTool = selectedTool;

      recordHistory();

      if (activeTool == InkTool.eraser) {
        eraseAt(event.localPosition);
        return;
      }

      currentStroke = InkStroke(
        points: [event.localPosition],
        color: selectedColor,
        width: activeTool == InkTool.highlighter ? penWidth * 5 : penWidth,
        tool: activeTool!,
      );

      currentPage.strokes.add(currentStroke!);
    });
  }

  void continueDrawing(PointerMoveEvent event) {
    if (event.pointer != activePointer) return;

    setState(() {
      if (activeTool == InkTool.eraser) {
        eraseAt(event.localPosition);
      } else {
        currentStroke?.points.add(event.localPosition);
      }
    });
  }

  void finishDrawing(int pointer) {
    if (pointer != activePointer) return;

    setState(() {
      activePointer = null;
      currentStroke = null;
      activeTool = null;
    });

    savePage();
  }

  double distanceToSegment(Offset point, Offset start, Offset end) {
    final segment = end - start;

    final lengthSquared = segment.dx * segment.dx + segment.dy * segment.dy;

    if (lengthSquared == 0) {
      return (point - start).distance;
    }

    final projection =
        ((point.dx - start.dx) * segment.dx +
            (point.dy - start.dy) * segment.dy) /
        lengthSquared;

    final t = projection.clamp(0.0, 1.0).toDouble();

    final closest = start + segment * t;

    return (point - closest).distance;
  }

  void eraseAt(Offset position) {
    currentPage.strokes.removeWhere((stroke) {
      final radius = 12 + stroke.width / 2;

      if (stroke.points.length == 1) {
        return (stroke.points.first - position).distance <= radius;
      }

      for (int i = 1; i < stroke.points.length; i++) {
        if (distanceToSegment(
              position,
              stroke.points[i - 1],
              stroke.points[i],
            ) <=
            radius) {
          return true;
        }
      }

      return false;
    });
  }

  void undo() {
    if (undoHistory.isEmpty || isDrawing || isSaving) {
      return;
    }

    setState(() {
      redoHistory.add(copyStrokes());
      currentPage.strokes = undoHistory.removeLast();
    });

    savePage();
  }

  void redo() {
    if (redoHistory.isEmpty || isDrawing || isSaving) {
      return;
    }

    setState(() {
      undoHistory.add(copyStrokes());
      currentPage.strokes = redoHistory.removeLast();
    });

    savePage();
  }

  void addPage() {
    if (isDrawing || isSaving) return;

    setState(() {
      widget.notebook.pages.add(
        NotebookPage(id: const Uuid().v4(), paperType: currentPage.paperType),
      );

      currentPageIndex = widget.notebook.pages.length - 1;

      undoHistory.clear();
      redoHistory.clear();
    });

    savePage();
  }

  void selectPage(int index) {
    if (isDrawing || isSaving) return;

    setState(() {
      currentPageIndex = index;
      undoHistory.clear();
      redoHistory.clear();
    });
  }

  void changePaper(PaperType type) {
    if (isDrawing || isSaving) return;

    setState(() {
      currentPage.paperType = type;
    });

    savePage();
  }

  Future<void> clearPage() async {
    if (isDrawing || isSaving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear this page?'),
          content: const Text(
            'All handwriting on this page will '
            'be removed. You can undo this change '
            'during this session.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Clear page'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      recordHistory();
      currentPage.strokes.clear();
    });

    savePage();
  }

  Widget toolButton(InkTool tool, IconData icon, String tooltip) {
    final selected = selectedTool == tool;

    return Container(
      decoration: BoxDecoration(
        color: selected
            ? AppColors.dustyRose.withValues(alpha: 0.35)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: isDrawing
            ? null
            : () {
                setState(() {
                  selectedTool = tool;
                });
              },
        icon: Icon(
          icon,
          color: selected ? AppColors.burgundy : AppColors.chocolate,
        ),
      ),
    );
  }

  Widget colorButton(Color color) {
    final selected = selectedColor == color;

    return GestureDetector(
      onTap: () {
        if (isDrawing) return;

        setState(() {
          selectedColor = color;

          if (selectedTool == InkTool.eraser) {
            selectedTool = InkTool.pen;
          }
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.burgundy : AppColors.border,
            width: selected ? 3 : 1,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check,
                size: 16,
                color: color.computeLuminance() < 0.35
                    ? Colors.white
                    : AppColors.chocolate,
              )
            : null,
      ),
    );
  }

  Widget buildToolbar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1049352D),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 5,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              toolButton(InkTool.pen, Icons.edit_outlined, 'Pen'),
              toolButton(InkTool.pencil, Icons.create_outlined, 'Pencil'),
              toolButton(
                InkTool.highlighter,
                Icons.highlight_outlined,
                'Highlighter',
              ),
              toolButton(InkTool.eraser, Icons.auto_fix_normal, 'Eraser'),

              IconButton(
                tooltip: 'Undo',
                onPressed: undoHistory.isEmpty || isDrawing || isSaving
                    ? null
                    : undo,
                icon: const Icon(Icons.undo),
              ),

              IconButton(
                tooltip: 'Redo',
                onPressed: redoHistory.isEmpty || isDrawing || isSaving
                    ? null
                    : redo,
                icon: const Icon(Icons.redo),
              ),

              PopupMenuButton<PaperType>(
                tooltip: 'Paper template',
                icon: const Icon(Icons.grid_on_outlined),
                onSelected: changePaper,
                itemBuilder: (context) {
                  return PaperType.values.map((type) {
                    return PopupMenuItem<PaperType>(
                      value: type,
                      child: Text(
                        '${type.name[0].toUpperCase()}'
                        '${type.name.substring(1)} paper',
                      ),
                    );
                  }).toList();
                },
              ),

              IconButton(
                tooltip: stylusOnly ? 'Allow finger drawing' : 'S Pen only',
                onPressed: isDrawing
                    ? null
                    : () {
                        setState(() {
                          stylusOnly = !stylusOnly;
                        });
                      },
                icon: Icon(
                  stylusOnly ? Icons.draw : Icons.touch_app_outlined,
                  color: stylusOnly ? AppColors.burgundy : AppColors.chocolate,
                ),
              ),

              IconButton(
                tooltip: 'Clear page',
                onPressed: clearPage,
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ],
          ),

          const Divider(),

          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: inkColors.map(colorButton).toList(),
          ),

          Row(
            children: [
              const SizedBox(width: 10),
              const Text('Thickness'),

              Expanded(
                child: Slider(
                  value: penWidth,
                  min: 1,
                  max: 12,
                  divisions: 11,
                  activeColor: AppColors.burgundy,
                  onChanged: isDrawing
                      ? null
                      : (value) {
                          setState(() {
                            penWidth = value;
                          });
                        },
                ),
              ),

              Text('${penWidth.toInt()}'),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPageSidebar() {
    return Container(
      width: 92,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const Text('Pages', style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: widget.notebook.pages.length,
              itemBuilder: (context, index) {
                final page = widget.notebook.pages[index];

                final selected = currentPageIndex == index;

                return GestureDetector(
                  onTap: () => selectPage(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      children: [
                        Container(
                          height: 88,
                          width: 64,
                          decoration: BoxDecoration(
                            color: AppColors.porcelain,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: selected
                                  ? AppColors.burgundy
                                  : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: ClipRect(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: 800,
                                height: 1100,
                                child: CustomPaint(
                                  painter: PaperPainter(
                                    paperType: page.paperType,
                                  ),
                                  foregroundPainter: InkPainter(
                                    strokes: page.strokes,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: selected
                                ? AppColors.burgundy
                                : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          IconButton(
            tooltip: 'Add page',
            onPressed: addPage,
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.burgundy,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const pageWidth = 800.0;
        const pageHeight = 1100.0;

        return Container(
          color: const Color(0xFFEDE8E0),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: constraints.maxWidth - 24,
                  height: constraints.maxHeight - 24,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: pageWidth,
                      height: pageHeight,
                      decoration: const BoxDecoration(
                        color: AppColors.porcelain,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x2049352D),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRect(
                        child: Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: startDrawing,
                          onPointerMove: continueDrawing,
                          onPointerUp: (event) {
                            finishDrawing(event.pointer);
                          },
                          onPointerCancel: (event) {
                            finishDrawing(event.pointer);
                          },
                          child: CustomPaint(
                            painter: PaperPainter(
                              paperType: currentPage.paperType,
                            ),
                            foregroundPainter: InkPainter(
                              strokes: currentPage.strokes,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.notebook.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle page sidebar',
            onPressed: isDrawing
                ? null
                : () {
                    setState(() {
                      showPages = !showPages;
                    });
                  },
            icon: const Icon(Icons.view_sidebar_outlined),
          ),

          IconButton(
            tooltip: 'Save notebook',
            onPressed: isDrawing || isSaving ? null : savePage,
            icon: Icon(
              saveFailed ? Icons.error_outline : Icons.save_outlined,
              color: saveFailed ? Colors.red : AppColors.burgundy,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          buildToolbar(),

          Expanded(
            child: Row(
              children: [
                if (showPages) buildPageSidebar(),

                Expanded(child: buildCanvas()),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Page ${currentPageIndex + 1} '
                  'of ${widget.notebook.pages.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),

                const Spacer(),

                Text(
                  '${currentPage.paperType.name} paper',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),

                const SizedBox(width: 12),

                Icon(
                  saveFailed
                      ? Icons.error_outline
                      : isSaving
                      ? Icons.sync
                      : Icons.check_circle_outline,
                  size: 16,
                  color: saveFailed ? Colors.red : const Color(0xFF53836A),
                ),

                const SizedBox(width: 5),

                Text(
                  saveFailed
                      ? 'Save failed'
                      : isSaving
                      ? 'Saving...'
                      : 'Saved',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
