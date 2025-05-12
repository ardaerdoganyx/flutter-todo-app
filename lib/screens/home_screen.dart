import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ToDo> _todoList = [];
  final List<String> _categories = ['Genel', 'İş', 'Okul', 'Kişisel'];
  String _selectedCategory = 'Genel';

  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

  Future<void> _loadToDoList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todo_list');

    if (todosJson != null) {
      final List decoded = jsonDecode(todosJson);
      setState(() {
        _todoList.clear();
        _todoList.addAll(decoded.map((item) => ToDo.fromJson(item)));
      });
    }
  }

  Future<void> _saveToDoList() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(_todoList.map((t) => t.toJson()).toList());
    await prefs.setString('todo_list', encoded);
  }


  void _toggleDone(ToDo todo) {
    setState(() {
      todo.toggleDone();
    });
    _saveToDoList();
  }

  void _removeToDo(ToDo todo) {
    setState(() {
      _todoList.remove(todo);
    });
    _saveToDoList();
  }

  void _editToDoDialog(ToDo todo) {
    final TextEditingController editTitleController =
        TextEditingController(text: todo.title);
    final TextEditingController editDescController =
        TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Görevi Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editTitleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Görev metni',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: editDescController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (opsiyonel)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = editTitleController.text.trim();
                final newDesc = editDescController.text.trim();
                if (newTitle.isNotEmpty) {
                  setState(() {
                    todo.title = newTitle;
                    todo.description = newDesc;
                  });
                  _saveToDoList();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToDoItem(ToDo todo) {
    String formattedDate =
        DateFormat('dd MMMM yyyy • HH:mm', 'tr_TR').format(todo.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: todo.isDone,
              onChanged: (_) => _toggleDone(todo),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => _editToDoDialog(todo),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration:
                            todo.isDone ? TextDecoration.lineThrough : null,
                        color: todo.isDone ? Colors.grey : Colors.black,
                      ),
                    ),
                    if (todo.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          todo.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            todo.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue[100],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeToDo(todo),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ToDo> pending =
        _todoList.where((todo) => !todo.isDone).toList();
    final List<ToDo> completed =
        _todoList.where((todo) => todo.isDone).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Açık gri ton
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _todoList.isEmpty
                ? const Center(child: Text('Henüz görev eklenmedi.'))
                : ListView(
                    children: [
                      if (pending.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6),
                          child: Text(
                            'Yapılacaklar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...pending.map(_buildToDoItem),
                      ],
                      if (completed.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6),
                          child: Text(
                            'Tamamlananlar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ...completed.map(_buildToDoItem),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String category = _selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Görev'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Başlık'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Kategori: "),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: category,
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            category = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isEmpty) return;
                setState(() {
                  _todoList.add(ToDo(
                    id: DateTime.now().toString(),
                    title: title,
                    description: desc,
                    category: category,
                  ));
                });
                _saveToDoList();
                Navigator.of(context).pop();
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }
}