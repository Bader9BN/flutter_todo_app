
import 'package:flutter/material.dart';

enum Priority { low, medium, high }

class Task {
  String id;
  String title;
  bool isDone;
  DateTime dueDate;
  Priority priority;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.dueDate,
    this.priority = Priority.medium,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isDone': isDone,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority.index,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    isDone: json['isDone'],
    dueDate: DateTime.parse(json['dueDate']),
    priority: Priority.values[json['priority']],
  );

  Color get priorityColor {
    switch (priority) {
      case Priority.high: return Colors.red;
      case Priority.medium: return Colors.orange;
      case Priority.low: return Colors.green;
    }
  }
}