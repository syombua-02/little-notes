import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/notebook.dart';
import '../core/constants/app_colors.dart';

class NotebookCover extends StatelessWidget {
  final Notebook notebook;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final ValueChanged<String> onMenuSelected;
  const NotebookCover({
    super.key,
    required this.notebook,
    required this.onTap,
    required this.onFavorite,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = notebook.coverColor.computeLuminance() < 0.35;

    final inkColor = isDark ? AppColors.ivory : AppColors.chocolate;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: notebook.coverColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2049352D),
                    blurRadius: 10,
                    offset: Offset(4, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 22,
                    right: 14,
                    top: 14,
                    bottom: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: inkColor.withValues(alpha: 0.35),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_outlined, color: inkColor, size: 30),
                          const SizedBox(height: 16),

                          Text(
                            notebook.title,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              color: inkColor,
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(width: 30, height: 1, color: inkColor),

                          const SizedBox(height: 10),

                          Text(
                            notebook.subject.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: inkColor,
                              fontSize: 9,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    right: 4,
                    top: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Favorite',
                          onPressed: onFavorite,
                          icon: Icon(
                            notebook.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: inkColor,
                            size: 20,
                          ),
                        ),

                        PopupMenuButton<String>(
                          tooltip: 'Notebook options',
                          icon: Icon(
                            Icons.more_vert,
                            color: inkColor,
                            size: 20,
                          ),
                          color: AppColors.ivory,
                          onSelected: onMenuSelected,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'open',
                              child: Row(
                                children: [
                                  Icon(Icons.menu_book_outlined),
                                  SizedBox(width: 12),
                                  Text('Open notebook'),
                                ],
                              ),
                            ),

                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: 12),
                                  Text('Edit notebook'),
                                ],
                              ),
                            ),

                            const PopupMenuItem(
                              value: 'duplicate',
                              child: Row(
                                children: [
                                  Icon(Icons.copy_outlined),
                                  SizedBox(width: 12),
                                  Text('Duplicate'),
                                ],
                              ),
                            ),

                            PopupMenuItem(
                              value: 'favorite',
                              child: Row(
                                children: [
                                  Icon(
                                    notebook.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    notebook.isFavorite
                                        ? 'Remove from favorites'
                                        : 'Add to favorites',
                                  ),
                                ],
                              ),
                            ),

                            const PopupMenuDivider(),

                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text(
                                    'Delete notebook',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            notebook.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),

          Text(
            notebook.subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
