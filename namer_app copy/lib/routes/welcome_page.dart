import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
        title: Text('Welcome to CoBuilder'), // name of the page
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // center the buttons
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // go to login page
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20.0), // add space btwn
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup'); // go to signup page
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}