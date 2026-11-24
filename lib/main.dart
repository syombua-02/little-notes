import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'screens/library/library_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: LittleNotesApp()));
}
-.
class LittleNotesApp extends StatelessWidget {
  const LittleNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Little Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LibraryScreen(),
    );
  }
}
