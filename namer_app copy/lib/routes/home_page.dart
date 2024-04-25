import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    _user = _auth.currentUser!;
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(_user.uid).get();
    setState(() {
      _userType = docSnapshot.get('userType') as String? ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User Type: $_userType'),
            SizedBox(height: 10),
            Text('Email: ${_user.email ?? 'Unknown'}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the chat page
          Navigator.pushNamed(context, '/editProfile');
        },
        child: Icon(Icons.chat),
      ),
      
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}