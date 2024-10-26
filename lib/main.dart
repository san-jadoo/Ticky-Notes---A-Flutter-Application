import 'package:flutter/material.dart';
import 'package:tickynotes1/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tickynotes1/screens/login_screen.dart';
import 'package:tickynotes1/screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text(
                'Ticky Notes App',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
            bottom: TabBar(
              tabs: [
                Tab(text: 'SignUp'),
                Tab(
                  text: 'Login',
                )
              ],
              labelColor: Colors.white,
            ),
          ),
          body: TabBarView(
            children: [
              SignUpScreen(),
              LoginScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
