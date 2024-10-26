import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tickynotes1/screens/login_screen.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  bool isVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  Future<void> _register() async {
    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _showSnackbar(
            'Empty Fields', 'Please fill in all fields', ContentType.warning);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _showSnackbar('Success', 'Successfully registered', ContentType.success);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      ContentType contentType;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          contentType = ContentType.warning;
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          contentType = ContentType.failure;
          break;
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          contentType = ContentType.warning;
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          contentType = ContentType.failure;
          break;
        default:
          errorMessage = 'Registration Failed: ${e.message}';
          contentType = ContentType.failure;
      }

      _showSnackbar('Registration Failed', errorMessage, contentType);
    } catch (e) {
      _showSnackbar('Error', 'An unexpected error occurred. Please try again.',
          ContentType.failure);
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                        icon: Icon(isVisible
                            ? Icons.visibility
                            : Icons.visibility_off))),
                obscureText: !isVisible,
              ),
              SizedBox(
                height: 10,
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        _register();
                      },
                      child: Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          foregroundColor: Colors.white),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String title, String message, ContentType contentType) {
    final snackBar = SnackBar(
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
