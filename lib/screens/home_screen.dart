import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tickynotes1/models/tickynotes_model.dart';
import 'package:tickynotes1/screens/login_screen.dart';
import 'package:tickynotes1/services/database_services.dart';
import 'package:tickynotes1/widgets/completed_widget.dart';
import 'package:tickynotes1/widgets/pending_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _buttonIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Widget> _widgets = [
    PendingWidget(),
    CompletedWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        title: Center(
          child: Text("Ticky Notes"),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding to the scroll view
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _buttonIndex = 0;
                      });
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 2.4,
                      decoration: BoxDecoration(
                        color: _buttonIndex == 0 ? Colors.teal.shade600 : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Pending",
                          style: TextStyle(
                            fontSize: _buttonIndex == 0 ? 16 : 14,
                            color:
                                _buttonIndex == 0 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _buttonIndex = 1;
                      });
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 2.4,
                      decoration: BoxDecoration(
                        color: _buttonIndex == 1 ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Completed",
                          style: TextStyle(
                            fontSize: _buttonIndex == 1 ? 16 : 14,
                            color:
                                _buttonIndex == 1 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              _widgets[_buttonIndex],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade600,
        onPressed: () {
          _showTaskDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void _showTaskDialog(BuildContext context, {Tickynotes? tn}) {
    final TextEditingController _titleController =
        TextEditingController(text: tn?.title);
    final TextEditingController _descController =
        TextEditingController(text: tn?.desc);
    final DatabaseServices _databaseService = DatabaseServices();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(tn == null ? 'Add Notes' : 'Notes Task'),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
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
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (tn == null) {
                  await _databaseService.addTodoItem(
                    _titleController.text,
                    _descController.text,
                  );
                } else {
                  await _databaseService.updateTodo(
                    tn.id,
                    _titleController.text,
                    _descController.text,
                  );
                }
                Navigator.pop(context);
              },
              child: Text(tn == null ? "Add" : "Edit"),
            ),
          ],
        );
      },
    );
  }
}
