import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tickynotes1/models/tickynotes_model.dart';
import 'package:tickynotes1/services/database_services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PendingWidget extends StatefulWidget {
  const PendingWidget({super.key});

  @override
  State<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends State<PendingWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;
  final DatabaseServices _databaseServices = DatabaseServices();

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Tickynotes>>(
      stream: _databaseServices.todos, // Stream from Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No tasks available.'));
        }

        List<Tickynotes> todos = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: todos.length,
          itemBuilder: (context, index) {
            Tickynotes todo = todos[index];
            return Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Slidable(
                key: ValueKey(todo.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.done,
                      label: "Mark as Complete",
                      onPressed: (context) {
                        _databaseServices.updateTodoStatus(todo.id, true);
                      },
                    )
                  ],
                ),
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: "Edit",
                      onPressed: (context) {
                        _showTaskDialog(context, todo: todo);
                      },
                    ),
                    SlidableAction(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: "Remove",
                      onPressed: (context) async {
                        await _databaseServices.deleteTask(todo.id);
                      },
                    )
                  ],
                ),
                child: ListTile(
                  title: Text(
                    todo.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    todo.desc,
                  ),
                  trailing: Text(
                    '${todo.timeStamp.toDate().day}/${todo.timeStamp.toDate().month}/${todo.timeStamp.toDate().year}',
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTaskDialog(BuildContext context, {Tickynotes? todo}) {
    final TextEditingController _titleController =
        TextEditingController(text: todo?.title);
    final TextEditingController _descController =
        TextEditingController(text: todo?.desc);
    final DatabaseServices _databaseService = DatabaseServices();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(todo == null ? 'Add Task' : 'Edit Task'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (todo == null) {
                  await _databaseService.addTodoItem(
                      _titleController.text, _descController.text);
                } else {
                  await _databaseService.updateTodo(
                      todo.id, _titleController.text, _descController.text);
                }
                Navigator.pop(context);
              },
              child: Text(todo == null ? "Add" : "Edit"),
            ),
          ],
        );
      },
    );
  }
}
