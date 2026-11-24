import 'package:flutter/material.dart';

class Notebook {
  final String id;
  final String title;
  final String subject;
  final Color coverColor;
  final DateTime createdAt;

  bool isFavorite;

  Notebook({
    required this.id,
    required this.title,
    required this.subject,
    required this.coverColor,
    required this.createdAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'coverColor': coverColor.toARGB32(),
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      coverColor: Color(json['coverColor'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
