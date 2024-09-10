import 'package:flutter/material.dart';

class Stage {
  final int id;
  final String name;
  bool isCompleted;

  Stage({
    required this.id,
    required this.name,
    this.isCompleted = false,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'],
      name: json['name'],
      isCompleted: json['is_completed'],
    );
  }
}