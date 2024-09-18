import 'package:MagiclineERP/UretimTakip/modals/stages.dart';
import 'package:flutter/material.dart';

class Location {
  final int id;
  final String name;
  List<Stage> stages;

  Location({
    required this.id,
    required this.name,
    required this.stages,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      stages: (json['stages'] as List<dynamic>).map((stage) => Stage.fromJson(stage)).toList(),
    );
  }
}
