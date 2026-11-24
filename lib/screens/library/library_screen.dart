import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../models/notebook.dart';
import '../../widgets/notebook_cover.dart';
import '../../services/notebook_storage.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String selectedSection = 'My library';
  String searchQuery = '';
  bool sidebarExpanded = true;

  final List<Notebook> notebooks = [
    Notebook(
      id: '1',
      title: 'Network Science',
      subject: 'Study notes',
      coverColor: AppColors.burgundy,
      createdAt: DateTime.now(),
    ),
    Notebook(
      id: '2',
      title: 'Machine Learning',
      subject: 'Study notes',
      coverColor: AppColors.butterYellow,
      createdAt: DateTime.now(),
    ),
    Notebook(
      id: '3',
      title: 'Daily Thoughts',
      subject: 'Personal',
      coverColor: AppColors.dustyRose,
      createdAt: DateTime.now(),
    ),
    Notebook(
      id: '4',
      title: 'Software Engineering',
      subject: 'Study notes',
      coverColor: AppColors.sage,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadNotebooks();
  }

  void loadNotebooks() {
    if (NotebookStorage.hasSavedNotebooks()) {
      final saved = NotebookStorage.loadNotebooks();

      setState(() {
        notebooks
          ..clear()
          ..addAll(saved);
      });
    } else {
      saveNotebooks();
    }
  }

  Future<void> saveNotebooks() async {
    try {
      await NotebookStorage.saveNotebooks(notebooks);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save notebooks: $error')),
      );
    }
  }

  List<Notebook> get filteredNotebooks {
    return notebooks.where((notebook) {
      final query = searchQuery.toLowerCase();

      final matchesSearch =
          notebook.title.toLowerCase().contains(query) ||
          notebook.subject.toLowerCase().contains(query);

      final matchesSection =
          selectedSection != 'Favorites' || notebook.isFavorite;

      return matchesSearch && matchesSection;
    }).toList();
  }

  void showCreateNotebook() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();

    Color selectedColor = AppColors.burgundy;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.ivory,
              title: Text(
                'A new beginning',
                style: GoogleFonts.playfairDisplay(color: AppColors.burgundy),
              ),
              content: SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Give your ideas a little home.',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                      const SizedBox(height: 24),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Notebook title',
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject or category',
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text('Choose a cover color'),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: AppColors.notebookColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color
                                      ? AppColors.chocolate
                                      : AppColors.border,
                                  width: selectedColor == color ? 3 : 1,
                                ),
                              ),
                              child: selectedColor == color
                                  ? Icon(
                                      Icons.check,
                                      color: color.computeLuminance() < 0.35
                                          ? Colors.white
                                          : AppColors.chocolate,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();

                    if (title.isEmpty) return;

                    setState(() {
                      notebooks.add(
                        Notebook(
                          id: const Uuid().v4(),
                          title: title,
                          subject: subjectController.text.trim().isEmpty
                              ? 'Personal'
                              : subjectController.text.trim(),
                          coverColor: selectedColor,
                          createdAt: DateTime.now(),
                        ),
                      );

                      selectedSection = 'My library';
                      searchQuery = '';
                    });
                    saveNotebooks();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Create notebook'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      subjectController.dispose();
    });
  }

  Widget navigationItem(IconData icon, String label) {
    final selected = selectedSection == label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? AppColors.burgundy : AppColors.mutedText,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.burgundy : AppColors.chocolate,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: AppColors.dustyRose.withValues(alpha: 0.20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          setState(() {
            selectedSection = label;
          });
        },
      ),
    );
  }

  Future<void> editNotebook(Notebook notebook) async {
    final titleController = TextEditingController(text: notebook.title);

    final subjectController = TextEditingController(text: notebook.subject);

    Color selectedColor = notebook.coverColor;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.ivory,

              title: Text(
                'Make it yours',
                style: GoogleFonts.playfairDisplay(color: AppColors.burgundy),
              ),

              content: SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'A little change makes it personal.',
                        style: TextStyle(color: AppColors.mutedText),
                      ),

                      const SizedBox(height: 24),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Notebook title',
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject or category',
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text('Cover color'),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: AppColors.notebookColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },

                            child: Container(
                              width: 40,
                              height: 40,

                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color
                                      ? AppColors.chocolate
                                      : AppColors.border,
                                  width: selectedColor == color ? 3 : 1,
                                ),
                              ),

                              child: selectedColor == color
                                  ? Icon(
                                      Icons.check,
                                      color: color.computeLuminance() < 0.35
                                          ? Colors.white
                                          : AppColors.chocolate,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();

                    if (title.isEmpty) return;

                    setState(() {
                      notebook.title = title;

                      notebook.subject = subjectController.text.trim().isEmpty
                          ? 'Personal'
                          : subjectController.text.trim();

                      notebook.coverColor = selectedColor;
                    });

                    saveNotebooks();

                    Navigator.pop(dialogContext);
                  },

                  child: const Text('Save changes'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    subjectController.dispose();
  }

  void duplicateNotebook(Notebook notebook) {
    setState(() {
      notebooks.add(
        Notebook(
          id: const Uuid().v4(),
          title: '${notebook.title} (Copy)',
          subject: notebook.subject,
          coverColor: notebook.coverColor,
          createdAt: DateTime.now(),
          isFavorite: notebook.isFavorite,
        ),
      );
    });

    saveNotebooks();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notebook duplicated successfully.')),
    );
  }

  Future<void> deleteNotebook(Notebook notebook) async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.ivory,

          title: const Text('Delete notebook?'),

          content: Text(
            'Are you sure you want to delete '
            '"${notebook.title}"? '
            'This action cannot be undone.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),

              onPressed: () {
                Navigator.pop(dialogContext, true);
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      notebooks.removeWhere((item) => item.id == notebook.id);
    });

    await saveNotebooks();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Notebook deleted.')));
  }

  void handleNotebookAction(String action, Notebook notebook) {
    switch (action) {
      case 'open':
        openNotebook(notebook);
        break;

      case 'edit':
        editNotebook(notebook);
        break;

      case 'duplicate':
        duplicateNotebook(notebook);
        break;

      case 'favorite':
        setState(() {
          notebook.isFavorite = !notebook.isFavorite;
        });

        saveNotebooks();
        break;

      case 'delete':
        deleteNotebook(notebook);
        break;
    }
  }

  Widget buildSidebar() {
    return Container(
      width: 235,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'little notes.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 30,
              fontStyle: FontStyle.italic,
              color: AppColors.burgundy,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'YOUR PERSONAL STUDY SPACE',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.5,
              color: AppColors.mutedText,
            ),
          ),

          const SizedBox(height: 45),

          navigationItem(Icons.auto_stories_outlined, 'My library'),

          navigationItem(Icons.favorite_border, 'Favorites'),

          const Spacer(),
          const Divider(),

          Text(
            'Make room for beautiful ideas.',
            style: GoogleFonts.caveat(fontSize: 21, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  void openNotebook(Notebook notebook) {
    setState(() {
      notebook.lastOpened = DateTime.now();
    });

    saveNotebooks();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${notebook.title} — writing studio coming next.'),
      ),
    );
  }

  Widget buildLibrary() {
    final visibleNotebooks = filteredNotebooks;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 1100
            ? 5
            : width >= 850
            ? 4
            : width >= 600
            ? 3
            : 2;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A LITTLE SPACE FOR EVERYTHING',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        color: AppColors.mutedText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      selectedSection,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Make room for beautiful ideas.',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Find a notebook...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Wrap(
                      spacing: 20,
                      runSpacing: 15,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Your notebooks',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),

                        ElevatedButton.icon(
                          onPressed: showCreateNotebook,
                          icon: const Icon(Icons.add),
                          label: const Text('New notebook'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${visibleNotebooks.length} notebooks',
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (visibleNotebooks.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No notebooks found.',
                    style: TextStyle(color: AppColors.mutedText),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final notebook = visibleNotebooks[index];

                    return NotebookCover(
                      notebook: notebook,

                      onTap: () => openNotebook(notebook),

                      onMenuSelected: (action) {
                        handleNotebookAction(action, notebook);
                      },

                      onFavorite: () {
                        setState(() {
                          notebook.isFavorite = !notebook.isFavorite;
                        });

                        saveNotebooks();
                      },
                    );
.                  }, childCount: visibleNotebooks.length),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Toggle navigation',
          icon: const Icon(Icons.menu),
          onPressed: () {
            if (wide) {
              setState(() {
                sidebarExpanded = !sidebarExpanded;
              });
            } else {
              showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.auto_stories_outlined),
                          title: const Text('My library'),
                          onTap: () {
                            setState(() {
                              selectedSection = 'My library';
                            });
                            Navigator.pop(sheetContext);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.favorite_border),
                          title: const Text('Favorites'),
                          onTap: () {
                            setState(() {
                              selectedSection = 'Favorites';
                            });
                            Navigator.pop(sheetContext);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),

        title: Text(
          'little notes.',
          style: GoogleFonts.playfairDisplay(
            fontStyle: FontStyle.italic,
            color: AppColors.burgundy,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'New notebook',
            onPressed: showCreateNotebook,
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: Row(
        children: [
          if (wide && sidebarExpanded) buildSidebar(),

          Expanded(child: buildLibrary()),
        ],
      ),
    );
  }
}
