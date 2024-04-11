import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedUserType;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email (edu)'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedUserType,
              hint: Text('Select User Type'),
              onChanged: (value) {
                setState(() {
                  _selectedUserType = value;
                });
              },
              items: ['Student', 'Advisor'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _signUp();
              },
              child: Text('Create Account'),
            ),
            SizedBox(height: 10),
            Text(_message),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                'Already have an account? Login',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    try {
      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty ||
          _confirmPasswordController.text.trim().isEmpty ||
          _selectedUserType == null) {
        setState(() {
          _message = 'Please fill all fields';
        });
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _message = 'Passwords do not match';
        });
        return;
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      setState(() {
        _message = 'Account created successfully';
        print('Message updated: $_message');
      });

      // Store additional user information in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'userType': _selectedUserType,
      });

      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _message = 'The password provided is too weak';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _message = 'The account already exists for that email';
        });
      } else {
        setState(() {
          _message = 'Error: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }
}