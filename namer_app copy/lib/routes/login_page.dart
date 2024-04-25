import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // instance of firbase authentication -> firbase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // instance of firestore
  final TextEditingController _emailController = TextEditingController(); // where they can enter their email
  final TextEditingController _passwordController = TextEditingController(); // enter their password
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold( // basic visual layout
      
      appBar: AppBar( // appBar is how we give the basic title property
        title: Text('Login'),
      ),
      
      body: Padding( // styling for body elements
        padding: EdgeInsets.all(16.0), // padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: 
          [

            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),


            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                _login();
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            
            Text(_message),
            SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text(
                "Don't have an account? Create one",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        setState(() {
          _message = 'Please fill all fields';
        });
        return;
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      final userData = await _firestore.collection('users').doc(userId).get();

      // Navigate to home page
      Navigator.pushReplacementNamed(context, '/dashboard');

    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }
}