import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 111, 15, 128),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png', // path for the logo
                width: 200, // width
                height: 200, // height
              ),
              SizedBox(height: 20.0),
              Text(
                'CoBuildr',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40.0),
              SizedBox(
                width: 200.0, // the button should be proper
                height: 50.0, 
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login'); // show the login
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 111, 15, 128),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: 200.0, // set the button
                height: 50.0, // set the button
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup'); // signup
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 111, 15, 128),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
