import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TodoController extends GetxController {
  var todos = <Todo>[].obs;

  TodoController() {
    loadTodos();
  }

  void addTodo(String title, TimeOfDay? time) {
    todos.add(Todo(
      title: title,
      taskTime: time,
    ));
    saveTodos(); 
  }

  void toggleTodoStatus(int index) {
    todos[index].isCompleted = !todos[index].isCompleted;
    todos.refresh(); 
    saveTodos();
  }

  void deleteTodo(int index) {
    todos.removeAt(index);
    saveTodos(); 
  }

  void saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList('todos', jsonList);
  }

  void loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('todos');

    if (jsonList != null && jsonList.isNotEmpty) {
      todos.value = jsonList.map((json) => Todo.fromJson(jsonDecode(json))).toList();
    } else {
      addDefaultTasks(); 
    }
  }

  void addDefaultTasks() {
    todos.addAll([
      Todo(title: 'Brush', isCompleted: false, taskTime: const TimeOfDay(hour: 5, minute: 0)),
      Todo(title: 'Workout', isCompleted: false, taskTime: const TimeOfDay(hour: 5, minute: 10)),
      Todo(title: 'Read a book', isCompleted: false, taskTime: const TimeOfDay(hour: 7, minute: 0)),
      Todo(title: 'Bath', isCompleted: false, taskTime: const TimeOfDay(hour: 7, minute: 10)),
      Todo(title: 'Breakfast', isCompleted: false, taskTime: const TimeOfDay(hour: 8, minute: 0)),
    ]);
    saveTodos();
  }
}

class Todo {
  String title;
  bool isCompleted;
  TimeOfDay? taskTime;

  Todo({
    required this.title,
    this.isCompleted = false,
    this.taskTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'taskTime': taskTime != null ? '${taskTime!.hour}:${taskTime!.minute}' : null,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      isCompleted: json['isCompleted'],
      taskTime: json['taskTime'] != null 
          ? TimeOfDay(
              hour: int.parse(json['taskTime'].split(':')[0]), 
              minute: int.parse(json['taskTime'].split(':')[1]),
            ) 
          : null,
    );
  }
}
