import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'notebook_page.dart';

class Notebook {
  final String id;
  String title;
  String subject;
  Color coverColor;
  final DateTime createdAt;

  DateTime? lastOpened;
  bool isFavorite;

  List<NotebookPage> pages;

  Notebook({
    required this.id,
    required this.title,
    required this.subject,
    required this.coverColor,
    required this.createdAt,
    this.lastOpened,
    this.isFavorite = false,
    List<NotebookPage>? pages,
  }) : pages = pages == null || pages.isEmpty
           ? [NotebookPage(id: const Uuid().v4())]
           : pages;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'coverColor': coverColor.toARGB32(),
      'createdAt': createdAt.toIso8601String(),
      'lastOpened': lastOpened?.toIso8601String(),
      'isFavorite': isFavorite,
      'pages': pages.map((page) => page.toJson()).toList(),
    };
  }

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      coverColor: Color(json['coverColor'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastOpened: json['lastOpened'] == null
          ? null
          : DateTime.parse(json['lastOpened'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      pages: (json['pages'] as List?)
          ?.map(
            (page) => NotebookPage.fromJson(Map<String, dynamic>.from(page)),
          )
          .toList(),
    );
  }
}
