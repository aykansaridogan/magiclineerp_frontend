class Task {
  final String name;

  Task({required this.name});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'] ?? 'Unnamed Task',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
