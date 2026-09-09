import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isDarkMode = false;

  List<Task> get tasks => _tasks;
  bool get isDarkMode => _isDarkMode;

  TaskProvider() {
    _loadData();
  }

  void addTask(String title, DateTime dueDate, Priority priority) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      dueDate: dueDate,
      priority: priority,
    );
    _tasks.add(newTask);
    _saveData();
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].isDone = !_tasks[taskIndex].isDone;
      _saveData();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((t) => json.encode(t.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    _tasks = tasksJson.map((t) => Task.fromJson(json.decode(t))).toList();
    notifyListeners();
  }
}