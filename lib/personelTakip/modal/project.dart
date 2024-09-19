import 'package:MagicERP/personelTakip/modal/task.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Project {
  final int id;
  final String name;
  final double progress;
  final String ownerName;
  final List<Task> tasks;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.progress,
    required this.ownerName,
    required this.tasks,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      progress: (json['progress'] ?? 0.0).toDouble(),
      ownerName: json['ownerName'] ?? 'Unknown',
      tasks: (json['tasks'] as List<dynamic>? ?? []).map((task) => Task.fromJson(task as Map<String, dynamic>)).toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'progress': progress,
      'ownerName': ownerName,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
