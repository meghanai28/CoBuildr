import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/models/user.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // instance
  final TextEditingController _emailController = TextEditingController(); // email placed here
  final TextEditingController _passwordController = TextEditingController(); // text placed here
  final TextEditingController _confirmPasswordController = TextEditingController(); // password placed here
  String? _selectedUserType; // what user selects
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // add padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email (edu)'), // edu emails
            ),
            SizedBox(height: 10), // spacing

            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'), // password
              obscureText: true,
            ),
            SizedBox(height: 10),

            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'), // double check
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
                ); // drop down for user to select if they are student or advisor
              }).toList(),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _signUp();
              },
              child: Text('Create Account'), // sign up
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
                style: TextStyle(color: const Color.fromARGB(255, 114, 33, 243)),
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
      } // if user doesnt fill everything

      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _message = 'Passwords do not match';
        });
        return;
      } // mistype

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password
      ); //create user credential

      //await userCredential.user!.sendEmailVerification();

      setState(() {
        _message = 'Account created successfully.';
      });

      UserProfile newUser = UserProfile (
        uid: userCredential.user!.uid,
        email: email,
        userType: _selectedUserType,
        seenProjects : [],
      );

      // save this information into the user database
      await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toMap());

      // Redirect based on user type
      if (_selectedUserType == 'Student') {
        Navigator.pushReplacementNamed(context, '/editProfile');
      } else if (_selectedUserType == 'Advisor') {
        Navigator.pushReplacementNamed(context, '/advisor/advisor_setting');
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _message = 'The password provided is weak';
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
