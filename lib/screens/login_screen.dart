import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tickynotes1/screens/home_screen.dart';
import 'package:tickynotes1/screens/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class LoginScreen extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isVisible = false;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      setState(() {
        _isLoading = true; // Show the loading indicator
      });
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _showSnackbar(
            'Empty Fields', 'Please fill in all fields', ContentType.warning);
        return;
      }
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showSnackbar('Login Successful', 'You have Successfully Logged In',
          ContentType.success);

      // Navigate to the HomeScreen only after successful login
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      ContentType contentType;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          contentType = ContentType.failure;
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          contentType = ContentType.failure;
          break;
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          contentType = ContentType.warning;
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password provided.';
          contentType = ContentType.failure;
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection.';
          contentType = ContentType.failure;
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Try again later.';
          contentType = ContentType.failure;
          break;
        default:
          errorMessage = 'Login Failed: ${e.message}';
          contentType = ContentType.failure;
      }
      _showSnackbar('Login Failed', errorMessage, contentType);
    } catch (e) {
      _showSnackbar(
          'Error', 'An Unexpected Error Occurred', ContentType.failure);
    } finally {
      setState(() {
        _isLoading = false; // Hide the loading indicator
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
                        _isVisible = !_isVisible;
                      });
                    },
                    icon: Icon(
                        _isVisible ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                obscureText: !_isVisible,
              ),
              SizedBox(
                height: 10,
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
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
