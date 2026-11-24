import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/notebook.dart';

class NotebookStorage {
  static const String boxName = 'little_notes';
  static const String notebookKey = 'notebooks';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(boxName);
  }

  static Box<String> get box {
    return Hive.box<String>(boxName);
  }

  static bool hasSavedNotebooks() {
    return box.containsKey(notebookKey);
  }

  static Future<void> saveNotebooks(List<Notebook> notebooks) async {
    final data = notebooks.map((notebook) => notebook.toJson()).toList();

    await box.put(notebookKey, jsonEncode(data));
  }

  static List<Notebook> loadNotebooks() {
    final savedData = box.get(notebookKey);

    if (savedData == null) {
      return [];
    }

    final decoded = jsonDecode(savedData) as List;

    return decoded.map((item) {
      return Notebook.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}
