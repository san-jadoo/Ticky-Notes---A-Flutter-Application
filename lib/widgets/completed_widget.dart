import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tickynotes1/models/tickynotes_model.dart';
import 'package:tickynotes1/services/database_services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CompletedWidget extends StatefulWidget {
  const CompletedWidget({super.key});

  @override
  State<CompletedWidget> createState() => _CompletedWidgetState();
}

class _CompletedWidgetState extends State<CompletedWidget> {
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
      stream: _databaseServices.completeTodos, // Stream from Firestore
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
                  children: [],
                ),
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
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
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough),
                  ),
                  subtitle: Text(
                    todo.desc,
                    style: TextStyle(decoration: TextDecoration.lineThrough),
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
}
