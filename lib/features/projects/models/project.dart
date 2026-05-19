import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Project {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final DateTime createdAt;

  Project({
    String? id,
    required this.name,
    required this.emoji,
    required this.color,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  static const availableColors = [
    Color(0xFFFF00FF), // neonPink
    Color(0xFF00FFFF), // neonCyan
    Color(0xFFCCFF00), // electricYellow
    Color(0xFF00FF88), // success
    Color(0xFFFFAA00), // warning
    Color(0xFFAA44FF), // purple
  ];

  static const availableEmojis = [
    '🏠', '🚿', '🍳', '🛏️', '🏗️', '🪜',
    '🔨', '🧱', '🪟', '🚪', '🌳', '🔌',
    '💡', '🛁', '🏊', '🧹', '🪣', '🔑',
  ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'color': color.value,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        color: Color(json['color'] as int),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
