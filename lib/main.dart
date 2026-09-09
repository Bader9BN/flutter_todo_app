import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'models/task.dart';
import 'providers/task_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do Pro',
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مهامي الاحترافية'),
        actions: [
          IconButton(
            icon: Icon(taskProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => taskProvider.toggleTheme(),
          ),
        ],
      ),
      body: taskProvider.tasks.isEmpty
          ? const Center(child: Text('لا توجد مهام حُفظت بعد!'))
          : ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (ctx, index) {
                final task = taskProvider.tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => taskProvider.toggleTaskStatus(task.id),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: task.priorityColor),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('yyyy/MM/dd - hh:mm a').format(task.dueDate),
                          style: TextStyle(color: task.priorityColor, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => taskProvider.deleteTask(task.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    Priority selectedPriority = Priority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16, left: 16, right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المهمة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('الوقت: ${DateFormat('MM/dd HH:mm').format(selectedDate)}'),
                  const Spacer(),
                  TextButton(
                    child: const Text('تغيير'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setModalState(() {
                            selectedDate = DateTime(
                              date.year, date.month, date.day, time.hour, time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('الأولوية: '),
                  DropdownButton<Priority>(
                    value: selectedPriority,
                    items: Priority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(
                          p.name.toUpperCase(),
                          style: TextStyle(
                            color: p == Priority.high
                                ? Colors.red
                                : p == Priority.medium
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedPriority = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    Provider.of<TaskProvider>(context, listen: false).addTask(
                      titleController.text,
                      selectedDate,
                      selectedPriority,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('إضافة المهمة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


